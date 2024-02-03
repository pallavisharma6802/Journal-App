import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journal/pages/HomePage.dart';
import 'package:journal/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarAppointmentsPage extends StatefulWidget {
  @override
  _CalendarAppointmentsPageState createState() =>
      _CalendarAppointmentsPageState();
}

class _CalendarAppointmentsPageState extends State<CalendarAppointmentsPage> {
  List<Appointment> _appointments = <Appointment>[];
  late SharedPreferences _prefs;
  late CalendarDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _initCalendarDataSource();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? appointmentStrings = _prefs.getStringList('appointments');
    if (appointmentStrings != null) {
      setState(() {
        _appointments =
            appointmentStrings.map((e) => Appointment.fromJson(e)).toList();
        _initCalendarDataSource();
      });
    } else {
      _initCalendarDataSource();
    }
  }

  void _initCalendarDataSource() {
    _dataSource = CustomCalendarDataSource(_appointments);
  }

  void _saveAppointments() {
    List<String> appointmentStrings =
        _appointments.map((e) => jsonEncode(e.toJson())).toList();
    _prefs.setStringList('appointments', appointmentStrings);
  }

  void _removeAppointment(Appointment appointment) {
    setState(() {
      _appointments.remove(appointment);
      _dataSource = CustomCalendarDataSource(_appointments);
      _saveAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightpurple,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: buttoncolor,
          ),
          tooltip: 'Back',
          onPressed: () => {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()))
          },
        ),
        title: const Text(
          "T I M E L I N E",
          style: TextStyle(color: mainFontColor),
        ),
      ),
      body: SfCalendar(
        dataSource: _dataSource,
        view: CalendarView.day,
        allowedViews: const [
          CalendarView.schedule,
          CalendarView.day,
          CalendarView.week,
          CalendarView.month,
        ],
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment) {
            final Appointment appointment =
                details.appointments!.first as Appointment;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Appointment'),
                  content:
                      Text('Are you sure you want to delete the appointment?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('No'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Yes'),
                      onPressed: () {
                        _removeAppointment(appointment);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else if (details.targetElement == CalendarElement.calendarCell) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                DateTime selectedDate = details.date!;
                String appointmentSubject = '';
                return AlertDialog(
                  title: Text('Add Appointment',
                      style: TextStyle(color: mainFontColor)),
                  content: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter appointment details',
                    ),
                    onChanged: (String value) {
                      appointmentSubject = value;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: mainFontColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child:
                          Text('Save', style: TextStyle(color: mainFontColor)),
                      onPressed: () {
                        setState(() {
                          _appointments.add(Appointment(
                            startTime: selectedDate,
                            endTime: selectedDate.add(Duration(hours: 1)),
                            subject: appointmentSubject,
                            color: mainFontColor,
                          ));
                          _dataSource = CustomCalendarDataSource(_appointments);
                          _saveAppointments();
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CustomCalendarDataSource extends CalendarDataSource {
  CustomCalendarDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color ?? mainFontColor;
  }
}

class Appointment {
  Appointment({
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.color,
  });

  final DateTime startTime;
  final DateTime endTime;
  final String subject;
  final Color color;

  factory Appointment.fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Appointment(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      subject: json['subject'],
      color: mainFontColor,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'subject': subject,
    };
  }
}
