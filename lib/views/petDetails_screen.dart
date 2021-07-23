import 'package:agenda/models/meeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PetDetails extends StatelessWidget {
  final Meeting appointmentDetails;

  PetDetails(this.appointmentDetails);

  @override
  Widget build(BuildContext context) {
    CollectionReference pets = FirebaseFirestore.instance
        .collection('users')
        .doc(appointmentDetails.userId)
        .collection('pets');
    return Scaffold(
      appBar: AppBar(
        title: Text(appointmentDetails.eventName),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                margin: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: FutureBuilder(
                      future: pets.doc(appointmentDetails.petId).get(),
                      builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.error != null) {
                          return Center(child: Text('Ocorreu um erro!'));
                        } else {
                          return Column(
                            children: [Text(snapshot.data!.get('petName'))],
                          );
                        }
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
