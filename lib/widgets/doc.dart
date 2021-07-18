import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Doc extends StatefulWidget {
  final Function(String?, String?, Map?) callback;

  Doc(this.callback);

  @override
  _DocState createState() => _DocState();
}

String backgroundSelector(String spec) {
  switch (spec) {
    case 'Ave':
      return ('assets/images/birds.jpg');
    case 'Canino':
      return ('assets/images/dogs.jpg');
    case 'Felino':
      return ('assets/images/cats.jpg');
    default:
      return ('assets/images/default.jpeg');
  }
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
            itemExtent: MediaQuery.of(context).size.height / 4,
            itemCount: collection.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () {
                widget.callback(collection[i].id, collection[i].get('name'),
                    collection[i].get('week'));
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.8), BlendMode.dstATop),
                      fit: BoxFit.cover,
                      image: AssetImage(
                          backgroundSelector(collection[i].get('spec'))),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${collection[i].get('name')}',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          color: Colors.white.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text('Seg'),
                                  Checkbox(
                                      value: collection[i].get('week')['1'],
                                      onChanged: (value) {}),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Ter'),
                                  Checkbox(
                                      value: collection[i].get('week')['2'],
                                      onChanged: (value) {}),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Qua'),
                                  Checkbox(
                                      value: collection[i].get('week')['3'],
                                      onChanged: (value) {}),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Qui'),
                                  Checkbox(
                                      value: collection[i].get('week')['4'],
                                      onChanged: (value) {}),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Sex'),
                                  Checkbox(
                                      value: collection[i].get('week')['5'],
                                      onChanged: (value) {}),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Sab'),
                                  Checkbox(
                                      value: collection[i].get('week')['6'],
                                      onChanged: (value) {}),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Dom'),
                                  Checkbox(
                                      value: collection[i].get('week')['7'],
                                      onChanged: (value) {}),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
