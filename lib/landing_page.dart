import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';   //Fonts
import 'package:icons_flutter/icons_flutter.dart'; //Extra icons
import 'package:google_generative_ai/google_generative_ai.dart'; //AI import

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
  final TextEditingController _input_controller = TextEditingController();

  //List to store chat messages, both user and AI
  final List<Message> _message_list = [];

  //Function for user to send message
  void _send_messages() {
    if (_input_controller.text.isNotEmpty || _input_controller.text != null) {
      setState(() {
        //Add message to list
        _message_list.insert(0, Message(_input_controller.text,true),);
      },);
      //Clear message?, let _ai_response clear the message
      //_input_controller.clear();
      print("---User Query succesfully sent---");
    }
  }

  //Function for AI to make a response
  Future<void> _ai_response() async{

    String local_key= Obtain_API_key(); //Call api key once
    if(local_key == null || local_key.isEmpty){
      //Manage error
      show_api_key_retrieval_dialog(context);
      throw Exception("Error in retrieving API key");
    }
    //Declare AI model
    final gemini_model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: local_key,
    );


    if (_input_controller.text.isNotEmpty || _input_controller.text != null) {
      //Extract AI response
      final ai_response = await
        gemini_model.generateContent([Content.text(_input_controller.text)]);
      //Extract the text content from AI response
      dynamic ai_text = ai_response.text;
      setState(() {
        //Add message to list
        _message_list.insert(0, Message(ai_text,false),);
      },);
      //Clear message
      //_input_controller.clear();
      print("---AI successfully responded back---");
    };
  }

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
              padding:
                  const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //List of displayed user and AI messages
                  Expanded(
                    //"Message" generater with a builder
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
                          child: Container(
                            padding: EdgeInsets.all(12.0), //Pad message's text
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              color: dyna_color,
                            ),
                            child: Text(
                              message.text,
                              style: GoogleFonts.handjet(
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ),
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
                          style: GoogleFonts.handjet(
                            textStyle: const TextStyle(
                              fontSize: 28,
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
                                  color: Colors.black),
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

                      //Icon button, container to create its frame
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
                            onPressed: () async {
                              _send_messages();
                              await _ai_response();
                              _input_controller.clear();
                            },
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
