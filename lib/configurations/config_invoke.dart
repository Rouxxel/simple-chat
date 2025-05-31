import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:simple_chat/methods_functions/methods.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'dart:io';
import 'package:path_provider/path_provider.dart';

//Extract configuration values
class app_configuration {
  final String directive;
  final String default_directive;
  final int response_length_limit;
  final int response_length_tolerance;
  final String ai_api_model;
  final int max_api_response_time_limit;
  final String verbose;
  final int character_render_speed_ms;

  final Color background_color;
  final Color app_bar_color;
  final Color text_color;
  final Color suggest_input_color;
  final Color user_text_box_color;
  final Color ai_text_box_color;
  final Color date_text_color;

  final String user_language;
  final String default_language;
  final String user_theme;

  final String default_image_path;
  final String image_path;

  final String app_version;
  final String legal_notice;

  app_configuration({
    required this.directive,
    required this.default_directive,
    required this.response_length_limit,
    required this.response_length_tolerance,
    required this.ai_api_model,
    required this.max_api_response_time_limit,
    required this.verbose,
    required this.character_render_speed_ms,

    required this.background_color,
    required this.app_bar_color,
    required this.text_color,
    required this.suggest_input_color,
    required this.user_text_box_color,
    required this.ai_text_box_color,
    required this.date_text_color,

    required this.user_language,
    required this.default_language,
    required this.user_theme,

    required this.default_image_path,
    required this.image_path,

    required this.app_version,
    required this.legal_notice,
  });

  factory app_configuration.fromJson(Map<String, dynamic> json) {
    final ai = json['ai'] ?? {};
    final colors = json['colors'] ?? {};
    final user_defaults = json['user_defaults'] ?? {};
    final image_paths = json['images'] ?? {};
    final app_info = json['app_info'] ?? {};

    return app_configuration(
      directive: ai['directive'] ?? '',
      default_directive: ai['default_directive'] ?? '',
      max_api_response_time_limit: ai['max_api_response_time_limit.s'] ?? 5,
      ai_api_model: ai["ai_api_model"],
      response_length_limit: ai['response_length_limit.tokens'] ?? 100,
      response_length_tolerance: ai['response_length_tolerance.tokens'] ?? 10,
      verbose: ai['verbose_level'] ?? 'medium',
      character_render_speed_ms: ai['character_render_speed.ms'] ?? 10,

      background_color: hex_to_color(colors['background.color'] ?? '#FFFFFFFF'),
      app_bar_color: hex_to_color(colors['app_bar.color'] ?? '#FFFFFFFF'),
      text_color: hex_to_color(colors['text.color'] ?? '#FF000000'),
      suggest_input_color: hex_to_color(colors['suggest_input.color'] ?? '#FF000000'),
      user_text_box_color: hex_to_color(colors['user_text_boxes.color'] ?? '#FFFFFFFF'),
      ai_text_box_color: hex_to_color(colors['ai_text_boxes.color'] ?? '#FFFFFFFF'),
      date_text_color: hex_to_color(colors['date_text.color'] ?? '#FF000000'),

      user_language: user_defaults['language'] ?? 'en',
      default_language: user_defaults['default_language'] ?? 'en',
      user_theme: user_defaults['theme'] ?? 'light',

      default_image_path: image_paths["default_image.path"] ?? '',
      image_path: image_paths["image.path"] ?? '',

      app_version: app_info['version'] ?? '1.0.0',
      legal_notice: app_info['legal_notice'] ?? '',
    );
  }
}

//Config file management------------------------------------
//Async asset JSON loader
Future<Map<String, dynamic>?> read_data_json_asset(String file_path) async {
  log_handler.d("[------read_data_json_asset function executing------]");
  try {
    final contents = await rootBundle.loadString(file_path);
    final Map<String, dynamic> json_data = jsonDecode(contents);
    return json_data;

  } on FlutterError catch (er) {
    log_handler.e("Error loading asset '$file_path': $er");
    return null;

  } on FormatException {
    log_handler.e("Error: The asset '$file_path' is not a valid JSON file.");
    return null;
  }
}

//Helper function to convert hex string to Color
Color hex_to_color(String hex) {
  log_handler.d("[------hex_to_color function executing------]");
  return Color(int.parse(hex.replaceFirst('#', '0x')));
}

//Helper HashMap to convert strings to hex
Map<String, String> color_name_to_hex_map = {
  'red': '#FFFF0000',
  'green': '#FF00FF00',
  'blue': '#FF0000FF',
  'yellow': '#FFFFFF00',
  'black': '#FF000000',
  'white': '#FFFFFFFF',
  'grey': '#FF888888',
  'gray': '#FF888888',
  'fuchsia': '#FFFF00FF',
  'cyan': '#FF00FFFF',
  'magenta': '#FFFF00FF',
  'orange': '#FFFFA500',
  'purple': '#FF800080',
  'pink': '#FFFFC0CB',
  'brown': '#FFA52A2A',
  'lime': '#FF00FF00',
  'lightgreen': '#FF90EE90',
  'lightblue': '#FFADD8E6',
  'darkred': '#FF8B0000',
  'darkblue': '#FF00008B',
  'aqua': '#FF00FFFF',
  'navy': '#FF000080',
  'teal': '#FF008080',
  'maroon': '#FF800000',
  'olive': '#FF808000',
  'silver': '#FFC0C0C0',
  'gold': '#FFFFD700',
  'beige': '#FFF5F5DC',
  'ivory': '#FFFFFFF0',
  'coral': '#FFFF7F50',
  'salmon': '#FFFA8072',
  'khaki': '#FFF0E68C',
  'turquoise': '#FF40E0D0',
  'indigo': '#FF4B0082',
  'violet': '#FFEE82EE',
  'orchid': '#FFDA70D6',
  'plum': '#FFDDA0DD',
  'crimson': '#FFDC143C',
  'skyblue': '#FF87CEEB',
  'deepskyblue': '#FF00BFFF',
  'dodgerblue': '#FF1E90FF',
  'slategray': '#FF708090',
  'darkgray': '#FFA9A9A9',
  'lightgray': '#FFD3D3D3',
  'seagreen': '#FF2E8B57',
  'forestgreen': '#FF228B22',
  'mintcream': '#FFF5FFFA',
  'snow': '#FFFFFAFA',
  'chocolate': '#FFD2691E',
  //Add more here
};

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
  log_handler.d("Configuration loaded from local file.");
}
