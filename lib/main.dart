import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simple_chat/methods_functions/methods.dart';
import 'package:simple_chat/screens_pages/landing_page.dart';
import 'package:simple_chat/configurations/config_invoke.dart';
import 'package:simple_chat/utils/logger_config.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Run app

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //First, Initialize logger
  await init_logger();
  log_handler?.i("Logger successfully initialized!");

  //Load environment variables
  await dotenv.load(fileName: "envvar.env");
  log_handler?.i("Environment variables loaded successfully.");

  //Validate presence of API key
  obtain_API_key();

  //Load configuration
  await initialize_config();

  //Check loaded configuration (I know its horrible coding)
  log_handler?.i(
      'directive: ${config_data.directive}\n'
          'default_directive: ${config_data.default_directive}\n'
          'default_image_path: ${config_data.default_image_path}\n'
          'default_language: ${config_data.default_language}\n'
          'default_verbose_level: ${config_data.default_verbose}\n'
          'default_background.color: ${config_data.default_background_color}\n'
          'default_app_bar.color: ${config_data.default_app_bar_color}\n'
          'default_user_text_boxes.color: ${config_data.default_user_text_boxes_color}\n'
          'default_ai_text_boxes.color: ${config_data.default_ai_text_boxes_color}\n'
          'default_sound_effects_status.color: ${config_data.default_sound_effects_status}\n'
          'response_length_limit: ${config_data.response_length_limit}\n'
          'response_length_tolerance: ${config_data.response_length_tolerance}\n'
          'ai_api_model: ${config_data.ai_api_model}\n'
          'max_api_response_time_limit: ${config_data.max_api_response_time_limit}\n'
          'verbose: ${config_data.verbose}\n'
          'character_render_speed_ms: ${config_data.character_render_speed_ms}\n'
          'background_color: ${config_data.background_color}\n'
          'app_bar_color: ${config_data.app_bar_color}\n'
          'text_color: ${config_data.text_color}\n'
          'suggest_input_color: ${config_data.suggest_input_color}\n'
          'user_text_box_color: ${config_data.user_text_box_color}\n'
          'ai_text_box_color: ${config_data.ai_text_box_color}\n'
          'date_text_color: ${config_data.date_text_color}\n'
          'user_language: ${config_data.user_language}\n'
          'user_theme: ${config_data.user_theme}\n'
          'image_path: ${config_data.image_path}\n'
          'button_pressed_effect: ${config_data.button_pressed_effect}\n'
          'miscellaneous_effect: ${config_data.miscellanous_effect}\n'
          'sound_effects_status: ${config_data.sound_effects_status}\n'
          'easter_egg: ${config_data.easter_egg}\n'
          'easter_egg_found: ${config_data.easter_egg_found}\n'
          'app_version: ${config_data.app_version}\n'
          'legal_notice: ${config_data.legal_notice}'
  );

  runApp(
    const MaterialApp(
      home: landing_page(),
    ),
  );
}
