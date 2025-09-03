class ChatTitlesListCache {
  static List<String>? chat_titles_list_cache;

  static void clear() {
    chat_titles_list_cache = null;
  }
}