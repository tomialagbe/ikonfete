import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/icons.dart';

class InitErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback retryHandler;

  InitErrorScreen({
    @required this.message,
    @required this.retryHandler,
  });

  @override
  Widget build(BuildContext context) {
    final tapHandler = TapGestureRecognizer();
    tapHandler.onTap = retryHandler;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewInsets.top + 40.0,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                FontAwesome5Icons.exclamationTriangle,
                size: 100.0,
              ),
              SizedBox(height: 20.0),
              Text(
                this.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                  text: "Retry",
                  recognizer: tapHandler,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
