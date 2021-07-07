import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/listings_screen.dart';
import 'views/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.blue,
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (ctx, AsyncSnapshot<User?> snapshot) {
            if (snapshot.hasData && snapshot.data!.emailVerified) {
              return ListingsScreen(snapshot.data);
            } else {
              return AuthScreen();
            }
          }),
    );
  }
}
