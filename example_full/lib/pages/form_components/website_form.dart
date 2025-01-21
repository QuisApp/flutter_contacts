import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/website.dart';

class WebsiteForm extends StatefulWidget {
  final Website website;
  final void Function(Website) onUpdate;
  final void Function() onDelete;

  WebsiteForm(
    this.website, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _WebsiteFormState createState() => _WebsiteFormState();
}

class _WebsiteFormState extends State<WebsiteForm> {
  final _formKey = GlobalKey<FormState>();
  static final _validLabels = WebsiteLabel.values;

  late TextEditingController _urlController;
  late WebsiteLabel _label;
  late TextEditingController _customLabelController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.website.url);
    _label = widget.website.label;
    _customLabelController =
        TextEditingController(text: widget.website.customLabel);
  }

  void _onChanged() {
    final website = Website(
      _urlController.text,
      label: _label,
      customLabel:
          _label == WebsiteLabel.custom ? _customLabelController.text : '',
    );
    widget.onUpdate(website);
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
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(hintText: 'URL'),
              ),
              DropdownButtonFormField(
                isExpanded: true, // to avoid overflow
                items: _validLabels
                    .map((e) => DropdownMenuItem<WebsiteLabel>(
                        value: e, child: Text(e.toString())))
                    .toList(),
                value: _label,
                onChanged: (WebsiteLabel? label) {
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
              _label == WebsiteLabel.custom
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
