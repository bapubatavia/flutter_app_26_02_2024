// 

import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_with_tabs/utils.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  Uint8List? _image;
  List<Contact> _contacts = [];
  bool _showContacts = false;

  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    // Request contacts permission
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus == PermissionStatus.granted) {
      _loadContacts();
    } else {
      // Handle denied or restricted permission
    }
  }

  Future<void> _loadContacts() async {
    // Load contacts if permission is granted
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
    });
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar = SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
                'NAME',
                style: TextStyle(
                  color: Colors.grey[800],
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Luc Bapu BATAVIA',
                style: TextStyle(
                    color: Colors.green[400],
                    letterSpacing: 2.0,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30.0),
              MaterialButton(
                color: Colors.green[400],
                elevation: 0,
                minWidth: double.infinity,
                height: 40,
                onPressed: () {
                  setState(() {
                    _showContacts = !_showContacts;
                  });
                },
                shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(50),
                ),                
                child: Text(
                  _showContacts ? 'Hide Contacts' : 'Show Contacts',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                ),
              ),
              const SizedBox(height: 10.0),
              Visibility(
                visible: _showContacts,
                child: Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        Contact contact = _contacts[index];
                        return GestureDetector(
                          onTap: (){
                            if(contact.phones != null && contact.phones!.isNotEmpty){
                              String phoneNumber = contact.phones!.first.value!;
                              launch("tel:$phoneNumber");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.horizontal(),
                            ),
                            child: ListTile(
                              leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                                ? CircleAvatar(
                                  backgroundImage: MemoryImage(contact.avatar!),
                                ) 
                                : CircleAvatar(
                                  child: Text(contact.initials()),
                                ),
                              title: Text(contact.displayName ?? ''),
                              subtitle: Text(contact.phones!.isNotEmpty ? contact.phones!.first.value ?? '' : ''),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OptionDialog extends StatelessWidget {
  final Function(String) onSelectImage;

  const OptionDialog({Key? key, required this.onSelectImage}) : super(key: key);

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