import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';

Widget avatar(Contact contact,
    [double radius = 48.0, IconData defaultIcon = Icons.person]) {
  if (contact.photo != null) {
    return CircleAvatar(
      backgroundImage: MemoryImage(contact.photo),
      radius: radius,
    );
  }
  return CircleAvatar(
    child: Icon(defaultIcon),
    radius: radius,
  );
}
