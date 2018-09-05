import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/routes.dart' as routes;
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  final List<MapEntry<String, String>> sliderEntries = [
    MapEntry<String, String>("assets/images/onboard_background1.png",
        "Connect with your\n true fans or favourite artist."),
    MapEntry<String, String>("assets/images/onboard_background2.png",
        "Understand your fan\n base with analytics."),
    MapEntry<String, String>("assets/images/onboard_background3.png",
        "Leverage your fan base\n and artist loyalty."),
    MapEntry<String, String>("assets/images/onboard_background4.png",
        "Choose what you want\n to stream, anytime."),
  ];

  SwiperController swiperController;
  final int sliderLength = 4;
  int currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();
    swiperController = SwiperController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildSlider(),
            _buildButtons(),
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
            Positioned(
              top: MediaQuery.of(context).viewInsets.top + 60.0,
              right: 40.0,
              child: GestureDetector(
                onTap: () {
                  swiperController.move(sliderLength - 1);
                },
                child: Text(
                  currentSliderIndex == sliderLength - 1 ? "" : "Skip",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            )
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
              onTap: () => Navigator.of(context).pushNamed(routes.artistSignup),
              text: "I'M AN ARTIST",
              defaultColor: colors.primaryButtonColor,
              activeColor: colors.primaryButtonActiveColor,
            ),
            SizedBox(height: 20.0),
            PrimaryButton(
              width: MediaQuery.of(context).size.width - 80,
              height: 50.0,
              onTap: () => Navigator.of(context).pushNamed(routes.fanSignup),
              text: "I'M A FAN",
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
