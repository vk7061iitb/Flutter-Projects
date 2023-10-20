import 'package:edialysis/pages/home_page.dart';
import 'package:edialysis/widgets/button.dart';
import 'package:edialysis/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class HpLoginPage extends StatefulWidget {

  HpLoginPage({super.key});

  @override
  State<HpLoginPage> createState() => _HpLoginPageState();
}

class _HpLoginPageState extends State<HpLoginPage> {
  final emailController = TextEditingController();
  final pswdController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pswdController.dispose();
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
                  padding: const EdgeInsets.fromLTRB(18.0,0,18.0,18.0),
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 30,
                          color: Color.fromRGBO(246, 82, 19, 1),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      MyTextField(
                          textEditingController: emailController,
                          myHintText: 'Email id',
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress
                      ),
                      const SizedBox(height: 20),
                      MyTextField(
                        textEditingController: pswdController,
                        myHintText: 'Password',
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        isItPswd: true,
                      ),
                      const SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: (){},
                            child: const Text(
                              'Forgot Password?  ',
                              style: TextStyle(
                                  color: Color.fromRGBO(246, 82, 19, 1),
                                  fontWeight: FontWeight.bold ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),

                      //sign-in button
                      MyButton(text: 'Login', onTap: (){Get.to(()=>HomePage(),transition: Transition.zoom);},iconVisible: false,),

                      //register now button
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New User? ',
                            style: TextStyle(
                                color: Colors.black,letterSpacing: 1
                            ),
                          ),
                          GestureDetector(
                            onTap: (){Get.back();},
                            child: const Text(
                              'Create Account',
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
