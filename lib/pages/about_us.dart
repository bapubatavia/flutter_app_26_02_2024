import 'dart:typed_data';
import 'package:app_with_tabs/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  Uint8List? _image;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  void selectImage(String type) async {
    Uint8List img;
    type == 'camera'
        ? img = await pickImage(ImageSource.camera)
        : img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    String email = user?.email ?? 'No email found';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator ID card', style: TextStyle(fontSize: 18.0)),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        titleTextStyle: const TextStyle(color: Colors.white),
        elevation: 0.0,
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                                'https://static-00.iconduck.com/assets.00/avatar-default-icon-1975x2048-2mpk4u9k.png'),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return OptionDialog(
                                onSelectImage: selectImage,
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 60.0,
                color: Colors.grey[900],
              ),
              Text(
                'EMAIL',
                style: TextStyle(
                  color: Colors.grey[800],
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                email,
                style: TextStyle(
                    color: Colors.green[400],
                    letterSpacing: 2.0,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}

class OptionDialog extends StatelessWidget {
  final Function(String) onSelectImage;

  const OptionDialog({super.key, required this.onSelectImage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose an option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Take a photo'),
            onTap: () {
              onSelectImage('camera');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Select from gallery'),
            onTap: () {
              onSelectImage('gallery');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}