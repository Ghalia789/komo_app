import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/user_repository.dart';

final GetIt locator = GetIt.instance;

void configureDependencies() {
	if (!locator.isRegistered<AuthRepository>()) {
		locator.registerLazySingleton<AuthRepository>(
			() => AuthRepositoryImpl(
				auth: FirebaseAuth.instance,
				firestore: FirebaseFirestore.instance,
			),
		);
	}

	if (!locator.isRegistered<UserRepository>()) {
		locator.registerLazySingleton<UserRepository>(
			() => UserRepositoryImpl(
				firestore: FirebaseFirestore.instance,
				auth: FirebaseAuth.instance,
				storage: FirebaseStorage.instance,
			),
		);
	}
}
