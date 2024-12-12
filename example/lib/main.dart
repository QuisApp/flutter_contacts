import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() => runApp(FlutterContactsExample());

class FlutterContactsExample extends StatefulWidget {
  @override
  _FlutterContactsExampleState createState() => _FlutterContactsExampleState();
}

class _FlutterContactsExampleState extends State<FlutterContactsExample> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
        withThumbnail: true,
        sorted: true
      );
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text('flutter_contacts_example')),
          body: _body()));

  Widget _body() {
    if (_permissionDenied) return Center(child: Text('Permission denied'));
    if (_contacts == null) return Center(child: CircularProgressIndicator());
    return ListView.builder(
        itemCount: _contacts!.length,
        itemBuilder: (context, i) => ListTile(
            leading: _contacts![i].thumbnail != null
                ? CircleAvatar(backgroundImage: MemoryImage(_contacts![i].thumbnail!))
                : CircleAvatar(child: Text(_contacts![i].displayName[0])),
            title: Text(_contacts![i].displayName),
            subtitle: Text(
                _contacts![i].phones.isNotEmpty ? _contacts![i].phones.first.number : ''),
            onTap: () async {
              final fullContact = await FlutterContacts.getContact(_contacts![i].id);
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ContactPage(fullContact!)));
            }));
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  ContactPage(this.contact);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(contact.displayName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.photo != null)
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: MemoryImage(contact.photo!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Text('First name: ${contact.name.first}'),
            Text('Last name: ${contact.name.last}'),
            Text(
                'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}'),
            Text(
                'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}'),
          ],
        ),
      ));
}
