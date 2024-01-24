import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class PCIButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final String imgPath;
  final String score;

  const PCIButton(
      {super.key,
      required this.onPressed,
      required this.label,
      required this.score,
      required this.imgPath});

  @override
  State<PCIButton> createState() => _PCIButtonState();
}

class _PCIButtonState extends State<PCIButton> {
  final bool flag = true;

  void showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Road Picture',
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(widget.imgPath),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text('Close',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.5 * MediaQuery.of(context).size.width,
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              side: BorderSide(color: Colors.blue.shade700),
            ),
            child: Text(
              widget.score,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          const Gap(10),
          InkWell(
            onTap: () {
              showImageDialog();
            },
            child: Text(
              widget.label,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
