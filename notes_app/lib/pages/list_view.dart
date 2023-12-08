import 'package:flutter/material.dart';
class NotesList extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  NotesList({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: ListTile(
                title: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Note Title',
                  ),
                ),
              ),
            );
          }),
        ),
        ElevatedButton(
          onPressed: () => {},
          child: const Text('Add Note'),
        )
      ],
    );
  }
}
