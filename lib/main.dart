import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/listings_screen.dart';
import 'views/auth_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting().then((_) => runApp(App()));
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
          builder: (ctx, AsyncSnapshot<User?> userSnapshot) {
            if (userSnapshot.hasData && userSnapshot.data!.emailVerified) {
              return ListingsScreen(userSnapshot.data);
            } else {
              return AuthScreen();
            }
          }),
    );
  }
}
