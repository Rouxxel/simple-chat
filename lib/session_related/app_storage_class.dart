import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  //Singleton instance of FlutterSecureStorage
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  //Keys
  static const String _access_token_key = 'access_token';
  static const String _refresh_token_key = 'refresh_token';
  static const String _expires_in_key = 'expires_in';
  static const String _token_type_key = 'token_type';

  //User data
  static const String _user_id_key = 'user_id';
  static const String _user_email_key = 'user_email';

  //SETTERS
  //Save token related values
  static Future<void> save_token_related(
      String access_token,
      String refresh_token,
      int expires_in,
      String token_type,
      ) async {
    await _storage.write(key: _access_token_key, value: access_token);
    await _storage.write(key: _refresh_token_key, value: refresh_token);
    await _storage.write(key: _expires_in_key, value: expires_in.toString());
    await _storage.write(key: _token_type_key, value: token_type);
  }

  //Save user related data
  static Future<void> save_user_data(
      String user_id,
      String user_email,
      ) async {
    await _storage.write(key: _user_id_key, value: user_id);
    await _storage.write(key: _user_email_key, value: user_email);
  }

  //Update token and refresh token
  //MAY NOT BE NECESSARY SINCE save_token_related() EXISTS
  static Future<void> update_token_and_refresh(
      String access_token,
      String refresh_token,
      ) async {
    await _storage.write(key: _access_token_key, value: access_token);
    await _storage.write(key: _refresh_token_key, value: refresh_token);
  }

  //GETTERS
  //Read access token
  static Future<String?> get_access_token() async {
    return await _storage.read(key: _access_token_key);
  }
  //Read refresh token
  static Future<String?> get_refresh_token() async {
    return await _storage.read(key: _refresh_token_key);
  }
  //Read expires in
  static Future<String?> get_expires_in() async {
    return await _storage.read(key: _expires_in_key);
  }
  //Read token type
  static Future<String?> get_token_type() async {
    return await _storage.read(key: _token_type_key);
  }

  //Read user id
  static Future<String?> get_user_id() async {
    return await _storage.read(key: _user_id_key);
  }
  //Read user email
  static Future<String?> get_user_email() async {
    return await _storage.read(key: _user_email_key);
  }

  //PANIC DELETER
  //Delete all tokens
  static Future<void> clear_tokens() async {
    await _storage.delete(key: _access_token_key);
    await _storage.delete(key: _refresh_token_key);
    await _storage.delete(key: _expires_in_key);
    await _storage.delete(key: _token_type_key);
    await _storage.delete(key: _user_id_key);
    await _storage.delete(key: _user_email_key);
  }
}
