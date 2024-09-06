import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_flutter/icons_flutter.dart'; //Extra icons

//imports
/////////////////////////////////////////////////////////////////////////////
//global variables

//global variables
/////////////////////////////////////////////////////////////////////////////
//screen itself
class landing_page extends StatelessWidget {
  const landing_page({super.key});

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
      ),
    );
  }
}
