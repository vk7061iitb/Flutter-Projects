import 'package:edialysis/pages/logins/hp_signup.dart';
import 'package:edialysis/pages/logins/signup.dart';
import 'package:edialysis/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoleSelection extends StatelessWidget {
  const RoleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                const Text('Let\'s get started...', style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.bold
                ),),
                const SizedBox(height: 30,),
                MyButton(text: 'I\'m a patient', onTap: (){Get.to(()=>SignupPage(),transition: Transition.fade);}, iconVisible: false,),
                const SizedBox(height: 10,),
                MyButton(text: 'I\'m a healthcare provider', onTap: (){Get.to(()=>HpSignupPage(),transition: Transition.fade);},iconVisible: false,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
