// Minimal demo app for flutter_contacts plugin.
// For a full-fledged contacts app, see https://github.com/QuisApp/flutter_contacts_example

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// Predefined mimetypes that a contact's raw_contact may carry under
// `ContactsContract.Data.MIMETYPE`. A contact passes a mimetype filter if any
// of its raw_contacts has at least one data row with the given mimetype.
const _predefinedMimetypes = <_Predicate>[
  _Predicate('phone_v2', 'vnd.android.cursor.item/phone_v2'),
  _Predicate('email_v2', 'vnd.android.cursor.item/email_v2'),
  _Predicate('name', 'vnd.android.cursor.item/name'),
  _Predicate('photo', 'vnd.android.cursor.item/photo'),
  _Predicate('postal', 'vnd.android.cursor.item/postal-address_v2'),
];

// Predefined `RawContacts.ACCOUNT_TYPE` values. A contact passes an account
// filter if any of its raw_contacts is in one of the checked accounts.
const _predefinedAccountTypes = <_Predicate>[
  _Predicate('Google', 'com.google'),
  _Predicate('WhatsApp', 'com.whatsapp'),
  _Predicate('Viber', 'com.viber.voip'),
  _Predicate('Telegram', 'org.telegram.messenger'),
];

class _Predicate {
  final String label;
  final String value;
  const _Predicate(this.label, this.value);
}

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

  // OR-combined: a contact passes if any of its raw_contacts matches any of
  // these mimetypes OR any of these account types. Empty sets mean "no
  // constraint" - i.e. all contacts pass.
  final Set<String> _requireMimetypes = {};
  final Set<String> _requireAccountTypes = {};

  bool get _filterActive =>
      _requireMimetypes.isNotEmpty || _requireAccountTypes.isNotEmpty;

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
      properties: {
        ContactProperty.photoThumbnail,
        if (_filterActive && Platform.isAndroid) ...{
          ContactProperty.identifiers,
          ContactProperty.dataMimetypes,
        },
      },
    );
    setState(() => _contacts = contacts);
  }

  bool _passesFilter(Contact c) {
    if (!Platform.isAndroid || !_filterActive) return true;
    final raws = c.android?.identifiers?.rawContacts ?? const [];
    if (raws.isEmpty) return true; // device-local; vendor ROMs may hide account
    return raws.any(
      (rc) =>
          rc.dataMimetypes.any(_requireMimetypes.contains) ||
          _requireAccountTypes.contains(rc.account?.type),
    );
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _buildActiveFilterChips() {
    final mimetypeLabels = {
      for (final p in _predefinedMimetypes) p.value: p.label,
    };
    final accountLabels = {
      for (final p in _predefinedAccountTypes) p.value: p.label,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Pass if any:', style: TextStyle(fontSize: 12)),
          for (final mt in _requireMimetypes)
            Chip(
              label: Text('mime: ${mimetypeLabels[mt] ?? mt}'),
              visualDensity: VisualDensity.compact,
              onDeleted: () {
                setState(() => _requireMimetypes.remove(mt));
                _load();
              },
            ),
          for (final at in _requireAccountTypes)
            Chip(
              label: Text('account: ${accountLabels[at] ?? at}'),
              visualDensity: VisualDensity.compact,
              onDeleted: () {
                setState(() => _requireAccountTypes.remove(at));
                _load();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Android filter (OR across all checked rows)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'A contact passes if any of its raw_contacts matches any '
                  'checked mimetype OR any checked account type. Empty = no filter.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Require mimetype',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              for (final p in _predefinedMimetypes)
                CheckboxListTile(
                  dense: true,
                  title: Text(p.label),
                  subtitle: Text(p.value, style: const TextStyle(fontSize: 11)),
                  value: _requireMimetypes.contains(p.value),
                  onChanged: (v) {
                    setSheet(() {
                      v == true
                          ? _requireMimetypes.add(p.value)
                          : _requireMimetypes.remove(p.value);
                    });
                  },
                ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Require account type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              for (final p in _predefinedAccountTypes)
                CheckboxListTile(
                  dense: true,
                  title: Text(p.label),
                  subtitle: Text(p.value, style: const TextStyle(fontSize: 11)),
                  value: _requireAccountTypes.contains(p.value),
                  onChanged: (v) {
                    setSheet(() {
                      v == true
                          ? _requireAccountTypes.add(p.value)
                          : _requireAccountTypes.remove(p.value);
                    });
                  },
                ),
              if (_filterActive)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear all'),
                    onPressed: () => setSheet(() {
                      _requireMimetypes.clear();
                      _requireAccountTypes.clear();
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (mounted) {
      setState(() {});
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = _contacts ?? const <Contact>[];
    final visible = _filterActive ? all.where(_passesFilter).toList() : all;
    final filteredOut = all.length - visible.length;
    return Scaffold(
      appBar: AppBar(
        title: _contacts == null
            ? const Text('Contacts')
            : Text(
                _filterActive
                    ? 'Contacts (${visible.length} of ${all.length}, $filteredOut hidden)'
                    : 'Contacts (${all.length})',
              ),
        actions: [
          if (Platform.isAndroid)
            IconButton(
              tooltip: 'Configure Android filter',
              icon: Icon(
                _filterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              onPressed: _openFilterSheet,
            ),
        ],
      ),
      body: _denied
          ? const Center(child: Text('Contact permission not granted'))
          : _contacts == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_filterActive) _buildActiveFilterChips(),
                Expanded(
                  child: ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (_, i) {
                      final c = visible[i];
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
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _open(const EditContactPage()),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  final String id;
  const ContactPage({super.key, required this.id});

  List<Widget> _buildRawContactsSection(Contact c) {
    final raws = c.android?.identifiers?.rawContacts ?? const [];
    if (raws.isEmpty) return const [];
    return [
      const Divider(),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          'Raw contacts (Android)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      for (final rc in raws)
        ListTile(
          leading: const Icon(Icons.account_tree_outlined),
          title: Text(rc.account?.type ?? '(no account)'),
          subtitle: Text(
            'rawContactId=${rc.rawContactId}\n'
            'mimetypes: ${rc.dataMimetypes.join(", ")}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
          isThreeLine: true,
        ),
    ];
  }

  Future<Contact?> _load() => FlutterContacts.get(
    id,
    properties: {
      ContactProperty.name,
      ContactProperty.phone,
      ContactProperty.email,
      ContactProperty.photoThumbnail,
      ContactProperty.photoFullRes,
      if (Platform.isAndroid) ...{
        ContactProperty.identifiers,
        ContactProperty.dataMimetypes,
      },
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
                  if (Platform.isAndroid) ..._buildRawContactsSection(c),
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
