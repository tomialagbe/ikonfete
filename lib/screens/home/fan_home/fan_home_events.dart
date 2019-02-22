import 'package:meta/meta.dart';

abstract class FanHomeEvent {}

class FanHomeLoadArtistEvent extends FanHomeEvent {
  final String currentTeamId;

  FanHomeLoadArtistEvent({@required this.currentTeamId});
}

class CheckFacebookAuth extends FanHomeEvent {}

class DoFacebookAuth extends FanHomeEvent {}

class SwitchTab extends FanHomeEvent {
  final int newTab;

  SwitchTab({@required this.newTab});
}
