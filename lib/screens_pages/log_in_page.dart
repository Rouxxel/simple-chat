import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';   //Fonts

import 'package:simple_chat/functionality_n_scripts/standalone_methods/general_methods.dart';
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/screens_pages/landing_page.dart';
import 'package:simple_chat/screens_pages/complete_profile_page.dart';
import 'package:simple_chat/functionality_n_scripts/session_related/app_storage_class.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';
import 'package:simple_chat/screens_pages/sign_up_page.dart';

import 'package:simple_chat/functionality_n_scripts/session_related/refresh_tk_watch_dog.dart';
import 'package:simple_chat/functionality_n_scripts/standalone_methods/user_entrypoint_methods.dart';
import 'package:simple_chat/widgets_and_ui_elements/labeled_text_field.dart';
import 'package:simple_chat/functionality_n_scripts/standalone_methods/session_methods.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//screen itself
class log_in_page extends StatefulWidget {
  const log_in_page({super.key});

  @override
  State<log_in_page> createState() => _log_in_pageState();
}

class _log_in_pageState extends State<log_in_page> {

  //Add input controllers
  final TextEditingController _log_in_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  //Boolean controller for send button and input controller hint text hiding
  bool _is_processing = false;

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Title column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
              ),
            ],
          ),
        ),

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
            ListView(
              children: [
                Padding(
                  //
                  padding: const EdgeInsets.symmetric(vertical: 170, horizontal: 35),
                  child: Center(
                    //
                    child: Container(
                      decoration: BoxDecoration(
                        color: config_data.ai_text_box_color, // Background color
                        borderRadius:
                        BorderRadius.circular(12), // Smooth (rounded) edges
                        border: Border.all(
                            color: config_data.user_text_box_color, width: 2.0),
                      ),

                      //
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Title of card
                            Text(
                              "Log to app",
                              style: GoogleFonts.bebasNeue(
                                textStyle: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal,
                                  color: config_data.text_color,
                                ),
                              ),
                            ),

                            //Inputs of card
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 0, 20),
                              child: Column(
                                children: [
                                  LabeledTextField(
                                    label: "Email",
                                    controller: _log_in_controller,
                                    hint_text: "example@provider.com",
                                    text_color: config_data.text_color,
                                    fill_color: config_data.user_text_box_color,
                                    hint_color: config_data.suggest_input_color,
                                    enabled: !_is_processing,
                                  ),
                                  const SizedBox(height: 10),
                                  LabeledTextField(
                                    label: "Password",
                                    controller: _password_controller,
                                    hint_text: "0Kzj#{[8ss9,",
                                    text_color: config_data.text_color,
                                    fill_color: config_data.user_text_box_color,
                                    hint_color: config_data.suggest_input_color,
                                    enabled: !_is_processing,
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                //Button of card
                                GestureDetector(
                                  onTap: _is_processing
                                      ? null //Disable button while processing
                                      : () async {
                                    //Get user input
                                    final String email = _log_in_controller.text;
                                    final String password = _password_controller.text;

                                    //play sound effect
                                    await play_effect_sound(config_data.button_pressed_effect);

                                    //Validate user inputs
                                    if (!validate_user_input(context, email) ||
                                        !validate_user_input(context, password)) {
                                      log_handler?.w("Input not sent due to suspicious input by user.");
                                      return;
                                    }

                                    //Start Log in request
                                    setState(() => _is_processing = true);

                                    //Make call to log in
                                    final response = await log_in(context, email, password);
                                    //Clear only if log in is successful
                                    if (response) {
                                      _log_in_controller.clear();
                                      _password_controller.clear();

                                      //Start timer for token refresh watch dog
                                      TokenWatchdog().start(context);

                                      //Check user exists
                                      final bool user_exists = await check_user_exists(context);

                                      if (user_exists){
                                        log_handler?.i("User profile complete, move to landing page");
                                        await Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                            const landing_page(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      } else{
                                        log_handler?.i("User profile incomplete, move to complete profile page");
                                        await Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                            const complete_profile(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    }
                                    setState(() => _is_processing = false);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: config_data.background_color,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.black, //Outline color
                                        width: 2.0,          //Outline thickness
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _is_processing ? "Logging in..." : "Log in",
                                        style: GoogleFonts.bebasNeue(
                                          textStyle: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FontStyle.normal,
                                            color: config_data.text_color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Spacing between button and link
                                const SizedBox(height: 15),

                                //Hyperlink text
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 16.0), // Base style
                                    children: [
                                      const TextSpan(
                                        text: "I have no account, ",
                                        style: TextStyle(color: Colors.black), // Normal text
                                      ),
                                      TextSpan(
                                        text: "Sign up!!!",
                                        style: TextStyle(
                                          color: !_is_processing ? Colors.blue : config_data.text_color,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: !_is_processing
                                            ? (TapGestureRecognizer()
                                          ..onTap = () async {
                                            log_handler?.d("Navigate to sign-up page");
                                            await Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) =>
                                                const sign_up_page(),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          })
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),

                                // Spacing between button and link
                                const SizedBox(height: 12),

                                //Forgot password
                                GestureDetector(
                                  onTap: _is_processing
                                      ? null                           // Disable while processing
                                      : () async {
                                    log_handler?.d("Navigate to forgot password page");
                                    await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                        const sign_up_page(), //Change to forgotpassword when done
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "I forgot my password",
                                    style: TextStyle(
                                      color: !_is_processing? Colors.blue : config_data.text_color,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
