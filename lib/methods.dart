
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";                   //env var
import "package:google_fonts/google_fonts.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:icons_flutter/icons_flutter.dart" as extra_icons;      //extra icons
import "package:http/http.dart" as http_rsc;                           //http resources
import "package:url_launcher/url_launcher.dart";                       //url launcher
import "package:intl/intl.dart" as interdates;                         //date-time formatting/parsing

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

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

//Function for user to send message
/*void send_messages(TextEditingController query, List<String> message_list) {
  if (query.text.isNotEmpty || query.text != null) {
    setState(() {
      //Add message to list
      message_list.insert(0, query.text);
    });
    //Clear message
    query.clear();
  }
}*/

//To ensure user input is not an attack
bool Validate_user_input(BuildContext context,String user_input) {
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

//Alert dialog for possible attack
void show_possible_attack_dialog(BuildContext context) {
  //Declare the buttons of alert
  Widget ok_button = TextButton(
    child: Text(
      "Ok",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
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
    backgroundColor: const Color.fromRGBO(160, 71, 71,1.0),
    title: Text(
      "Error 221", //Invalid characters
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    content: Text(
      "There was an error processing your query, try avoiding special characters",
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
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

//Test
Future<void> testai() async{
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: Obtain_API_key(),
  );
  final user_prompt = 'Write a story about a magic backpack.';

  final response = await model.generateContent([Content.text(user_prompt)]);
  print("---AI response succesful---");
  print(response.text);
}