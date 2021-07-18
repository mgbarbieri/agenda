import 'package:agenda/models/meeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class VetPanel extends StatefulWidget {
  const VetPanel({Key? key}) : super(key: key);

  @override
  _VetPanelState createState() => _VetPanelState();
}

class _VetPanelState extends State<VetPanel> {
  MeetingDataSource? events;
  @override
  void initState() {
    getDataFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCalendar(
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment)
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("AlertDialog"),
                  content: Text(
                      "Would you like to get information on this appointment?"),
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
                    )
                  ],
                );
              },
            );
        },
        todayHighlightColor: Colors.blue,
        view: CalendarView.month,
        dataSource: events,
        monthViewSettings: MonthViewSettings(showAgenda: true),
      ),
    );
  }

  Future<void> getDataFromDatabase() async {
    CollectionReference appointments = FirebaseFirestore.instance
        .collection('people')
        .doc(FirebaseAuth.instance.currentUser!.uid)
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
    setState(() {
      events = MeetingDataSource(list);
    });
  }
}
