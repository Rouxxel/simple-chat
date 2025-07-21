import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';

//Extract countries values
class countries {
  final String name;
  final String code;

  countries({
    required this.name, required this.code
  });

  factory countries.fromJson(Map<String, dynamic> json) {
    return countries(
      name: json['name'] ?? 'Unknown',
      code: json['code'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
    };
  }
}

//Countries file management------------------------------------
//Holds the list globally
List<countries> list_of_countries = [];

//Load countries from JSON asset
Future<void> initialize_countries() async {
  log_handler?.d("[------initialize_countries executing------]");

  try {
    final contents = await rootBundle.loadString('assets/countries_list.json');
    final List<dynamic> jsonList = jsonDecode(contents);

    list_of_countries = jsonList
        .map((countryJson) => countries.fromJson(countryJson))
        .toList();

    log_handler?.d("Countries loaded: ${list_of_countries.length}");
  } catch (e) {
    log_handler?.e("Failed to load countries: $e");
  }
}
