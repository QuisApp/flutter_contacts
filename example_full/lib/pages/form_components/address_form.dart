import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/address.dart';

class AddressForm extends StatefulWidget {
  final Address address;
  final void Function(Address) onUpdate;
  final void Function() onDelete;

  AddressForm(
    this.address, {
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  static final _validLabels = AddressLabel.values;

  late TextEditingController _addressController;
  late AddressLabel _label;
  late TextEditingController _customLabelController;
  late TextEditingController _streetController;
  late TextEditingController _poboxController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _isoCountryController;
  late TextEditingController _subAdminAreaController;
  late TextEditingController _subLocalityController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.address.address);
    _label = widget.address.label;
    _customLabelController =
        TextEditingController(text: widget.address.customLabel);
    _streetController = TextEditingController(text: widget.address.street);
    _poboxController = TextEditingController(text: widget.address.pobox);
    _neighborhoodController =
        TextEditingController(text: widget.address.neighborhood);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _postalCodeController =
        TextEditingController(text: widget.address.postalCode);
    _countryController = TextEditingController(text: widget.address.country);
    _isoCountryController =
        TextEditingController(text: widget.address.isoCountry);
    _subAdminAreaController =
        TextEditingController(text: widget.address.subAdminArea);
    _subLocalityController =
        TextEditingController(text: widget.address.subLocality);
  }

  void _onChanged() {
    final address = Address(
      _addressController.text,
      label: _label,
      customLabel:
          _label == AddressLabel.custom ? _customLabelController.text : '',
      street: _streetController.text,
      pobox: _poboxController.text,
      neighborhood: _neighborhoodController.text,
      city: _cityController.text,
      state: _stateController.text,
      postalCode: _postalCodeController.text,
      country: _countryController.text,
      isoCountry: _isoCountryController.text,
      subAdminArea: _subAdminAreaController.text,
      subLocality: _subLocalityController.text,
    );
    widget.onUpdate(address);
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
                controller: _addressController,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(hintText: 'Address'),
                maxLines: null,
              ),
              DropdownButtonFormField(
                isExpanded: true, // to avoid overflow
                items: _validLabels
                    .map((e) => DropdownMenuItem<AddressLabel>(
                        value: e, child: Text(e.toString())))
                    .toList(),
                value: _label,
                onChanged: (AddressLabel? label) {
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
              _label == AddressLabel.custom
                  ? TextFormField(
                      controller: _customLabelController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: 'Custom label'),
                    )
                  : Container(),
              TextFormField(
                  controller: _streetController,
                  textCapitalization: TextCapitalization.words,
                  maxLines: null,
                  decoration: InputDecoration(hintText: 'Street')),
              TextFormField(
                  controller: _poboxController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'Pobox')),
              TextFormField(
                  controller: _neighborhoodController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'Neighborhood')),
              TextFormField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'City')),
              TextFormField(
                  controller: _stateController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'State')),
              TextFormField(
                  controller: _postalCodeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'Postal code')),
              TextFormField(
                  controller: _countryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'Country')),
              TextFormField(
                  controller: _isoCountryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'ISO country')),
              TextFormField(
                  controller: _subAdminAreaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'Sub admin area')),
              TextFormField(
                  controller: _subLocalityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'Sub locality')),
            ],
          ),
        ),
      ),
    );
  }
}
