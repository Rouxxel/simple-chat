import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simple_chat/landing_page.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Run app

void main() async{
  //Load enviromental variable to make it available
  await dotenv.load(fileName:"envvar.env");

  runApp(
    const MaterialApp(
      home: landing_page(),
    ),
  );
}
