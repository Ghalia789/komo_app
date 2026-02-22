import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import 'complete_profile_event.dart';
import 'complete_profile_state.dart';

class CompleteProfileBloc extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  CompleteProfileBloc() : super(CompleteProfileState()) {
    on<CompleteProfileNameChanged>(_onNameChanged);
    on<CompleteProfileJobTitleChanged>(_onJobTitleChanged);
    on<CompleteProfileCompanyChanged>(_onCompanyChanged);
    on<CompleteProfileRoleChanged>(_onRoleChanged);
    on<CompleteProfileAvatarChanged>(_onAvatarChanged);
    on<CompleteProfileSubmitted>(_onSubmitted);
  }

  void _onNameChanged(CompleteProfileNameChanged event, Emitter<CompleteProfileState> emit) {
    //final error = Validators.required(event.name, fieldName: 'Full Name');
    emit(state.copyWith(
      name: event.name,
      nameError: null,
    ));
  }

  void _onJobTitleChanged(CompleteProfileJobTitleChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(jobTitle: event.jobTitle));
  }

  void _onCompanyChanged(CompleteProfileCompanyChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(company: event.company));
  }

  void _onRoleChanged(CompleteProfileRoleChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(role: event.role));
  }

  void _onAvatarChanged(CompleteProfileAvatarChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(avatarPath: event.imagePath));
  }

  Future<void> _onSubmitted(CompleteProfileSubmitted event, Emitter<CompleteProfileState> emit) async {
    final nameError = Validators.required(state.name, fieldName: 'Full Name');
    
    if (nameError != null) {
      emit(state.copyWith(nameError: nameError));
      return;
    }

    emit(state.copyWith(isLoading: true));

    // TODO: Save profile to Firebase
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(isLoading: false, isSuccess: true));
  }
}