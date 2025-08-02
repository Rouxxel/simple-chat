import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import "dart:async";

//Import methods
import 'package:simple_chat/functionality_n_scripts/standalone_methods/general_methods.dart';
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import "package:simple_chat/functionality_n_scripts/session_related/app_storage_class.dart";
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';
import "package:simple_chat/widgets_and_ui_elements/alert_dialog_builders.dart";

//imports
/////////////////////////////////////////////////////////////////////////////
//Classes

class Message {
  String text;
  final bool is_user;
  late final DateTime time_stamp;

  //Normal constructor
  Message(this.text, this.is_user) : time_stamp = DateTime.now();

  //Named constructor for deserialization
  Message.fromJson(Map<String, dynamic> json)
      : text = json['text'] ?? '',
        is_user = json['is_user'] ?? false,
        time_stamp = DateTime.parse(json['time_stamp']);

  //Function for user to send message
  void send_messages(TextEditingController input_controller,
      List<Message> message_list, Function set_state_callback) {
    log_handler?.d("[------send_messages function executing------]");
    if (input_controller.text.isNotEmpty) {
      set_state_callback(() {
        //Add message to list
        message_list.insert(0, Message(input_controller.text, true));
      },);
      log_handler?.d("---User Query successfully sent---");
    }
  }

  //Function for AI to make a response
  Future<void> ai_query_and_response(
      BuildContext context,
      TextEditingController input_controller,
      List<Message> message_list,
      //String ai_personality,
      Function set_state_callback) async {
    log_handler?.d("[------ai_query_and_response function executing------]");
    if (input_controller.text.isEmpty) {
      //No input to process
      log_handler?.e("input_controller is empty");
      return;
    }

    try {
      //Build conversation memory for current session
      String history = build_conversation_context(message_list);
      String new_prompt = "$history\nUser: ${input_controller.text}\nAI:";

      //Obtain critical user data
      final String? user_id = await AppStorage.get_user_id();
      final String? access_token = await AppStorage.get_access_token();

      //Prepare request payload
      final body_for_backend = jsonEncode({
        "prompt": new_prompt,
        "ai_model": config_data.ai_api_model,
        "time_limit": config_data.max_api_response_time_limit,
        "user_id": user_id,
        "access_token": access_token
      });

      //log_handler?.w(body_for_backend);

      //POST request to your backend URL
      final response = await http
          .post(
        Uri.parse(config_data.backend_url + config_data.generate_ai_response_suffix),
        headers: {"Content-Type": "application/json"},
        body: body_for_backend,
      )
          .timeout(
        Duration(seconds: config_data.max_api_response_time_limit + 5),
        onTimeout: () async {
          await build_informative_alert_dialog(
            context,
            "Ok",
            "Error 227", //AI response took too long
            "There was an error with the processing time, please try again later",
          );
          throw TimeoutException('AI response took too long');
        },
      );

      //Check response status code
      switch(response.statusCode){
        case 200:
          //Log and proceed
          log_handler?.i("Backend response successful ${response.statusCode}");
          break;
        case 504:
          log_handler?.e("AI timeout: ${response.statusCode} - ${response.body}");
          await build_informative_alert_dialog(
            context,
            "OK",
            "Error 224", //API error
            "There was an error with AI response or when trying to communicate with AI",
          );
          return;
        case 500:
          log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
          await build_informative_alert_dialog(
            context,
            "Ok",
            "Error 230", //Server error
            "There has been an error with the server, please try again later",
          );
          return;
        case 422:
          log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
          await build_informative_alert_dialog(
            context,
            "Ok",
            "Error 245", //Unprocessable Entity
            "There was an issue with the data provided. Please try again later",
          );
          return;
        case 429:
          log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
          await build_informative_alert_dialog(
            context,
            "Ok",
            "Error 230", //Server error
            "There has been an error with the server, please try again later",
          );
          return;
        default:
          log_handler?.w("Unexpected status code: ${response.statusCode}");
          await build_informative_alert_dialog(
            context,
            "Ok",
            "Error 231", //Unexpected unknown server error
            "There has been an unexpected backend error, please try again later.",
          );
          return;
      }

      //Parse AI response text
      final data = jsonDecode(response.body);
      String ai_text = data['ai_answer'] ?? "Error with AI response";

      //Extract and animate AI response
      Message ai_message = Message("", false);
      set_state_callback(() {
        //Add AI response to list
        message_list.insert(0, ai_message);
      });

      for (int i = 0; i < ai_text.length; i = i + 1) {
        await Future.delayed(Duration(milliseconds: config_data.character_render_speed_ms));
        set_state_callback(() {
          ai_message.text = ai_message.text + ai_text[i];
        });
      }

      log_handler?.d("---AI successfully responded back---");
    } catch (er) {
      log_handler?.e("Error: $er");
      await build_informative_alert_dialog(
        context,
        "OK",
        "Error 224", //API error
        "There was an error with AI response or when trying to communicate with AI",
      );
    }
  }

  //Old versions
  // //Converts a List<Message> to a List<Map<String, dynamic>>
  // static List<Map<String, dynamic>> message_to_json_list(List<Message> message_list) {
  //   return message_list.map((message) {
  //     return {
  //       'text': message.text,
  //       'is_user': message.is_user,
  //       'time_stamp': message.time_stamp.toUtc().toIso8601String(),
  //     };
  //   }).toList();
  // }
  //
  // //Converts a List<Map<String, dynamic>> to a List<Message>
  // static List<Message> json_to_message_list(List<Map<String, dynamic>> json_list) {
  //   return json_list.map((json) {
  //     return Message(
  //       json['text'] ?? '',
  //       json['is_user'] ?? false,
  //     )..time_stamp = DateTime.parse(json['time_stamp']);
  //   }).toList();
  // }

  // Serialization method
  Map<String, dynamic> toJson() => {
    'text': text,
    'is_user': is_user,
    'time_stamp': time_stamp.toUtc().toIso8601String(),
  };

  // Converts List<Message> to List<Map<String, dynamic>>
  static List<Map<String, dynamic>> message_to_json_list(List<Message> messages) {
    return messages.map((m) => m.toJson()).toList();
  }

  // Converts List<Map<String, dynamic>> to List<Message>
  static List<Message> json_to_message_list(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }
}
