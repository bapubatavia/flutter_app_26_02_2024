import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';



class ContactPage extends StatefulWidget {
  const ContactPage({super.key});
  
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>{
  List<Contact>? _contacts = [];

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
    // } else {
    //   _handleInvalidPermissions(permissionStatus);
    // }
  }


  Future<void> _loadContacts() async {
    // Load contacts if permission is granted
    List<Contact> contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
      withAccounts: true,
    );
    setState(() {
      _contacts = contacts;
    });
  }

  // void _handleInvalidPermissions(PermissionStatus permissionStatus) {
  //   if (permissionStatus == PermissionStatus.denied) {
  //     const snackBar = SnackBar(content: Text('Access to contact data denied'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
  //     const snackBar = SnackBar(content: Text('Contact data not available on device'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  String _getInitials(String displayName) {
    if (displayName.isEmpty) return '';

    final names = displayName.trim().split(' ');
    if (names.isEmpty) return '';

    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }

    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts', style: TextStyle(fontSize: 18.0)),
      ) ,
      body: ListView.builder(
        itemCount:  _contacts!.length,
        itemBuilder: (context, index){
          Contact? contact = _contacts![index];
          return ListTile(
            leading: contact.photo != null
                ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.photo!),
                  )
                : CircleAvatar(
                    child: Text(_getInitials(contact.displayName)),
                  ),
            title: Text(contact.displayName),
            subtitle: contact.phones.isNotEmpty
                ? Text(contact.phones.first.number)
                : const Text(''),
            trailing: contact.phones.isNotEmpty
              ? IconButton(
                onPressed: () => _makePhoneCall(contact.phones.first.number),
                icon: const Icon(Icons.call)
                )
                : null,

            // GestureDetector(
            //   onTap: () {
            //     if (contact.phones != null && contact.phones!.isNotEmpty){
            //       String phoneNumber = contact.phones!.first.value!;
            //       launch("tel:$phoneNumber");
            //     }
            //   },
            //   child: const Icon(Icons.call),
            // ),
          );
        })
    );
  }
}