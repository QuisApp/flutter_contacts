import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/event.dart';

class EventForm extends StatefulWidget {
  final Event event;
  final void Function(Event) onUpdate;
  final void Function() onDelete;

  EventForm(
    this.event, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  static final _validLabels = EventLabel.values;

  late TextEditingController _dateController;
  late EventLabel _label;
  late TextEditingController _customLabelController;
  late int _year;
  late int _month;
  late int _day;
  late bool _noYear;

  String _formatDate() =>
      '${_noYear ? '--' : _year.toString().padLeft(4, '0')}/'
      '${_month.toString().padLeft(2, '0')}/'
      '${_day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _label = widget.event.label;
    _customLabelController =
        TextEditingController(text: widget.event.customLabel);
    _year = widget.event.year ?? DateTime.now().year;
    _month = widget.event.month;
    _day = widget.event.day;
    _noYear = widget.event.year == null;
    _dateController = TextEditingController(text: _formatDate());
  }

  void _onChanged() {
    final event = Event(
      year: _noYear ? null : _year,
      month: _month,
      day: _day,
      label: _label,
      customLabel:
          _label == EventLabel.custom ? _customLabelController.text : '',
    );
    widget.onUpdate(event);
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
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(hintText: 'yyyy/mm/dd'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(3000));
                  if (date != null) {
                    setState(() {
                      _year = date.year;
                      _month = date.month;
                      _day = date.day;
                      _dateController.text = _formatDate();
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
                onChanged: (EventLabel? label) {
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
                onChanged: (bool? noYear) {
                  setState(() {
                    _noYear = noYear ?? false;
                    _dateController.text = _formatDate();
                  });
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
