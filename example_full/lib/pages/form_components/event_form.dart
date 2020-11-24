import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/event.dart';

class EventForm extends StatefulWidget {
  final Event event;
  final void Function(Event) onUpdate;
  final void Function() onDelete;

  EventForm(
    this.event, {
    @required this.onUpdate,
    @required this.onDelete,
    Key key,
  }) : super(key: key);

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  static final _validLabels = EventLabel.values;

  TextEditingController _dateController;
  EventLabel _label;
  TextEditingController _customLabelController;
  bool _noYear;

  @override
  void initState() {
    super.initState();
    _dateController =
        TextEditingController(text: widget.event.date?.toIso8601String());
    _label = widget.event.label;
    _customLabelController =
        TextEditingController(text: widget.event.customLabel);
    _noYear = widget.event.noYear;
  }

  void _onChanged() {
    final event = Event(
      DateTime.tryParse(_dateController.text) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      label: _label,
      customLabel:
          _label == EventLabel.custom ? _customLabelController.text : "",
      noYear: _noYear,
    );
    widget.onUpdate(event);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: PopupMenuButton(
        itemBuilder: (context) =>
            [PopupMenuItem(child: Text('Delete'), value: 'Delete')],
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
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(hintText: 'mm/dd/yyyy'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(3000));
                  if (date != null) {
                    setState(() {
                      _dateController.text = date.toIso8601String();
                    });
                  }
                },
              ),
              DropdownButtonFormField(
                isExpanded: true, // to avoid overflow
                items: _validLabels
                    .map((e) => DropdownMenuItem<EventLabel>(
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
              _label == EventLabel.custom
                  ? TextFormField(
                      controller: _customLabelController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: 'Custom label'),
                    )
                  : Container(),
              CheckboxListTile(
                title: Text('No year'),
                value: _noYear,
                onChanged: (noYear) {
                  setState(() => _noYear = noYear);
                  _onChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
