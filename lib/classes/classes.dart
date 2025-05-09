import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "dart:async";

//Import methods
import 'package:simple_chat/methods_functions/methods.dart';
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
    if (input_controller.text.isNotEmpty) {
      set_state_callback(() {
        //Add message to list
        message_list.insert(0, Message(input_controller.text, true));
      },
      );
      print("---User Query succesfully sent---");
    }
  }

  //Function for AI to make a response
  Future<void> ai_query_and_response(
      BuildContext context,
      TextEditingController input_controller,
      List<Message> message_list,
      Function set_state_callback) async {

    String local_key = obtain_API_key(); //Call api key once
    if (local_key.isEmpty) {
      //Manage error
      show_api_key_retrieval_error_dialog(context);
      throw Exception("Error in retrieving API key");
    }

    //Try to make API call
    try {
      //Declare AI model
      final gemini_model = await GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: local_key,
      );

      //Declare ai response to be updated
      dynamic ai_response=null;
      if (input_controller.text.isNotEmpty) {
        const String system_prompt = "You are a chatbot named Simple Chat. "
                                    "Act like a British butler and use a formal, "
                                    "refined vocabulary. ";

        //Update input_controller
        String text_to_ai = system_prompt + input_controller.text;
        //Original text to be sent to AI
        //input_controller.text = system_prompt + input_controller.text;
        
        //Extract AI response, with a time limit to respond
        ai_response = await gemini_model
            .generateContent([Content.text(text_to_ai)])
            .timeout(Duration(seconds: 7), onTimeout: () {
          show_ai_took_too_long_error(context);
          throw TimeoutException('AI response took too long');
        },
        );
      }

      //Extract the text content from AI response, safely handle possible null
      String ai_text = ai_response?.text.toString() ?? "Error with AI response";

      //Create a new AI message with an empty string (for gradual typing)
      Message ai_message = Message("", false);
      set_state_callback(() {
        //Add the empty message to the list first
        message_list.insert(0, ai_message);
      });

      //Add characters one by one with a delay to simulate typing
      for (int i = 0; i < ai_text.length; i=i+1) {
        await Future.delayed(const Duration(milliseconds: 1)); // Adjust speed here

        //Update the message text character by character
        set_state_callback(() {
          ai_message.text = ai_message.text + ai_text[i];
        });
      }

      print("---AI successfully responded back---");
    } catch (er) {
      print("Error: $er");

      //Display AI response error
      show_ai_response_error(context);
    }
  }

}