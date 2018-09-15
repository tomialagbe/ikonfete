import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginFormField extends StatelessWidget {
  final String placeholder;
  final keyboardType;
  final textInputAction;
  final focusNode;
  final Function(String) onFieldSubmitted;
  final IconData suffixIcon;
  final FormFieldValidator<String> validator;
  final Function(String) onSaved;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;
  final bool enabled;
  final TextEditingController controller;
  final Color fillColor;

  LoginFormField({
    this.placeholder: "",
    this.keyboardType: TextInputType.text,
    this.textInputAction: TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.validator,
    this.onSaved,
    this.textStyle,
    this.textAlign,
    this.maxLines: 1,
    this.inputFormatters: const [],
    this.enabled: true,
    this.controller,
    this.fillColor,
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
      controller: controller,
      autofocus: false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onSaved: onSaved,
      style: textStyle ??
          Theme.of(context).textTheme.body1.copyWith(fontSize: 15.0),
      textAlign: textAlign ?? TextAlign.start,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Color(0xFF8F8F8F)),
        filled: true,
        fillColor: fillColor ?? Color(0xFFEFEFEF),
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
  final Function(String) onSaved;
  final TextStyle textStyle;

  LoginPasswordField({
    this.placeholder: "",
    this.keyboardType: TextInputType.text,
    this.textInputAction: TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
    this.revealIcon,
    this.hideIcon,
    this.validator,
    this.onSaved,
    this.textStyle,
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
      onSaved: widget.onSaved,
      style: widget.textStyle ?? Theme.of(context).textTheme.body1,
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
