import 'package:edialysis/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/button.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/textfield.dart';

class HpSignup3 extends StatefulWidget {

  HpSignup3({super.key});

  @override
  State<HpSignup3> createState() => _HpSignup3State();
}

class _HpSignup3State extends State<HpSignup3> {
  final pswdController = TextEditingController();
  final pswdConfirmController = TextEditingController();

  @override
  void dispose() {
    pswdController.dispose();
    pswdConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: (){Get.back();},
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              const Text(
                'Almost there...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color:Color.fromRGBO(246, 82, 19, 1),
                ),
              ),
              const SizedBox(height: 20,),
              MyTextField(
                textEditingController: pswdController,
                myHintText: 'Create your Password',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                isItPswd: true,
              ),
              const SizedBox(height: 10,),
              MyTextField(
                textEditingController: pswdConfirmController,
                myHintText: 'Re-enter Password',
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                isItPswd: true,
              ),
              const SizedBox(height: 20,),

              //sign-in button
              MyButton(text: 'Signup', onTap: (){Get.to(()=>HomePage(),transition: Transition.zoom);},iconVisible: true,),

            ],
          ),
        ),
      ),
    );
  }
}
