import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/screens/home/artist_home.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home.dart';
import 'package:ikonfetemobile/screens/login/login.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';
import 'package:ikonfetemobile/screens/pending_verification/pending_verification.dart';
import 'package:ikonfetemobile/screens/profile/profile_screen.dart';
import 'package:ikonfetemobile/screens/profile/profile_screen_bloc.dart';
import 'package:ikonfetemobile/screens/signup/signup.dart';
import 'package:ikonfetemobile/screens/splash.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold_screen.dart';

final router = Router();

void defineRoutes(Router router) {
  router.define(
    Routes.login,
    handler: Handler(
      handlerFunc: (ctx, params) {
        return loginScreen(ctx);
      },
    ),
  );

  router.define(
    Routes.signup,
    handler: Handler(
      handlerFunc: (ctx, params) {
        return signupScreen(ctx);
      },
    ),
  );

  router.define(
    Routes.pendingVerification(),
    handler: Handler(
      handlerFunc: (ctx, params) {
        final uid = params["uid"][0];
        return pendingVerificationScreen(ctx, uid);
      },
    ),
  );

  router.define(
    Routes.artistHome,
    handler: Handler(
      handlerFunc: (ctx, params) {
        return artistHomeScreen(ctx);
      },
    ),
  );

  router.define(
    Routes.fanHome,
    handler: Handler(
      handlerFunc: (ctx, params) {
        return fanHomeScreen(ctx);
      },
    ),
  );
}

class Routes {
  static final String login = "/login";
  static final String signup = "/signup";
  static final String artistHome = "/artistHome";
  static final String fanHome = "/fanHome";

  static String pendingVerification({String uid}) {
    return "/pendingVerification/${uid == null ? ":uid" : uid}";
  }
}

final splashHandler = Handler(handlerFunc: (ctx, params) {
  return SplashScreen();
});
final onBoardingHandler = Handler(handlerFunc: (ctx, params) {
  return OnBoardingScreen();
});

Handler signupHandler({bool isArtist: true}) {
//  return Handler(handlerFunc: (ctx, params) {
//    return BlocProvider<SignupBloc>(
//      child: SignupScreen(
//        isArtist: isArtist,
//        appConfig: AppConfig.of(ctx),
//      ),
//      bloc: SignupBloc(AppConfig.of(ctx)),
//    );
//  });
// TODO:
  return null;
}

Handler loginHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
//    return BlocProvider<LoginBloc>(
//      child: LoginScreen(isArtist: isArtist),
//      bloc: LoginBloc(
//        isArtist: isArtist,
//        appConfig: AppConfig.of(ctx),
//      ),
//    );
    return Container();
  });
}

Handler activationHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
    final appConfig = AppConfig.of(ctx);
    final uid = params["uid"][0];

//    return BlocProvider<ActivationBloc>(
//      bloc: ActivationBloc(appConfig, isArtist: isArtist, uid: uid),
//      child: ActivationScreen(isArtist: isArtist, uid: uid),
//    );
    return Container();
  });
}

Handler signupProfileHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
    final appConfig = AppConfig.of(ctx);
    final uid = params["uid"][0];

//    return BlocProvider<UserSignupProfileBloc>(
//      bloc: UserSignupProfileBloc(
//        appConfig: appConfig,
//        isArtist: isArtist,
//        uid: uid,
//      ),
//      child: UserSignupProfileScreen(
//        isArtist: isArtist,
//      ),
//    );
    return Container();
  });
}

final artistVerificationHandler = Handler(handlerFunc: (ctx, params) {
  final uid = params["uid"][0];
//  return BlocProvider<ArtistVerificationBloc>(
//    bloc: ArtistVerificationBloc(appConfig: AppConfig.of(ctx)),
//    child: ArtistVerificationScreen(uid: uid),
//  );
  return Container();
});

final artistPendingVerificationHandler = Handler(handlerFunc: (ctx, params) {
  final uid = params["uid"][0];
//  return BlocProvider<ArtistPendingVerificationBloc>(
//    bloc: ArtistPendingVerificationBloc(
//      uid: uid,
//      appConfig: AppConfig.of(ctx),
//    ),
//    child: ArtistPendingVerificationScreen(uid: uid),
//  );
  return Container();
});

final fanTeamSelectionHandler = Handler(handlerFunc: (ctx, params) {
  final uid = params["uid"][0];
  final name = params["name"][0];
//  return BlocProvider<FanTeamSelectionBloc>(
//    bloc: FanTeamSelectionBloc(appConfig: AppConfig.of(ctx)),
//    child: FanTeamSelectionScreen(uid: uid, name: name),
//  );
  return Container();
});

final artistHomeHandler = Handler(handlerFunc: (ctx, params) {
  return ZoomScaffoldScreen(
    isArtist: true,
    screenId: 'home',
    params: <String, String>{},
  );
});

final fanHomeHandler = Handler(handlerFunc: (ctx, params) {
  return ZoomScaffoldScreen(
    isArtist: false,
    screenId: 'home',
    params: <String, String>{},
  );
});

Handler profileHandler({bool isArtist: true}) {
  return Handler(handlerFunc: (ctx, params) {
    final uid = params["uid"][0];
    return BlocProvider<ProfileScreenBloc>(
      bloc: ProfileScreenBloc(appConfig: AppConfig.of(ctx), isArtist: isArtist),
      child: ProfileScreen(uid: uid, isArtist: isArtist),
    );
  });
}

//final artistProfileHandler = Handler(handlerFunc: (ctx, params) {
//  final uid = params["uid"][0];
//  return BlocProvider<ArtistProfileScreenBloc>(
//    bloc: ArtistProfileScreenBloc(
//      appConfig: AppConfig.of(ctx),
//    ),
//    child: ArtistProfileScreen(uid: uid),
//  );
//});

/*
void defineRoutes(Router router, AppConfig appConfig) {
  
  router.define(RouteNames.splash, handler: splashHandler);

  router.define(RouteNames.onBoarding, handler: onBoardingHandler);

  router.define(RouteNames.signup(isArtist: true),
      handler: signupHandler(isArtist: true));

  router.define(RouteNames.signup(isArtist: false),
      handler: signupHandler(isArtist: false));

  router.define(RouteNames.login(isArtist: true),
      handler: loginHandler(isArtist: true));

  router.define(RouteNames.login(isArtist: false),
      handler: loginHandler(isArtist: false));

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

  router.define(RouteNames.teamSelection(), handler: fanTeamSelectionHandler);

//  router.define(RouteNames.artistProfile(), handler: artistProfileHandler);
  router.define(RouteNames.artistHome, handler: artistHomeHandler);

  router.define(RouteNames.fanHome, handler: fanHomeHandler);

  router.define(RouteNames.profile(isArtist: true),
      handler: profileHandler(isArtist: true));
  router.define(RouteNames.profile(isArtist: false),
      handler: profileHandler(isArtist: false));
      
}
*/

class RouteNames {
  static final splash = "/splash";
  static final onBoarding = "/onboarding";
  static final artistHome = "/artist_home";
  static final fanHome = "/fan_home";

  static String teamSelection({String uid: "", String name: ""}) {
    return "/fan_team_selection/${uid.isEmpty ? ":uid" : uid}/${name.isEmpty ? ":name" : name}";
  }

  static String login({bool isArtist: true}) {
    return isArtist ? "/artist_login" : "/fan_login";
  }

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

  static String artistPendingVerification(
      {String uid: "", String facebookLoginId}) {
    return "/artist_pending_verification/${uid.trim().isEmpty ? ":uid" : uid}";
  }

  static String inactiveUser({String uid: "", bool isArtist: true}) {
    final s = isArtist ? "/inactive_artist" : "/inactive_fan";
    return "$s/${uid.trim().isEmpty ? ":uid" : uid}";
  }

  static String profile({String uid: "", bool isArtist: true}) {
    final s = isArtist ? "/artist_profile" : "/fan_profile";
    return "$s/${uid.trim().isEmpty ? ":uid" : uid}";
  }

//  static String artistProfile({String uid: ""}) {
//    return "/artist_profile/${uid.trim().isEmpty ? ":uid" : uid}";
//  }
}
