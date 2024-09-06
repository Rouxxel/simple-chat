
import "package:flutter_dotenv/flutter_dotenv.dart";                   //env var
import "package:icons_flutter/icons_flutter.dart" as extra_icons;      //extra icons
import "package:http/http.dart" as http_rsc;                           //http resources
import "package:url_launcher/url_launcher.dart";                       //url launcher
import "package:intl/intl.dart" as interdates;                         //date-time formatting/parsing

//imports
/////////////////////////////////////////////////////////////////////////////
//Enviromental

//To retrieve the apikey from .env file
String Obtain_API_key() {
  String? AI_API_key = dotenv.env['ai_api_key'];
  if (AI_API_key == null) {
    throw Exception('API key not found');
  }

  print("---API key succesfully found---");
  //Return the API key
  return AI_API_key;
}