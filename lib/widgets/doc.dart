import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Doc extends StatefulWidget {
  final Function(String?, String?) callback;

  Doc(this.callback);

  @override
  _DocState createState() => _DocState();
}

class _DocState extends State<Doc> {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('people');
    return FutureBuilder(
      future: users.get(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return Center(child: Text('Ocorreu um erro!'));
        } else {
          final collection = snapshot.data!.docs;

          return ListView.builder(
            itemCount: collection.length,
            itemBuilder: (ctx, i) => Card(
              child: ListTile(
                onTap: () {
                  widget.callback(collection[i].id, collection[i].get('name'));
                },
                title: Text('${collection[i].get('name')}'),
              ),
            ),
          );
        }
      },
    );
  }
}
