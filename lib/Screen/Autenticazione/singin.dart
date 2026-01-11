import 'dart:math';

import 'package:FuoriMenu/Models/UserModel.dart';
import 'package:FuoriMenu/Servizi/AuthFirebase.dart';
import 'package:flutter/material.dart';

class Singin extends StatefulWidget {
  Singin({this.loginCallback,this.auth});

  final AuthService auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _Singin();
}

class _Singin extends State<Singin> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      User user = null;
      try {
        if (_isLoginForm) {
          user = await widget.auth.singinEmail(_email, _password);
          print('Signed in: '+user.uid);
        } else {
          user = await widget.auth.registerEmail(_email, _password);
          //widget.auth.sendEmailVerification();
          //_showVerifyEmailSentDialog();
          print('Signed up user: '+user.uid);
        }
        setState(() {
          _isLoading = false;
        });

        if (user != null && user.uid.isNotEmpty && _isLoginForm) {
          widget.loginCallback();
        }

      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if(_isLoginForm){
            _errorMessage = 'Non è stato possibile effettuare il login.';
          }else{
            _errorMessage = 'Non è stato possibile creare l\' account.';
          }
          _errorMessage += 'Controlla le credenziali e l\' accesso a internet e riprova';

        });
      }
      finally{
        _isLoading = false;
        if(_errorMessage == ""){
          _isLoginForm = true;
        }
      }

    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            _showForm(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content:
//              new Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                toggleFormMode();
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  Widget _showForm() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showEmailInput(),
              showPasswordInput(),
              showErrorMessage(),
              showPrimaryButton(),
              showSecondaryButton(),
            ],
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage != null &&_errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
          top: 10,
        ),
        child: Text(
          _errorMessage,
          style: TextStyle(
              fontSize: 13.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60,
          child: Image.asset('assets/Logo.png'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Email',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange,width: 2),
            ),
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'il campo Email non può essere vuoto' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Password',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange,width: 2),
            ),
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'il campo Password non può essere vuoto' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showSecondaryButton() {
    return FlatButton(
        child: Text(
            _isLoginForm ? 'Crea un account' : 'Hai già un account? Accedi',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }

  Widget showPrimaryButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: Colors.orange,
            child: Text(_isLoginForm ? 'Login' : 'Crea un account',
                style: TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }
}