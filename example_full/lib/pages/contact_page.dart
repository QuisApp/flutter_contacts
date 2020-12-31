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
  Contact _contact;

  @override
  void afterFirstLayout(BuildContext context) {
    final contact = ModalRoute.of(context).settings.arguments as Contact;
    setState(() {
      _contact = contact;
    });
    _fetchContact();
  }

  Future _fetchContact() async {
    // First fetch all contact details
    await _fetchContactWith(false);

    // Then fetch contact with high resolution photo
    await _fetchContactWith(true);
  }

  Future _fetchContactWith(bool highRes) async {
    final contact = await FlutterContacts.getContact(_contact.id,
        useHighResolutionPhotos: highRes);
    setState(() {
      _contact = contact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact?.displayName ?? ''),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('Delete contact'), value: _contact.id)
            ],
            onSelected: (contactId) async {
              await FlutterContacts.deleteContact(contactId);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('Deleted contact ${_contact?.displayName ?? ''}')));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _body(_contact),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () =>
            Navigator.of(context).pushNamed('/editContact', arguments: {
          'contact': _contact,
          // A better solution would be to make [ContactPage] listen to DB
          // changes, but this will do for now
          'onUpdate': _fetchContact,
        }),
      ),
    );
  }

  Widget _body(Contact contact) {
    if (_contact?.name == null)
      return Center(child: CircularProgressIndicator());
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
                    Text('Date: ${x.date}'),
                    Text('Label: ${x.label}'),
                    Text('Custom label: ${x.customLabel}'),
                    Text('No year: ${x.noYear}'),
                  ]),
          _makeCard(
              'Notes',
              contact.notes,
              (x) => [
                    Divider(),
                    Text('Note: ${x.note}'),
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
                    Text(prettyJson(x.toJson())),
                  ]),
        ]),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    final spacer = SizedBox(height: 8);
    return <Widget>[spacer] +
        widgets.map((p) => [p, spacer]).expand((p) => p).toList();
  }

  Card _makeCard(
      String title, List fields, List<Widget> Function(dynamic) mapper) {
    var elements = <Widget>[];
    fields?.forEach((field) => elements.addAll(mapper(field)));
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
}
