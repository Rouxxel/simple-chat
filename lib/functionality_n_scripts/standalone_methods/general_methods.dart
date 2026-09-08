import "package:audioplayers/audioplayers.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "dart:async";
import "dart:convert";
import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

//Import alert dialogs and others
import "package:simple_chat/widgets_and_ui_elements/alert_dialog_builders.dart";
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import "package:simple_chat/functionality_n_scripts/message_related/message_class.dart";
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/colort_list_invoke.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';

//Audio instance
final AudioPlayer _audio_instance = AudioPlayer();

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//AI session memory--------------------------------------------------
//Re-read the whole conversation so far
String build_conversation_context(List<Message> messages) {
  final buffer = StringBuffer();
  for (var msg in messages) {
    if (msg.is_user) {
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
  log_handler?.d("[------validate_user_input function executing------]");

  //Check if input is empty or only whitespace
  if (user_input.trim().isEmpty) {
    build_informative_alert_dialog(
      context,
      "Ok",
      "Empty input",
      "Please, fill all fields before proceeding.",
    );
    throw ArgumentError("Input is empty");
  }

  //Normalize and sanitize user input
  final sanitized_input = _sanitize_input(user_input);
  log_handler?.d("[validate_user_input] Sanitized input: $sanitized_input");

  //Check for suspicious content (excluding math blocks)
  if (_contains_suspicious_patterns(sanitized_input)) {
    build_informative_alert_dialog(
      context,
      "OK",
      "Error 221", //Invalid characters
      "There was an error processing your query, try avoiding special characters",
    );
    log_handler?.w("[validate_user_input] Possible attack detected in sanitized input");
    return false;
  }

  log_handler?.d("[validate_user_input] Valid user input");
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
  log_handler?.d("[------_contains_suspicious_patterns function executing------]");

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
      log_handler?.w("[contains_suspicious_patterns] Suspicious pattern found: $pattern");
      return true;
    }
  }
  log_handler?.d("[contains_suspicious_patterns] No suspicious pattern found");
  return false;
}

//Function to check a valid email
bool is_valid_email(BuildContext context, String email) {
  //Check for exactly one '@'
  if ('@'.allMatches(email).length != 1) {
    log_handler?.w("[is_valid_email] Invalid email '$email': must contain exactly one '@'");
    return false;
  }

  final parts = email.split('@');
  final local_part = parts[0];
  final domain_part = parts[1];

  //Validate local part
  final local_regex = RegExp(r'^[\w\.-]+$');
  if (local_part.isEmpty || !local_regex.hasMatch(local_part)) {
    log_handler?.w("[is_valid_email] Invalid email '$email': local part is invalid");
    return false;
  }

  //Check domain has exactly one '.'
  if ('.'.allMatches(domain_part).length != 1) {
    log_handler?.w("[is_valid_email] Invalid email '$email': domain part must contain exactly one '.'");
    return false;
  }

  final domain_parts = domain_part.split('.');
  final provider = domain_parts[0];
  final tld = domain_parts[1];

  //Check provider and TLD are allowed
  if (!config_data.allowed_email_providers.contains(provider)) {
    log_handler?.w("[is_valid_email] Invalid email '$email': provider '$provider' not allowed");
    return false;
  }
  if (!config_data.allowed_email_tlds.contains(tld)) {
    log_handler?.w("[is_valid_email] Invalid email '$email': TLD '$tld' not allowed");
    return false;
  }

  log_handler?.d("[is_valid_email] Email '$email' is valid, proceeding");
  return true;
}

//Function to check valid password
bool is_valid_password(BuildContext context, String password) {
  //Rule 1: minimum length
  if (password.length < 8) {
    log_handler?.w('[is_valid_password] Password validation failed: fewer than 8 characters');
    return false;
  }

  //Rule 2: at least one lowercase letter
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    log_handler?.w('[is_valid_password] Password validation failed: no lowercase letter found');
    return false;
  }

  //Rule 3: at least one uppercase letter
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    log_handler?.w('[is_valid_password] Password validation failed: no uppercase letter found');
    return false;
  }

  //Rule 4: at least one digit
  if (!RegExp(r'\d').hasMatch(password)) {
    log_handler?.w('[is_valid_password] Password validation failed: no digit found');
    return false;
  }

  // Rule 5: at least one special symbol (anything not letter, digit, or underscore/whitespace)
  if (!RegExp(r'[^\w\s]').hasMatch(password)) {
    log_handler?.w('[is_valid_password] Password validation failed: no special symbol found');
    return false;
  }

  log_handler?.d('[is_valid_password] Password is valid, proceeding');
  return true;
}

//Function to check valid phone number
bool is_valid_phone_number(BuildContext context, String phone_number) {
  log_handler?.d('[is_valid_phone_number] Validating phone number: $phone_number');

  // Clean input: remove spaces, dashes, and parentheses
  String cleaned = phone_number.replaceAll(RegExp(r'[\s\-\(\)]'), '');

  // Rule 1: must be digits only (with optional leading +)
  if (!RegExp(r'^\+?\d+$').hasMatch(cleaned)) {
    log_handler?.w('[is_valid_phone_number] Phone number validation failed: contains invalid characters -> $phone_number');
    return false;
  }

  // Rule 2: length between 7 and 15 digits (standard international range)
  final digitCount = cleaned.startsWith('+') ? cleaned.length - 1 : cleaned.length;
  if (digitCount < 7 || digitCount > 15) {
    log_handler?.w('[is_valid_phone_number] Phone number validation failed: length not in valid range (7–15 digits)');
    return false;
  }

  log_handler?.d('[is_valid_phone_number] Phone number is valid, proceeding');
  return true;
}

String date_formatter(BuildContext context, String date) {
  //Safety check
  if (!date.contains("/") || date.split("/").length != 3) {
    throw const FormatException("Invalid date format. Expected DD/MM/YYYY.");
  }

  //Split into parts
  List<String> date_parts = date.split("/");
  String day = date_parts[0].padLeft(2, '0');    //Ensure 2-digit day
  String month = date_parts[1].padLeft(2, '0');  //Ensure 2-digit month
  String year = date_parts[2];

  //Return in YYYY-MM-DD format
  return "$year-$month-$day";
}

//Audio handling------------------------------
//General play audio
Future<void> play_effect_sound(String asset_path) async {
  try {
    if (config_data.sound_effects_status){
      await _audio_instance.play(AssetSource(asset_path));
      log_handler?.i('[play_effect_sound] Sound $asset_path player');
    } else {
      log_handler?.w('[play_effect_sound] Sound $asset_path nor played, effects disabled');
    }
  } catch (er) {
    log_handler?.e('[play_effect_sound] Error playing sound "$asset_path": $er');
  }
}

//Configuration and settings methods--------------------------------------------------
//Update main directory of the AI
Future<void> update_directive(BuildContext context, String? new_directive, {int min_length = 20}) async {
  if (new_directive == null || new_directive.trim().isEmpty || new_directive.trim().length < min_length) {
    log_handler?.w("[update_directive] Attempted to update directive with null, empty, or too short string. Update skipped.");
    return;
  }

  //Validate user input, if false, don't proceed
  try {
    final is_valid = validate_user_input(context, new_directive);
    if (!is_valid) {
      log_handler?.w("[update_directive] Directive failed validation. Update skipped.");
      return;
    }
  } on ArgumentError catch (e) {
    log_handler?.w("[update_directive] Directive validation threw ArgumentError: ${e.message}. Update skipped.");
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
Future<void> update_color_value(String section_key, String color_input) async {
  final file = await get_local_config_file();

  // Normalize input
  final normalized_input = color_input.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');

  String? hex_color;

  //Case 1: Check if it's a known color name
  if (color_name_to_hex_map.containsKey(normalized_input)) {
    hex_color = color_name_to_hex_map[normalized_input];
    log_handler?.d("[update_color_value] Color name '$color_input' resolved to hex '$hex_color'.");
  }
  //Case 2: Check if it's a valid hex code
  else if (RegExp(r'^#?[A-Fa-f0-9]{6,8}$').hasMatch(color_input)) {
    hex_color = color_input.startsWith('#') ? color_input.toUpperCase() : '#${color_input.toUpperCase()}';
    log_handler?.d("[update_color_value] Using direct hex input: '$hex_color'.");
  } else {
    log_handler?.w("[update_color_value] Invalid color input: '$color_input'. Update skipped.");
    return;
  }

  //Update config if key exists
  if (raw_config_json['colors'].containsKey(section_key)) {
    raw_config_json['colors'][section_key] = hex_color;
    await file.writeAsString(jsonEncode(raw_config_json));
    log_handler?.d("[update_color_value] Color for '$section_key' updated to $hex_color.");
  } else {
    log_handler?.w("[update_color_value] Section key '$section_key' not found in 'colors'. Update skipped.");
  }
}

//Update user language
Future<void> update_user_language(BuildContext context, String? new_language, {int min_length = 2}) async {
  if (new_language == null || new_language.trim().isEmpty || new_language.trim().length < min_length) {
    log_handler?.w("[update_user_language] Attempted to update language with null, empty, or too short string. Update skipped.");
    return;
  }

  //Validate user input, if false, don't proceed
  try {
    final is_valid = validate_user_input(context, new_language);
    if (!is_valid) {
      log_handler?.w("[update_user_language] Language failed validation. Update skipped.");
      return;
    }
  } on ArgumentError catch (e) {
    log_handler?.w("[update_user_language] Language validation threw ArgumentError: ${e.message}. Update skipped.");
    return;
  }

  final file = await get_local_config_file();

  raw_config_json['user_defaults']['language'] = new_language.trim();
  await file.writeAsString(jsonEncode(raw_config_json));
}

//Email sender
Future<void> send_feedback_by_email(BuildContext context, String feedback) async {
  try {
    // Get app document directory
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    // Filter for .log files
    final generated_files = files
        .whereType<File>()
        .where((file) => file.path.endsWith('.log'))
        .toList();

    if (generated_files.isEmpty) {
      await build_informative_alert_dialog(
        context,
        "Ok",
        "Feedback limit reached",
        "Sorry, you can only send your feedback once per session, please restart "
            "the app to send your feedback.",
      );
      log_handler?.w("[send_feedback_by_email] No generated files found.");
      return;
    }

    // Create ZIP archive
    final archive = Archive();
    for (var file in generated_files) {
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last.replaceAll('.log', '.txt');
      archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
    }

    final zipData = ZipEncoder().encode(archive);
    final zipFilePath = '${directory.path}/feedback_logs.zip';
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(zipData);

    // Create email with zip attachment
    final Email email = Email(
      body: feedback,
      subject: 'Simple AI Chat Feedback',
      recipients: [''], //Do not hardcode mails
      attachmentPaths: [zipFilePath],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);

    // Delete generated original log files
    for (var file in generated_files) {
      try {
        await file.delete();
        log_handler?.i('[send_feedback_by_email] Deleted file: ${file.path}');
      } catch (e) {
        log_handler?.e('[send_feedback_by_email] Error deleting file ${file.path}: $e');
      }
    }

    // Delete ZIP file
    try {
      await zipFile.delete();
      log_handler?.i('[send_feedback_by_email] Deleted zip file: $zipFilePath');
    } catch (e) {
      log_handler?.e('[send_feedback_by_email] Error deleting zip file $zipFilePath: $e');
    }

  } catch (e) {
    log_handler?.e('[send_feedback_by_email] Error sending feedback email: $e');
  }
}

//Update sound effect status
Future<void> update_sound_effect_status(bool sound_effect_status) async {
  final file = await get_local_config_file();

  raw_config_json['audio']['sound_effects_status'] = sound_effect_status;
  await file.writeAsString(jsonEncode(raw_config_json));
}

//Update easter egg found
bool? parse_bool_preference(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
    }
  }
  return null;
}

Future<void> update_easter_egg_found(dynamic easter_egg_found) async {
  final parsed = parse_bool_preference(easter_egg_found);
  if (parsed == null) return;

  final file = await get_local_config_file();

  raw_config_json['audio']['easter_egg_found'] = parsed;
  await file.writeAsString(jsonEncode(raw_config_json));
}

//Testing different methods and others------------------------------
//Test AI, don't use for anything else
Future<void> test_ai(String api_key) async {
  log_handler?.d("[------test_ai function executing------]");
  final model = GenerativeModel(
    model: config_data.ai_api_model,
    apiKey: api_key,
  );
  const user_prompt = 'Write a story about a magic backpack.';

  final response = await model.generateContent([Content.text(user_prompt)]);
  log_handler?.d("---AI response succesful---");
  log_handler?.d("[test_ai] ${response.text}");
}
