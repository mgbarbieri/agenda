import 'package:agenda/models/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final AuthData _authData = AuthData();
  bool _pwVisible = false;

  _submit() {
    bool isValid = _formKey.currentState!.validate();

    if (isValid) {}
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_authData.isSignup)
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        key: ValueKey('name'),
                        decoration: InputDecoration(
                          labelText: 'Nome',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 4) {
                            return 'Nome deve ter no mínimo 4 caracteres';
                          }
                          return null;
                        },
                      ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      key: ValueKey('email'),
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                      ),
                      onChanged: (value) => _authData.email = value,
                      validator: (value) => EmailValidator.validate(value!)
                          ? null
                          : 'Forneça um e-mail válido',
                    ),
                    TextFormField(
                      obscureText: _pwVisible ? false : true,
                      textInputAction: _authData.isLogin
                          ? TextInputAction.done
                          : TextInputAction.next,
                      key: ValueKey('password'),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        suffixIcon: IconButton(
                          alignment: Alignment.bottomRight,
                          onPressed: () {
                            setState(() {
                              _pwVisible = !_pwVisible;
                            });
                          },
                          icon: Icon(
                            _pwVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      onChanged: (value) => _authData.password = value,
                      validator: (value) {
                        if (value == null || value.trim().length < 7) {
                          return 'Senha deve ter no mínimo 7 caracteres';
                        }
                        return null;
                      },
                    ),
                    if (_authData.isSignup)
                      TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        key: ValueKey('passwordConfirmation'),
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                        ),
                        validator: (value) {
                          if (value == null || value != _authData.password) {
                            return 'Senhas não conferem';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_authData.isLogin ? 'Entrar' : 'Cadastrar'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _authData.toggleMode();
                        });
                      },
                      child: Text(
                        _authData.isLogin
                            ? 'Criar nova conta'
                            : 'Já possui uma conta?',
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
