import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListingsScreen extends StatefulWidget {
  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Agenda'),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
