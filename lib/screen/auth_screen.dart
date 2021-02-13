import 'dart:io';
import 'package:note_app/widgets/auth/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;
  void submit(String email, String userName, String password, File image,
      bool isRegister, BuildContext ctx) async {
    final auth = FirebaseAuth.instance;
    var authResult;

    try {
      setState(() {
        isLoading = true;
      });
      if (isRegister) {
        authResult = await auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        print('kk');
        authResult = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        final ref = FirebaseStorage.instance
            .ref()
            .child('${authResult.user.uid}')
            .child(authResult.user.uid + '.jpg');
        UploadTask uploadTask = ref.putFile(image);
        await uploadTask;
        final url = await ref.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'userName': userName,
          'email': email,
          'imageUrl': url,
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'userName': userName,
          'email': email,
          'imageUrl': url,
        });
      }
      setState(() {
        isLoading = false;
      });
    } on PlatformException catch (err) {
      var message = 'Please check your credentials';
      if (err.message != null) {
        message = err.message;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.white,
      ));
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(submit, isLoading),
    );
  }
}
