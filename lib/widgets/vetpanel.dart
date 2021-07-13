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
        view: CalendarView.month,
        dataSource: events,
        monthViewSettings: MonthViewSettings(showAgenda: true),
      ),
    );
  }

  Future<void> getDataFromDatabase() async {
    CollectionReference appointments =
        FirebaseFirestore.instance.collection('appointments');
    QuerySnapshot snapshot = await appointments
        .where('vetUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<Meeting> list = snapshot.docs
        .map((doc) => Meeting(doc.get('petName'), doc.get('date').toDate(),
            doc.get('to').toDate(), Colors.blue, false))
        .toList();
    setState(() {
      events = MeetingDataSource(list);
    });
  }
}
