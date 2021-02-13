import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) pickedImageFn;
  UserImagePicker(this.pickedImageFn);
  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  void imagepick() async {
    final pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.pickedImageFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          child: _pickedImage == null
              ? Icon(
                  Icons.image,
                  color: Colors.black,
                )
              : null,
          backgroundImage:
              _pickedImage == null ? null : FileImage(_pickedImage),
          radius: 40,
        ),
        FlatButton.icon(
          onPressed: imagepick,
          icon: Icon(Icons.camera),
          label: Text('add image'),
        )
      ],
    );
  }
}
