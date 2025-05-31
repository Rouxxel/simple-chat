import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';   //Fonts
import 'package:icons_flutter/icons_flutter.dart'; //Extra icons
import 'package:intl/intl.dart'; //For date and time formatting
import 'package:flutter_markdown/flutter_markdown.dart'; //For markdown

import 'package:simple_chat/methods_functions/methods.dart';
import 'package:simple_chat/classes/classes.dart';
import 'package:simple_chat/configurations/config_invoke.dart';

//Other screens
import 'package:simple_chat/screens_pages/settings.dart';

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Background color
      backgroundColor: config_data.background_color,

      //Top App bar
      appBar: AppBar(
        backgroundColor: config_data.app_bar_color,

        //auto-generated back button
        leading: IconButton(
          icon: const Icon(Icons.close_sharp),
          iconSize: 40,
          color: Colors.black,

          onPressed: () {
            //Custom action
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents the AppBar from expanding too much
          children: [
            Text(
              "- Simple AI Chat -",
              style: GoogleFonts.bebasNeue(
                textStyle: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  color: config_data.text_color,
                ),
              ),
            ),
            Text(
              "Google Gemini 2.0 Flash API powered",
              style: TextStyle(
                fontSize: 9,
                color: config_data.text_color,
              ),
            ),
          ],
        ),
      ),

      body: Stack(),
    );
  }
}