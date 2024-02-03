import 'package:flutter/material.dart';

import 'notes_model/route_generator.dart';

void main() async {
  runApp(NoteEntry());
}

class NoteEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: GenerateAllRoutes.generateRoute,
    );
  }
}
