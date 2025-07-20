import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:simple_chat/utils/logger_config.dart';

//Extract configuration values
class app_configuration {
  final String main_title;

  final String directive;
  final String default_directive;
  final int response_length_limit;
  final int response_length_tolerance;
  final String ai_api_model;
  final int max_api_response_time_limit;
  final String verbose;
  final String default_verbose;
  final int character_render_speed_ms;

  final String backend_url;
  final String backend_url_generate_ai_response;
  final String backend_url_sign_up;
  final String backend_url_log_in;
  final String backend_url_log_out;
  final String backend_url_refresh_token;
  final String backend_url_reset_password;
  final String backend_url_complete_profile;
  final String backend_url_user_exists;
  final String backend_url_user_prefences;

  final List<dynamic> allowed_email_providers;
  final List<dynamic> allowed_email_tlds;
  final int refresh_token_preemptive;

  final Color background_color;
  final Color default_background_color;
  final Color app_bar_color;
  final Color default_app_bar_color;
  final Color text_color;
  final Color suggest_input_color;
  final Color user_text_box_color;
  final Color default_user_text_boxes_color;
  final Color ai_text_box_color;
  final Color default_ai_text_boxes_color;
  final Color date_text_color;

  final String user_language;
  final String default_language;
  final String user_theme;

  final String default_background_image_path;
  final String background_image_path;

  final String button_pressed_effect;
  final String miscellanous_effect;
  final bool sound_effects_status;
  final bool default_sound_effects_status;
  final String easter_egg;
  final bool easter_egg_found;

  final String app_version;
  final String legal_notice;

  app_configuration({
    required this.main_title,

    required this.directive,
    required this.default_directive,
    required this.response_length_limit,
    required this.response_length_tolerance,
    required this.ai_api_model,
    required this.max_api_response_time_limit,
    required this.verbose,
    required this.default_verbose,
    required this.character_render_speed_ms,

    required this.backend_url,
    required this.backend_url_generate_ai_response,
    required this.backend_url_sign_up,
    required this.backend_url_log_in,
    required this.backend_url_log_out,
    required this.backend_url_refresh_token,
    required this.backend_url_reset_password,
    required this.backend_url_complete_profile,
    required this.backend_url_user_exists,
    required this.backend_url_user_prefences,

    required this.allowed_email_providers,
    required this.allowed_email_tlds,
    required this.refresh_token_preemptive,

    required this.background_color,
    required this.default_background_color,
    required this.app_bar_color,
    required this.default_app_bar_color,
    required this.text_color,
    required this.suggest_input_color,
    required this.user_text_box_color,
    required this.default_user_text_boxes_color,
    required this.ai_text_box_color,
    required this.default_ai_text_boxes_color,
    required this.date_text_color,

    required this.user_language,
    required this.default_language,
    required this.user_theme,

    required this.default_background_image_path,
    required this.background_image_path,

    required this.button_pressed_effect,
    required this.miscellanous_effect,
    required this.sound_effects_status,
    required this.default_sound_effects_status,
    required this.easter_egg,
    required this.easter_egg_found,

    required this.app_version,
    required this.legal_notice,
  });

  factory app_configuration.fromJson(Map<String, dynamic> json) {
    final ai = json['ai'] ?? {};
    final colors = json['colors'] ?? {};
    final backend = json["backend"] ?? {};
    final db = json["db"] ?? {};
    final user_defaults = json['user_defaults'] ?? {};
    final image_paths = json['images'] ?? {};
    final audio_paths = json['audio'] ?? {};
    final app_info = json['app_info'] ?? {};

    return app_configuration(
      main_title: user_defaults['main_title'] ?? 'main_title',

      directive: ai['directive'] ?? 'personality',
      default_directive: ai['default_directive'] ?? 'default_personality',
      max_api_response_time_limit: ai['max_api_response_time_limit.s'] ?? 10,
      ai_api_model: ai["ai_api_model"],
      response_length_limit: ai['response_length_limit.tokens'] ?? 100,
      response_length_tolerance: ai['response_length_tolerance.tokens'] ?? 10,
      verbose: ai['verbose_level'] ?? 'verbose_level',
      default_verbose: ai['default_verbose_level'] ?? 'default_verbose_level',
      character_render_speed_ms: ai['character_render_speed.ms'] ?? 10,

      backend_url: backend["backend_url"]?? 'invalid://missing-host',
      backend_url_generate_ai_response: backend["backend_url_generate_ai_response"]?? 'invalid://missing-host',
      backend_url_sign_up: backend["backend_url_sign_up"]?? 'invalid://missing-host',
      backend_url_log_in: backend["backend_url_log_in"]?? 'invalid://missing-host',
      backend_url_log_out: backend["backend_url_log_out"]?? 'invalid://missing-host',
      backend_url_refresh_token: backend["backend_url_refresh_token"]?? 'invalid://missing-host',
      backend_url_reset_password: backend["backend_url_reset_password"]?? 'invalid://missing-host',
      backend_url_complete_profile: backend["backend_url_complete_profile"]?? 'invalid://missing-host',
      backend_url_user_exists: backend["backend_url_check_user_exists"]?? 'invalid://missing-host',
      backend_url_user_prefences: backend["backend_url_user_prefences"]?? 'invalid://missing-host',

      allowed_email_providers: db["allowed_email_providers"]?? [''],
      allowed_email_tlds: db["allowed_email_tlds"]?? [''],
      refresh_token_preemptive: db["refresh_token_preemptive.s"]?? 10,

      background_color: hex_to_color(colors['background.color'] ?? '#FFFFFFFF'),
      default_background_color: hex_to_color(colors['default_background.color'] ?? '#FFFFFFFF'),
      app_bar_color: hex_to_color(colors['app_bar.color'] ?? '#FFFF7F50'),
      default_app_bar_color: hex_to_color(colors['default_app_bar.color'] ?? '#FFFF7F50'),
      text_color: hex_to_color(colors['text.color'] ?? '#FF000000'),
      suggest_input_color: hex_to_color(colors['suggest_input.color'] ?? '#FF808080'),
      user_text_box_color: hex_to_color(colors['user_text_boxes.color'] ?? '#FF008080'),
      default_user_text_boxes_color: hex_to_color(colors['default_user_text_boxes.color'] ?? '#FF008080'),
      ai_text_box_color: hex_to_color(colors['ai_text_boxes.color'] ?? '#FF800000'),
      default_ai_text_boxes_color: hex_to_color(colors['default_ai_text_boxes.color'] ?? '#FF800000'),
      date_text_color: hex_to_color(colors['date_text.color'] ?? '#FF000000'),

      user_language: user_defaults['language'] ?? 'language',
      default_language: user_defaults['default_language'] ?? 'default_language',
      user_theme: user_defaults['theme'] ?? 'theme',

      default_background_image_path: image_paths["default_background_image.path"] ?? 'not_found',
      background_image_path: image_paths["background_image.path"] ?? 'not_found',

      button_pressed_effect: audio_paths["button_pressed_effect.mp3"] ?? 'not_found',
      miscellanous_effect: audio_paths["miscellanous_effect.mp3"] ?? 'not_found',
      sound_effects_status: audio_paths["sound_effects_status"] ?? false,
      default_sound_effects_status: audio_paths["default_sound_effects_status"] ?? false,
      easter_egg: audio_paths["easter_egg"] ?? 'not_found',
      easter_egg_found: audio_paths["easter_egg_found"] ?? false,

      app_version: app_info['version'] ?? 'version',
      legal_notice: app_info['legal_notice'] ?? 'legal_notice',
    );
  }
}

//Config file management------------------------------------
//Async asset JSON loader
Future<Map<String, dynamic>?> read_data_json_asset(String file_path) async {
  log_handler?.d("[------read_data_json_asset function executing------]");
  try {
    final contents = await rootBundle.loadString(file_path);
    final Map<String, dynamic> json_data = jsonDecode(contents);
    return json_data;

  } on FlutterError catch (er) {
    log_handler?.e("Error loading asset '$file_path': $er");
    return null;

  } on FormatException {
    log_handler?.e("Error: The asset '$file_path' is not a valid JSON file.");
    return null;
  }
}

//Helper function to convert hex string to Color
Color hex_to_color(String hex) {
  log_handler?.d("[------hex_to_color function executing------]");
  return Color(int.parse(hex.replaceFirst('#', '0x')));
}

//Helper function to convert a Color to hex string including alpha (#FFA62987)
String color_to_hex(Color color) {
  log_handler?.d("[------color_to_hex function executing------]");
  return '#'
      '${color.alpha.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${color.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${color.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${color.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

//To load configuration once
late app_configuration config_data;
late Map<String, dynamic> raw_config_json;

//Load config once
Future<File> get_local_config_file() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/config_file.json');
}

//Initialize config
Future<void> initialize_config() async {
  final localFile = await get_local_config_file();

  // If config doesn't exist locally, copy from asset
  if (!await localFile.exists()) {
    final assetData = await rootBundle.loadString('assets/config_file.json');
    await localFile.writeAsString(assetData);
  }

  final content = await localFile.readAsString();
  final json_data = jsonDecode(content);

  raw_config_json = json_data;
  config_data = app_configuration.fromJson(json_data);
  log_handler?.d("Configuration loaded from local file.");
}
