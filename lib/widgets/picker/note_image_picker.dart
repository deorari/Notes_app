import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NoteImagePicker extends StatefulWidget {
  final void Function(File image) pickedImageFn;
  NoteImagePicker(this.pickedImageFn);
  @override
  _NoteImagePickerState createState() => _NoteImagePickerState();
}

class _NoteImagePickerState extends State<NoteImagePicker> {
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
