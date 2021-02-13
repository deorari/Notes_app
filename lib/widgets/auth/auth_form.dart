import 'dart:io';
import 'package:note_app/widgets/picker/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String userName, String password,
      File image, bool isRegister, BuildContext ctx) submitForm;
  bool isLoading;

  AuthForm(this.submitForm, this.isLoading);
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  var _formKey = GlobalKey<FormState>();
  var userName = '';
  var email = '';
  var password = '';
  bool isRegister = true;
  File userImage;

  void _getUserImage(File image) {
    userImage = image;
  }

  void _submit() {
    var isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (userImage == null && !isRegister) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          'Please select an image',
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
      ));
      return;
    }
    if (isValid) {
      _formKey.currentState.save();
      widget.submitForm(
          email, userName, password, userImage, isRegister, context);
    }
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isRegister) UserImagePicker(_getUserImage),
                  TextFormField(
                    key: ValueKey('Email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                    ),
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value;
                    },
                  ),
                  if (!isRegister)
                    TextFormField(
                      key: ValueKey('Username'),
                      decoration: InputDecoration(
                        labelText: 'Username',
                      ),
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'Please enter valid username';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        userName = value;
                      },
                    ),
                  TextFormField(
                    key: ValueKey('Password'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty || value.length < 4) {
                        return 'Please enter valid password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    RaisedButton(
                      child: Text(isRegister ? 'Login' : 'Sign Up'),
                      onPressed: _submit,
                    ),
                  if (!widget.isLoading)
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          isRegister = !isRegister;
                        });
                      },
                      child: Text(isRegister
                          ? 'Create New Acoount'
                          : 'Already have an account'),
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
