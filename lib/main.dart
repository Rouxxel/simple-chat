import 'package:flutter/material.dart';
import 'package:simple_chat/configuration/colort_list_invoke.dart';
import 'package:simple_chat/configuration/config_invoke.dart';
import 'package:simple_chat/configuration/countries_invoke.dart';
import 'package:simple_chat/utils/logger_config.dart';
import 'package:simple_chat/screens_pages/log_in_page.dart';
import 'package:simple_chat/standalone_methods_functions/user_entrypoint_methods.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Run app

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //First, Initialize logger
  await init_logger();
  log_handler?.i("Logger successfully initialized!");

  //Load configurations
  await initialize_config();
  await initialize_countries();
  await initialize_color_name_to_hex_map();

  //Wake up backend
  await root_endpoint(); //Ping the backend

  //Check loaded configuration (I know its horrible coding)
  log_handler?.i(
      'directive: ${config_data.directive}\n'
          'default_directive: ${config_data.default_directive}\n'
          'default_image_path: ${config_data.default_background_image_path}\n'
          'default_language: ${config_data.default_language}\n'
          'default_verbose_level: ${config_data.default_verbose}\n'
          'default_background.color: ${color_to_hex(config_data.default_background_color)}\n'
          'default_app_bar.color: ${color_to_hex(config_data.default_app_bar_color)}\n'
          'default_user_text_boxes.color: ${color_to_hex(config_data.default_user_text_boxes_color)}\n'
          'default_ai_text_boxes.color: ${color_to_hex(config_data.default_ai_text_boxes_color)}\n'
          'default_sound_effects_status.color: ${config_data.default_sound_effects_status}\n'
          'response_length_limit: ${config_data.response_length_limit}\n'
          'response_length_tolerance: ${config_data.response_length_tolerance}\n'
          'ai_api_model: ${config_data.ai_api_model}\n'
          'max_api_response_time_limit: ${config_data.max_api_response_time_limit}\n'
          'verbose: ${config_data.verbose}\n'
          'character_render_speed_ms: ${config_data.character_render_speed_ms}\n'
          'backend_url: ${config_data.backend_url}\n'
          'backend_url_generate_ai_response: ${config_data.backend_url_generate_ai_response}\n'
          'backend_url_sign_up: ${config_data.backend_url_sign_up}\n'
          'backend_url_log_in: ${config_data.backend_url_log_in}\n'
          'backend_url_log_out: ${config_data.backend_url_log_out}\n'
          'backend_url_refresh_token: ${config_data.backend_url_refresh_token}\n'
          'backend_url_reset_password: ${config_data.backend_url_reset_password}\n'
          'backend_url_complete_profile: ${config_data.backend_url_complete_profile}\n'
          'backend_url_user_exists: ${config_data.backend_url_user_exists}\n'
          'backend_url_user_preferences: ${config_data.backend_url_user_preferences}\n'
          'allowed_email_providers: ${config_data.allowed_email_providers}\n'
          'allowed_email_tlds: ${config_data.allowed_email_tlds}\n'
          'refresh_token_preemptive.s: ${config_data.refresh_token_preemptive}\n'
          'background_color: ${color_to_hex(config_data.background_color)}\n'
          'app_bar_color: ${color_to_hex(config_data.app_bar_color)}\n'
          'text_color: ${color_to_hex(config_data.text_color)}\n'
          'suggest_input_color: ${color_to_hex(config_data.suggest_input_color)}\n'
          'user_text_box_color: ${color_to_hex(config_data.user_text_box_color)}\n'
          'ai_text_box_color: ${color_to_hex(config_data.ai_text_box_color)}\n'
          'date_text_color: ${color_to_hex(config_data.date_text_color)}\n'
          'user_language: ${config_data.user_language}\n'
          'user_theme: ${config_data.user_theme}\n'
          'background_image_path: ${config_data.background_image_path}\n'
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
      home: log_in_page(),
    ),
  );
}
