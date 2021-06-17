enum AuthMode {
  LOGIN,
  SIGNUP,
}

class AuthData {
  String? name;
  String? email;
  String? password;
  AuthMode _mode = AuthMode.LOGIN;
}
