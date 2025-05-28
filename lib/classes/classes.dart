import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "dart:async";

//Import methods
import 'package:simple_chat/methods_functions/methods.dart';
import 'package:simple_chat/configurations/config_invoke.dart';
//Import alert dialogs
import "package:simple_chat/utils/alert_dialog_list.dart";

//imports
/////////////////////////////////////////////////////////////////////////////
//Classes

class Message {
  String text;
  final bool user;
  final DateTime time_stamp;

  Message(this.text, this.user) : time_stamp = DateTime.now();

  //Function for user to send message
  void send_messages(TextEditingController input_controller,
      List<Message> message_list, Function set_state_callback) {
    log_handler.d("[------send_messages function executing------]");
    if (input_controller.text.isNotEmpty) {
      set_state_callback(() {
        //Add message to list
        message_list.insert(0, Message(input_controller.text, true));
      },);
      log_handler.d("---User Query successfully sent---");
    }
  }

  //Function for AI to make a response
  Future<void> ai_query_and_response(
      BuildContext context,
      TextEditingController input_controller,
      List<Message> message_list,
      Function set_state_callback) async {
    log_handler.d("[------ai_query_and_response function executing------]");
    String local_key = obtain_API_key(); //Call api key once
    if (local_key.isEmpty) {
      show_api_key_retrieval_error_dialog(context);
      throw Exception("Error in retrieving API key");
    }
    try {
      final gemini_model = GenerativeModel(
        model: config_data.ai_api_model,
        apiKey: local_key,
      );

      dynamic ai_response;
      if (input_controller.text.isNotEmpty) {
        //OLD VERSION TO Build conversation memory for current session
        // const String system_prompt = "You are 'Simple Chat', an AI assistant who "
        //     "responds with the manner and refinement of "
        //     "a British butler. Use polite, formal language, "
        //     "and maintain a respectful tone. You may "
        //     "occasionally use British expressions, but avoid "
        //     "beginning every response with greetings or "
        //     "repeating the user's name unless it's contextually "
        //     "appropriate. Only introduce yourself if asked, "
        //     "and focus on being concise, helpful, and eloquent.";
        //
        // //Build conversation memory for current session
        // String history = build_conversation_context(message_list);
        // String new_prompt = "$system_prompt\n$history\nUser: ${input_controller.text}\nAI:";

        //Build conversation memory for current session
        String history = build_conversation_context(message_list);
        String new_prompt = "$history\nUser: ${input_controller.text}\nAI:";

        //Send full memory context to the AI along with new query
        ai_response = await gemini_model
            .generateContent([Content.text(new_prompt)])
            .timeout(Duration(seconds: config_data.max_api_response_time_limit), onTimeout: () {
          show_ai_took_too_long_error(context);
          throw TimeoutException('AI response took too long');
        },);
      }

      //Extract and animate AI response
      String ai_text = ai_response?.text.toString() ?? "Error with AI response";
      Message ai_message = Message("", false);
      set_state_callback(() {
        message_list.insert(0, ai_message);
      });

      for (int i = 0; i < ai_text.length; i = i + 1) {
        await Future.delayed(Duration(milliseconds: config_data.character_render_speed_ms));
        set_state_callback(() {
          ai_message.text = ai_message.text + ai_text[i];
        });
      }

      log_handler.d("---AI successfully responded back---");
    } catch (er) {
      log_handler.e("Error: $er");
      show_ai_response_error(context);
    }
  }
}
