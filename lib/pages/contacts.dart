import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';



class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);
  
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>{
  List<Contact> _contacts = [];

  @override
  void initState(){
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus == PermissionStatus.granted) {
      _loadContacts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts', style: TextStyle(fontSize: 18.0)),
      ) ,
      body: ListView.builder(
        itemCount:  _contacts.length,
        itemBuilder: (context, index){
          Contact contact = _contacts[index];
          return ListTile(
            leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.avatar!),
                  )
                : CircleAvatar(
                    child: Text(contact.initials()),
                  ),
            title: Text(contact.displayName ?? ''),
            subtitle: Text(contact.phones!.isNotEmpty ? contact.phones!.first.value ??'': ''),
            trailing: GestureDetector(
              onTap: () {
                if (contact.phones != null && contact.phones!.isNotEmpty){
                  String phoneNumber = contact.phones!.first.value!;
                  launch("tel:$phoneNumber");
                }
              },
              child: Icon(Icons.call),
            ),
          );
        })
    );
  }
}