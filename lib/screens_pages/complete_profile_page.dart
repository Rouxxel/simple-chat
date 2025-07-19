import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';   //Fonts
import 'package:intl/intl.dart';
import 'package:simple_chat/configuration/countries_invoke.dart';

import 'package:simple_chat/standalone_methods_functions/general_methods.dart';
import 'package:simple_chat/standalone_methods_functions/user_entrypoint_methods.dart';
import 'package:simple_chat/configuration/config_invoke.dart';
import 'package:simple_chat/screens_pages/landing_page.dart';
import 'package:simple_chat/utils/widgets_and_ui_elements/alert_dialog_list.dart';
import 'package:simple_chat/utils/logger_config.dart';
import 'package:simple_chat/session_related/app_storage_class.dart';
import 'package:simple_chat/utils/widgets_and_ui_elements/labeled_text_field.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//screen itself
class complete_profile extends StatefulWidget {
  const complete_profile({super.key});

  @override
  State<complete_profile> createState() => _complete_profileState();
}

class _complete_profileState extends State<complete_profile> {

  //Add input controllers
  final TextEditingController _first_name_controller = TextEditingController();
  final TextEditingController _last_name_controller = TextEditingController();
  final TextEditingController _user_name_controller = TextEditingController();
  final TextEditingController _date_birth_controller = TextEditingController();
  final TextEditingController _phone_number_controller = TextEditingController();
  final TextEditingController _country_controller = TextEditingController();
  final TextEditingController _country_code_controller = TextEditingController();

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
            Image.asset(
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

            //Actual content
            ListView(
              children: [
                Padding(
                  //
                  padding: EdgeInsets.symmetric(vertical: 35, horizontal: 35),
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
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Title of card
                            Text(
                              "Complete Profile",
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
                              padding: EdgeInsets.fromLTRB(16, 0, 0, 20),
                              child: Container(
                                child: Column(
                                  children: [
                                    LabeledTextField(
                                      label: "First name",
                                      controller: _first_name_controller,
                                      hint_text: "John",
                                      text_color: config_data.text_color,
                                      fill_color: config_data.user_text_box_color,
                                      hint_color: config_data.suggest_input_color,
                                      enabled: !_is_processing,
                                    ),
                                    SizedBox(height: 10),
                                    LabeledTextField(
                                      label: "Last name",
                                      controller: _last_name_controller,
                                      hint_text: "Doe",
                                      text_color: config_data.text_color,
                                      fill_color: config_data.user_text_box_color,
                                      hint_color: config_data.suggest_input_color,
                                      enabled: !_is_processing,
                                    ),
                                    SizedBox(height: 10),
                                    LabeledTextField(
                                      label: "User name",
                                      controller: _user_name_controller,
                                      hint_text: "JohnDoe86",
                                      text_color: config_data.text_color,
                                      fill_color: config_data.user_text_box_color,
                                      hint_color: config_data.suggest_input_color,
                                      enabled: !_is_processing,
                                    ),
                                    SizedBox(height: 10),
                                    LabeledTextField(
                                      label: "Date of birth",
                                      controller: _date_birth_controller,
                                      hint_text: "Select your birth date",
                                      text_color: config_data.text_color,
                                      fill_color: config_data.user_text_box_color,
                                      hint_color: config_data.suggest_input_color,
                                      enabled: !_is_processing,
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(2000),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                        );
                                        if (pickedDate != null) {
                                          _date_birth_controller.text = DateFormat("dd/MM/yyyy").format(pickedDate);
                                        }
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    LabeledTextField(
                                      label: "Phone Number",
                                      controller: _phone_number_controller,
                                      hint_text: "+12 345 567891",
                                      text_color: config_data.text_color,
                                      fill_color: config_data.user_text_box_color,
                                      hint_color: config_data.suggest_input_color,
                                      enabled: !_is_processing,
                                    ),
                                    SizedBox(height: 10),
                                    LabeledTextField(
                                      label: "Country",
                                      controller: _country_controller,
                                      hint_text: "Select your country",
                                      text_color: config_data.text_color,
                                      fill_color: config_data.user_text_box_color,
                                      hint_color: config_data.suggest_input_color,
                                      enabled: !_is_processing,
                                      readOnly: true,
                                      onTap: () async {
                                        final selected_country = await showModalBottomSheet<countries>(
                                          context: context,
                                          builder: (context) {
                                            return ListView.builder(
                                              itemCount: list_of_countries.length,
                                              itemBuilder: (context, index) {
                                                final country = list_of_countries[index];
                                                return ListTile(
                                                  title: Text("${country.name} (${country.code})"),
                                                  onTap: () {
                                                    Navigator.pop(context, country);
                                                  },
                                                );
                                              },
                                            );//
                                          },
                                        );

                                        if (selected_country != null) {
                                          _country_controller.text = selected_country.name;
                                          _country_code_controller.text = selected_country.code;
                                        }
                                      },
                                    ),

                                  ],
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: _is_processing
                                  ? null //Disable button while processing
                                  : () async {
                                //Get user input
                                final String first_name = _first_name_controller.text;
                                final String last_name = _last_name_controller.text;
                                final String user_name = _user_name_controller.text;
                                final String date_birth = date_formatter(context, _date_birth_controller.text);
                                final String phone_num = _phone_number_controller.text;
                                final String country = _country_controller.text;
                                final String country_code = _country_code_controller.text;

                                //Get session data
                                final String? email = await AppStorage.get_user_email();
                                final String? token = await AppStorage.get_access_token();

                                //play sound effect
                                await play_effect_sound(config_data.button_pressed_effect);

                                //Validate user inputs
                                if (!validate_user_input(context, first_name) ||
                                    !validate_user_input(context, last_name) ||
                                    !validate_user_input(context, user_name) ||
                                    !validate_user_input(context, date_birth) ||
                                    !validate_user_input(context, phone_num) ||
                                    !validate_user_input(context, country) ||
                                    !validate_user_input(context, country_code)
                                ) {
                                  log_handler?.w("Input not sent due to suspicious input by user.");
                                  setState(() {_is_processing = false;});
                                  return;
                                }

                                //Validate phone number
                                if (!is_valid_phone_number(context, phone_num)) {
                                  show_invalid_phone_number_error(context);
                                  setState(() {_is_processing = false;});
                                  return;
                                }

                                //Start sign up request
                                setState(() => _is_processing = true);

                                //Make call to complete profile
                                final bool answer = await complete_user_profile(context,
                                    access_token: token.toString(),
                                    email: email.toString(),
                                    user_name: user_name,
                                    first_name: first_name,
                                    last_name: last_name,
                                    phone_number: phone_num,
                                    date_birth: date_birth,
                                    country: country,
                                    country_code: country_code);
                                //Clear only if answer is successful
                                if (answer){
                                  //Update accordingly
                                  _first_name_controller.clear();
                                  _last_name_controller.clear();
                                  _user_name_controller.clear();
                                  _date_birth_controller.clear();
                                  _phone_number_controller.clear();
                                  _country_controller.clear();

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
                                    _is_processing ? "Processing..." : "Complete profile",
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
