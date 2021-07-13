import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Pets extends StatelessWidget {
  final User? user;
  Pets(this.user);

  @override
  Widget build(BuildContext context) {
    CollectionReference pets = FirebaseFirestore.instance.collection('pets');
    return FutureBuilder(
        future: pets.where('owner', isEqualTo: user!.uid).get(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text('Ocorreu um erro!'));
          } else {
            final petDocs = snapshot.data!.docs;

            if (petDocs.isEmpty) {
              return Center(child: Text('Não há nenhum pet cadastrado!'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: petDocs.length,
              itemBuilder: (ctx, i) => Container(
                width: petDocs.length == 1
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 2,
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          petDocs[i].get('name'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      petDocs[i].get('imgUrl') != null
                          ? Expanded(
                              child: Image.network(
                                petDocs[i].get('imgUrl'),
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          : Expanded(
                              child: Image.asset(
                                'assets/images/default.jpeg',
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
