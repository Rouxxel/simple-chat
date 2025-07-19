import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint_text;
  final Color text_color;
  final Color fill_color;
  final Color hint_color;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  const LabeledTextField({
    Key? key,
    required this.label,
    required this.controller,
    required this.hint_text,
    required this.text_color,
    required this.fill_color,
    required this.hint_color,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: text_color,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: TextField(
            controller: controller,
            enabled: enabled,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            decoration: InputDecoration(
              hintText: hint_text,
              filled: true,
              fillColor: fill_color,
              hintStyle: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: hint_color,
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
            ),
            cursorColor: Colors.black,
          ),
        ),
      ],
    );
  }
}