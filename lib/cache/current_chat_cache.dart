import 'package:simple_chat/functionality_n_scripts/message_related/message_class.dart';

class CurrentChatCache {
  //Stores the ongoing chat messages (user + AI)
  static List<Message> message_list = [];

  //Title of the currently saved chat (null if unsaved/new)
  static String? current_saved_chat_title;

  //Clears the current chat session cache
  static void clear() {
    message_list.clear();
    current_saved_chat_title = null;
  }

  //Check if any messages exist
  static bool get has_messages => message_list.isNotEmpty;
}
