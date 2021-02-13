import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddNoteScreen extends StatefulWidget {
  static const routeName = 'addNoteScreen';
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  File _pickedImage;
  void imagepick() async {
    final pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    setState(() {
      _pickedImage = pickedImageFile;
    });
  }

  final _formKey = GlobalKey<FormState>();
  Map<String, Object> args = {
    'title': '',
    'description': '',
    'imageUrl': '',
    'createdOn': '',
    'editOn': '',
    'reminderDate': '',
    'reminderTime': ''
  };
  var uid = FirebaseAuth.instance.currentUser.uid;

  final format = DateFormat.jm();
  bool first = true;
  DateTime _choosenDate;
  TimeOfDay _choosenTime;
  void _dateSubmit() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            lastDate: DateTime(2200),
            firstDate: DateTime.now())
        .then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _choosenDate = value;
        args['reminderDate'] = value.toIso8601String();
      });
    });
  }

  void _timeSubmit() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _choosenTime = value;
        args['reminderTime'] = value.format(context);
      });
    });
  }

  final String noImageUrl =
      'https://previews.123rf.com/images/pavelstasevich/pavelstasevich1902/pavelstasevich190200120/124934975-no-image-available-icon-vector-flat.jpg';

  void submitNote(bool isEdit) async {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (_pickedImage != null) {
      final ref = FirebaseStorage.instance.ref().child('$uid').child(
          '${DateTime.now().toIso8601String()}' + '${args['title']}.jpg');
      UploadTask uploadTask = ref.putFile(_pickedImage);
      await uploadTask;
      args['imageUrl'] = await ref.getDownloadURL();
    } else {
      if (args['imageUrl'] == '') {
        args['imageUrl'] = noImageUrl;
      }
    }
    if (isEdit) {
      args['editOn'] = DateTime.now().toString();
      FirebaseFirestore.instance
          .collection('users/$uid/notes')
          .doc(args['id'])
          .set({
        'title': args['title'],
        'createdOn': args['createdOn'],
        'description': args['description'],
        'imageUrl': args['imageUrl'],
        'editOn': args['editOn'],
        'reminderDate': args['reminderDate'],
        'reminderTime': args['reminderTime'],
      });
    } else {
      args['createdOn'] = DateTime.now().toIso8601String();
      args['editOn'] = '';

      FirebaseFirestore.instance.collection('users/$uid/notes').add({
        'title': args['title'],
        'createdOn': args['createdOn'],
        'description': args['description'],
        'imageUrl': args['imageUrl'],
        'editOn': args['editOn'],
        'reminderDate': args['reminderDate'],
        'reminderTime': args['reminderTime'],
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context).settings.arguments;
    bool isEdit = arguments.isNotEmpty;
    if (isEdit && first) {
      args = arguments;
      first = false;
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton.icon(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            label: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => submitNote(isEdit),
          )
        ],
        title: Text(isEdit ? 'Edit Note' : 'Add Note'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                    //images
                    height: 100,
                    width: 150,
                    child: _pickedImage != null
                        ? Image.file(_pickedImage)
                        : Image.network(
                            args['imageUrl'] == ''
                                ? noImageUrl
                                : args['imageUrl'],
                            fit: BoxFit.contain,
                          ),
                  ),
                  RaisedButton.icon(
                    icon: Icon(
                      Icons.camera,
                      // color: Colors.pink,
                    ),
                    label: Text(
                      args['imageUrl'] == '' ? 'Add image' : 'Change Image',
                      //style: TextStyle(color: Colors.pink),
                    ),
                    onPressed: imagepick,
                  ),
                ],
              ),
              TextFormField(
                initialValue: args['title'],
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.pink)),
                textInputAction: TextInputAction.next,
                onSaved: (val) {
                  args['title'] = val;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter title';
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Description',
                style: TextStyle(color: Colors.pink),
              ),
              TextFormField(
                maxLines: 10,
                initialValue: args['description'],
                decoration: InputDecoration(border: OutlineInputBorder()),
                textInputAction: TextInputAction.next,
                onSaved: (val) {
                  args['description'] = val;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter Description';
                  } else {
                    return null;
                  }
                },
              ),
              Container(
                height: 70,
                child: Row(
                  children: <Widget>[
                    Text(
                      _choosenDate == null
                          ? isEdit
                              ? args['reminderDate'] == ''
                                  ? 'No Reminder Date'
                                  : '${DateFormat.yMMMd().format(DateTime.parse(args['reminderDate']))}'
                              : 'No Reminder Date'
                          : '${DateFormat.yMMMd().format(_choosenDate)}',
                    ),
                    FlatButton(
                      disabledColor: Colors.grey,
                      onPressed: _dateSubmit,
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 70,
                child: Row(
                  children: <Widget>[
                    Text(
                      _choosenTime == null
                          ? isEdit
                              ? args['reminderTime'] == ''
                                  ? 'No Reminder Time'
                                  : '${TimeOfDay.fromDateTime(format.parse(args['reminderTime'])).format(context)}'
                              : 'No Reminder Time'
                          : '${_choosenTime.format(context).toString()}',
                    ),
                    FlatButton(
                      disabledColor: Colors.grey,
                      onPressed: _timeSubmit,
                      child: Text(
                        'Choose Time',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
