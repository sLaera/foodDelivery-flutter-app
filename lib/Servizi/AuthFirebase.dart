import '../Models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //crea l'oggetto user
  User _getUserFromFirebaseObj(FirebaseUser user){
    return user != null ? new User(user.uid,user.isAnonymous) : null;
  }

  // listener cambiamento login
  Stream<User> get user{
    return _auth.onAuthStateChanged
        .map(_getUserFromFirebaseObj);
  }

  //---login anonimo
  Future singinAnonymus() async{
    try{
      var result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _getUserFromFirebaseObj(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //---login con email
  Future<User> singinEmail(String email,String password) async{
    try{
      var result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _getUserFromFirebaseObj(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<User> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return _getUserFromFirebaseObj(user);
  }

  //---logout
  Future<void> signOut() async {
    return _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _auth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _auth.currentUser();
    return user.isEmailVerified;
  }

  Future<User> registerEmail(String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return _getUserFromFirebaseObj(user);
  }

}