import 'dart:io';

import 'package:agenda/models/pet_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PetForm extends StatefulWidget {
  final void Function(PetData petData) onSubmit;

  PetForm(this.onSubmit);
  @override
  _PetFormState createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  static const List<String> species = ['Canino', 'Felino', 'Ave'];
  static const List<String> gender = ['Masculino', 'Feminino'];
  String? _selectedSpecies;
  String? _selectedGender;
  TextEditingController dateCtl = TextEditingController();
  final PetData _petData = PetData();

  _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    PickedFile? imageFile = await _picker.getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (imageFile == null) return;

    setState(() {
      _petData.image = File(imageFile.path);
    });
  }

  Future<void> _submit() async {
    bool isValid = _formKey.currentState!.validate();

    if (isValid) {
      widget.onSubmit(_petData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) => _petData.name = value,
                  textInputAction: TextInputAction.next,
                  key: ValueKey('name'),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: DropdownButtonFormField(
                            key: ValueKey('specie'),
                            value: _selectedSpecies,
                            items: species
                                .map(
                                  (label) => DropdownMenuItem(
                                    child: Text(label.toString()),
                                    value: label,
                                  ),
                                )
                                .toList(),
                            hint: Text('Espécie'),
                            onChanged: (value) =>
                                _petData.specie = value.toString(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: DropdownButtonFormField(
                            key: ValueKey('sex'),
                            value: _selectedGender,
                            items: gender
                                .map(
                                  (label) => DropdownMenuItem(
                                    child: Text(label.toString()),
                                    value: label,
                                  ),
                                )
                                .toList(),
                            hint: Text('Sexo'),
                            onChanged: (value) =>
                                _petData.sex = value.toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  onChanged: (value) => _petData.race = value,
                  textInputAction: TextInputAction.next,
                  key: ValueKey('race'),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Raça',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dateCtl,
                          decoration: InputDecoration(
                            labelText: 'Data de nascimento',
                          ),
                          onTap: () async {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());

                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(DateTime.now().year - 100),
                              lastDate: DateTime.now(),
                            );
                            if (date != null)
                              dateCtl.text =
                                  DateFormat('dd-MMM-yyyy').format(date);
                            _petData.birthDate = dateCtl.text;
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: _petData.castrated,
                          onChanged: (bool? value) {
                            setState(() {
                              _petData.castrated = value!;
                            });
                          },
                          title: Text('Castrado?'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    onChanged: (value) => _petData.history = value,
                    textInputAction: TextInputAction.done,
                    key: ValueKey('history'),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Breve Histórico',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: _petData.image == null
                          ? Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            )
                          : Image.file(
                              _petData.image!,
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                      onPressed: _submit, child: Text('Cadastrar')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}