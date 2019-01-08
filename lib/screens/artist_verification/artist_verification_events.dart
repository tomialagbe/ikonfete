abstract class ArtistVerificationEvent {}

class AddFacebook extends ArtistVerificationEvent {}

class AddTwitter extends ArtistVerificationEvent {}

class AddBio extends ArtistVerificationEvent {
  final String bio;

  AddBio(this.bio);
}

class SubmitVerification extends ArtistVerificationEvent {}
