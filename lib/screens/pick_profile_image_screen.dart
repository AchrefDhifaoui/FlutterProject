import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forgamers/screens/choosing_games_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forgamers/models/CustomUser.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PickProfileImageScreen extends StatefulWidget {
  final CustomUser user;

  const PickProfileImageScreen({Key? key, required this.user}) : super(key: key);

  @override
  _PickProfileImageScreenState createState() => _PickProfileImageScreenState();
}

class _PickProfileImageScreenState extends State<PickProfileImageScreen> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
    }
  }

  Future<void> _saveProfileImage() async {
    if (_pickedImage != null) {
      Reference storageReference =
      FirebaseStorage.instance.ref().child('profile_images/${widget.user.id}.jpg');

      UploadTask uploadTask = storageReference.putFile(_pickedImage!);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
        'image': downloadURL,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChoosingGamesScreen(user: widget.user, sourcePage: "pickPhoto"),
        ),
      );
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Card(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: const [
                        Icon(Icons.image, size: 60.0),
                        SizedBox(height: 12.0),
                        Text(
                          "Gallery",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      ],
                    ),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: SizedBox(
                      child: Column(
                        children: const [
                          Icon(Icons.camera_alt, size: 60.0),
                          SizedBox(height: 12.0),
                          Text(
                            "Camera",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _imgFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  void _imgFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pick Profile Image'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pickedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(150.0),
                child: Image.file(_pickedImage!, height: 300.0, width: 300.0, fit: BoxFit.fill),
              )
                  : Image.asset('assets/images/no_profile_image.png', height: 300.0, width: 300.0),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _showImagePicker(context),
                    child: Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[800],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveProfileImage,
                    child: Text('Next'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
