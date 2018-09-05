import 'package:flutter/material.dart';

class LoginFormField extends StatelessWidget {
  final String placeholder;
  final keyboardType;
  final textInputAction;
  final focusNode;
  final Function(String) onFieldSubmitted;
  final IconData suffixIcon;
  final FormFieldValidator<String> validator;

  LoginFormField({
    this.placeholder: "",
    this.keyboardType: TextInputType.text,
    this.textInputAction: TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
        color: Colors.transparent,
        style: BorderStyle.none,
      ),
    );
    final errorInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
        color: Colors.red,
        style: BorderStyle.solid,
      ),
    );

    return TextFormField(
      autofocus: false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Color(0xFF8F8F8F)),
        filled: true,
        fillColor: Color(0xFFEFEFEF),
        border: inputBorder,
        focusedBorder: inputBorder,
        disabledBorder: inputBorder,
        enabledBorder: inputBorder,
        errorBorder: errorInputBorder,
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                size: 20.0,
                color: Color(0xFF8F8F8F),
              )
            : null,
      ),
    );
  }
}

class LoginPasswordField extends StatefulWidget {
  final String placeholder;
  final keyboardType;
  final textInputAction;
  final focusNode;
  final Function(String) onFieldSubmitted;
  final IconData revealIcon;
  final IconData hideIcon;
  final FormFieldValidator<String> validator;

  LoginPasswordField({
    this.placeholder: "",
    this.keyboardType: TextInputType.text,
    this.textInputAction: TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
    this.revealIcon,
    this.hideIcon,
    this.validator,
  })  : assert(!(revealIcon != null && hideIcon == null)),
        assert(!(revealIcon == null && hideIcon != null));

  @override
  _LoginPasswordFieldState createState() {
    return new _LoginPasswordFieldState();
  }
}

class _LoginPasswordFieldState extends State<LoginPasswordField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
        color: Colors.transparent,
        style: BorderStyle.none,
      ),
    );
    final errorInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
        color: Colors.red,
        style: BorderStyle.solid,
      ),
    );

    return TextFormField(
      autofocus: false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      obscureText: obscureText,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: Color(0xFF8F8F8F)),
        filled: true,
        fillColor: Color(0xFFEFEFEF),
        border: inputBorder,
        focusedBorder: inputBorder,
        disabledBorder: inputBorder,
        enabledBorder: inputBorder,
        errorBorder: errorInputBorder,
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        errorMaxLines: 2,
        suffixIcon: widget.revealIcon != null
            ? IconButton(
                iconSize: 20.0,
                icon: Icon(
                  obscureText ? widget.revealIcon : widget.hideIcon,
                  color: Color(0xFF8F8F8F),
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}

class FormFieldValidators {
  static FormFieldValidator<String> notEmpty(String fieldName) {
    return (String val) {
      if (val.trim().isEmpty) {
        return "Your $fieldName is required";
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLength(String fieldName, int minLength) {
    return (String val) {
      if (val.trim().length < minLength) {
        return "Your $fieldName should be at least $minLength characters.";
      }
      return null;
    };
  }

  static FormFieldValidator<String> isValidEmail() {
    return (String email) {
      bool valid = RegExp(
              r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
          .hasMatch(email);
      if (!valid) {
        return "Enter a valid email";
      }
      return null;
    };
  }
}
