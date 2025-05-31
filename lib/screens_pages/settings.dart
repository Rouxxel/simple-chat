import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; //Fonts
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
          mainAxisSize:
              MainAxisSize.min, // Prevents the AppBar from expanding too much
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

      //Actual content
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(

          //Move children to the left
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Settings text
            Text(
              "Settings",
              style: GoogleFonts.bebasNeue(
                textStyle: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  color: config_data.text_color,
                ),
              ),
            ),

          //List of settings
          Expanded(
            //Listview
            child: ListView(
              children: [
                //AI section
                Container(
                  color: Colors.yellow,
                  child: Padding(
                    //
                    padding: EdgeInsets.fromLTRB(16,0,16,0),
                    child: Column(
                      //
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "AI",
                          style: GoogleFonts.bebasNeue(
                            textStyle: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              color: config_data.text_color,
                            ),
                          ),
                        ),

                        //Main directory
                        Padding(
                          padding: EdgeInsets.fromLTRB(16,0,0,0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Title
                              Text(
                                  "Personality",
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: config_data.text_color,
                                  ),
                                ),
                              ),
                              //Textfield for personality
                              TextField(
                                //controller: _input_controller,
                                //readOnly: _is_processing,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    fontSize: 18,               // match markdown paragraph font size
                                    fontWeight: FontWeight.normal,  // normal weight like markdown p
                                    fontStyle: FontStyle.normal, // normal style (not italic by default)
                                    //color: _is_processing ? Colors.transparent : config_data.text_color,
                                  ),
                                ),
                                maxLines: 8, // Allows up to 8 lines
                                minLines: 4, // Starts with 4 lines of height
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: config_data.user_text_box_color,
                                  //hintText: _is_processing ? '' : (_first_query_done ? "" : "Say hello..."),
                                  hintStyle: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.normal,
                                      color: config_data.suggest_input_color,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                ),
                                cursorColor: Colors.black,
                              ),
                            ],
                          ),
                        ),

                        //Verbose level
                        Padding(
                          padding: EdgeInsets.fromLTRB(16,0,0,0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Title
                              Text(
                                  "Verbose level",
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: config_data.text_color,
                                  ),
                                ),
                              ),
                              //Option buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        print("Low pressed");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            bottomLeft: Radius.circular(4),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text("Low"),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        print("Medium pressed");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        color: Colors.grey[400], // no radius here to keep edges flat
                                        alignment: Alignment.center,
                                        child: Text("Medium"),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        print("High pressed");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[500],
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4),
                                            bottomRight: Radius.circular(4),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text("High"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //Color section
                Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Text(
                          "Colorimetry",
                        style: GoogleFonts.bebasNeue(
                          textStyle: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            color: config_data.text_color,
                          ),
                        ),
                      ),
                      Text("Background color"),
                      Text("Bar colors"),
                      Text("User text box color"),
                      Text("AI text box color"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),

      //Bottom bar
      bottomNavigationBar: BottomAppBar(
        color: config_data.app_bar_color,

        child: Row(

          children: [],
        ),
      ),
    );
  }
}
