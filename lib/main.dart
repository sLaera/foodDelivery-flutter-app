import 'Screen/Wrapper.dart';
import 'package:FuoriMenu/Servizi/AuthFirebase.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'screen/mappa.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter login demo',
        debugShowCheckedModeBanner: false,
        theme:ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:Wrapper(auth: AuthService()));

  }
}
