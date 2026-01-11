import '../Servizi/AuthFirebase.dart';
import 'package:flutter/material.dart';

import 'mappa.dart';
import 'Autenticazione/singin.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class Wrapper extends StatefulWidget {
  Wrapper({this.auth});

  final AuthService auth;

  @override
  State<StatefulWidget> createState() => new _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          userId = user.uid;
          authStatus =
          user.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
        }else{
          authStatus = AuthStatus.NOT_LOGGED_IN;
        }

      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return Singin(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (userId.isNotEmpty && userId != null) {
          return Mappa(auth: widget.auth);
        } else {
          return buildWaitingScreen();
        }
        break;
      default:
        return buildWaitingScreen();
    }
  }
}