// Minimal demo app for flutter_contacts plugin.
// For a full-fledged contacts app, see https://github.com/QuisApp/flutter_contacts_example

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    home: const ContactListPage(),
  ),
);

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});
  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact>? _contacts;
  StreamSubscription? _sub;
  bool _denied = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final s = await FlutterContacts.permissions.request(
      PermissionType.readWrite,
    );
    if (s != PermissionStatus.granted && s != PermissionStatus.limited) {
      return setState(() => _denied = true);
    }
    _sub = FlutterContacts.onContactChange.listen((changes) {
      for (final c in changes) {
        print('Contact ${c.type.name}: ${c.contactId}'); // ignore: avoid_print
      }
      _load();
    });
    _load();
  }

  Future<void> _load() async {
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.photoThumbnail},
    );
    setState(() => _contacts = contacts);
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Contacts')),
    body: _denied
        ? const Center(child: Text('Contact permission not granted'))
        : _contacts == null
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _contacts!.length,
            itemBuilder: (_, i) {
              final c = _contacts![i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: c.photo?.thumbnail != null
                      ? MemoryImage(c.photo!.thumbnail!)
                      : null,
                  child: c.photo?.thumbnail == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(c.displayName ?? '(No name)'),
                onTap: () => _open(ContactPage(id: c.id!)),
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => _open(const EditContactPage()),
    ),
  );
}

class ContactPage extends StatelessWidget {
  final String id;
  const ContactPage({super.key, required this.id});

  Future<Contact?> _load() => FlutterContacts.get(
    id,
    properties: {
      ContactProperty.name,
      ContactProperty.phone,
      ContactProperty.email,
      ContactProperty.photoThumbnail,
      ContactProperty.photoFullRes,
    },
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<Contact?>(
    future: _load(),
    builder: (context, snap) {
      final c = snap.data;
      final photo = c?.photo?.fullSize ?? c?.photo?.thumbnail;
      return Scaffold(
        appBar: AppBar(
          title: Text(c?.displayName ?? ''),
          actions: [
            if (c != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditContactPage(contact: c),
                  ),
                ),
              ),
          ],
        ),
        body: c == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  if (photo != null)
                    Image.memory(photo, height: 200, fit: BoxFit.cover),
                  for (final p in c.phones)
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(p.number),
                    ),
                  for (final e in c.emails)
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(e.address),
                    ),
                ],
              ),
      );
    },
  );
}

class EditContactPage extends StatefulWidget {
  final Contact? contact;
  const EditContactPage({super.key, this.contact});
  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late final _first = TextEditingController(
    text: widget.contact?.name?.first ?? '',
  );
  late final _last = TextEditingController(
    text: widget.contact?.name?.last ?? '',
  );
  late final _phones = (widget.contact?.phones ?? [])
      .map((p) => TextEditingController(text: p.number))
      .toList();
  late final _emails = (widget.contact?.emails ?? [])
      .map((e) => TextEditingController(text: e.address))
      .toList();

  Future<void> _save() async {
    final phones = [
      for (final c in _phones)
        if (c.text.isNotEmpty) Phone(number: c.text),
    ];
    final emails = [
      for (final c in _emails)
        if (c.text.isNotEmpty) Email(address: c.text),
    ];
    final name = Name(first: _first.text, last: _last.text);
    if (widget.contact == null) {
      await FlutterContacts.create(
        Contact(name: name, phones: phones, emails: emails),
      );
    } else {
      await FlutterContacts.update(
        widget.contact!.copyWith(name: name, phones: phones, emails: emails),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.contact == null ? 'New Contact' : 'Edit Contact'),
      actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _first,
          decoration: const InputDecoration(labelText: 'First name'),
        ),
        TextField(
          controller: _last,
          decoration: const InputDecoration(labelText: 'Last name'),
        ),
        const SizedBox(height: 16),
        _section('Phones', _phones, TextInputType.phone),
        const SizedBox(height: 16),
        _section('Emails', _emails, TextInputType.emailAddress),
      ],
    ),
  );

  Widget _section(
    String title,
    List<TextEditingController> ctrls,
    TextInputType type,
  ) => Column(
    children: [
      Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => ctrls.add(TextEditingController())),
          ),
        ],
      ),
      for (final c in ctrls)
        TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: title.substring(0, title.length - 1),
          ),
          keyboardType: type,
        ),
    ],
  );
}
