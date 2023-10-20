import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool iconVisible;
  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.iconVisible
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Color.fromRGBO(246, 82, 19, 1),
        ),
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 1
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
              Visibility(
                visible: iconVisible,
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white, weight: 2,
                    size: 20,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
