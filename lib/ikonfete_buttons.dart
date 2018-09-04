import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final double width;
  final double height;
  final Function onTap;
  final String text;
  final Color defaultColor;
  final Color activeColor;
  final Color borderColor;

  PrimaryButton({
    @required this.width,
    @required this.height,
    @required this.text,
    @required this.defaultColor,
    this.activeColor,
    this.borderColor: Colors.transparent,
    this.onTap,
  });

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  Color _buttonColor;

  @override
  void initState() {
    super.initState();
    _buttonColor = widget.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (details) {
        if (widget.activeColor != null) {
          setState(() {
            _buttonColor = widget.activeColor;
          });
        }
      },
      onTapUp: (details) {
        setState(() {
          _buttonColor = widget.defaultColor;
        });
      },
      child: Container(
        width: this.widget.width,
        height: 50.0,
        child: Material(
          type: MaterialType.button,
          color: _buttonColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: widget.borderColor, width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 1.0,
          child: Center(
            child: Text(
              this.widget.text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
