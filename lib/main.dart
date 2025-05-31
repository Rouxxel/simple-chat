import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simple_chat/screens_pages/landing_page.dart';
import 'package:simple_chat/configurations/config_invoke.dart';
import 'package:simple_chat/utils/logger_config.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Run app

void main() async{
  //Load environmental variable to make it available
  await dotenv.load(fileName:"envvar.env");

  //Load configuration
  await initialize_config();

  //Initialize logger
  WidgetsFlutterBinding.ensureInitialized();
  await init_logger();
  log_handler?.i("Logger initialized!");

  //Check loaded configuration (I know its horrible coding)
  log_handler?.i(
      'directive: ${config_data.directive}\n'
          'default_directive: ${config_data.default_directive}\n'
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
          'default_language: ${config_data.default_language}\n'
          'user_theme: ${config_data.user_theme}\n'
          'default_image_path: ${config_data.default_image_path}\n'
          'image_path: ${config_data.image_path}\n'
          'app_version: ${config_data.app_version}\n'
          'legal_notice: ${config_data.legal_notice}'
  );

  runApp(
    const MaterialApp(
      home: landing_page(),
    ),
  );
}
