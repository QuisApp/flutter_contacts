import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts_example/pages/form_components/address_form.dart';
import 'package:flutter_contacts_example/pages/form_components/email_form.dart';
import 'package:flutter_contacts_example/pages/form_components/event_form.dart';
import 'package:flutter_contacts_example/pages/form_components/name_form.dart';
import 'package:flutter_contacts_example/pages/form_components/note_form.dart';
import 'package:flutter_contacts_example/pages/form_components/organization_form.dart';
import 'package:flutter_contacts_example/pages/form_components/phone_form.dart';
import 'package:flutter_contacts_example/pages/form_components/social_media_form.dart';
import 'package:flutter_contacts_example/pages/form_components/website_form.dart';
import 'package:flutter_contacts_example/util/avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pretty_json/pretty_json.dart';

class EditContactPage extends StatefulWidget {
  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage>
    with AfterLayoutMixin<EditContactPage> {
  var _contact = Contact();
  bool _isEdit = false;
  void Function()? _onUpdate;

  final _imagePicker = ImagePicker();

  @override
  void afterFirstLayout(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      _contact = args['contact'];
      _isEdit = true;
      _onUpdate = args['onUpdate'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isEdit ? 'Edit' : 'New'} contact'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(prettyJson(
                      _contact.toJson(withPhoto: false, withThumbnail: false))),
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
                      _contact.toVCard(withPhoto: false, includeDate: true)),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (_isEdit) {
                await _contact.update(withGroups: true);
              } else {
                await _contact.insert();
              }
              if (_onUpdate != null) _onUpdate!();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Form(
          child: Column(
            children: _contactFields(),
          ),
        ),
      ),
    );
  }

  List<Widget> _contactFields() => [
        _photoField(),
        _starredField(),
        _nameCard(),
        _phoneCard(),
        _emailCard(),
        _addressCard(),
        _organizationCard(),
        _websiteCard(),
        _socialMediaCard(),
        _eventCard(),
        _noteCard(),
        _groupCard(),
      ];

  Future _pickPhoto() async {
    final photo = await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _contact.photo = bytes;
      });
    }
  }

  Widget _photoField() => Stack(children: [
        Center(
            child: InkWell(
          onTap: _pickPhoto,
          child: avatar(_contact, 48, Icons.add),
        )),
        _contact.photo == null
            ? Container()
            : Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'Delete', child: Text('Delete photo'))
                  ],
                  onSelected: (_) => setState(() {
                    _contact.photo = null;
                  }),
                ),
              ),
      ]);

  Card _fieldCard(
    String fieldName,
    List<dynamic> fields,
    /* void | Future<void> */ Function()? addField,
    Widget Function(int, dynamic) formWidget,
    void Function()? clearAllFields, {
    bool createAsync = false,
  }) {
    var forms = <Widget>[
      Text(fieldName, style: TextStyle(fontSize: 18)),
    ];
    fields.asMap().forEach((int i, dynamic p) => forms.add(formWidget(i, p)));
    void Function() onPressed;
    if (createAsync) {
      onPressed = () async {
        if (addField != null) await addField();
        setState(() {});
      };
    } else {
      onPressed = () => setState(() {
            if (addField != null) addField();
          });
    }
    var buttons = <ElevatedButton>[];
    if (addField != null) {
      buttons.add(
        ElevatedButton(
          onPressed: onPressed,
          child: Text('+ New'),
        ),
      );
    }
    if (clearAllFields != null) {
      buttons.add(ElevatedButton(
        onPressed: () {
          clearAllFields();
          setState(() {});
        },
        child: Text('Delete all'),
      ));
    }
    if (buttons.isNotEmpty) {
      forms.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons,
      ));
    }

    return Card(
      margin: EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: forms,
          ),
        ),
      ),
    );
  }

  Card _nameCard() => _fieldCard(
        'Name',
        [_contact.name],
        null,
        (int i, dynamic n) => NameForm(
          n,
          onUpdate: (name) => _contact.name = name,
          key: UniqueKey(),
        ),
        null,
      );

  Card _phoneCard() => _fieldCard(
        'Phones',
        _contact.phones,
        () => _contact.phones = _contact.phones + [Phone('')],
        (int i, dynamic p) => PhoneForm(
          p,
          onUpdate: (phone) => _contact.phones[i] = phone,
          onDelete: () => setState(() => _contact.phones.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.phones = [],
      );

  Card _emailCard() => _fieldCard(
        'Emails',
        _contact.emails,
        () => _contact.emails = _contact.emails + [Email('')],
        (int i, dynamic e) => EmailForm(
          e,
          onUpdate: (email) => _contact.emails[i] = email,
          onDelete: () => setState(() => _contact.emails.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.emails = [],
      );

  Card _addressCard() => _fieldCard(
        'Addresses',
        _contact.addresses,
        () => _contact.addresses = _contact.addresses + [Address('')],
        (int i, dynamic a) => AddressForm(
          a,
          onUpdate: (address) => _contact.addresses[i] = address,
          onDelete: () => setState(() => _contact.addresses.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.addresses = [],
      );

  Card _organizationCard() => _fieldCard(
        'Organizations',
        _contact.organizations,
        () =>
            _contact.organizations = _contact.organizations + [Organization()],
        (int i, dynamic o) => OrganizationForm(
          o,
          onUpdate: (organization) => _contact.organizations[i] = organization,
          onDelete: () => setState(() => _contact.organizations.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.organizations = [],
      );

  Card _websiteCard() => _fieldCard(
        'Websites',
        _contact.websites,
        () => _contact.websites = _contact.websites + [Website('')],
        (int i, dynamic w) => WebsiteForm(
          w,
          onUpdate: (website) => _contact.websites[i] = website,
          onDelete: () => setState(() => _contact.websites.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.websites = [],
      );

  Card _socialMediaCard() => _fieldCard(
        'Social medias',
        _contact.socialMedias,
        () => _contact.socialMedias = _contact.socialMedias + [SocialMedia('')],
        (int i, dynamic w) => SocialMediaForm(
          w,
          onUpdate: (socialMedia) => _contact.socialMedias[i] = socialMedia,
          onDelete: () => setState(() => _contact.socialMedias.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.socialMedias = [],
      );

  Future<DateTime?> _selectDate(BuildContext context) async => showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(3000));

  Card _eventCard() => _fieldCard(
        'Events',
        _contact.events,
        () async {
          final date = await _selectDate(context);
          if (date != null) {
            _contact.events = _contact.events +
                [Event(year: date.year, month: date.month, day: date.day)];
          }
        },
        (int i, dynamic w) => EventForm(
          w,
          onUpdate: (event) => _contact.events[i] = event,
          onDelete: () => setState(() => _contact.events.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.events = [],
        createAsync: true,
      );

  Card _noteCard() => _fieldCard(
        'Notes',
        _contact.notes,
        () => _contact.notes = _contact.notes + [Note('')],
        (int i, dynamic w) => NoteForm(
          w,
          onUpdate: null,
          onDelete: () => setState(() => _contact.groups.removeAt(i)),
          key: UniqueKey(),
        ),
        () => _contact.notes = [],
      );

  Card _groupCard() => _fieldCard(
        'Groups',
        _contact.groups,
        () async {
          final group = await _promptGroup(exclude: _contact.groups);
          if (group != null) {
            setState(() => _contact.groups = _contact.groups + [group]);
          }
        },
        (int i, dynamic w) => ListTile(
          title: Text(_contact.groups[i].name),
          trailing: IconButton(
            onPressed: () => setState(() => _contact.groups.removeAt(i)),
            icon: Icon(Icons.delete),
          ),
        ),
        () => setState(() => _contact.groups = []),
      );

  Card _starredField() => Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Starred'),
            SizedBox(width: 24.0),
            Checkbox(
              value: _contact.isStarred,
              onChanged: (bool? isStarred) =>
                  setState(() => _contact.isStarred = isStarred ?? false),
            ),
          ],
        ),
      );

  Future<Group?> _promptGroup({required List<Group> exclude}) async {
    final excludeIds = exclude.map((x) => x.id).toSet();
    final groups = (await FlutterContacts.getGroups())
        .where((g) => !excludeIds.contains(g.id))
        .toList();
    Group? selectedGroup;
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        content: Container(
          height: 300.0,
          width: 300.0,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: groups.length,
            itemBuilder: (BuildContext ctx, int i) => ListTile(
              title: Text(groups[i].name),
              onTap: () {
                selectedGroup = groups[i];
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ),
      ),
    );
    return selectedGroup;
  }
}
