import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';

//Own project imports
import 'package:simple_chat/widgets_and_ui_elements/alert_dialog_builders.dart';
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';
import 'package:simple_chat/cache/e_key_cache.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//Encryption--------------------------------------------------
Future<String?> retrieve_e_public_key(
    BuildContext context,
    ) async {
  log_handler?.d("[------retrieve_e_public_key function executing------]");

  //Check cache first
  if (EKeyCache.e_key_cache != null && EKeyCache.e_key_cache is String) {
    log_handler?.i("Using cached E public key");
    return EKeyCache.e_key_cache;
  } else {
    log_handler?.i("Retrieving key for encryption, not yet cached");
  }

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.retrieve_public_e_key),
      headers: {"Content-Type": "application/json"},
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return null;
  } on TimeoutException {
    return null;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
    return null;
  }

  try {
    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);
        log_handler?.i("E public key successfully retrieved, 200");

        //Cache the key
        EKeyCache.e_key_cache = data['public_key'] as String?;
        log_handler?.i("E public key cached for the rest of the session");
        return data['public_key'];
      case 400:
        log_handler?.e("Invalid parameters: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return null;
      case 401:
        log_handler?.w("Unauthorized: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return null;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return null;
      case 429:
        log_handler?.e("Rate limited: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return null;
      case 500:
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return null;
    }
  } catch (er) {
    log_handler?.e("Error processing response: $er");
    return null;
  }
}

Future<String> encrypt_in(
    BuildContext context,
    dynamic message,
    ) async {
  //Retrieve public key
  final public_key_pem = await retrieve_e_public_key(context);
  if (public_key_pem!.startsWith("Unable to retrieve")) {
    throw Exception("Failed to get encryption public key");
  }

  //Convert data to string (JSON if Map/List)
  String plain_text;
  if (message is Map || message is List) {
    plain_text = jsonEncode(message);
  } else {
    plain_text = message.toString();
  }

  //Parse the PEM public key
  final public_key = parse_public_key_from_pem(public_key_pem);

  //Encrypt using RSA-OAEP with SHA-256
  final cipher = OAEPEncoding.withSHA256(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(public_key));

  final input_bytes = Uint8List.fromList(utf8.encode(plain_text));
  final encrypted_bytes = cipher.process(input_bytes);

  //Return Base64 encoded ciphertext
  return base64Encode(encrypted_bytes);
}

RSAPublicKey parse_public_key_from_pem(String pem) {
  //Remove the header and footer
  String public_key_pem = pem
      .replaceAll("-----BEGIN PUBLIC KEY-----", "")
      .replaceAll("-----END PUBLIC KEY-----", "")
      .replaceAll("\n", "");

  Uint8List public_key_DER = base64Decode(public_key_pem);

  ASN1Parser parser = ASN1Parser(public_key_DER);
  ASN1Sequence top_level_seq = parser.nextObject() as ASN1Sequence;

  ASN1BitString public_key_as_bit_string = top_level_seq.elements[1] as ASN1BitString;
  ASN1Parser public_key_parser = ASN1Parser(public_key_as_bit_string.stringValue as Uint8List);
  ASN1Sequence public_key_seq = public_key_parser.nextObject() as ASN1Sequence;

  ASN1Integer modulus = public_key_seq.elements[0] as ASN1Integer;
  ASN1Integer exponent = public_key_seq.elements[1] as ASN1Integer;

  return RSAPublicKey(
    modulus.valueAsBigInteger,
    exponent.valueAsBigInteger,
  );
}
