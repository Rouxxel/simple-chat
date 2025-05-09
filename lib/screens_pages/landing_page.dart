import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';   //Fonts
import 'package:icons_flutter/icons_flutter.dart'; //Extra icons
import 'package:intl/intl.dart'; //For date and time formatting

import 'package:simple_chat/methods_functions/methods.dart';
import 'package:simple_chat/classes/classes.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//screen itself
class landing_page extends StatefulWidget {
  const landing_page({super.key});

  @override
  State<landing_page> createState() => _landing_pageState();
}

class _landing_pageState extends State<landing_page> {
  //Create a TextEditingController for the input box
  final TextEditingController _input_controller = TextEditingController();

  //List to store chat messages, both user and AI
  final List<Message> _message_list = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //Background color
        backgroundColor: const Color.fromRGBO(52, 49, 49, 1.0),

        //Top App bar
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(160, 71, 71, 1.0),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Prevents the AppBar from expanding too much
              children: [
                Text(
                  "- Simple AI Chat -",
                  style: GoogleFonts.bebasNeue(
                    textStyle: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Text(
                  "Google Gemini 1.5 Flash API powered",
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),

        //Main content
        body: Stack(
          children: [
            //Background image
            Image.asset(
              "images/background.jpeg",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),

            //Actual content
            Padding(
              padding:
                  const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //List of displayed user and AI messages
                  Expanded(

                    //"Message" generator with a builder
                    child: ListView.builder(
                      reverse: true, //Start at the bottom
                      itemCount: _message_list.length,
                      //Message blueprint
                      itemBuilder: (context, index) {
                        //Declare message with list that has class
                        final message = _message_list[index];

                        //Declare dynamic color
                        Color dyna_color= message.user?
                          Color.fromRGBO(216, 162, 94, 1.0):
                          Color.fromRGBO(238, 223, 122, 1.0);
                        //Declare dynamic Edge Insets
                        EdgeInsets dyna_padding= message.user?
                          EdgeInsets.fromLTRB(112, 4, 0, 4):
                          EdgeInsets.fromLTRB(0, 4, 112, 4);

                        return Padding(
                          padding: dyna_padding, //Pad messages
                          child: Column(
                              crossAxisAlignment: message.user ?
                                CrossAxisAlignment.end :
                                CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                              //Container for each message
                              Container(
                                padding: const EdgeInsets.all(12.0), //Pad message's text in container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.0),
                                  color: dyna_color,
                                ),
                                //Inner column for message/timestamp
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    //Actual message text
                                    Text(
                                      message.text,
                                      style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                    //Timestamp of message
                                    Text(
                                      //Format the timestamp as '12:30pm, 23/09/2024'
                                      DateFormat('hh:mma, dd/MM/yyyy').format(message.time_stamp).toLowerCase(),
                                      style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic,
                                          color: Color.fromRGBO(33, 33, 33, 1.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  //Input field and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Input field
                      Expanded(
                        child: TextField(
                          //Controller to manage user input
                          controller: _input_controller,

                          //Decorate user input text
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color: Colors.black,
                            ),
                          ),

                          //Decorate input box and hint text
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromRGBO(216, 162, 94, 1.0),
                            hintText: "Say hello!!!",
                            hintStyle: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              /*borderSide: BorderSide( //TODO: why is the border color not being updated?
                                color: Colors.pinkAccent,
                                width: 15.0,
                              ),*/
                            ),
                          ),
                        ),
                      ),

                      //Icon button, container to create its frame
                      Container(
                        //Round up Iconbutton's container edges
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: const Color.fromRGBO(216, 162, 94, 1.0),
                        ),
                        height: 62,
                        width: 62,

                        //Search icon
                        child: Center(
                          child: IconButton(
                            //Icon decoration
                            icon: const Icon(
                              MaterialIcons.send,
                            ),
                            alignment: Alignment.center,
                            iconSize: 40,
                            color: Colors.black,

                            //Icon script execution
                            onPressed: () async {
                              final userInput = _input_controller.text;

                              //First validate the input
                              if (validate_user_input(context, userInput) &&
                                  userInput.isNotEmpty) {
                                //Create a message and send it
                                Message message = Message(userInput, true);
                                message.send_messages(_input_controller, _message_list, setState);

                                //Then get AI response
                                await message.ai_query_and_response(
                                  context,
                                  _input_controller,
                                  _message_list,
                                  setState,
                                );

                                _input_controller.clear();
                              } else {
                                print("Message not sent due to invalid input.");
                              }
                            }
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
