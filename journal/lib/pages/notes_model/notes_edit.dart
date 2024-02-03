// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:journal/theme/colors.dart';

import 'package:share/share.dart';

import 'note.dart';
import 'note_database.dart';

const c1 = 0xFFFDFFFC,
    c2 = 0xFFFF595E,
    c3 = 0xFF374B4A,
    c4 = 0xFF00B1CC,
    c5 = 0xFFFFD65C,
    c6 = 0xFFB9CACA,
    c7 = 0x80374B4A;

class NotesEdit extends StatefulWidget {
  final args;
  const NotesEdit(this.args, {super.key});

  @override
  State<NotesEdit> createState() => _NotesEditState();
}

class _NotesEditState extends State<NotesEdit> {
  String noteTitle = '';
  String noteContent = '';
  String noteColor = 'red';

  static final TextEditingController _titleTextController =
      TextEditingController();
  static final TextEditingController _contentTextController =
      TextEditingController();

  void onSelectAppBarPopupMenuItem(
      BuildContext currentContext, String optionName) {
    switch (optionName) {
      case 'Share':
        handleNoteShare();
        break;
      case 'Delete':
        handleNoteDelete();
        break;
    }
  }

  void handleNoteShare() async {
    await Share.share(noteContent, subject: noteTitle);
  }

  void handleNoteDelete() async {
    if (widget.args[0] == 'update') {
      try {
        NotesDatabase notesDb = NotesDatabase();
        await notesDb.initDatabase();
        int result = await notesDb.deleteNote(widget.args[1]['id']);
        await notesDb.closeDatabase();
      } finally {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
      return;
    }
  }

  void handleTitleTextChange() {
    if (mounted) {
      setState(() {
        noteTitle = _titleTextController.text.trim();
      });
    }
  }

  void handleNoteTextChange() {
    if (mounted) {
      setState(() {
        noteContent = _contentTextController.text.trim();
      });
    }
  }

  Future<void> _insertNote(Note note) async {
    NotesDatabase notesDb = NotesDatabase();
    await notesDb.initDatabase();
    int result = await notesDb.insertNote(note);
    await notesDb.closeDatabase();
  }

  Future<void> _updateNote(Note note) async {
    NotesDatabase notesDb = NotesDatabase();
    await notesDb.initDatabase();
    int result = await notesDb.updateNote(note);
    await notesDb.closeDatabase();
  }

  void handleBackButton() async {
    if (noteTitle.isEmpty) {
      // Go Back without saving
      if (noteContent.isEmpty) {
        Navigator.pop(context);
        return;
      } else {
        String title = noteContent.split('\n')[0];
        if (title.length > 31) {
          title = title.substring(0, 31);
        }
        if (mounted) {
          setState(() {
            noteTitle = title;
          });
        }
      }
    }
    // Save New note
    if (widget.args[0] == 'new') {
      Note noteObj =
          Note(title: noteTitle, content: noteContent, noteColor: noteColor);
      try {
        await _insertNote(noteObj);
      } finally {
        Navigator.pop(context);
      }
    }
    // Update Note
    else if (widget.args[0] == 'update') {
      Note noteObj = Note(
          id: widget.args[1]['id'],
          title: noteTitle,
          content: noteContent,
          noteColor: noteColor);
      try {
        await _updateNote(noteObj);
      } finally {
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    noteTitle = (widget.args[0] == 'new' ? '' : widget.args[1]['title']);
    noteContent = (widget.args[0] == 'new' ? '' : widget.args[1]['content']);
    noteColor = (widget.args[0] == 'new' ? 'red' : widget.args[1]['noteColor']);

    _titleTextController.text =
        (widget.args[0] == 'new' ? '' : widget.args[1]['title']);
    _contentTextController.text =
        (widget.args[0] == 'new' ? '' : widget.args[1]['content']);
    _titleTextController.addListener(handleTitleTextChange);
    _contentTextController.addListener(handleNoteTextChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        handleBackButton();
        return true;
      },
      child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: secondary,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: buttoncolor,
            ),
            tooltip: 'Back',
            onPressed: () => handleBackButton(),
          ),

          title: NoteTitleEntry(_titleTextController),

          // actions
          actions: [
            appBarPopMenu(
              parentContext: context,
              onSelectPopupmenuItem: onSelectAppBarPopupMenuItem,
            ),
          ],
        ),
        body: NoteEntry(_contentTextController),
      ),
    );
  }
}

class NoteTitleEntry extends StatefulWidget {
  final _textFieldController;

  const NoteTitleEntry(this._textFieldController);

  @override
  State<NoteTitleEntry> createState() => _NoteTitleEntryState();
}

class _NoteTitleEntryState extends State<NoteTitleEntry> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget._textFieldController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.all(0),
        counter: null,
        counterText: "",
        hintText: 'Title',
        hintStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
      maxLength: 31,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        height: 1.5,
        color: mainFontColor,
      ),
      textCapitalization: TextCapitalization.words,
    );
  }
}

class NoteEntry extends StatefulWidget {
  final _textFieldController;
  // ignore: use_key_in_widget_constructors
  const NoteEntry(this._textFieldController);

  @override
  State<NoteEntry> createState() => _NoteEntryState();
}

class _NoteEntryState extends State<NoteEntry> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextField(
          controller: widget._textFieldController,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: null,
          style: const TextStyle(
            fontSize: 19,
            height: 1.5,
          ),
        ));
  }
}

// A PopUp Widget shows different colors

// More Menu to display various options like Color, Sort, Share...
// ignore: camel_case_types
class appBarPopMenu extends StatelessWidget {
  final popupMenuButtonItems = {
    1: const {'name': 'Share', 'icon': Icons.share},
    2: const {'name': 'Delete', 'icon': Icons.delete},
  };
  final parentContext;
  final void Function(BuildContext, String) onSelectPopupmenuItem;

  appBarPopMenu({
    required this.parentContext,
    required this.onSelectPopupmenuItem,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert,
        color: const Color(c1),
      ),
      color: Color(c1),
      itemBuilder: (context) {
        var list = popupMenuButtonItems.entries.map((entry) {
          return PopupMenuItem(
            // ignore: sort_child_properties_last
            child: Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.3,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      entry.value['icon'] as IconData,
                      color: blue,
                    ),
                  ),
                  Text(
                    entry.value['name'] as String,
                    style: const TextStyle(
                      color: Color(c3),
                    ),
                  ),
                ],
              ),
            ),
            value: entry.key,
          );
        }).toList();
        return list;
      },
      onSelected: (value) {
        onSelectPopupmenuItem(
            parentContext, popupMenuButtonItems[value]!['name'] as String);
      },
    );
  }
}

// ignore: constant_identifier_names
const NoteColors = {
  'red': {'l': 0xFFFFCDD2, 'b': 0xFFE57373},
  'pink': {'l': 0xFFF8BBD0, 'b': 0xFFF06292},
  'purple': {'l': 0xFFE1BEE7, 'b': 0xFFBA68C8},
  'deepPurple': {'l': 0xFFD1C4E9, 'b': 0xFF9575CD},
  'indigo': {'l': 0xFFC5CAE9, 'b': 0xFF7986CB},
  'blue': {'l': 0xFFBBDEFB, 'b': 0xFF64B5F6},
  'lightBlue': {'l': 0xFFB3E5FC, 'b': 0xFF4FC3F7},
  'cyan': {'l': 0xFFB2EBF2, 'b': 0xFF4DD0E1},
  'teal': {'l': 0xFFB2DFDB, 'b': 0xFF4DB6AC},
  'green': {'l': 0xFFC8E6C9, 'b': 0xFF81C784},
  'lightGreen': {'l': 0xFFDCEDC8, 'b': 0xFFAED581},
  'lime': {'l': 0xFFF0F4C3, 'b': 0xFFDCE775},
  'yellow': {'l': 0xFFFFF9C4, 'b': 0xFFFFF176},
  'amber': {'l': 0xFFFFECB3, 'b': 0xFFFFD54F},
  'orange': {'l': 0xFFFFE0B2, 'b': 0xFFFFB74D},
  'deepOrange': {'l': 0xFFFFCCBC, 'b': 0xFFFF8A65},
  'brown': {'l': 0xFFD7CCCB, 'b': 0xFFA1887F},
  'blueGray': {'l': 0xFFCFD8DC, 'b': 0xFF90A4AE},
};
