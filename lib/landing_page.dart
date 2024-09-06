import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_flutter/icons_flutter.dart'; //Extra icons

import 'package:simple_chat/methods.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//global variables

//global variables
/////////////////////////////////////////////////////////////////////////////
//screen itself
class landing_page extends StatefulWidget {
  const landing_page({super.key});

  @override
  State<landing_page> createState() => _landing_pageState();
}

class _landing_pageState extends State<landing_page> {
  //Create a TextEditingController for the input box
  final TextEditingController _input_controller= TextEditingController();

  //List to store chat messages, both user and AI
  final List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //Background color
        backgroundColor: const Color.fromRGBO(52, 49, 49, 1.0),

        //Top App bar
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(160, 71, 71, 1.0),

          //App name title
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "- Simple Chat -",
              style: GoogleFonts.bebasNeue(
                textStyle: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),

        //Main content
        body: Stack(
          children: [
            //Background image
            Container(
              child: Image.asset(
                "images/background.jpeg",
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),

            //Actual content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          //Controller to manage user input
                          controller: _input_controller,

                          //Decorate user input text
                          style: GoogleFonts.handjet(
                            textStyle: const TextStyle(
                              fontSize:28,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color: Colors.black,
                            ),
                          ),

                          //Decorate input box and hint text
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(216, 162, 94, 1.0),
                            hintText: "Insert your query",
                            hintStyle: GoogleFonts.handjet(
                              textStyle: TextStyle(
                                fontSize: 28,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14.0),
                              ),
                              /*borderSide: BorderSide( //TODO: why is the border color not being updated?
                                color: Colors.pinkAccent,
                                width: 15.0,
                              ),*/
                            ),
                          ),
                        ),
                      ),

                      //Container to create a frame for Icon button
                      Container(
                        //Round up Iconbutton's container edges
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.0),
                          color: Color.fromRGBO(216, 162, 94, 1.0),
                        ),
                        height: 74,
                        width: 74,

                        //Search icon
                        child: Center(
                          child: IconButton(
                            //Icon decoration
                            icon: const Icon(
                              MaterialIcons.send,
                            ),
                            alignment: Alignment.center,
                            iconSize: 50,
                            color: Colors.black,

                            //Icon script execution
                            onPressed: ()async{},
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
    );
  }
}
