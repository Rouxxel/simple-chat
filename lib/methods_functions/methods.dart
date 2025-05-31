import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart"; //env var
import "package:google_generative_ai/google_generative_ai.dart";
import "dart:async";
import "dart:convert";
import 'package:logger/logger.dart';

//Import alert dialogs and others
import "package:simple_chat/utils/alert_dialog_list.dart";
import 'package:simple_chat/configurations/config_invoke.dart';
import "package:simple_chat/classes/classes.dart";
import 'package:simple_chat/utils/colorimetry_blueprints.dart';

//Initialize logger
var log_handler= Logger();

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//API key retrieval--------------------------------------------------
//To retrieve the apikey from .env file
String obtain_API_key() {
  log_handler.d("[------obtain_API_key function executing------]");
  String? ai_API_key = dotenv.env['ai_api_key'];
  if (ai_API_key == null) {
    throw Exception('API key not found');
  }

  log_handler.d("---API key successfully found---");
  //Return the API key
  return ai_API_key;
}

//AI session memory
//Re-read the whole conversation so far
String build_conversation_context(List<Message> messages) {
  final buffer = StringBuffer();
  for (var msg in messages) {
    if (msg.user) {
      buffer.writeln("User: ${msg.text}");
    } else {
      buffer.writeln("AI: ${msg.text}");
    }
  }
  return buffer.toString();
}

//Data validation----------------------------------------------------
//To ensure user input is not an attack
bool validate_user_input(BuildContext context, String user_input) {
  log_handler.d("[------validate_user_input function executing------]");

  //Check if input is empty or only whitespace
  if (user_input.trim().isEmpty) {
    throw ArgumentError("Input is empty");
  }

  //Normalize and sanitize user input
  final sanitized_input = _sanitize_input(user_input);
  log_handler.d("Sanitized input: $sanitized_input");

  //Check for suspicious content (excluding math blocks)
  if (_contains_suspicious_patterns(sanitized_input)) {
    show_possible_attack_dialog(context);
    log_handler.w("Possible attack detected in sanitized input");
    return false;
  }

  log_handler.d("Valid user input");
  return true;
}

//Normalize and sanitize input for safe use in HTML or UI
String _sanitize_input(String input) {
  //Remove invisible/control characters
  String cleaned = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

  //Find LaTeX-style math blocks ($...$)
  final latex_regex = RegExp(r'\$(.+?)\$', dotAll: true);
  final buffer = StringBuffer();
  int lastMatchEnd = 0;

  for (final match in latex_regex.allMatches(cleaned)) {
    //Escape text before math
    final beforeMath = cleaned.substring(lastMatchEnd, match.start);
    buffer.write(const HtmlEscape(HtmlEscapeMode.element).convert(beforeMath));

    //Preserve math block as-is
    buffer.write(match.group(0)); // Keep $...$ untouched

    lastMatchEnd = match.end;
  }

  //Escape and append remaining text after last math block
  if (lastMatchEnd < cleaned.length) {
    final remaining = cleaned.substring(lastMatchEnd);
    buffer.write(const HtmlEscape(HtmlEscapeMode.element).convert(remaining));
  }
  return buffer.toString().trim();
}

//Function to check for suspicious patterns like SQL injection, XSS, etc.
bool _contains_suspicious_patterns(String input) {
  log_handler.d("[------_contains_suspicious_patterns function executing------]");

  //Remove LaTeX math blocks ($...$) before checking for dangerous patterns
  final cleaned_input = input.replaceAll(RegExp(r'\$(.+?)\$', dotAll: true), '');

  //Define suspicious patterns
  final suspicious_patterns = [
    r"SELECT\s+.*\s+FROM",                   //SQL SELECT
    r"DROP\s+TABLE",                         //SQL DROP
    r"<script.*?>.*?</script>",             //XSS Script tag
    r"(\b|\s)(union|select|insert|delete|drop|update)(\s|\b)", //SQL keywords
    r"<.*?>",                                //Any HTML tags
  ];

  for (final pattern in suspicious_patterns) {
    final regex = RegExp(pattern, caseSensitive: false, dotAll: true);
    if (regex.hasMatch(cleaned_input)) {
      log_handler.w("Suspicious pattern found: $pattern");
      return true;
    }
  }
  log_handler.d("No suspicious pattern found");
  return false;
}

//Testing different methods and others------------------------------
//Test AI, don't use for anything else
Future<void> test_ai() async {
  log_handler.d("[------test_ai function executing------]");
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: obtain_API_key(),
  );
  final user_prompt = 'Write a story about a magic backpack.';

  final response = await model.generateContent([Content.text(user_prompt)]);
  log_handler.d("---AI response succesful---");
  log_handler.d(response.text);
}

//Configuration and settings methods--------------------------------------------------
//Update main directory of the AI
Future<void> update_directive(BuildContext context, String? new_directive, {int min_length = 20}) async {
  if (new_directive == null || new_directive.trim().isEmpty || new_directive.trim().length < min_length) {
    log_handler.w("Attempted to update directive with null, empty, or too short string. Update skipped.");
    return;
  }

  //Validate user input, if false, don't proceed
  try {
    final is_valid = validate_user_input(context, new_directive);
    if (!is_valid) {
      log_handler.w("Directive failed validation. Update skipped.");
      return;
    }
  } on ArgumentError catch (e) {
    log_handler.w("Directive validation threw ArgumentError: ${e.message}. Update skipped.");
    return;
  }

  final file = await get_local_config_file();

  raw_config_json['ai']['directive'] = new_directive.trim();
  await file.writeAsString(jsonEncode(raw_config_json));
}

//Update verbose level
Future<void> update_verbose_level(String new_verbose_level) async {
  final file = await get_local_config_file();

  raw_config_json['ai']['verbose_level'] = new_verbose_level;
  await file.writeAsString(jsonEncode(raw_config_json));
}

//Update color values
Future<void> update_color_value(String section_key, String color_name) async {
  final file = await get_local_config_file();

  //Force string to be lowercase and delete whitespaces
  final normalized_color_name = color_name
      .toLowerCase()
      .replaceAll(RegExp(r'[\s_\-]+'), '');
  if (!color_name_to_hex_map.containsKey(normalized_color_name)) {
    log_handler.w("Not supported color name provided: '$color_name'. Update skipped.");
    return;
  }

  final hex_color = color_name_to_hex_map[normalized_color_name];

  if (raw_config_json['colors'].containsKey(section_key)) {
    raw_config_json['colors'][section_key] = hex_color;
    await file.writeAsString(jsonEncode(raw_config_json));
    log_handler.d("Color for '$section_key' updated to $hex_color.");
  } else {
    log_handler.w("Section key '$section_key' not found in 'colors'. Update skipped.");
  }
}

//Update user language
Future<void> update_user_language(BuildContext context, String? new_language, {int min_length = 2}) async {
  if (new_language == null || new_language.trim().isEmpty || new_language.trim().length < min_length) {
    log_handler.w("Attempted to update language with null, empty, or too short string. Update skipped.");
    return;
  }

  //Validate user input, if false, don't proceed
  try {
    final is_valid = validate_user_input(context, new_language);
    if (!is_valid) {
      log_handler.w("Language failed validation. Update skipped.");
      return;
    }
  } on ArgumentError catch (e) {
    log_handler.w("Language validation threw ArgumentError: ${e.message}. Update skipped.");
    return;
  }

  final file = await get_local_config_file();

  raw_config_json['user_defaults']['language'] = new_language.trim();
  await file.writeAsString(jsonEncode(raw_config_json));
}
