import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/note.dart';

class NoteForm extends StatefulWidget {
  final Note note;
  final void Function(Note)? onUpdate;
  final void Function() onDelete;

  NoteForm(
    this.note, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note.note);
  }

  void _onChanged() {
    final note = Note(
      _noteController.text,
    );
    if (widget.onUpdate != null) widget.onUpdate!(note);
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
                controller: _noteController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                minLines: 3,
                decoration: InputDecoration(hintText: 'Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
