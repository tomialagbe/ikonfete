import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/profile.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:ikonfetemobile/utils/upload_helper.dart';
import 'package:meta/meta.dart';

class EditProfileData {
  bool isArtist;
  String uid;
  String displayName;
  String facebookId;
  String twitterId;
  String bio;
  String countryIsoCode;
  File profilePicture;
  String profilePictureUrl;
  String oldProfilePictureUrl;
  bool removeFacebook;
  bool removeTwitter;
}

abstract class ProfileScreenEvent {}

class InitProfile extends ProfileScreenEvent {
  final AppState appState;

  InitProfile(this.appState);
}

class FacebookEnabled extends ProfileScreenEvent {
  final bool enabled;

  FacebookEnabled(this.enabled);
}

class TwitterEnabled extends ProfileScreenEvent {
  final bool enabled;

  TwitterEnabled(this.enabled);
}

class ProfileInfoChange extends ProfileScreenEvent {
  final File profilePicture;
  final String displayName;
  final String countryIsoCode;
  final String country;

  ProfileInfoChange({
    @required this.profilePicture,
    @required this.displayName,
    @required this.countryIsoCode,
    @required this.country,
  });
}

class BioUpdated extends ProfileScreenEvent {
  final String bio;

  BioUpdated(this.bio);
}

class EditProfile extends ProfileScreenEvent {
  final EditProfileData data;

  EditProfile(this.data);
}

class _EditProfile extends ProfileScreenEvent {
  final EditProfileData data;

  _EditProfile(this.data);
}

class ProfileScreenState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final bool editProfileResult;

  final String displayName;
  final String profilePictureUrl;
  final String username;
  final String country;
  final String countryIsoCode;
  final String email;
  final String bio;
  final bool facebookEnabled;
  final bool twitterEnabled;
  final String facebookId;
  final String twitterId;

  final String newDisplayName;
  final File newProfilePicture;
  final String newCountry;
  final String newCountryIsoCode;
  final String newBio;
  final String newFacebookId;
  final String newTwitterId;

  ProfileScreenState({
    @required this.isLoading,
    @required this.hasError,
    @required this.errorMessage,
    @required this.editProfileResult,
    @required this.displayName,
    @required this.profilePictureUrl,
    @required this.username,
    @required this.country,
    @required this.countryIsoCode,
    @required this.email,
    @required this.bio,
    @required this.facebookEnabled,
    @required this.twitterEnabled,
    @required this.facebookId,
    @required this.twitterId,
    @required this.newDisplayName,
    @required this.newProfilePicture,
    @required this.newCountry,
    @required this.newCountryIsoCode,
    @required this.newBio,
    @required this.newFacebookId,
    @required this.newTwitterId,
  });

  factory ProfileScreenState.initial() {
    return ProfileScreenState(
      isLoading: false,
      hasError: false,
      errorMessage: "",
      editProfileResult: false,
      displayName: "",
      profilePictureUrl: "",
      username: "",
      country: "",
      countryIsoCode: "",
      email: "",
      bio: "",
      facebookEnabled: false,
      twitterEnabled: false,
      facebookId: "",
      twitterId: "",
      newDisplayName: "",
      newProfilePicture: null,
      newCountry: "",
      newCountryIsoCode: "",
      newBio: "",
      newFacebookId: "",
      newTwitterId: "",
    );
  }

  ProfileScreenState copyWith({
    bool isLoading,
    String displayName,
    bool editProfileResult,
    String profilePictureUrl,
    String username,
    String country,
    String countryIsoCode,
    String email,
    String bio,
    bool facebookEnabled,
    bool twitterEnabled,
    String facebookId,
    String twitterId,
    bool hasError,
    String errorMessage,
    String newDisplayName,
    File newProfilePicture,
    String newCountry,
    String newCountryIsoCode,
    String newBio,
    String newFacebookId,
    String newTwitterId,
  }) {
    return ProfileScreenState(
      isLoading: isLoading ?? this.isLoading,
      editProfileResult: editProfileResult ?? this.editProfileResult,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      username: username ?? this.username,
      country: country ?? this.country,
      countryIsoCode: countryIsoCode ?? this.countryIsoCode,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      facebookEnabled: facebookEnabled ?? this.facebookEnabled,
      twitterEnabled: twitterEnabled ?? this.twitterEnabled,
      facebookId: facebookId ?? this.facebookId,
      twitterId: twitterId ?? this.twitterId,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      newDisplayName: newDisplayName ?? this.newDisplayName,
      newProfilePicture: newProfilePicture ?? this.newProfilePicture,
      newCountryIsoCode: newCountryIsoCode ?? this.newCountryIsoCode,
      newCountry: newCountry ?? this.newCountry,
      newBio: newBio ?? this.newBio,
      newFacebookId: newFacebookId ?? this.newFacebookId,
      newTwitterId: newTwitterId ?? this.newTwitterId,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is ProfileScreenState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      editProfileResult == other.editProfileResult &&
      hasError == other.hasError &&
      errorMessage == other.errorMessage &&
      displayName == other.displayName &&
      profilePictureUrl == other.profilePictureUrl &&
      username == other.username &&
      country == other.country &&
      countryIsoCode == other.countryIsoCode &&
      email == other.email &&
      bio == other.bio &&
      facebookEnabled == other.facebookEnabled &&
      twitterEnabled == other.twitterEnabled &&
      facebookId == other.facebookId &&
      twitterId == other.twitterId &&
      newDisplayName == other.newDisplayName &&
      newProfilePicture == other.newProfilePicture &&
      newCountry == other.newCountry &&
      newCountryIsoCode == other.newCountryIsoCode &&
      newBio == other.newBio &&
      newFacebookId == other.newFacebookId &&
      newTwitterId == other.newTwitterId;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      hasError.hashCode ^
      errorMessage.hashCode ^
      editProfileResult.hashCode ^
      displayName.hashCode ^
      profilePictureUrl.hashCode ^
      username.hashCode ^
      country.hashCode ^
      countryIsoCode.hashCode ^
      email.hashCode ^
      bio.hashCode ^
      facebookEnabled.hashCode ^
      twitterEnabled.hashCode ^
      facebookId.hashCode ^
      twitterId.hashCode ^
      newDisplayName.hashCode ^
      newProfilePicture.hashCode ^
      newCountry.hashCode ^
      newCountryIsoCode.hashCode ^
      newBio.hashCode ^
      newFacebookId.hashCode ^
      newTwitterId.hashCode;
}

class ProfileScreenBloc extends Bloc<ProfileScreenEvent, ProfileScreenState> {
  final AppConfig appConfig;

  ProfileScreenBloc({@required this.appConfig});

  @override
  ProfileScreenState get initialState => ProfileScreenState.initial();

  @override
  void onTransition(
      Transition<ProfileScreenEvent, ProfileScreenState> transition) {
    super.onTransition(transition);
    final event = transition.event;
    if (event is EditProfile) {
      dispatch(_EditProfile(event.data));
    }
  }

  @override
  Stream<ProfileScreenState> mapEventToState(
      ProfileScreenState state, ProfileScreenEvent event) async* {
    if (event is InitProfile) {
      final isArtist = event.appState.isArtist;
      final artist = isArtist ? event.appState.artistOrFan.first : null;
      final fan = isArtist ? null : event.appState.artistOrFan.second;
      final displayName = isArtist ? artist.name : fan.name;
      final profilePictureUrl =
          isArtist ? artist.profilePictureUrl : fan.profilePictureUrl;
      final username = isArtist ? artist.username : fan.username;
      final country = isArtist ? artist.country : fan.country;
      final countryIsoCode =
          isArtist ? artist.countryIsoCode : fan.countryIsoCode;
      final email = isArtist ? artist.email : fan.email;
      final bio = isArtist ? artist.bio : "";
      final facebookEnabled = isArtist
          ? !StringUtils.isNullOrEmpty(artist.facebookId)
          : !StringUtils.isNullOrEmpty(fan.facebookId);
      final twitterEnabled = isArtist
          ? !StringUtils.isNullOrEmpty(artist.twitterId)
          : !StringUtils.isNullOrEmpty(fan.twitterId);
      final facebookId = isArtist ? artist.facebookId : fan.facebookId;
      final twitterId = isArtist ? artist.twitterId : fan.twitterId;

      yield state.copyWith(
        isLoading: false,
        hasError: false,
        errorMessage: "",
        displayName: displayName,
        profilePictureUrl: profilePictureUrl,
        username: username,
        country: country,
        countryIsoCode: countryIsoCode,
        email: email,
        bio: bio,
        facebookEnabled: facebookEnabled,
        twitterEnabled: twitterEnabled,
        facebookId: facebookId,
        twitterId: twitterId,
        newDisplayName: "",
        newCountry: "",
        newCountryIsoCode: "",
        newBio: "",
        newFacebookId: facebookId,
        newTwitterId: twitterId,
      );
    }

    if (event is EditProfile) {
      yield state.copyWith(isLoading: true, hasError: false, errorMessage: "");
    }

    if (event is _EditProfile) {
      try {
        final success = await _editProfile(event.data);
        yield state.copyWith(
            hasError: false, errorMessage: "", editProfileResult: success);
      } on Exception catch (e) {
        yield state.copyWith(
            isLoading: false, hasError: true, errorMessage: e.toString());
      }
    }

    if (event is ProfileInfoChange) {
      yield state.copyWith(
        hasError: false,
        countryIsoCode: event.countryIsoCode,
        country: event.country,
        newProfilePicture: event.profilePicture,
        newDisplayName: event.displayName,
      );
    }

    if (event is BioUpdated) {
      yield state.copyWith(
          hasError: false, errorMessage: "", newBio: event.bio);
    }

    try {
      if (event is FacebookEnabled) {
        if (event.enabled) {
          // enable facebook
          final result = await _enableFacebook();
          if (result.success) {
            yield state.copyWith(
                hasError: false,
                errorMessage: "",
                facebookEnabled: event.enabled,
                newFacebookId: result.facebookUID);
          } else {
            yield state.copyWith(
              hasError: false,
              errorMessage: "",
              facebookEnabled: false,
              newFacebookId: "",
            );
          }
        } else {
          yield state.copyWith(
            hasError: false,
            errorMessage: "",
            facebookEnabled: false,
            newFacebookId: "",
          );
        }
      }

      if (event is TwitterEnabled) {
        if (event.enabled) {
          final result = await _enableTwitter();
          if (result.success) {
            yield state.copyWith(
                hasError: false,
                errorMessage: "",
                twitterEnabled: event.enabled,
                newTwitterId: result.twitterUID);
          } else {
            yield state.copyWith(
                hasError: false,
                errorMessage: "",
                twitterEnabled: false,
                newTwitterId: "");
          }
        } else {
          yield state.copyWith(
              hasError: false,
              errorMessage: "",
              twitterEnabled: false,
              newTwitterId: "");
        }
      }
    } on Exception catch (e) {
      yield state.copyWith(hasError: true, errorMessage: e.toString());
    }
  }

  Future<FacebookAuthResult> _enableFacebook() async {
    final facebookAuth = FacebookAuth();
    final result = await facebookAuth.facebookAuth();
    return result;
  }

  Future<TwitterAuthResult> _enableTwitter() async {
    final twitterAuth = TwitterAuth(appConfig: appConfig);
    final result = await twitterAuth.twitterAuth();
    return result;
  }

  Future<bool> _editProfile(EditProfileData data) async {
    try {
      if (data.profilePicture != null) {
        // delete the old profilePicture
        final uploadHelper = CloudStorageUploadHelper();
        try {
          if (!StringUtils.isNullOrEmpty(data.oldProfilePictureUrl)) {
            uploadHelper.deleteProfilePicture(
                FirebaseStorage.instance, data.uid);
          }
        } on PlatformException catch (e) {} // if deletion fails, do nothing

        // upload a new profile picture, if one was specified
        final uploadResult = await uploadHelper.uploadProfilePicture(
            FirebaseStorage.instance, data.uid, data.profilePicture);
        data.profilePictureUrl = uploadResult.fileDownloadUrl;
      }

      // make call to update profile api
      final profileApi = ProfileApi(appConfig.serverBaseUrl);
      bool updated = await profileApi.updateProfile(data);
      return updated;
    } on ApiException catch (e) {
      throw e;
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}

/*
import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/profile.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:ikonfetemobile/utils/upload_helper.dart';
import 'package:meta/meta.dart';

class ProfileScreenBloc extends BlocBase {
  final AppConfig appConfig;
  final bool isArtist;

  StreamController<EditProfileData> _editProfileActionController =
      StreamController();
  StreamController<bool> _editProfileResult = StreamController();

  StreamController _facebookAuthActionController = StreamController();
  StreamController _twitterAuthActionController = StreamController();
  StreamController<FacebookAuthResult> _facebookAuthResultController =
      StreamController();
  StreamController<TwitterAuthResult> _twitterAuthResultController =
      StreamController();

  Sink<EditProfileData> get editProfile => _editProfileActionController.sink;

  Stream<bool> get edtProfileResult => _editProfileResult.stream;

  Sink get facebookAuth => _facebookAuthActionController.sink;

  Sink get twitterAuth => _twitterAuthActionController.sink;

  Stream<FacebookAuthResult> get facebookAuthResult =>
      _facebookAuthResultController.stream;

  Stream<TwitterAuthResult> get twitterAuthResult =>
      _twitterAuthResultController.stream;

  ProfileScreenBloc({
    @required this.appConfig,
    @required this.isArtist,
  }) {
    _facebookAuthActionController.stream
        .listen((_) => _handleFacebookAuthAction());
    _twitterAuthActionController.stream
        .listen((_) => _handleTwitterAuthAction());
    _editProfileActionController.stream.listen(_handleEditProfileAction);
  }

  @override
  void dispose() {
    _editProfileActionController.close();
    _facebookAuthActionController.close();
    _twitterAuthActionController.close();
    _facebookAuthResultController.close();
    _twitterAuthResultController.close();
    _editProfileResult.close();
  }

  void _handleFacebookAuthAction() async {
    final facebookAuth = FacebookAuth();
    final result = await facebookAuth.facebookAuth();
    _facebookAuthResultController.add(result);
  }

  void _handleTwitterAuthAction() async {
    final twitterAuth = TwitterAuth(appConfig: appConfig);
    final result = await twitterAuth.twitterAuth();
    _twitterAuthResultController.add(result);
  }

  void _handleEditProfileAction(EditProfileData data) async {
    try {
      if (data.profilePicture != null) {
        // delete the old profilePicture
        final uploadHelper = CloudStorageUploadHelper();
        try {
          if (!StringUtils.isNullOrEmpty(data.oldProfilePictureUrl)) {
            uploadHelper.deleteProfilePicture(
                FirebaseStorage.instance, data.uid);
          }
        } on PlatformException catch (e) {} // if deletion fails, do nothing

        // upload a new profile picture, if one was specified
        final uploadResult = await uploadHelper.uploadProfilePicture(
            FirebaseStorage.instance, data.uid, data.profilePicture);
        data.profilePictureUrl = uploadResult.fileDownloadUrl;
      }

      // make call to update profile api
      final profileApi = ProfileApi(appConfig.serverBaseUrl);
      bool updated = await profileApi.updateProfile(data);
      _editProfileResult.add(updated);
    } on ApiException catch (e) {
      _editProfileResult.addError(e.message);
    } on PlatformException catch (e) {
      _editProfileResult.addError(e.message);
    } on Exception catch (e) {
      _editProfileResult.addError(e.toString());
    }
  }
}
*/
