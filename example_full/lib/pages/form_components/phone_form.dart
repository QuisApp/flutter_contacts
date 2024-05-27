import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/phone.dart';

class PhoneForm extends StatefulWidget {
  final Phone phone;
  final void Function(Phone) onUpdate;
  final void Function() onDelete;

  PhoneForm(
    this.phone, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _PhoneFormState createState() => _PhoneFormState();
}

class _PhoneFormState extends State<PhoneForm> {
  final _formKey = GlobalKey<FormState>();
  static final _validLabels = PhoneLabel.values;

  late TextEditingController _numberController;
  late PhoneLabel _label;
  late TextEditingController _customLabelController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.phone.number);
    _label = widget.phone.label;
    _customLabelController =
        TextEditingController(text: widget.phone.customLabel);
  }

  void _onChanged() {
    final phone = Phone(_numberController.text,
        label: _label,
        customLabel:
            _label == PhoneLabel.custom ? _customLabelController.text : '');
    widget.onUpdate(phone);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: PopupMenuButton(
        itemBuilder: (context) =>
            [PopupMenuItem(value: 'Delete', child: Text('Delete'))],
        onSelected: (_) => widget.onDelete(),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          onChanged: _onChanged,
          child: Column(
            children: [
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: 'Phone'),
              ),
              DropdownButtonFormField(
                isExpanded: true, // to avoid overflow
                items: _validLabels
                    .map((e) => DropdownMenuItem<PhoneLabel>(
                        value: e, child: Text(e.toString())))
                    .toList(),
                value: _label,
                onChanged: (PhoneLabel? label) {
                  setState(() {
                    if (label != null) _label = label;
                  });
                  // Unfortunately, the form's `onChanged` gets triggered before
                  // the dropdown's `onChanged`, so it doesn't update the
                  // contact when updating the dropdown, and we need to do it
                  // explicitly here.
                  _onChanged();
                },
              ),
              _label == PhoneLabel.custom
                  ? TextFormField(
                      controller: _customLabelController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: 'Custom label'),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
