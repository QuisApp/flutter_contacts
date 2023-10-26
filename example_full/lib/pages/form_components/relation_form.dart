import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/relation.dart';

class RelationForm extends StatefulWidget {
  final Relation relation;
  final void Function(Relation) onUpdate;
  final void Function() onDelete;

  RelationForm(
    this.relation, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _RelationFormState createState() => _RelationFormState();
}

class _RelationFormState extends State<RelationForm> {
  final _formKey = GlobalKey<FormState>();
  static final _validLabels = RelationLabel.values;

  late TextEditingController _nameController;
  RelationLabel? _label;
  late TextEditingController _customLabelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.relation.name);
    _label = widget.relation.label;
    _customLabelController =
        TextEditingController(text: widget.relation.customLabel);
  }

  void _onChanged() {
    if (_label != null) {
      final email = Relation(
        _nameController.text,
        label: _label!,
        customLabel:
            _label == RelationLabel.custom ? _customLabelController.text : '',
      );
      widget.onUpdate(email);
    }
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
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'Name'),
              ),
              DropdownButtonFormField(
                isExpanded: true, // to avoid overflow
                items: _validLabels
                    .map((e) => DropdownMenuItem<RelationLabel>(
                        value: e, child: Text(e.toString())))
                    .toList(),
                value: _label,
                onChanged: (label) {
                  setState(() {
                    _label = label;
                  });
                  // Unfortunately, the form's `onChanged` gets triggered before
                  // the dropdown's `onChanged`, so it doesn't update the
                  // contact when updating the dropdown, and we need to do it
                  // explicitly here.
                  _onChanged();
                },
              ),
              _label == RelationLabel.custom
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
