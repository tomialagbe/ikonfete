import 'dart:ui' as ui;

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  List<MapEntry<String, String>> sliderEntries;

  SwiperController swiperController;
  final int sliderLength = 4;
  int currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();
    swiperController = SwiperController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sliderEntries = [
      MapEntry<String, String>("assets/images/onboard_background1.png",
          AppLocalizations.of(context).onboardText1),
      MapEntry<String, String>("assets/images/onboard_background2.png",
          AppLocalizations.of(context).onboardText2),
      MapEntry<String, String>("assets/images/onboard_background3.png",
          AppLocalizations.of(context).onboardText3),
      MapEntry<String, String>("assets/images/onboard_background4.png",
          AppLocalizations.of(context).onboardText4),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildSlider(),
            _buildButtons(),
            Positioned(
              top: MediaQuery.of(context).viewInsets.top + 60.0,
              right: 40.0,
              child: GestureDetector(
                onTap: () {
                  swiperController.move(sliderLength - 1);
                },
                child: Text(
                  currentSliderIndex == sliderLength - 1
                      ? ""
                      : AppLocalizations.of(context).skip, //"Skip",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Swiper(
      itemCount: sliderLength,
      scrollDirection: Axis.horizontal,
      curve: Curves.easeIn,
      controller: swiperController,
      onIndexChanged: (newIndex) {
        setState(() {
          currentSliderIndex = newIndex;
        });
      },
      itemBuilder: (context, index) {
        final entry = sliderEntries[index];
        String imageAsset = entry.key;
        String text = entry.value;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      pagination: SwiperPagination(
        alignment: Alignment(0.0, 0.2),
        builder: DotSwiperPaginationBuilder(
          color: Colors.white70.withOpacity(0.5),
          activeColor: Color(0xFFEE1C24),
          space: 5.0,
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(),
        ),
        Column(
          children: <Widget>[
            PrimaryButton(
              width: MediaQuery.of(context).size.width - 80,
              height: 50.0,
              onTap: () => router.navigateTo(
                  context, RouteNames.signup(isArtist: true),
                  replace: false, transition: TransitionType.inFromRight),
              text: AppLocalizations.of(context).artistSignupButtonText,
              // I'M AN ARTIST
              defaultColor: colors.primaryButtonColor,
              activeColor: colors.primaryButtonActiveColor,
            ),
            SizedBox(height: 20.0),
            PrimaryButton(
              width: MediaQuery.of(context).size.width - 80,
              height: 50.0,
              onTap: () => router.navigateTo(
                  context, RouteNames.signup(isArtist: false),
                  replace: false, transition: TransitionType.inFromRight),
              text: AppLocalizations.of(context).fanSignupButtonText,
              //"I'M A FAN",
              defaultColor: Colors.transparent,
              activeColor: Colors.white.withOpacity(0.2),
              borderColor: Colors.white,
            )
          ],
        ),
        SizedBox(height: 40.0),
      ],
    );
  }
}
