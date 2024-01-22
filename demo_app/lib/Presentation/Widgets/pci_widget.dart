import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PCIButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final String imgPath;

  const PCIButton(
      {super.key,
      required this.onPressed,
      required this.label,
      required this.imgPath});

  @override
  State<PCIButton> createState() => _PCIButtonState();
}

class _PCIButtonState extends State<PCIButton> {
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: widget.onPressed,
          radius: 10,
          splashColor: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
        /* SizedBox(
          child: InkWell(
            onTap: (){
              flag = !flag;
              setState(() {
                
              });
            },
            child: flag
                ? const Icon(Icons.image)
                : Dialog(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 5.0, left: 5.0, right: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.asset(
                            widget.imgPath,
                            width: 0.4 * MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ), */
      ],
    );
  }
}
