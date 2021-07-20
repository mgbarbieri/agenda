import 'package:agenda/models/meeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class Consult extends StatefulWidget {
  final DateTime date;
  final String? docId;
  final String? docName;
  final Map week;

  Consult(this.date, this.docId, this.docName, this.week);

  @override
  _ConsultState createState() => _ConsultState();
}

class _ConsultState extends State<Consult> {
  MeetingDataSource? events;
  List<Meeting> reg = [];
  List<DateTime> off = [];
  List<String> pets = [];
  String? appointmentPet;
  @override
  void initState() {
    reg = appointments();
    getDataFromDatabase();
    getPets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCalendar(
        monthViewSettings: MonthViewSettings(showAgenda: true),
        todayHighlightColor: Colors.blue,
        view: CalendarView.month,
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment) {
            Meeting consulta = details.appointments!.first;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: Text("Consulta"),
                    content: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Gostaria de marcar uma consulta ${DateFormat.yMd('pt').format(details.date!)} as ${DateFormat.Hms().format(consulta.from)} ?"),
                          DropdownButton(
                            value: appointmentPet,
                            items: pets
                                .map((pet) => DropdownMenuItem(
                                      value: pet,
                                      child: Text(pet),
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                appointmentPet = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            child: Text("Cancelar"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            child: Text("Confirmar"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ],
                  );
                });
              },
            );
          }
        },
        blackoutDates: off,
        dataSource: events,
        minDate: DateTime.now(),
        maxDate: DateTime.now().add(const Duration(days: 90)),
      ),
    );
  }

  List<Meeting> appointments() {
    List<Meeting> regular = [];
    final minDate = DateTime.now().add(Duration(hours: 1));
    final maxDate = minDate.add(const Duration(days: 90));
    var days = maxDate.difference(minDate).inDays;
    DateTime date =
        DateTime(minDate.year, minDate.month, minDate.day, minDate.hour);

    for (var i = 0; i <= days; i++) {
      if (widget.week[date.weekday.toString()]) {
        for (var j = 0; j < 10; j++) {
          if (date.hour >= 18) continue;
          if (date.hour != 12) {
            regular.add(Meeting(
                background: Colors.blue,
                from: date,
                to: date.add(Duration(hours: 1))));
          }

          date = date.add(Duration(hours: 1));
        }
        date = date.add(Duration(hours: 14));
      } else {
        off.add(DateTime(date.year, date.month, date.day));
        date = date.add(Duration(days: 1));
        date = DateTime(date.year, date.month, date.day, 8);
      }
    }
    return regular;
  }

  Future<void> getPets() async {
    CollectionReference petsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pets');

    QuerySnapshot snapshot = await petsRef.get();
    List<String> petsList =
        snapshot.docs.map((pet) => pet.get('petName').toString()).toList();
    if (petsList.isNotEmpty) {
      setState(() {
        pets = petsList;
        appointmentPet = petsList.first;
      });
    }
  }

  Future<void> getDataFromDatabase() async {
    CollectionReference appointmentsRef = FirebaseFirestore.instance
        .collection('people')
        .doc(widget.docId)
        .collection('appointments');
    QuerySnapshot snapshot = await appointmentsRef.get();
    List<Meeting> list = snapshot.docs
        .map((doc) => Meeting(
            eventName: doc.get('petName'),
            from: doc.get('date').toDate(),
            to: doc.get('to').toDate(),
            background: Colors.blue,
            isAllDay: false))
        .toList();
    reg.removeWhere((element) => list.contains(element));
    setState(() {
      events = MeetingDataSource(reg);
    });
  }
}
