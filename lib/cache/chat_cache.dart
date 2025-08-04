class ChatCache {
  static List<String>? chat_titles_cache;

  static void clear() {
    chat_titles_cache = null;
  }
}