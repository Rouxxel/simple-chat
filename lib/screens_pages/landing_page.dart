import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';   //Fonts
import 'package:icons_flutter/icons_flutter.dart'; //Extra icons
import 'package:intl/intl.dart'; //For date and time formatting
import 'package:flutter_markdown/flutter_markdown.dart'; //For markdown
import 'package:simple_chat/functionality_n_scripts/session_related/refresh_tk_watch_dog.dart';

import 'package:simple_chat/functionality_n_scripts/standalone_methods/general_methods.dart';
import 'package:simple_chat/functionality_n_scripts/message_related/message_class.dart';
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/functionality_n_scripts/standalone_methods/session_methods.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';

//Other screens
import 'package:simple_chat/screens_pages/settings_page.dart';
import 'package:simple_chat/screens_pages/chats_page.dart';
import 'package:simple_chat/screens_pages/chats_page.dart';
import 'package:simple_chat/widgets_and_ui_elements/alert_dialog_builders.dart';
import 'package:simple_chat/screens_pages/log_in_page.dart';
import 'package:simple_chat/cache/chat_cache.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//screen itself
class landing_page extends StatefulWidget {
  const landing_page({super.key});

  @override
  State<landing_page> createState() => _landing_pageState();
}

class _landing_pageState extends State<landing_page> {
  //Create a TextEditingController for the input box and get user input
  final TextEditingController _input_controller = TextEditingController();

  //List to store chat messages, both user and AI that will be displayed in UI
  List<Message> _message_list = [];

  //Boolean controller for send button and input controller hint text hiding
  bool _is_processing = false;
  bool _first_query_done = false;

  //Flag for updating or saving current chat
  String? current_saved_chat_title;  //null by default

  //Add the personality of the AI
  @override
  void initState() {
    super.initState();
    _load_system_prompt();
  }

  //Load AI personality and add it to message list so AI has context
  String system_prompt = "";
  void _load_system_prompt() {
    setState(() {
      system_prompt = "${config_data.directive}. "
          "Verbose level: ${config_data.verbose}. "
          "Response limit: ${config_data.response_length_limit} tokens. "
          "Tolerance response limit: ${config_data.response_length_tolerance} extra tokens. "
          "Default language: ${config_data.user_language} but match prompt language.";

      //Add AI personality as first message
      if (_message_list.isEmpty) {
        _message_list.add(Message(system_prompt, false));
      } else {
        _message_list[_message_list.length - 1] = Message(system_prompt, false);
      }
    });

    int last_index = _message_list.length - 1;
    log_handler?.i("Loaded/saved directory: ${_message_list[last_index].text}");
    log_handler?.i(
        "Loaded messages (Bottom up):\n\n${_message_list.map((m) =>
            "${m.is_user}: ${m.text.replaceAll('\n', ' ')} | ${m.time_stamp}"
            ).join('\n')}"
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //Background color
        backgroundColor: config_data.background_color,

        //Top App bar
        appBar: AppBar(
          backgroundColor: config_data.app_bar_color,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Title column
              GestureDetector(
                onTap: _is_processing
                ? null  //disables the button when true
                : () async {
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

                  final selected = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      position.dx+30,
                      position.dy+75,
                      overlay.size.width - (position.dx + 30),
                      overlay.size.height - (position.dy + 75),
                    ),
                    items: [
                      PopupMenuItem<String>(
                        value: 'save_new_chat',
                        child: Text(
                          'Save current chat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: config_data.text_color,
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'saved_old_chats',
                        child: Text(
                          'See past chats',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: config_data.text_color,
                          ),
                        ),
                      ),
                    ],
                  );

                  if (selected == 'save_new_chat') {
                    log_handler?.d("Selected choice: $selected");
                    setState(() => _is_processing = true); //Start processing

                    //Ensure chat has been initiated
                    if(_message_list.length <= 1){
                      log_handler?.w("Chat list 'empty', only main directory present ${_message_list.length}");
                      await build_informative_alert_dialog(
                          context,
                          "Ok",
                          "Empty chat",
                          "Please initiate a conversation or banter before saving, try with 'Hello'"
                      );
                      setState(() => _is_processing = false); //End processing early
                      return;
                    }

                    //Handle already saved chat, Update existing chat
                    if (current_saved_chat_title?.isNotEmpty == true) {
                      final bool? user_decision = await build_yes_no_alert_dialog(
                          context,
                          "Confirm",
                          "Cancel",
                          "Update current saved chat",
                          "Do you wish to save your current progress in the chat '${current_saved_chat_title}'"
                      );

                      if (user_decision == true) {
                        await save_current_chat(
                          context,
                          chat_title: current_saved_chat_title!,
                          chat_list: _message_list,
                        );

                        //Reload the cached saved chat
                        final result = await retrieve_all_user_chats(context);

                        if(result.containsKey("chat_titles")){
                          final titles = List<String>.from(result["chat_titles"]);

                          ChatCache.chat_titles_cache = titles;
                          log_handler?.d("Chat cache updated");
                        }
                      } else {
                        log_handler?.i("Chat saving was cancelled by the user.");
                      }

                      setState(() => _is_processing = false);
                      return;
                    }

                    //Handle new chat since it is not a pre-saved chat
                    final user_inputs = await build_dynamic_input_dialog(
                      context,
                      title: "Save chat",
                      description: "Please provide a title for the current chat to save.",
                      yes_button_text: "Confirm",
                      no_button_text: "Cancel",
                      labels: ["Chat title"],
                      input_types: [TextInputType.text],
                      obscure_text: [false],
                    );

                    if (user_inputs != null) {
                      //Save new chat
                      final chat_title = user_inputs["Chat title"]!;
                      await save_current_chat(
                        context,
                        chat_title: chat_title,
                        chat_list: _message_list,
                      );
                      //Update flag
                      current_saved_chat_title = chat_title;
                    } else {
                      //User cancelled
                      log_handler?.i("Chat saving was cancelled by the user.");
                    }

                    setState(() => _is_processing = false);
                    return;
                  }

                  if (selected == 'saved_old_chats') {
                    log_handler?.d("Selected choice: $selected");
                    //Navigate to settings page with fade transition
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const chats_list(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  }
                },

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Prevents the AppBar from expanding too much
                  children: [
                    Text(
                      "- ${config_data.main_title} -",
                      style: GoogleFonts.bebasNeue(
                        textStyle: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          color: config_data.text_color,
                        ),
                      ),
                    ),
                    Text(
                      "Google Gemini 2.0 Flash API powered",
                      style: TextStyle(
                        fontSize: 9,
                        color: config_data.text_color,
                      ),
                    ),
                  ],
                ),
              ),
              Row(

                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    iconSize: 35,
                    color: Colors.black,
                    onPressed: _is_processing
                        ? null  //disable during processing
                        : () async {

                      //play the button sound
                      await play_effect_sound(config_data.button_pressed_effect);

                      //Navigate to settings page with fade transition
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const settings(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                      //Run after returning from the settings screen
                      _load_system_prompt();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    iconSize: 35,
                    color: Colors.black,
                    onPressed: _is_processing
                        ? null  //disable during processing
                        : () async {

                      //play the button sound
                      await play_effect_sound(config_data.button_pressed_effect);

                      bool? user_decision = await build_yes_no_alert_dialog(
                        context,
                        "Confirm",
                        "Cancel",
                        "Log out of app",
                        "Do you wish to log out of the current session?, any unsaved"
                            "conversations will be lost",
                      );
                      if (user_decision == true){
                        setState(() {_is_processing = true;});

                        await log_out(context);
                        //Stop watch dog for token refresh
                        TokenWatchdog().stop();
                        log_handler?.i("User logged out. Returning to log in page");

                        ChatCache.clear(); //Nullify chat cache

                        setState(() {_is_processing = false;});

                        //Navigate to login page with fade transition
                        await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const log_in_page(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      } else {
                        //User cancelled or dismissed the dialog
                        log_handler?.i("Logout cancelled by user");
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),

        //Main content
        body: Stack(
          children: [
            //Background image
            MediaQuery.removeViewInsets(
              removeBottom: true,
              context: context,
              child: Image.asset(
                config_data.background_image_path,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: config_data.background_color,  // fallback color or widget
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  );
                },
              ),
            ),

            //Actual content
            Padding(
              padding:
                  const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //List of displayed user and AI messages
                  Expanded(

                    //"Message" generator with a builder
                    child: ListView.builder(
                      reverse: true, //Start at the bottom
                      itemCount: _message_list.length -1,
                      //Message blueprint
                      itemBuilder: (context, index) {
                        //Declare message with list that has class
                        final message = _message_list[index];

                        //Declare dynamic color
                        Color dyna_color= message.is_user?
                          config_data.user_text_box_color:
                          config_data.ai_text_box_color;
                        //Declare dynamic Edge Insets
                        EdgeInsets dyna_padding= message.is_user?
                          const EdgeInsets.fromLTRB(50, 4, 0, 4):
                          const EdgeInsets.fromLTRB(0, 4, 50, 4);

                        return Padding(
                          padding: dyna_padding, //Pad messages
                          child: Column(
                              crossAxisAlignment: message.is_user ?
                                CrossAxisAlignment.end :
                                CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                              //Container for each message
                              Container(
                                padding: const EdgeInsets.all(12.0), //Pad message's text in container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.0),
                                  color: dyna_color,
                                ),
                                //Inner column for message/timestamp
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Actual message text
                                    MarkdownBody(
                                      data: message.text,
                                      styleSheet: MarkdownStyleSheet(
                                        p: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black
                                          ),
                                        ),
                                        em: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black,
                                          ),
                                        ),
                                        strong: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        del: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        code: GoogleFonts.robotoMono(
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            backgroundColor: Color(0xFFEFEFEF),
                                          ),
                                        ),
                                        blockquote: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        h1: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        h2: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),

                                        //Add more header styles in this level
                                      ),
                                    ),

                                    //Timestamp of message
                                    Text(
                                      //Format the timestamp as '12:30pm, 23/09/2024'
                                      DateFormat('hh:mma, dd/MM/yyyy').format(message.time_stamp).toLowerCase(),
                                      style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic,
                                          color: config_data.date_text_color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  //Input field and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Input field
                      Expanded(
                        child: TextField(
                          controller: _input_controller,
                          readOnly: _is_processing,
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 18,               // match markdown paragraph font size
                              fontWeight: FontWeight.normal,  // normal weight like markdown p
                              fontStyle: FontStyle.normal, // normal style (not italic by default)
                              color: _is_processing ? Colors.transparent : config_data.text_color,
                            ),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: config_data.user_text_box_color,
                            hintText: _is_processing ? '' : (_first_query_done ? "" : "Say hello..."),
                            hintStyle: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal,
                                color: config_data.suggest_input_color,
                              ),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),

                      SizedBox(
                        width: 5,
                      ),

                      //Send Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: config_data.user_text_box_color,
                          border: Border.all(
                              color: config_data.user_text_box_color,
                              width: 2.0
                          ),
                        ),
                        height: 62,
                        width: 62,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(MaterialIcons.send),
                            alignment: Alignment.center,
                            iconSize: 40,
                            color: Colors.black,
                            onPressed: _is_processing
                                ? null //Disable button while processing
                                : () async {
                              //Get user input
                              final userInput = _input_controller.text;

                              //Validate user input
                              if (validate_user_input(context, userInput) &&
                                  userInput.isNotEmpty) {

                                //play sound effect
                                await play_effect_sound(config_data.button_pressed_effect);

                                setState(() => _is_processing = true); //Start processing

                                //Instantiate new message and add it to message_list
                                Message message = Message(userInput, true);
                                message.send_messages(_input_controller, _message_list, setState);

                                await message.ai_query_and_response(
                                  context,
                                  _input_controller,
                                  _message_list,
                                  setState,
                                );

                                //Update accordingly
                                _input_controller.clear();
                                setState(() {
                                  _first_query_done = true;
                                  _is_processing = false;
                                });//End processing
                              } else {
                                log_handler?.w("Message not sent due to invalid input.");
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
