import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart"; //env var
import "package:google_generative_ai/google_generative_ai.dart";
import "dart:async";
import "dart:convert";
import "dart:io";
import 'package:logger/logger.dart';

//Import alert dialogs
import "package:simple_chat/utils/alert_dialog_list.dart";

//Initialize logger
var log_handler = Logger();

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//API key retrieval--------------------------------------------------
//To retrieve the apikey from .env file
String obtain_API_key() {
  String? ai_API_key = dotenv.env['ai_api_key'];
  if (ai_API_key == null) {
    throw Exception('API key not found');
  }
  log_handler.d("[------obtain_API_key function executing------]");
  log_handler.d("---API key successfully found---");
  //Return the API key
  return ai_API_key;
}

//Data validation----------------------------------------------------
//To ensure user input is not an attack
bool validate_user_input(BuildContext context, String user_input) {
  log_handler.d("[------validate_user_input function executing------]");

  // Check if input is empty
  if (user_input.isEmpty) {
    throw ArgumentError("Input is empty");
  }

  // Limit the valid characters by user (same as your original RegExp)
  final valid_chars = RegExp(r'^[a-zA-Z0-9\s\-\?\.\,\!\:\"]+$');

  // Check if input matches allowed characters
  if (!valid_chars.hasMatch(user_input)) {
    // Handle invalid input (could be potential attack)
    show_possible_attack_dialog(context);
    log_handler.w("Invalid user input");
    return false;
  }

  // Additional Checks for potential attack patterns (e.g., SQL Injection, XSS, etc.)
  if (_contains_suspicious_patterns(user_input)) {
    // If suspicious patterns are found, show warning and return false
    show_possible_attack_dialog(context);
    log_handler.w("Possible attack detected");
    return false;
  }

  log_handler.d("Valid user input");
  return true;
}

//Function to check for suspicious patterns like SQL injection, XSS, etc.
bool _contains_suspicious_patterns(String input) {
  log_handler.d("[------_contains_suspicious_patterns function executing------]");
  // Check for common attack patterns (e.g., SQL Injection, XSS, etc.)
  final suspiciousPatterns = [
  r"SELECT.*FROM",  // SQL SELECT statement pattern
  r"DROP.*TABLE",   // SQL DROP command pattern
  r"<script.*>.*</script>", // Basic XSS attempt
  r"(\b|\s)(union|select|insert|delete|drop|update)(\s|\b)", // SQL keywords
  r"<.*?>",  // Potential XSS tags
  ];

  for (var pattern in suspiciousPatterns) {
  final regex = RegExp(pattern, caseSensitive: false);
  if (regex.hasMatch(input)) {
    log_handler.w("Found suspicious pattern");
    return true;  // Found suspicious pattern
    }
  }
  log_handler.d("No suspicious pattern found");
  return false;  // No suspicious pattern found
}

//Config file management------------------------------------
//To extract data from json file
Map<String, dynamic>? read_data_json(
    String file_path,
    {bool exitOnError = true}) {
  log_handler.d("[------read_data_json function executing------]");
  try {
    final file = File(file_path);
    final contents = file.readAsStringSync();  // Synchronous method
    final Map<String, dynamic> json_data = jsonDecode(contents);
    return json_data;
  } on FileSystemException {
    log_handler.w("Error: The file '$file_path' was not found.");
    if (exitOnError) exit(1);
    return null;
  } on FormatException {
    log_handler.w("Error: The file '$file_path' is not a valid JSON file.");
    if (exitOnError) exit(1);
    return null;
  }
}

//Helper function to convert hex string to Color
Color hex_to_color(String hex) {
  log_handler.d("[------hex_to_color function executing------]");
  return Color(int.parse(hex.replaceFirst('#', '0x')));
}

//Testing different methods and others------------------------------
//Test AI, don't use for anything else
Future<void> test_ai() async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: obtain_API_key(),
  );
  final user_prompt = 'Write a story about a magic backpack.';

  final response = await model.generateContent([Content.text(user_prompt)]);
  log_handler.d("---AI response succesful---");
  log_handler.d(response.text);
}
