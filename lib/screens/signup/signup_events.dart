import 'package:meta/meta.dart';

abstract class SignupEvent {}

class NameEntered extends SignupEvent {
  final String name;

  NameEntered(this.name);
}

class EmailEntered extends SignupEvent {
  final String email;

  EmailEntered(this.email);
}

class PasswordEntered extends SignupEvent {
  final String password;

  PasswordEntered(this.password);
}

class EmailSignup extends SignupEvent {
  final bool isArtist;

  EmailSignup({@required this.isArtist});
}

class FacebookSignup extends SignupEvent {
  final bool isArtist;

  FacebookSignup({@required this.isArtist});
}
