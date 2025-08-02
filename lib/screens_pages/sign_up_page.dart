import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';   //Fonts

import 'package:simple_chat/functionality_n_scripts/standalone_methods/general_methods.dart';
import 'package:simple_chat/functionality_n_scripts/standalone_methods/user_entrypoint_methods.dart';
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/widgets_and_ui_elements/alert_dialog_builders.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';
import 'package:simple_chat/screens_pages/log_in_page.dart';
import 'package:simple_chat/widgets_and_ui_elements/labeled_text_field.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//screen itself
class sign_up_page extends StatefulWidget {
  const sign_up_page({super.key});

  @override
  State<sign_up_page> createState() => _sign_up_pageState();
}

class _sign_up_pageState extends State<sign_up_page> {

  //Add input controllers
  final TextEditingController _sign_in_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();
  final TextEditingController _confirm_password_controller = TextEditingController();

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
                              "Sign to app",
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
                                    controller: _sign_in_controller,
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
                                  const SizedBox(height: 10),
                                  LabeledTextField(
                                    label: "Confirm password",
                                    controller: _confirm_password_controller,
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
                                    final String email = _sign_in_controller.text;
                                    final String password = _password_controller.text;
                                    final String confirm_password = _confirm_password_controller.text;

                                    //play sound effect
                                    await play_effect_sound(config_data.button_pressed_effect);

                                    //Validate user inputs
                                    if (!validate_user_input(context, email) ||
                                        !validate_user_input(context, password) ||
                                        !validate_user_input(context, confirm_password)) {
                                      log_handler?.w("Input not sent due to suspicious input by user.");
                                      setState(() {_is_processing = false;});
                                      return;
                                    }

                                    //Ensure passwords match
                                    if(password != confirm_password){
                                      log_handler?.w("Password and password confirm are not the same");
                                      await build_informative_alert_dialog(
                                        context,
                                        "Ok",
                                        "Passwords don't match",
                                        "The passwords you provided do not match, please ensure they both"
                                            "match before continuing",
                                      );
                                      setState(() {_is_processing = false;});
                                      return;
                                    }

                                    //Start sign up request
                                    setState(() => _is_processing = true);

                                    //Make call to sign up
                                    final bool answer = await sign_up(context, email, password);
                                    //Clear only if answer is successful
                                    if (answer){
                                      //Update accordingly
                                      _sign_in_controller.clear();
                                      _password_controller.clear();
                                      _confirm_password_controller.clear();

                                      //Navigate to log in page
                                      await Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                          const log_in_page(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    setState(() {_is_processing = false;});
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
                                        _is_processing ? "Signing up..." : "Sign up",
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
                                const SizedBox(height: 12),

                                //Hyperlink text
                                GestureDetector(
                                  onTap: _is_processing
                                      ? null                           // Disable while processing
                                      : () async {
                                    log_handler?.d("Navigate to log-in page");

                                    await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                        const log_in_page(),
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
                                    "I remembered I have a user!!!",
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
