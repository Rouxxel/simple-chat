class UserPreferencesCache {
  static Map<String, dynamic>? user_preferences_cache;

  static void clear() {
    user_preferences_cache = null;
  }
}