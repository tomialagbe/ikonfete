import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/auth_utils.dart';
import 'package:ikonfetemobile/model/fan.dart';

class SignupState {
  final bool isLoading;
  final String name;
  final String email;
  final String password;
  final AuthResult signupResult;

  SignupState({
    this.isLoading,
    this.name,
    this.email,
    this.password,
    this.signupResult,
  });

  bool get isArtist => signupResult == null ? false : signupResult.isArtist;

  Artist get artist => isArtist ? signupResult.artist : null;

  Fan get fan => (signupResult != null && !signupResult.isArtist)
      ? signupResult.fan
      : null;

  String get uid =>
      artist != null ? artist.uid : (fan != null ? fan.uid : null);

  factory SignupState.initial() {
    return SignupState(
      isLoading: false,
      name: null,
      email: null,
      password: null,
      signupResult: null,
    );
  }

  SignupState copyWith({
    bool isLoading,
    String name,
    String email,
    String password,
    String uid,
    AuthResult signupResult,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      signupResult: signupResult ?? this.signupResult,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is SignupState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      name == other.name &&
      email == other.email &&
      password == other.password &&
      signupResult == other.signupResult;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      signupResult.hashCode;
}
