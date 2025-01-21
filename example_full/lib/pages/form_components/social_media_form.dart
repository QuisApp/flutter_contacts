import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/social_media.dart';

class SocialMediaForm extends StatefulWidget {
  final SocialMedia socialMedia;
  final void Function(SocialMedia) onUpdate;
  final void Function() onDelete;

  SocialMediaForm(
    this.socialMedia, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _SocialMediaFormState createState() => _SocialMediaFormState();
}

class _SocialMediaFormState extends State<SocialMediaForm> {
  final _formKey = GlobalKey<FormState>();
  static final _validLabels = SocialMediaLabel.values;

  late TextEditingController _userNameController;
  late SocialMediaLabel _label;
  late TextEditingController _customLabelController;

  @override
  void initState() {
    super.initState();
    _userNameController =
        TextEditingController(text: widget.socialMedia.userName);
    _label = widget.socialMedia.label;
    _customLabelController =
        TextEditingController(text: widget.socialMedia.customLabel);
  }

  void _onChanged() {
    final socialMedia = SocialMedia(
      _userNameController.text,
      label: _label,
      customLabel:
          _label == SocialMediaLabel.custom ? _customLabelController.text : '',
    );
    widget.onUpdate(socialMedia);
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
                controller: _userNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: 'User name'),
              ),
              DropdownButtonFormField(
                isExpanded: true, // to avoid overflow
                items: _validLabels
                    .map((e) => DropdownMenuItem<SocialMediaLabel>(
                        value: e, child: Text(e.toString())))
                    .toList(),
                value: _label,
                onChanged: (SocialMediaLabel? label) {
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
              _label == SocialMediaLabel.custom
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
