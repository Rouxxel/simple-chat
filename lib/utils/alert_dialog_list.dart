import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:simple_chat/configurations/config_invoke.dart";

//TODO:Create a single alert dialog that can be modified to have title and paragraph
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
    backgroundColor: config_data.app_bar_color,
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
    backgroundColor: config_data.app_bar_color,
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
    backgroundColor: config_data.app_bar_color,
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

//Alert to show changes saved
void show_changes_saved(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Changes saved!!!",
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
      "All changes were successfully saved, configuration applied",
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

//Alert to show changes reset
void show_changes_reset(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Changes Reset!!!",
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
      "All changes were successfully reset",
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

//Alert to show feature in progress saved
void show_feature_in_progress(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Feature in progress...",
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
      "The feature you just tried to use is in development. Please enjoy"
          "all the other features and stay tuned for future updates",
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

//Alert to show feedback sent
void show_feedback_sent(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Feedback Sent!!!",
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
      "Your Feedback has been sent through the email/s you selected",
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

//Alert to show only one feedback per session
void show_one_feedback_per_session(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Feedback limit reached",
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
      "Sorry, you can only send your feedback once per session, please restart "
          "the app to send your feedbakck.",
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

//Alert to show easter egg unlocked
void show_easter_egg_discovered(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "You discovered the easter egg!!!",
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
      "Congratulations!, either by chance, luck or consciously, you have"
          "discovered the easter egg in this app, enjoy it in the sound "
          "effects section after restarting the app",
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

//Alert to show empty input
void show_empty_input(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Empty input",
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
      "Please, fill all fields before proceeding.",
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

//Alert to show successful sign up
void show_successful_sign_up(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Successful Sign up!!!",
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
      "You have been successfully signed into our app, please check the email you "
      "provided to confirm your onboarding and enjoy the app. Please go back to log "
      "in.",
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

//Alert to show server error
void show_server_error(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Error 230",
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
      "There has been an error with the server, please try again later",
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

//Alert to show invalid email error
void show_invalid_email(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Invalid email",
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
      "The email you provided is invalid, please enter a valid email",
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

//Alert to show passwords dont match error
void show_nonmatching_passwords(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Passwords don't match",
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
      "The email you provided is invalid, please enter a valid email",
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

//Alert to show invalid password
void show_invalid_password_error(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Invalid password",
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
      "The password you entered is invalid, please enter a valid password that contains. "
      "at least 8 characters, 1 upper case character, 1 lower case character, 1 number and "
      "1 number.",
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

//Alert to show non matchin passwords error
void show_unexpected_backend_error(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Error 231",
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
      "There has been an unexpected backend error, please try again later.",
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

//Alert to show unexpected invalid parameters error
void show_invalid_parameters_error(BuildContext context) {
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
    backgroundColor: config_data.app_bar_color,
    title: Text(
      "Invalid entered values",
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
      "You have entered invalid values, please enter valid values.",
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
