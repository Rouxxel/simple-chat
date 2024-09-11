import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart"; //env var
import "package:google_fonts/google_fonts.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "dart:async";
import "package:intl/intl.dart" as interdates; //date-time formatting/parsing

//imports
/////////////////////////////////////////////////////////////////////////////
//Classes

class Message {
  final String text;
  final bool user;

  Message(this.text, this.user);
}

//Classes
/////////////////////////////////////////////////////////////////////////////
//Methods

//API key retrieval--------------------------------------------------
//To retrieve the apikey from .env file
String Obtain_API_key() {
  String? AI_API_key = dotenv.env['ai_api_key'];
  if (AI_API_key == null) {
    throw Exception('API key not found');
  }

  print("---API key succesfully found---");
  //Return the API key
  return AI_API_key;
}

//Message related methods-------------------------------------------
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
Future<void> ai_response(
    BuildContext context,
    TextEditingController input_controller,
    List<Message> message_list,
    Function set_state_callback) async {

  String local_key = Obtain_API_key(); //Call api key once
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
      //Extract AI response, with a time limit to respond
      ai_response = await gemini_model
          .generateContent([Content.text(input_controller.text)])
          .timeout(Duration(seconds: 7), onTimeout: () {
        show_ai_took_too_long_error(context);
        throw TimeoutException('AI response took too long');
      },
      );
    }

    //Extract the text content from AI response, safely handle possible null
    String ai_text = ai_response?.text.toString() ?? "Error with AI response";
    //Update UI with inserted message
    set_state_callback(() {
      //Add message to list
      message_list.insert(0, Message(ai_text, false));
    },
    );
    //Clear message?, clear it outside functions
    //_input_controller.clear();
    print("---AI successfully responded back---");
  } catch (er) {
    print("Error: $er");

    //Display AI response error
    show_ai_response_error(context);
  }
}

//Data validation----------------------------------------------------
//To ensure user input is not an attack
bool validate_user_input(BuildContext context, String user_input) {
  print("[------validateuserinput function executed------]");
  if (user_input == null || user_input.isEmpty) {
    throw ArgumentError("Input is empty");
  }

  //Limit the valid characters by user
  final valid_chars = RegExp(r'^[a-zA-Z0-9\s\-]+$');

  if (valid_chars.hasMatch(user_input)) {
    print("Valid user input");
    return true;
  } else {
    //Handle invalid name or even possible attack
    show_possible_attack_dialog(context);
    print("Invalid user input");
    return false;
  }
}

//Alert dialogs------------------------------------------------------
//Alert dialog for possible attack
void show_possible_attack_dialog(BuildContext context) {
  //Declare the buttons of alert
  Widget ok_button = TextButton(
    child: Text(
      "Ok",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  //Set variables as the alert itself
  var alert = AlertDialog(
    backgroundColor: const Color.fromRGBO(160, 71, 71, 1.0),
    title: Text(
      "Error 221", //Invalid characters
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    content: Text(
      "There was an error processing your query, try avoiding special characters",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    actions: [
      ok_button,
    ],
  );

  //Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

//Alert dialog for API key retrieval error, dont use in final version
void show_api_key_retrieval_error_dialog(BuildContext context) {
  //Declare the buttons of alert
  Widget ok_button = TextButton(
    child: Text(
      "Ok",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  //Set variables as the alert itself
  var alert = AlertDialog(
    backgroundColor: const Color.fromRGBO(160, 71, 71, 1.0),
    title: Text(
      "Error 222", //Invalid characters
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    content: Text(
      "There was an error with API key retrieval",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    actions: [
      ok_button,
    ],
  );

  //Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

//Alert dialog for API response error
void show_ai_response_error(BuildContext context) {
  //Declare the buttons of alert
  Widget ok_button = TextButton(
    child: Text(
      "Ok",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  //Set variables as the alert itself
  var alert = AlertDialog(
    backgroundColor: const Color.fromRGBO(160, 71, 71, 1.0),
    title: Text(
      "Error 224",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    content: Text(
      "There was an error with AI response or when trying to communicate with AI",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    actions: [
      ok_button,
    ],
  );

  //Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

//Alert dialog for API response error
void show_ai_took_too_long_error(BuildContext context) {
  //Declare the buttons of alert
  Widget ok_button = TextButton(
    child: Text(
      "Ok",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  //Set variables as the alert itself
  var alert = AlertDialog(
    backgroundColor: const Color.fromRGBO(160, 71, 71, 1.0),
    title: Text(
      "Error 227",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    content: Text(
      "There was an error with the processing time, please try again later",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    actions: [
      ok_button,
    ],
  );

  //Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

//Testing different methods and others------------------------------
//Test AI, don't use for anything else
Future<void> testai() async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: Obtain_API_key(),
  );
  final user_prompt = 'Write a story about a magic backpack.';

  final response = await model.generateContent([Content.text(user_prompt)]);
  print("---AI response succesful---");
  print(response.text);
}
