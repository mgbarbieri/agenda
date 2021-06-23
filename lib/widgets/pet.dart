import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Pet extends StatelessWidget {
  final User? user;
  Pet(User? this.user);

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
            final collection = snapshot.data!.docs;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: collection.length,
              itemBuilder: (ctx, i) => Container(
                //decoration: BoxDecoration(image: DecorationImage(image: image)),
                width: MediaQuery.of(context).size.width / 2,
                child: Card(
                  child: ListTile(
                    title: Text('oi'),
                  ),
                ),
              ),
            );
          }
        });
  }
}
