const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

const db = admin.firestore();
const RESET_CODES_COLLECTION = 'resetCodes';
const INVITATIONS_COLLECTION = 'invitations';
const PROJECTS_COLLECTION = 'projects';
const USERS_COLLECTION = 'users';
const NOTIFICATIONS_COLLECTION = 'notifications';
const INVITATION_STATUS_PENDING = 'pending';
const INVITATION_STATUS_ACCEPTED = 'accepted';
const CODE_TTL_MINUTES = 10;
const RESEND_COOLDOWN_SECONDS = 60;
const MAX_ATTEMPTS = 3;

const sendGridKey = functions.config().sendgrid && functions.config().sendgrid.key;
if (sendGridKey) {
  sgMail.setApiKey(sendGridKey);
}

function isValidEmail(email) {
  return typeof email === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function isValidPassword(password) {
  return typeof password === 'string' && password.length >= 8;
}

function normalizeEmail(email) {
  return typeof email === 'string' ? email.trim().toLowerCase() : '';
}

function buildEmailHtml(code) {
  return `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
      <h2 style="color: #2d2a4a;">KOMO Password Reset</h2>
      <p>Use this 6-digit code to reset your password:</p>
      <div style="font-size: 36px; letter-spacing: 6px; font-weight: 700; padding: 16px; text-align: center; background: #f3f1ff; border-radius: 12px;">
        ${code}
      </div>
      <p style="margin-top: 16px; color: #666;">Code expires in 10 minutes.</p>
      <p style="color: #666;">If you did not request this, you can ignore this email.</p>
    </div>
  `;
}

async function reserveShortCode(email, oobCode) {
  const now = admin.firestore.Timestamp.now();
  const expiresAt = admin.firestore.Timestamp.fromMillis(
    Date.now() + CODE_TTL_MINUTES * 60 * 1000,
  );

  for (let i = 0; i < 10; i += 1) {
    const shortCode = String(Math.floor(100000 + Math.random() * 900000));
    const ref = db.collection(RESET_CODES_COLLECTION).doc(shortCode);
    const existing = await ref.get();
    if (existing.exists) {
      continue;
    }

    await ref.set({
      oobCode,
      email,
      createdAt: now,
      expiresAt,
      used: false,
      attempts: 0,
      lastSentAt: now,
    });

    return shortCode;
  }

  throw new functions.https.HttpsError('resource-exhausted', 'Could not generate reset code. Please retry.');
}

exports.sendPasswordResetCode = functions.https.onCall(async (data) => {
  const email = typeof data.email === 'string' ? data.email.trim().toLowerCase() : '';
  if (!isValidEmail(email)) {
    throw new functions.https.HttpsError('invalid-argument', 'Please provide a valid email address.');
  }

  const recentSnap = await db
    .collection(RESET_CODES_COLLECTION)
    .where('email', '==', email)
    .where('used', '==', false)
    .orderBy('createdAt', 'desc')
    .limit(1)
    .get();

  if (!recentSnap.empty) {
    const doc = recentSnap.docs[0];
    const lastSentAt = doc.get('lastSentAt');
    if (lastSentAt && lastSentAt.toMillis) {
      const secondsSince = Math.floor((Date.now() - lastSentAt.toMillis()) / 1000);
      if (secondsSince < RESEND_COOLDOWN_SECONDS) {
        throw new functions.https.HttpsError(
          'resource-exhausted',
          `Please wait ${RESEND_COOLDOWN_SECONDS - secondsSince}s before requesting a new code.`,
        );
      }
    }
  }

  let oobCode = '';
  try {
    const resetLink = await admin.auth().generatePasswordResetLink(email);
    const parsed = new URL(resetLink);
    oobCode = parsed.searchParams.get('oobCode') || '';
  } catch (error) {
    console.error('generatePasswordResetLink failed', error);
    return { success: true };
  }

  if (!oobCode) {
    throw new functions.https.HttpsError('internal', 'Failed to generate reset token.');
  }

  const shortCode = await reserveShortCode(email, oobCode);

  if (!sendGridKey) {
    console.warn('sendgrid.key config is missing; reset code generated but email not sent');
    return { success: true };
  }

  try {
    await sgMail.send({
      to: email,
      from: 'cara.inc.komo@gmail.com',
      subject: 'Your KOMO password reset code',
      html: buildEmailHtml(shortCode),
    });
  } catch (error) {
    console.error('SendGrid send failed', error);
    throw new functions.https.HttpsError('internal', 'Unable to send reset email. Please try again.');
  }

  return { success: true };
});

exports.confirmPasswordResetCode = functions.https.onCall(async (data) => {
  const email = typeof data.email === 'string' ? data.email.trim().toLowerCase() : '';
  const code = typeof data.code === 'string' ? data.code.trim() : '';
  const newPassword = typeof data.newPassword === 'string' ? data.newPassword : '';

  if (!isValidEmail(email)) {
    throw new functions.https.HttpsError('invalid-argument', 'Please provide a valid email address.');
  }
  if (!/^\d{6}$/.test(code)) {
    throw new functions.https.HttpsError('invalid-argument', 'Reset code must be 6 digits.');
  }
  if (!isValidPassword(newPassword)) {
    throw new functions.https.HttpsError('invalid-argument', 'Password must be at least 8 characters.');
  }

  const codeRef = db.collection(RESET_CODES_COLLECTION).doc(code);

  const payload = await db.runTransaction(async (tx) => {
    const doc = await tx.get(codeRef);
    if (!doc.exists) {
      throw new functions.https.HttpsError('not-found', 'Invalid reset code.');
    }

    const row = doc.data();
    const used = row.used === true;
    const attempts = Number(row.attempts || 0);
    const expiresAt = row.expiresAt;
    const codeEmail = typeof row.email === 'string' ? row.email : '';

    if (used) {
      throw new functions.https.HttpsError('failed-precondition', 'This code has already been used.');
    }
    if (!expiresAt || expiresAt.toMillis() < Date.now()) {
      throw new functions.https.HttpsError('deadline-exceeded', 'This reset code has expired.');
    }
    if (attempts >= MAX_ATTEMPTS) {
      throw new functions.https.HttpsError('permission-denied', 'Too many attempts. Request a new code.');
    }
    if (codeEmail !== email) {
      tx.update(codeRef, { attempts: attempts + 1 });
      throw new functions.https.HttpsError('permission-denied', 'Code does not match this email.');
    }

    return { attempts, codeEmail };
  });

  try {
    const user = await admin.auth().getUserByEmail(payload.codeEmail);
    await admin.auth().updateUser(user.uid, { password: newPassword });
    await codeRef.delete();
  } catch (error) {
    console.error('confirmPasswordResetCode failed', error);
    throw new functions.https.HttpsError('internal', 'Failed to reset password. Please try again.');
  }

  return { success: true };
});

exports.cleanupExpiredResetCodes = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const expired = await db
      .collection(RESET_CODES_COLLECTION)
      .where('expiresAt', '<', now)
      .limit(500)
      .get();

    if (expired.empty) {
      return null;
    }

    const batch = db.batch();
    for (const doc of expired.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    return null;
  });

exports.processPendingInvitationsOnUserCreate = functions.auth.user().onCreate(async (user) => {
  const email = normalizeEmail(user.email);
  if (!email) {
    return null;
  }

  const pendingInvites = await db
    .collection(INVITATIONS_COLLECTION)
    .where('invitedEmail', '==', email)
    .where('status', '==', INVITATION_STATUS_PENDING)
    .limit(100)
    .get();

  if (pendingInvites.empty) {
    return null;
  }

  const now = admin.firestore.Timestamp.now();

  for (const inviteDoc of pendingInvites.docs) {
    const invitation = inviteDoc.data();
    const projectId = invitation.projectId;
    if (!projectId) {
      await inviteDoc.ref.update({
        status: 'invalid',
        updatedAt: now,
      });
      continue;
    }

    const projectRef = db.collection(PROJECTS_COLLECTION).doc(projectId);

    try {
      await db.runTransaction(async (tx) => {
        const projectSnap = await tx.get(projectRef);
        if (!projectSnap.exists) {
          tx.update(inviteDoc.ref, {
            status: 'invalid',
            updatedAt: now,
          });
          return;
        }

        tx.update(projectRef, {
          memberIds: admin.firestore.FieldValue.arrayUnion(user.uid),
          updatedAt: now,
        });

        tx.update(inviteDoc.ref, {
          status: INVITATION_STATUS_ACCEPTED,
          invitedUserId: user.uid,
          acceptedAt: now,
          updatedAt: now,
        });
      });
    } catch (error) {
      console.error('Failed to process invitation', inviteDoc.id, error);
    }
  }

  return null;
});

exports.sendPushOnNotificationCreate = functions.firestore
  .document(`${NOTIFICATIONS_COLLECTION}/{notificationId}`)
  .onCreate(async (snap) => {
    const notification = snap.data() || {};
    const userId = notification.userId;

    if (!userId) {
      return null;
    }

    const userSnap = await db.collection(USERS_COLLECTION).doc(userId).get();
    if (!userSnap.exists) {
      return null;
    }

    const userData = userSnap.data() || {};
    const pushEnabled = userData.pushNotificationsEnabled !== false;
    const tokens = Array.isArray(userData.fcmTokens)
      ? userData.fcmTokens.filter((t) => typeof t === 'string' && t.trim())
      : [];

    if (!pushEnabled || tokens.length === 0) {
      return null;
    }

    const title = notification.title || 'KOMO';
    const body = notification.message || 'You have a new update';

    const message = {
      tokens,
      notification: {
        title,
        body,
      },
      data: {
        type: String(notification.type || ''),
        relatedTaskId: String(notification.relatedTaskId || ''),
        relatedProjectId: String(notification.relatedProjectId || ''),
        route: String(notification.relatedTaskId ? '/task-details' : '/dashboard'),
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'komo_notifications',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message);

    const invalidTokens = [];
    response.responses.forEach((r, idx) => {
      if (!r.success && r.error && (
        r.error.code === 'messaging/registration-token-not-registered' ||
        r.error.code === 'messaging/invalid-registration-token'
      )) {
        invalidTokens.push(tokens[idx]);
      }
    });

    if (invalidTokens.length > 0) {
      await db.collection(USERS_COLLECTION).doc(userId).set(
        {
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    return null;
  });
