// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
/*
Remplacer les valeurs par celles de ton google-services.json :
current_key → apiKey
mobilesdk_app_id → appId
project_id → projectId
storage_bucket → storageBucket
project_number → messagingSenderId*/

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyCU1l5P-EDXKQUtf3dJ61PfOgRnm46Hs5o',
    appId: '1:1090561963140:android:7ee1831a3404765c293ed1',
    messagingSenderId: '1090561963140',
    projectId: 'komo-1b403',
    storageBucket: 'komo-1b403.firebasestorage.app',
  );
}