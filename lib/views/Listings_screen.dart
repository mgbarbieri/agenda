import 'package:agenda/widgets/consult.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListingsScreen extends StatefulWidget {
  final User? user;

  ListingsScreen(this.user);
  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  DateTime date = DateTime.now();

  Future<void> pickDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate == null) return;

    setState(() {
      date = selectedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Column(
              children: [
                Text('Dr...'),
                Text(DateFormat('dd-MMM-yyyy').format(date)),
              ],
            ),
          ),
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
                    accountName: Text('widget.user!.displayName!'),
                    accountEmail: Text(widget.user!.email!),
                  ),
                  ListTile(
                    leading: Icon(Icons.list),
                    title: Text('Lista'),
                    subtitle: Text('Listas'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text('Favoritos'),
                    subtitle: Text('favoritos'),
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
              Expanded(
                child: Consult(DateFormat('dd-MMM-yyyy').format(date)),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.date_range),
                label: Text('Selecionar data'),
                onPressed: () => pickDate(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
