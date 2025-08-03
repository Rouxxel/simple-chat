import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart";

//Alert dialog mehtod------------------------------------------------------
Future<void> build_informative_alert_dialog(
    BuildContext context,
    String button_text,
    String title,
    String description,
    ) async {
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

Future<Map<String, String>?> build_dynamic_input_dialog(
    BuildContext context, {
      required String title,
      required String description,
      required String yes_button_text,
      required String no_button_text,
      required List<String> labels,
      required List<TextInputType> input_types,
      required List<bool> obscure_text,
    }) {
  assert(labels.length == input_types.length && labels.length == obscure_text.length);

  final controllers = List.generate(labels.length, (_) => TextEditingController());

  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: config_data.app_bar_color,
        title: Text(
          title,
          style: GoogleFonts.handjet(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                description,
                style: GoogleFonts.handjet(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(labels.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: controllers[i],
                    keyboardType: input_types[i],
                    obscureText: obscure_text[i],
                    cursorColor: config_data.text_color,  //Cursor color
                    decoration: InputDecoration(
                      labelText: labels[i],
                      labelStyle: TextStyle(color: config_data.text_color), //Label color
                      filled: true,
                      fillColor: config_data.user_text_box_color.withOpacity(0.5), //Input field background
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: config_data.text_color,     //Custom border color when enabled (not focused)
                          width: 1.0,                        //Border thickness
                        ),
                        borderRadius: BorderRadius.circular(8), //Round corners
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: config_data.text_color,  //Custom border color when focused
                          width: 2.0,                     //Thicker border when focused
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text(
              no_button_text,
              style: GoogleFonts.handjet(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final values = <String, String>{};
              for (int i = 0; i < labels.length; i++) {
                final value = controllers[i].text.trim();
                values[labels[i]] = value;
              }
              Navigator.pop(context, values);
            },
            child: Text(
              yes_button_text,
              style: GoogleFonts.handjet(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    },
  );
}
