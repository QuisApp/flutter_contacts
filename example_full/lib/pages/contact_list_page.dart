import 'dart:developer';

import 'package:after_layout/after_layout.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts_example/util/avatar.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage>
    with AfterLayoutMixin<ContactListPage> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      setState(() {
        _contacts = null;
        _permissionDenied = true;
      });
      return;
    }

    await _refetchContacts();

    // Listen to DB changes
    FlutterContacts.addListener(() async {
      print('Contacts DB changed, refecthing contacts');
      await _refetchContacts();
    });
  }

  Future _refetchContacts() async {
    // First load all contacts without photo
    await _loadContacts(false);

    // Next with photo
    await _loadContacts(true);
  }

  Future _loadContacts(bool withPhotos) async {
    final contacts = withPhotos
        ? (await FlutterContacts.getContacts(withThumbnail: true)).toList()
        : (await FlutterContacts.getContacts()).toList();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('flutter_contacts_example'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _handleOverflowSelected,
              itemBuilder: (_) => [
                'Groups',
                'Insert external',
                'Insert external (prepopulated)',
              ].map(_menuItemBuilder).toList(),
            ),
          ],
        ),
        body: _body(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed('/editContact'),
          child: Icon(Icons.add),
        ),
      );

  Widget _body() {
    if (_permissionDenied) {
      return Center(child: Text('Permission denied'));
    }
    if (_contacts == null) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, i) {
        final contact = _contacts![i];
        return ListTile(
          leading: avatar(contact, 18.0),
          title: Text(contact.displayName),
          onTap: () => Navigator.of(context).pushNamed(
            '/contact',
            arguments: contact,
          ),
        );
      },
    );
  }

  void _handleOverflowSelected(String value) {
    switch (value) {
      case 'Groups':
        Navigator.of(context).pushNamed('/groups');
        break;
      case 'Insert external':
        FlutterContacts.openExternalInsert();
        break;
      case 'Insert external (prepopulated)':
        FlutterContacts.openExternalInsert(
          Contact(
            name: Name(first: 'John', last: 'Doe'),
            phones: [Phone('+1 555-123-4567')],
            emails: [Email('john.doe@gmail.com')],
            addresses: [Address('123 Main St')],
            websites: [Website('https://flutter.dev')],
            organizations: [
              Organization(company: 'Flutter', title: 'Developer')
            ],
          ),
        );
        break;
      default:
        log('Unknown overflow menu item: $value');
    }
  }

  static PopupMenuItem<String> _menuItemBuilder(String choice) {
    return PopupMenuItem<String>(
      value: choice,
      child: Text(choice),
    );
  }
}
