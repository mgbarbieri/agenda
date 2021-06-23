import 'package:agenda/widgets/consult.dart';
import 'package:agenda/widgets/doc.dart';
import 'package:agenda/widgets/pet.dart';
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
  String doc = '';
  String? docId;
  String? _drawer;

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

  callback(newDocId, newDoc) {
    setState(() {
      docId = newDocId;
      doc = newDoc;
      _drawer = 'con';
    });
    Consult(DateFormat('dd-MMM-yyyy').format(date), docId);
  }

  Widget drawerSelector(String? drawer) {
    switch (drawer) {
      case 'vet':
        return Doc(callback);
      case 'pet':
        return Pet(widget.user);
      case 'con':
        return Consult(DateFormat('dd-MMM-yyyy').format(date), docId);
      default:
        return Consult(DateFormat('dd-MMM-yyyy').format(date), docId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Column(
            children: [
              Text(
                doc,
              ),
              Text(
                DateFormat('dd-MMM-yyyy').format(date),
              ),
            ],
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
                    title: Text('Doutores'),
                    subtitle: Text('Veterinários'),
                    onTap: () {
                      setState(() {
                        _drawer = 'vet';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.pets),
                    title: Text('Pets'),
                    subtitle: Text(''),
                    onTap: () {
                      setState(() {
                        _drawer = 'pet';
                      });
                      Navigator.pop(context);
                    },
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
              Expanded(child: drawerSelector(_drawer)),
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
