import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Consult extends StatelessWidget {
  final String date;
  final String? docId;

  Consult(this.date, this.docId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('people')
            .doc(docId)
            .collection(date)
            .orderBy('time')
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> consultSnapshot) {
          if (consultSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (consultSnapshot.hasData &&
              consultSnapshot.data!.docs.length == 0) {
            return Center(
              child: Text('Não estamos atendendo neste dia'),
            );
          }

          final consultDocs = consultSnapshot.data!.docs;

          return ListView.builder(
            itemCount: consultDocs.length,
            itemBuilder: (ctx, i) => Card(
              color: consultDocs[i].get('occupied')
                  ? Theme.of(context).accentColor
                  : Colors.white,
              child: ListTile(
                onTap: consultDocs[i].get('occupied') ? null : () {},
                title: Text('${consultDocs[i].get('time')}'),
              ),
            ),
          );
        });
  }
}
