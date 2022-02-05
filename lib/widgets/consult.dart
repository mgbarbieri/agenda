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

  const Consult(this.date, this.docId, this.docName, this.week, {Key? key})
      : super(key: key);

  @override
  _ConsultState createState() => _ConsultState();
}

class _ConsultState extends State<Consult> {
  MeetingDataSource? events;
  List<Meeting> reg = [];
  List<DateTime> off = [];
  List<Map<String, dynamic>> pets = [];
  Map<String, dynamic> appointmentPet = {};
  @override
  void initState() {
    reg = appointments();
    getDataFromDatabase();
    getPets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      monthViewSettings: MonthViewSettings(
          showAgenda: true,
          numberOfWeeksInView:
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? 2
                  : 6),
      todayHighlightColor: Colors.blue,
      view: CalendarView.month,
      allowedViews: const [
        CalendarView.day,
        CalendarView.week,
        CalendarView.month,
      ],
      appointmentTimeTextFormat: 'HH:mm',
      timeSlotViewSettings: const TimeSlotViewSettings(timeFormat: 'HH:mm'),
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.appointment) {
          Meeting consulta = details.appointments!.first;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: const Text("Consulta"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "Gostaria de marcar uma consulta ${DateFormat.yMd('pt').format(details.date!)} as ${DateFormat.Hms().format(consulta.from)} ?"),
                      DropdownButton(
                        items: pets
                            .map((pet) => DropdownMenuItem(
                                  value: pet['id'].toString(),
                                  child: Text(pet['petName']),
                                ))
                            .toList(),
                        value: appointmentPet['id'].toString(),
                        onChanged: (String? value) {
                          setState(() {
                            appointmentPet =
                                pets.firstWhere((pet) => pet['id'] == value);
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          child: const Text("Cancelar"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Confirmar"),
                          onPressed: () => confirmAppointment(details),
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
    );
  }

  List<Meeting> appointments() {
    List<Meeting> regular = [];
    final minDate = DateTime.now().add(const Duration(hours: 1));
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
                eventName: 'Disponível',
                background: Colors.blue,
                from: date,
                to: date.add(const Duration(hours: 1))));
          }

          date = date.add(const Duration(hours: 1));
        }
        date = date.add(const Duration(hours: 14));
      } else {
        off.add(DateTime(date.year, date.month, date.day));
        date = date.add(const Duration(days: 1));
        date = DateTime(date.year, date.month, date.day, 8);
      }
    }
    return regular;
  }

  Future<void> confirmAppointment(CalendarTapDetails details) async {
    if (appointmentPet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
              'A consulta não foi registrada. Por favor adicione um pet antes de agendar uma consulta')));
      Navigator.pop(context);
      return;
    }

    final vetAppointment = {
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'date': details.appointments!.first.from,
      'petName': appointmentPet['petName'],
      'petId': appointmentPet['id'],
      'to': details.appointments!.first.from.add(const Duration(hours: 1))
    };

    final userAppointment = {
      'date': details.appointments!.first.from,
      'to': details.appointments!.first.from.add(const Duration(hours: 1)),
      'vet': widget.docName,
      'vetId': widget.docId,
    };

    CollectionReference userAppRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pets')
        .doc(appointmentPet['id'])
        .collection('appointments');

    await userAppRef.doc().set(userAppointment);

    CollectionReference appointmentRef = FirebaseFirestore.instance
        .collection('people')
        .doc(widget.docId)
        .collection('appointments');

    await appointmentRef.doc().set(vetAppointment);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Consulta marcada!'),
      backgroundColor: Colors.blue,
    ));

    Navigator.pop(context);
    getDataFromDatabase();
  }

  Future<void> getPets() async {
    CollectionReference petsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pets');

    QuerySnapshot snapshot = await petsRef.get();
    List<Map<String, dynamic>> petsList = snapshot.docs
        .map((pet) => {
              'id': pet.id,
              'petName': pet.get('petName'),
            })
        .toList();
    if (petsList.isNotEmpty) {
      setState(() {
        pets = petsList;
        appointmentPet = petsList.first;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content:
              Text('Por favor adicione um pet antes de agendar uma consulta')));
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
