import 'package:flutter/material.dart';
import 'package:note/models/note_model.dart';
import 'package:note/pages/edit_note_page.dart';
import 'package:note/services/database_helper.dart';
import 'package:note/pages/notes_page.dart'; // Import for NoteCard

class NoteSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white)
      )
    );
  }
  
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: DatabaseHelper.instance.searchNotes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No notes found."));
        }

        final notes = snapshot.data!;
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return GestureDetector(
              onTap: () {
                close(context, null); // Close search
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditNotePage(note: note),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: NoteCard(note: note), // Reuse the beautiful card
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // For simplicity, we can show the same results as suggestions.
    // Or you could build a more complex suggestion logic here.
    return buildResults(context);
  }
}