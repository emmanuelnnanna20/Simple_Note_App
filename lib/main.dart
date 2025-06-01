import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart'; // import your Note class

void main() {
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Note App',
      home: NoteHomePage(),
    );
  }
}

class NoteHomePage extends StatefulWidget {
  @override
  _NoteHomePageState createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  List<Note> notes = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    List<String>? jsonList = prefs.getStringList('notes');
    if (jsonList != null) {
      notes = jsonList
          .map((jsonStr) => Note.fromJson(jsonDecode(jsonStr)))
          .toList();
    } else {
      notes = [];
    }
    setState(() {});
  }

  Future<void> saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('notes', jsonList);
  }

  void addNote() {
    if (titleController.text.isNotEmpty || contentController.text.isNotEmpty) {
      setState(() {
        notes.add(Note(
          title: titleController.text,
          content: contentController.text,
        ));
        titleController.clear();
        contentController.clear();
      });
      saveNotes();
    }
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  void editNoteDialog(int index) {
    // Create controllers here with existing text
    final titleEditController = TextEditingController(text: notes[index].title);
    final contentEditController = TextEditingController(text: notes[index].content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleEditController,
                  decoration: InputDecoration(labelText: 'Note Title'),
                ),
                TextField(
                  controller: contentEditController,
                  decoration: InputDecoration(labelText: 'Note Content'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save edits and update
                setState(() {
                  notes[index].title = titleEditController.text;
                  notes[index].content = contentEditController.text;
                });
                await saveNotes();
                Navigator.of(context).pop(); // Close dialog after saving
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Note Title'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Note Content'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addNote,
              child: Text('Add Note'),
            ),
            SizedBox(height: 10),
            Expanded(
              child: notes.isEmpty
                  ? Center(child: Text('No notes yet'))
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return ListTile(
                          title: Text(note.title.isEmpty ? '(No Title)' : note.title),
                          subtitle: Text(note.content),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteNote(index),
                          ),
                          onTap: () => editNoteDialog(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
