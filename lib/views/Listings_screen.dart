import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListingsScreen extends StatefulWidget {
  final User? user;

  ListingsScreen(User? this.user);
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
          actions: [],
        ),
        drawer: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration:
                        BoxDecoration(color: Theme.of(context).accentColor),
                    accountName: Text(widget.user!.displayName!),
                    accountEmail: Text(widget.user!.email!),
                  ),
                  ListTile(
                    leading: Icon(Icons.list),
                    title: Text('Lista'),
                    subtitle: Text('Listas'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Sair'),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.date_range),
                  label: Text('Selecionar data'),
                  onPressed: () {
                    Future<DateTime?> selectDate = showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                  },
                )
              ],
            )),
      ),
    );
  }
}
