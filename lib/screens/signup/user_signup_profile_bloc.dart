import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/types.dart';
import 'package:ikonfetemobile/utils/upload_helper.dart';
import 'package:meta/meta.dart';

abstract class UserSignupProfileEvent {}

class SignupProfileEntered extends UserSignupProfileEvent {
  final bool isArtist;
  final String uid;
  final String username;
  final File profilePicture;
  final String countryCode;
  final String countryName;

  SignupProfileEntered({
    @required this.isArtist,
    @required this.uid,
    @required this.username,
    @required this.profilePicture,
    @required this.countryCode,
    @required this.countryName,
  });
}

class _SignupProfileEntered extends UserSignupProfileEvent {
  final bool isArtist;
  final String uid;
  final String username;
  final File profilePicture;
  final String countryCode;
  final String countryName;

  _SignupProfileEntered({
    @required this.isArtist,
    @required this.uid,
    @required this.username,
    @required this.profilePicture,
    @required this.countryCode,
    @required this.countryName,
  });
}

class UserSignupProfileState {
  final bool isLoading;
  final String username;
  final File profilePicture;
  final String countryIsoCode;
  final String countryName;
  final Pair<bool, String> userProfileSetupResult;

  UserSignupProfileState({
    this.isLoading,
    this.username,
    this.profilePicture,
    this.countryIsoCode,
    this.countryName,
    this.userProfileSetupResult,
  });

  factory UserSignupProfileState.initial() {
    return UserSignupProfileState(
      isLoading: false,
      username: null,
      profilePicture: null,
      countryIsoCode: null,
      countryName: null,
      userProfileSetupResult: null,
    );
  }

  UserSignupProfileState copyWith({
    bool isLoading,
    String username,
    File profilePicture,
    String countryIsoCode,
    String countryName,
    Pair<bool, String> userProfileSetupResult,
  }) {
    return UserSignupProfileState(
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      countryIsoCode: countryIsoCode ?? this.countryIsoCode,
      countryName: countryName ?? this.countryName,
      userProfileSetupResult:
          userProfileSetupResult ?? this.userProfileSetupResult,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is UserSignupProfileState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      username == other.username &&
      profilePicture == other.profilePicture &&
      countryIsoCode == other.countryIsoCode &&
      countryName == other.countryName &&
      userProfileSetupResult == other.userProfileSetupResult;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      username.hashCode ^
      profilePicture.hashCode ^
      countryIsoCode.hashCode ^
      countryName.hashCode ^
      userProfileSetupResult.hashCode;
}

class UserSignupProfileBloc
    extends Bloc<UserSignupProfileEvent, UserSignupProfileState> {
  final AppConfig appConfig;

  UserSignupProfileBloc({@required this.appConfig});

  @override
  UserSignupProfileState get initialState => UserSignupProfileState.initial();

  @override
  void onTransition(
      Transition<UserSignupProfileEvent, UserSignupProfileState> transition) {
    super.onTransition(transition);
    final event = transition.event;
    if (event is SignupProfileEntered) {
      dispatch(_SignupProfileEntered(
          isArtist: event.isArtist,
          uid: event.uid,
          username: event.username,
          profilePicture: event.profilePicture,
          countryCode: event.countryCode,
          countryName: event.countryName));
    }
  }

  @override
  Stream<UserSignupProfileState> mapEventToState(
      UserSignupProfileState state, UserSignupProfileEvent event) async* {
    if (event is SignupProfileEntered) {
      yield state.copyWith(
          isLoading: true,
          username: event.username,
          profilePicture: event.profilePicture,
          countryIsoCode: event.countryCode,
          countryName: event.countryName);
    }

    if (event is _SignupProfileEntered) {
      final result = await _updateProfile(state, event.uid, event.isArtist);
      yield state.copyWith(isLoading: false, userProfileSetupResult: result);
    }
  }

  Future<Pair<bool, String>> _updateProfile(
      UserSignupProfileState state, String uid, bool isArtist) async {
    if (StringUtils.isNullOrEmpty(state.countryIsoCode)) {
      return Pair.from(false, "Please select a country");
    }

    final firebaseStorage = FirebaseStorage.instance;
    final uploadHelper = CloudStorageUploadHelper();
    String profilePicUrl = "";

    if (state.profilePicture != null) {
      try {
        final uploadResult = await uploadHelper.uploadProfilePicture(
            firebaseStorage, uid, state.profilePicture);
        profilePicUrl = uploadResult.fileDownloadUrl;
      } on PlatformException catch (e) {
        return Pair.from(false, e.message);
      }
    }

    // make api call to update firebase user with username and profile picture url
    final authApi = AuthApiFactory.authApi(appConfig.serverBaseUrl,
        isArtist ? AuthUserType.artist : AuthUserType.fan);
    try {
      final ok = await authApi.setupUserProfile(
        uid,
        state.username,
        state.countryIsoCode,
        profilePicUrl,
        isArtist,
      );
      if (ok) {
        return Pair.from(true, null);
      } else {
        uploadHelper.deleteProfilePicture(firebaseStorage, uid);
        return Pair.from(false, "An unknown error occurred");
      }
    } on ApiException catch (e) {
      uploadHelper.deleteProfilePicture(firebaseStorage, uid);
      return Pair.from(false, e.message);
    } on Exception catch (e) {
      uploadHelper.deleteProfilePicture(firebaseStorage, uid);
      return Pair.from(false, e.toString());
    }
  }
}
