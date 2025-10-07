// lib/pages/edit_note_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note/models/category_model.dart';
import 'package:note/models/note_model.dart';
import 'package:note/services/database_helper.dart';
import 'package:share_plus/share_plus.dart';

class EditNotePage extends StatefulWidget {
  final Note? note;

  const EditNotePage({Key? key, this.note}) : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  List<Category> _categories = [];
  int? _selectedCategoryId;

  // Controller for the new category dialog
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategoryId = widget.note?.categoryId;
    _loadCategories();
  }
  
  @override
  void dispose() {
    _categoryController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.readAllCategories();
    setState(() {
      _categories = categories;
      // If no category is selected and we are editing a note, set it
      if (widget.note?.categoryId != null) {
        _selectedCategoryId = widget.note!.categoryId;
      }
      // If it's a new note, default to the first category if it exists
      else if (_selectedCategoryId == null && _categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }
    });
  }

  Future<void> _showAddCategoryDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2E2E48),
          title: Text('New Category', style: GoogleFonts.poppins(color: Colors.white)),
          content: TextField(
            controller: _categoryController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter category name",
              hintStyle: TextStyle(color: Colors.white54)
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                _categoryController.clear();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('CREATE', style: TextStyle(color: Colors.deepPurpleAccent)),
              onPressed: () async {
                final String categoryName = _categoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  final newCategory = Category(name: categoryName);
                  final createdCategory = await DatabaseHelper.instance.createCategory(newCategory);
                  
                  setState(() {
                    _categories.add(createdCategory);
                    _selectedCategoryId = createdCategory.id;
                  });
                  
                  _categoryController.clear();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        createdTime: widget.note?.createdTime ?? DateTime.now(),
        categoryId: _selectedCategoryId,
      );

      if (widget.note == null) {
        await DatabaseHelper.instance.createNote(note);
      } else {
        await DatabaseHelper.instance.updateNote(note);
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note != null) {
      await DatabaseHelper.instance.deleteNote(widget.note!.id!);
      Navigator.of(context).pop();
    }
  }

  void _shareNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty || content.isNotEmpty) {
      Share.share('$title\n\n$content', subject: title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note', style: GoogleFonts.poppins()),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: _shareNote),
          if (widget.note != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteNote),
          IconButton(icon: const Icon(Icons.save_outlined), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildCategoryDropdown(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title',
                  hintStyle: GoogleFonts.poppins(fontSize: 26, color: Colors.white38),
                ),
                validator: (value) => value!.trim().isEmpty ? 'The title cannot be empty.' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contentController,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.white70),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start typing your note...',
                  hintStyle: GoogleFonts.lato(fontSize: 18, color: Colors.white38),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                 validator: (value) => value!.trim().isEmpty ? 'The note content cannot be empty.' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    // We create a new list of items for the dropdown
    List<DropdownMenuItem<int>> dropdownItems = _categories.map((Category category) {
      return DropdownMenuItem<int>(
        value: category.id,
        child: Text(category.name),
      );
    }).toList();

    // Add our special "Add New" item at the end
    dropdownItems.add(
      DropdownMenuItem<int>(
        value: -1, // Use a special value to signify this action
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.deepPurpleAccent),
            const SizedBox(width: 8),
            Text('Add New Category', style: GoogleFonts.lato(color: Colors.deepPurpleAccent)),
          ],
        ),
      ),
    );

    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E48),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          isExpanded: true,
          hint: Text('Select Category', style: GoogleFonts.lato(color: Colors.white54)),
          dropdownColor: const Color(0xFF2E2E48),
          style: GoogleFonts.lato(color: Colors.white),
          onChanged: (int? newValue) {
            if (newValue == -1) {
              // If user selects "Add New", show the dialog
              _showAddCategoryDialog();
            } else {
              setState(() {
                _selectedCategoryId = newValue;
              });
            }
          },
          items: dropdownItems,
        ),
      ),
    );
  }
}