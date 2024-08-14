import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  // final FormFieldValidator<String>? contactValidator;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obsureText,
    this.keyboardType,
    this.validator,
    // this.contactValidator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obsureText,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'Montserrat',
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
