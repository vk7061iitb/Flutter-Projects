import 'dart:js_interop';

import 'package:flutter/material.dart';
import '../utils/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // In dart We make members private by using "_" before the name.

  String name = "";
  bool changeButton = false;
  final _formKey = GlobalKey<FormState>();

  moveToHome(BuildContext context) async {
    setState(() {
      changeButton = true;
    });
    await Future.delayed(
      const Duration(seconds: 1),
    );
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, MyRoutes.homeRoute);
    await Future.delayed(
      const Duration(seconds: 1),
    );
    setState(() {
      changeButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          Image.asset(
            "assets/images/6310507.jpg",
            fit: BoxFit.cover,
          ),
//
          const SizedBox(
            height: 10.0,
          ),
//
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Welcome $name",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
//
          const SizedBox(
            height: 10.0,
          ),
//
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value.isNull) {
                        "username cannot be empty";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      name = value;
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter username",
                      labelText: "username",
                    ),
                  ),
//
                  TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value!.length < 6) {
                        return "length of should be atleast 6";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter Password",
                      labelText: "password",
                    ),
                  ),
//
                  const SizedBox(
                    height: 20.0,
                  ),
//
                  Material(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(50),
//
                    child: InkWell(
                      onTap: () async {
                        moveToHome(context);
                      },
//
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: changeButton ? 50 : 150,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: changeButton
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                        ),
                        alignment: Alignment.center,
//
                        child: changeButton
                            ? const Icon(
                                Icons.done,
                                color: Colors.white,
                              )
//
                            : const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
