import 'package:agenda/models/meeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  @override
  void initState() {
    reg = appointments();
    events = MeetingDataSource(reg);
    getDataFromDatabase();
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
          if (details.targetElement == CalendarElement.appointment)
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("AlertDialog"),
                  content: Text("Would you like to schedule an appointment?"),
                  actions: [
                    ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      child: Text("Continue"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
        },
        dataSource: events,
        minDate: DateTime.now(),
        maxDate: DateTime.now().add(const Duration(days: 90)),
      ),
    );
  }

  List<Meeting> appointments() {
    List<Meeting> regular = [];
    final minDate = DateTime.now();
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
        date = date.add(Duration(days: 1));
        date = DateTime(date.year, date.month, date.day, 8);
      }
    }
    return regular;
  }

  Future<void> getDataFromDatabase() async {
    CollectionReference appointments = FirebaseFirestore.instance
        .collection('people')
        .doc(widget.docId)
        .collection('appointments');
    QuerySnapshot snapshot = await appointments.get();
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
