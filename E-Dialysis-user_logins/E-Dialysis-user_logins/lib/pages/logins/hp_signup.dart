import 'package:edialysis/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/button.dart';
import '../../widgets/textfield.dart';
import 'package:get/get.dart';

import 'hp_login_page.dart';
import 'hp_signup2.dart';

class HpSignupPage extends StatefulWidget {

  HpSignupPage({super.key});

  @override
  State<HpSignupPage> createState() => _HpSignupPageState();
}

class _HpSignupPageState extends State<HpSignupPage> {
  final nameController = TextEditingController();
  final licenseController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height*0.3,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Lottie.network('https://lottie.host/5c143979-3cef-4808-87cc-13ef286a331c/HGZ7pWR3b8.json')
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 30,
                          color: Color.fromRGBO(246, 82, 19, 1),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      MyTextField(
                          textEditingController: nameController,
                          myHintText: 'Hospital name',
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text
                      ),
                      const SizedBox(height: 10,),
                      MyTextField(
                          textEditingController: licenseController,
                          myHintText: 'License number',
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text
                      ),
                      const SizedBox(height: 20),

                      //sign-in button
                      MyButton(
                        text: 'Next',
                        onTap: (){Get.to(()=>HpSignup2(),transition: Transition.rightToLeft);},
                        iconVisible: true,
                      ),

                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account ? ',
                            style: TextStyle(
                                color: Colors.black,letterSpacing: 1
                            ),
                          ),
                          GestureDetector(
                            onTap: (){Get.to(()=>HpLoginPage(),transition: Transition.downToUp);},
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  color: Color.fromRGBO(246, 82, 19, 1),
                                  fontWeight: FontWeight.bold ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
