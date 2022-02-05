import 'package:agenda/models/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class AuthForm extends StatefulWidget {
  final void Function(AuthData authData) onSubmit;

  const AuthForm(this.onSubmit, {Key? key}) : super(key: key);
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final AuthData _authData = AuthData();
  bool _pwVisible = false;

  _submit() {
    bool isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      widget.onSubmit(_authData);
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusNode textFocusNode = FocusNode();
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
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
                      key: const ValueKey('name'),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                      ),
                      initialValue: _authData.name,
                      onChanged: (value) => _authData.name = value,
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
                    key: const ValueKey('email'),
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                    ),
                    onChanged: (value) => _authData.email = value,
                    validator: (value) => EmailValidator.validate(value!)
                        ? null
                        : 'Forneça um e-mail válido',
                  ),
                  TextFormField(
                    onEditingComplete: _authData.isLogin
                        ? null
                        : () =>
                            FocusScope.of(context).requestFocus(textFocusNode),
                    obscureText: _pwVisible ? false : true,
                    textInputAction: _authData.isLogin
                        ? TextInputAction.done
                        : TextInputAction.next,
                    key: const ValueKey('password'),
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
                          _pwVisible ? Icons.visibility_off : Icons.visibility,
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
                      focusNode: textFocusNode,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      key: const ValueKey('passwordConfirmation'),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Senha',
                      ),
                      validator: (value) {
                        if (value == null || value != _authData.password) {
                          return 'Senhas não conferem';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
