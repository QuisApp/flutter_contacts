import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts_example/util/avatar.dart';
import 'package:pretty_json/pretty_json.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with AfterLayoutMixin<ContactPage> {
  Contact? _contact;

  @override
  void afterFirstLayout(BuildContext context) {
    final contact = ModalRoute.of(context)!.settings.arguments as Contact;
    setState(() {
      _contact = contact;
    });
    _fetchContact();
  }

  Future _fetchContact() async {
    // First fetch all contact details
    await _fetchContactWith(highRes: false);

    // Then fetch contact with high resolution photo
    await _fetchContactWith(highRes: true);
  }

  Future _fetchContactWith({required bool highRes}) async {
    final contact = await FlutterContacts.getContact(
      _contact!.id,
      withThumbnail: !highRes,
      withPhoto: highRes,
      withGroups: true,
      withAccounts: true,
    );
    setState(() {
      _contact = contact;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_contact == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Contact'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact!.displayName),
        actions: [
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(prettyJson(_contact!
                      .toJson(withPhoto: false, withThumbnail: false))),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.file_present),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(
                      _contact!.toVCard(withPhoto: false, includeDate: true)),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleOverflowSelected,
            itemBuilder: (BuildContext context) {
              return ['Delete contact', 'External view', 'External edit']
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _body(_contact!),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed('/editContact', arguments: {
          'contact': _contact,
          // A better solution would be to make [ContactPage] listen to DB
          // changes, but this will do for now
          'onUpdate': _fetchContact,
        }),
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget _body(Contact contact) {
    if (_contact?.name == null) {
      return Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withSpacing([
          Center(child: avatar(contact)),
          _makeCard(
              'ID',
              [contact],
              (x) => [
                    Divider(),
                    Text('ID: ${x.id}'),
                    Text('Display name: ${x.displayName}'),
                    Text('Starred: ${x.isStarred}'),
                  ]),
          _makeCard(
              'Name',
              [contact.name],
              (x) => [
                    Divider(),
                    Text('Prefix: ${x.prefix}'),
                    Text('First: ${x.first}'),
                    Text('Middle: ${x.middle}'),
                    Text('Last: ${x.last}'),
                    Text('Suffix: ${x.suffix}'),
                    Text('Nickname: ${x.nickname}'),
                    Text('Phonetic first: ${x.firstPhonetic}'),
                    Text('Phonetic middle: ${x.middlePhonetic}'),
                    Text('Phonetic last: ${x.lastPhonetic}'),
                  ]),
          _makeCard(
              'Phones',
              contact.phones,
              (x) => [
                    Divider(),
                    Text('Number: ${x.number}'),
                    Text('Normalized number: ${x.normalizedNumber}'),
                    Text('Label: ${x.label}'),
                    Text('Custom label: ${x.customLabel}'),
                    Text('Primary: ${x.isPrimary}')
                  ]),
          _makeCard(
              'Emails',
              contact.emails,
              (x) => [
                    Divider(),
                    Text('Address: ${x.address}'),
                    Text('Label: ${x.label}'),
                    Text('Custom label: ${x.customLabel}'),
                    Text('Primary: ${x.isPrimary}')
                  ]),
          _makeCard(
              'Addresses',
              contact.addresses,
              (x) => [
                    Divider(),
                    Text('Address: ${x.address}'),
                    Text('Label: ${x.label}'),
                    Text('Custom label: ${x.customLabel}'),
                    Text('Street: ${x.street}'),
                    Text('PO box: ${x.pobox}'),
                    Text('Neighborhood: ${x.neighborhood}'),
                    Text('City: ${x.city}'),
                    Text('State: ${x.state}'),
                    Text('Postal code: ${x.postalCode}'),
                    Text('Country: ${x.country}'),
                    Text('ISO country: ${x.isoCountry}'),
                    Text('Sub admin area: ${x.subAdminArea}'),
                    Text('Sub locality: ${x.subLocality}'),
                  ]),
          _makeCard(
              'Organizations',
              contact.organizations,
              (x) => [
                    Divider(),
                    Text('Company: ${x.company}'),
                    Text('Title: ${x.title}'),
                    Text('Department: ${x.department}'),
                    Text('Job description: ${x.jobDescription}'),
                    Text('Symbol: ${x.symbol}'),
                    Text('Phonetic name: ${x.phoneticName}'),
                    Text('Office location: ${x.officeLocation}'),
                  ]),
          _makeCard(
              'Websites',
              contact.websites,
              (x) => [
                    Divider(),
                    Text('URL: ${x.url}'),
                    Text('Label: ${x.label}'),
                    Text('Custom label: ${x.customLabel}'),
                  ]),
          _makeCard(
              'Social medias',
              contact.socialMedias,
              (x) => [
                    Divider(),
                    Text('Value: ${x.userName}'),
                    Text('Label: ${x.label}'),
                    Text('Custom label: ${x.customLabel}'),
                  ]),
          _makeCard(
              'Events',
              contact.events,
              (x) => [
                    Divider(),
                    Text('Date: ${_formatDate(x)}'),
                    Text('Label: ${x.label}'),
                    Text('Custom label: ${x.customLabel}'),
                  ]),
          _makeCard(
              'Notes',
              contact.notes,
              (x) => [
                    Divider(),
                    Text('Note: ${x.note}'),
                  ]),
          _makeCard(
              'Groups',
              contact.groups,
              (x) => [
                    Divider(),
                    Text('Group ID: ${x.id}'),
                    Text('Name: ${x.name}'),
                  ]),
          _makeCard(
              'Accounts',
              contact.accounts,
              (x) => [
                    Divider(),
                    Text('Raw IDs: ${x.rawId}'),
                    Text('Type: ${x.type}'),
                    Text('Name: ${x.name}'),
                    Text('Mimetypes: ${x.mimetypes}'),
                  ]),
          _makeCard(
              'Raw JSON',
              [contact],
              (x) => [
                    Divider(),
                    Text(prettyJson(
                        x.toJson(withThumbnail: false, withPhoto: false))),
                  ]),
        ]),
      ),
    );
  }

  String _formatDate(Event e) =>
      '${e.year?.toString().padLeft(4, '0') ?? '--'}/'
      '${e.month.toString().padLeft(2, '0')}/'
      '${e.day.toString().padLeft(2, '0')}';

  List<Widget> _withSpacing(List<Widget> widgets) {
    final spacer = SizedBox(height: 8);
    return <Widget>[spacer] +
        widgets.map((p) => [p, spacer]).expand((p) => p).toList();
  }

  Card _makeCard(
      String title, List fields, List<Widget> Function(dynamic) mapper) {
    var elements = <Widget>[];
    fields.forEach((field) => elements.addAll(mapper(field)));
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _withSpacing(<Widget>[
                Text(title, style: TextStyle(fontSize: 22)),
              ] +
              elements),
        ),
      ),
    );
  }

  Future<void> _handleOverflowSelected(String choice) async {
    if (choice == 'Delete contact') {
      await _contact!.delete();
      Navigator.of(context).pop();
    } else if (choice == 'External view') {
      await FlutterContacts.openExternalView(_contact!.id);
    } else if (choice == 'External edit') {
      await FlutterContacts.openExternalEdit(_contact!.id);
    }
  }
}
