import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/custom_field.dart';

class CustomFieldForm extends StatefulWidget {
  final CustomField customField;
  final void Function(CustomField) onUpdate;
  final void Function() onDelete;

  CustomFieldForm(
    this.customField, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _CustomFieldFormState createState() => _CustomFieldFormState();
}

class _CustomFieldFormState extends State<CustomFieldForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customField.name);
    _labelController = TextEditingController(text: widget.customField.label);
  }

  void _onChanged() {
    final customField = CustomField(
      _nameController.text,
      _labelController.text,
    );
    widget.onUpdate(customField);
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
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: 'Name'),
              ),
              TextFormField(
                controller: _labelController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: 'Label'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
