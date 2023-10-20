import 'package:edialysis/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/button.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/textfield.dart';

class Signup2 extends StatefulWidget {
  Signup2({super.key});

  @override
  State<Signup2> createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {
  final pswdController = TextEditingController();
  final pswdConfirmController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
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
                'Create Account',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  color:Color.fromRGBO(246, 82, 19, 1),
                ),
              ),
              const SizedBox(height: 20,),
              MyTextField(
                textEditingController: pswdController,
                myHintText: 'Create your Password',
                textInputAction: TextInputAction.done,
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
              MyButton(text: 'Signup', onTap: (){Get.to(()=>HomePage(),transition: Transition.zoom);}, iconVisible: true,),

            ],
          ),
        ),
      ),
    );
  }
}
