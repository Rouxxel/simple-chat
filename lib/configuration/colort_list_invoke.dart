import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:simple_chat/utils/logger_config.dart';

//Globally accessible map
Map<String, String> color_name_to_hex_map = {};

//Load from JSON file dynamically
Future<void> initialize_color_name_to_hex_map() async {
  final String contents = await rootBundle.loadString('assets/color_list.json');

  final Map<String, dynamic> jsonMap = jsonDecode(contents);

  //Normalize and populate
  color_name_to_hex_map = jsonMap.map((key, value) {
    final normalizedKey = key.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
    return MapEntry(normalizedKey, value.toString());
  });

  log_handler?.d("Loaded colors: ${color_name_to_hex_map.length}");
}
