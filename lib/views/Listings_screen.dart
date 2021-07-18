import 'package:agenda/models/pet_data.dart';
import 'package:agenda/widgets/consult.dart';
import 'package:agenda/widgets/doc.dart';
import 'package:agenda/widgets/pets.dart';
import 'package:agenda/widgets/pet_form.dart';
import 'package:agenda/widgets/vetPanel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  bool? vet;
  Map week = {};

  void initState() {
    vetCheck(widget.user);
    super.initState();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (selectedDate == null) return;

    final DateTime format =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    setState(() {
      date = format;
    });
  }

  callback(newDocId, newDoc, nWeek) {
    setState(() {
      week = nWeek;
      docId = newDocId;
      doc = newDoc;
      _drawer = 'con';
    });
    Consult(date, docId, doc, week);
  }

  Widget drawerSelector(String? drawer) {
    switch (drawer) {
      case 'vet':
        return Doc(callback);
      case 'pet':
        return Pets(widget.user);
      case 'con':
        return Consult(date, docId, doc, week);
      case 'addPet':
        setState(() {
          _drawer = drawer;
        });
        return PetForm(_handleSubmit);
      case 'vetPanel':
        return VetPanel();
      default:
        return Doc(callback);
    }
  }

  Future<void> _handleSubmit(PetData petData) async {
    final String? url;
    try {
      if (petData.image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('pet_images')
            .child(widget.user!.uid + '.jpg');

        await ref.putFile(petData.image!);
        url = await ref.getDownloadURL();
      } else {
        url = null;
      }

      final pet = {
        'owner': widget.user!.uid,
        'imgUrl': url,
        'name': petData.name,
        'sex': petData.sex,
        'specie': petData.specie,
        'race': petData.race,
        'birthDate': petData.birthDate,
        'history': petData.history,
      };

      await FirebaseFirestore.instance.collection('pets').doc().set(pet);
    } catch (e) {}

    setState(() {
      _drawer = 'pet';
    });
  }

  Future<void> vetCheck(User? user) async {
    await FirebaseFirestore.instance
        .collection('people')
        .where('uid', isEqualTo: user!.uid)
        .get()
        .then((value) {
      if (value.size == 1) {
        setState(() {
          vet = true;
        });
      } else {
        vet = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Column(
            children: [
              if (_drawer == 'vet' || _drawer == 'con') Text(doc),
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
                    accountName: Text('Olá'),
                    accountEmail: Text(widget.user!.displayName!),
                  ),
                  vet == true
                      ? ListTile(
                          leading: Icon(Icons.list),
                          title: Text('Agenda'),
                          subtitle: Text('Suas consultas'),
                          onTap: () {
                            setState(() {
                              _drawer = 'vetPanel';
                            });
                            Navigator.pop(context);
                          },
                        )
                      : Container(),
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
              if (_drawer == 'pet')
                ElevatedButton.icon(
                  onPressed: () => drawerSelector('addPet'),
                  icon: Icon(Icons.pets),
                  label: Text('Adicionar um pet'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
