import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart"; //env var
import "package:google_generative_ai/google_generative_ai.dart";
import "dart:async";
import "dart:convert";
import "dart:io";

//Import alert dialogs
import "package:simple_chat/utils/alert_dialog_list.dart";

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//API key retrieval--------------------------------------------------
//To retrieve the apikey from .env file
String obtain_API_key() {
  String? AI_API_key = dotenv.env['ai_api_key'];
  if (AI_API_key == null) {
    throw Exception('API key not found');
  }

  print("---API key succesfully found---");
  //Return the API key
  return AI_API_key;
}

//Data validation----------------------------------------------------
//To ensure user input is not an attack
bool validate_user_input(BuildContext context, String user_input) {
  print("[------validateuserinput function executed------]");

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
    print("Invalid user input");
    return false;
  }

  // Additional Checks for potential attack patterns (e.g., SQL Injection, XSS, etc.)
  if (_containsSuspiciousPatterns(user_input)) {
    // If suspicious patterns are found, show warning and return false
    show_possible_attack_dialog(context);
    print("Possible attack detected");
    return false;
  }

  print("Valid user input");
  return true;
}

//Function to check for suspicious patterns like SQL injection, XSS, etc.
bool _containsSuspiciousPatterns(String input) {
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
  return true;  // Found suspicious pattern
  }
  }

  return false;  // No suspicious pattern found
}

//
//
Future<Map<String, dynamic>?> readDataFromJson(String filePath, {bool exitOnError = true}) async {
  try {
    final file = File(filePath);
    final contents = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(contents);
    return jsonData;
  } on FileSystemException {
    print("Error: The file '$filePath' was not found.");
    if (exitOnError) exit(1);
    return null;
  } on FormatException {
    print("Error: The file '$filePath' is not a valid JSON file.");
    if (exitOnError) exit(1);
    return null;
  }
}

//Testing different methods and others------------------------------
//Test AI, don't use for anything else
Future<void> testai() async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: obtain_API_key(),
  );
  final user_prompt = 'Write a story about a magic backpack.';

  final response = await model.generateContent([Content.text(user_prompt)]);
  print("---AI response succesful---");
  print(response.text);
}
