// ignore: file_names
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:journal/pages/college.dart';
import 'package:journal/pages/daily_page.dart';
import 'package:journal/pages/notes.dart';
import 'package:journal/theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;

  List<Widget> pages = [
    const DailyPage(),
    NoteEntry(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: purple),
      backgroundColor: primary,
      drawer: Drawer(
        backgroundColor: lightpurple,
        child: Column(
          children: [
            const DrawerHeader(
              child: Icon(
                Icons.favorite,
                color: purple,
                size: 50,
              ),
            ),
            InkWell(
              child: const ListTile(
                leading: Icon(
                  Icons.home,
                  color: purple,
                ),
                title: Text(
                  'D A S H B O A R D',
                  style: TextStyle(color: mainFontColor),
                ),
              ),
              onTap: () => {Navigator.pop(context)},
            ),
            InkWell(
              child: const ListTile(
                leading: Icon(
                  Icons.notes,
                  color: purple,
                ),
                title: Text(
                  'N O T E S',
                  style: TextStyle(color: mainFontColor),
                ),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NoteEntry()))
              },
            ),
            InkWell(
              child: const ListTile(
                leading: Icon(
                  Icons.school,
                  color: purple,
                ),
                title: Text(
                  'T I M E L I N E',
                  style: TextStyle(color: mainFontColor),
                ),
              ),
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalendarAppointmentsPage()))
              },
            ),
          ],
        ),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  setTabs(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
