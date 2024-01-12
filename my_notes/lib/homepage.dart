import 'package:couter_app/notes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  TextEditingController descriptionController = TextEditingController();
  List<Notes> notesList = [];
  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 0.8 * MediaQuery.of(context).size.height,
            child: ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (kDebugMode) {
                        print('Hello World!');
                      }
                    },
                    child: ListTile(
                      title: Text(notesList[index].title),
                      subtitle: Text(notesList[index].description),
                    ),
                  );
                }),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                    shape: const BeveledRectangleBorder(),
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: titleController,
                              style: GoogleFonts.poppins(
                                color: Colors.blue,
                                fontWeight: FontWeight.normal,
                                fontSize: 10,
                              ),
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'Title',
                                hintText: 'Title Name',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10,
                                ),
                                labelStyle: GoogleFonts.raleway(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: descriptionController,
                              style: GoogleFonts.poppins(
                                color: Colors.blue,
                                fontWeight: FontWeight.normal,
                                fontSize: 10,
                              ),
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'Description',
                                hintText: 'Enter the description',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10,
                                ),
                                labelStyle: GoogleFonts.raleway(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                              onPressed: () {
                                notesList.add(Notes(
                                    title: titleController.text,
                                    description: descriptionController.text));
                                setState(() {});
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add'))
                        ],
                      );
                    });
              },
              child: const Icon(Icons.add)),
        )
      ],
    );
  }
}
