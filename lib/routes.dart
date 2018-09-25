import 'package:fluro/fluro.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/activation_bloc.dart';
import 'package:ikonfetemobile/bloc/artist_verification_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/inactive_user_bloc.dart';
import 'package:ikonfetemobile/bloc/login_bloc.dart';
import 'package:ikonfetemobile/bloc/pending_verification_bloc.dart';
import 'package:ikonfetemobile/bloc/signup_bloc.dart';
import 'package:ikonfetemobile/bloc/user_signup_profile_bloc.dart';
import 'package:ikonfetemobile/screens/activation.dart';
import 'package:ikonfetemobile/screens/artist_home.dart';
import 'package:ikonfetemobile/screens/artist_verification.dart';
import 'package:ikonfetemobile/screens/fan_home.dart';
import 'package:ikonfetemobile/screens/inactive_user.dart';
import 'package:ikonfetemobile/screens/login.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';
import 'package:ikonfetemobile/screens/pending_verification.dart';
import 'package:ikonfetemobile/screens/signup.dart';
import 'package:ikonfetemobile/screens/splash.dart';
import 'package:ikonfetemobile/screens/user_signup_profile.dart';

final router = Router();

final splashHandler = Handler(handlerFunc: (ctx, params) {
  return SplashScreen();
});
final onBoardingHandler = Handler(handlerFunc: (ctx, params) {
  return OnBoardingScreen();
});

Handler signupHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
    return BlocProvider<SignupBloc>(
      child: SignupScreen(
        isArtist: isArtist,
        appConfig: AppConfig.of(ctx),
      ),
      bloc: SignupBloc(AppConfig.of(ctx)),
    );
  });
}

Handler loginHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
    return BlocProvider<LoginBloc>(
      child: LoginScreen(isArtist: isArtist),
      bloc: LoginBloc(isArtist: isArtist),
    );
  });
}

Handler activationHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
    final appConfig = AppConfig.of(ctx);
    final uid = params["uid"][0];

    return BlocProvider<ActivationBloc>(
      bloc: ActivationBloc(appConfig, isArtist: isArtist, uid: uid),
      child: ActivationScreen(isArtist: isArtist, uid: uid),
    );
  });
}

Handler signupProfileHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
    final appConfig = AppConfig.of(ctx);
    final uid = params["uid"][0];

    return BlocProvider<UserSignupProfileBloc>(
      bloc: UserSignupProfileBloc(
        appConfig: appConfig,
        isArtist: isArtist,
        uid: uid,
      ),
      child: UserSignupProfileScreen(
        isArtist: isArtist,
      ),
    );
  });
}

final artistVerificationHandler = Handler(handlerFunc: (ctx, params) {
  final uid = params["uid"][0];
  return BlocProvider<ArtistVerificationBloc>(
    bloc: ArtistVerificationBloc(appConfig: AppConfig.of(ctx)),
    child: ArtistVerificationScreen(uid: uid),
  );
});

final artistPendingVerificationHandler = Handler(handlerFunc: (ctx, params) {
  final uid = params["uid"][0];
  return BlocProvider<ArtistPendingVerificationBloc>(
    bloc: ArtistPendingVerificationBloc(uid: uid),
    child: ArtistPendingVerificationScreen(uid: uid),
  );
});

final artistHomeHandler = Handler(handlerFunc: (ctx, params) {
  return ArtistHomeScreen();
});

final fanHomeHandler = Handler(handlerFunc: (ctx, params) {
  return FanHomeScreen();
});

void defineRoutes(Router router, AppConfig appConfig) {
  router.define(RouteNames.splash, handler: splashHandler);
  router.define(RouteNames.onBoarding, handler: onBoardingHandler);
  router.define(RouteNames.signup(isArtist: true),
      handler: signupHandler(isArtist: true));
  router.define(RouteNames.signup(isArtist: false),
      handler: signupHandler(isArtist: false));
  router.define(RouteNames.artistLogin, handler: loginHandler());
  router.define(RouteNames.fanLogin, handler: loginHandler(isArtist: false));
  router.define(RouteNames.activation(isArtist: true),
      handler: activationHandler(isArtist: true));
  router.define(RouteNames.activation(isArtist: false),
      handler: activationHandler(isArtist: false));
  router.define(RouteNames.signupProfile(isArtist: true),
      handler: signupProfileHandler(isArtist: true));
  router.define(RouteNames.signupProfile(isArtist: false),
      handler: signupProfileHandler(isArtist: false));
  router.define(RouteNames.artistVerification(),
      handler: artistVerificationHandler);
  router.define(RouteNames.artistPendingVerification(),
      handler: artistPendingVerificationHandler);
  router.define(RouteNames.artistHome, handler: artistHomeHandler);
  router.define(RouteNames.fanHome, handler: fanHomeHandler);
  router.define(
    RouteNames.inactiveUser(isArtist: true),
    handler: Handler(handlerFunc: (ctx, params) {
      return BlocProvider<InactiveUserScreenBloc>(
        child: InactiveUserScreen(uid: params["uid"][0], isArtist: true),
        bloc: InactiveUserScreenBloc(
            appConfig: AppConfig.of(ctx), isArtist: true),
      );
    }),
  );
  router.define(
    RouteNames.inactiveUser(isArtist: false),
    handler: Handler(handlerFunc: (ctx, params) {
      return BlocProvider<InactiveUserScreenBloc>(
        child: InactiveUserScreen(uid: params["uid"][0], isArtist: false),
        bloc: InactiveUserScreenBloc(
            appConfig: AppConfig.of(ctx), isArtist: false),
      );
    }),
  );
}

class RouteNames {
  static final splash = "/splash";
  static final onBoarding = "/onboarding";
  static final artistLogin = "/artist_login";
  static final fanLogin = "/fan_login";
  static final artistHome = "/artist_home";
  static final fanHome = "/fan_home";

  static String signup({bool isArtist: true}) {
    final s = isArtist ? "/artist_signup" : "/fan_signup";
    return s;
  }

  static String activation({bool isArtist: true, String uid: ""}) {
    final s = isArtist ? "/artist_activation" : "/fan_activation";
    return "$s/${uid.trim().isEmpty ? ":uid" : uid}";
  }

  static String signupProfile({bool isArtist: true, String uid: ""}) {
    final s = isArtist ? "/artist_signup_profile" : "/fan_signup_profile";
    return "$s/${uid.trim().isEmpty ? ":uid" : uid}";
  }

  static String artistVerification({String uid: ""}) {
    return "/artist_verification/${uid.trim().isEmpty ? ":uid" : uid}";
  }

  static String artistPendingVerification({String uid: ""}) {
    return "/artist_pending_verification/${uid.trim().isEmpty ? ":uid" : uid}";
  }

  static String inactiveUser({String uid: "", bool isArtist: true}) {
    final s = isArtist ? "/inactive_artist" : "/inactive_fan";
    return "$s/${uid.trim().isEmpty ? ":uid" : uid}";
  }
}
