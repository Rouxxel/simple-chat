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
  final VoidCallback? on_tap;
  final bool read_only;
  final int? max_length;
  final int? max_lines;
  final int? min_lines;
  final double? height;
  final double? width;
  final bool obscure_text;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint_text,
    required this.text_color,
    required this.fill_color,
    required this.hint_color,
    this.enabled = true,
    this.on_tap,
    this.read_only = false,
    this.max_length,
    this.max_lines,
    this.min_lines,
    this.height,
    this.width,
    this.obscure_text = false,
  });

  @override
  Widget build(BuildContext context) {
    final int effective_max_lines = obscure_text ? 1 : (max_lines ?? 1);
    final int effective_min_lines = obscure_text ? 1 : (min_lines ?? 1);
    final bool is_multiline = effective_max_lines > 1 || effective_min_lines > 1;

    final textField = TextField(
      controller: controller,
      enabled: enabled,
      readOnly: read_only,
      onTap: on_tap,
      maxLength: max_length,
      maxLines: effective_max_lines,
      minLines: is_multiline ? effective_min_lines : 1,
      obscureText: obscure_text,
      textAlignVertical: TextAlignVertical.top,
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: text_color,
        ),
      ),
      decoration: InputDecoration(
        hintText: hint_text,
        filled: true,
        fillColor: fill_color,
        alignLabelWithHint: is_multiline,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
      ),
      cursorColor: Colors.black,
    );

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
        if (is_multiline)
          textField
        else
          SizedBox(
            width: width ?? double.infinity,
            height: height ?? 55,
            child: textField,
          ),
      ],
    );
  }
}
