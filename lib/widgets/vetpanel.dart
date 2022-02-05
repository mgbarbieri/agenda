import 'package:agenda/models/meeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:agenda/views/pet_details.dart';

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
    return SfCalendar(
      allowedViews: const [
        CalendarView.day,
        CalendarView.week,
        CalendarView.month,
      ],
      timeSlotViewSettings: const TimeSlotViewSettings(timeFormat: 'HH:mm'),
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.appointment) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PetDetails(details.appointments!.first)));
        }
      },
      todayHighlightColor: Colors.blue,
      view: CalendarView.month,
      dataSource: events,
      monthViewSettings: MonthViewSettings(
          showAgenda: true,
          numberOfWeeksInView:
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? 2
                  : 6),
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
            userId: doc.get('userId'),
            petId: doc.get('petId'),
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
