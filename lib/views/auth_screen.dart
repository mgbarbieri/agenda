import 'dart:async';

import 'package:agenda/models/auth_data.dart';
import 'package:agenda/widgets/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _isLoading = false;

  Future<void> _handleSubmit(AuthData authData) async {
    UserCredential userCredential;
    setState(() {
      _isLoading = true;
    });
    try {
      if (authData.isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: authData.email!.trim(), password: authData.password!);

        if (!userCredential.user!.emailVerified) {
          _scaffoldKey.currentState!.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: 'RE-ENVIAR',
                onPressed: () async {
                  await userCredential.user!.sendEmailVerification();
                },
                textColor: Colors.white,
              ),
              content: const Text(
                  'Email da conta não verificado, por favor confirme o cadastro acessando o link enviado ao email'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
          return;
        }
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: authData.email!.trim(),
          password: authData.password!,
        );

        userCredential.user!.updateDisplayName(authData.name);

        final userData = {
          'name': authData.name,
          'email': authData.email,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        await userCredential.user!.sendEmailVerification();
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text('Link de ativação enviado ao email cadastrado'),
            duration: Duration(seconds: 5),
          ),
        );
        authData.toggleMode();
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Ocorreu um erro! verifique suas credenciais!';
      _scaffoldKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(children: [
                  AuthForm(_handleSubmit),
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
