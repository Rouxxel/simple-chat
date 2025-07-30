import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart";

//Alert dialog mehtod------------------------------------------------------
void build_informative_alert_dialog(
    BuildContext context,
    String button_text,
    String title,
    String description,
    ) {
  //Declare the buttons of alert
  Widget confirm_button = TextButton(
    child: Text(
      button_text,
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

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: config_data.app_bar_color,
        title: Text(
          title,
          style: GoogleFonts.handjet(
            textStyle: const TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        content: Text(
          description,
          style: GoogleFonts.handjet(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          confirm_button,
        ],
      );
    },
  );
}

Future<bool?> build_yes_no_alert_dialog(
    BuildContext context,
    String yes_button_text,
    String no_button_text,
    String title,
    String description,
    ) {
  //Declare the buttons of alert
  Widget yes_button = TextButton(
    child: Text(
      yes_button_text,
      style: GoogleFonts.handjet(
        textStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop(true);
    },
  );
  Widget no_button = TextButton(
    child: Text(
      no_button_text,
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
      Navigator.of(context, rootNavigator: true).pop(false);
    },
  );

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: config_data.app_bar_color,
        title: Text(
          title,
          style: GoogleFonts.handjet(
            textStyle: const TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        content: Text(
          description,
          style: GoogleFonts.handjet(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          yes_button,
          no_button,
        ],
      );
    },
  );
}
