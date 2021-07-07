import 'package:agenda/models/pet_data.dart';
import 'package:agenda/widgets/consult.dart';
import 'package:agenda/widgets/doc.dart';
import 'package:agenda/widgets/pet.dart';
import 'package:agenda/widgets/pet_form.dart';
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
        setState(() {
          _drawer = drawer;
        });
        return Doc(callback);
      case 'pet':
        setState(() {
          _drawer = drawer;
        });
        return Pets(widget.user);
      case 'con':
        setState(() {
          _drawer = drawer;
        });
        return Consult(DateFormat('dd-MMM-yyyy').format(date), docId);
      case 'addPet':
        setState(() {
          _drawer = drawer;
        });
        return PetForm(_handleSubmit);
      default:
        return Consult(DateFormat('dd-MMM-yyyy').format(date), docId);
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

  Future<bool> vetCheck(User? user) async {
    await FirebaseFirestore.instance
        .collection('people')
        .where('uid', isEqualTo: user!.uid)
        .get()
        .then((value) {
      if (value.size == 1) return true;
    });
    return false;
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
                  FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('people')
                          .where('uid', isEqualTo: widget.user!.uid)
                          .get(),
                      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.error != null) {
                          return Center(child: Text('Ocorreu um erro!'));
                        } else {
                          if (snapshot.data!.size == 1) {
                            return ListTile(
                              leading: Icon(Icons.list),
                              title: Text('Agenda'),
                              subtitle: Text('Suas consultas'),
                              onTap: () {},
                            );
                          }
                          return Container(
                            child: Column(
                              children: [
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
                              ],
                            ),
                          );
                        }
                      }),
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
              if (_drawer != 'addPet')
                ElevatedButton.icon(
                    onPressed: _drawer == 'pet'
                        ? () => drawerSelector('addPet')
                        : () => pickDate(context),
                    icon: _drawer == 'pet'
                        ? Icon(Icons.pets)
                        : Icon(Icons.date_range),
                    label: _drawer == 'pet'
                        ? Text('Adicionar um pet')
                        : Text('Selecionar data'))
            ],
          ),
        ),
      ),
    );
  }
}
