import 'package:flutter/material.dart';
import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'pages/contact_list_page.dart';
import 'pages/contact_page.dart';
import 'pages/edit_contact_page.dart';
import 'pages/groups_page.dart';

void main() {
  FlutterContacts.config.vCardVersion = VCardVersion.v4;
  runApp(FlutterContactsExample());
}

class FlutterContactsExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_contacts_example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/contactList',
      routes: {
        '/contactList': (context) => ContactListPage(),
        '/contact': (context) => ContactPage(),
        '/editContact': (context) => EditContactPage(),
        '/groups': (context) => GroupsPage(),
      },
    );
  }
}
