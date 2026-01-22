import '../../../models/contact/contact.dart';
import '../../../models/android/android_data.dart';
import '../../../models/properties/name.dart';
import '../../../models/properties/phone.dart';
import '../../../models/properties/email.dart';
import '../../../models/properties/address.dart';
import '../../../models/properties/organization.dart';
import '../../../models/properties/website.dart';
import '../../../models/properties/social_media.dart';
import '../../../models/properties/event.dart';
import '../../../models/properties/relation.dart';
import '../../../models/properties/note.dart';
import '../../../models/properties/photo.dart';

/// Mutable builder for constructing a Contact from parsed properties.
class ContactBuilder {
  String? id;
  String? displayName;
  Name? name;
  final phones = <Phone>[];
  final emails = <Email>[];
  final addresses = <Address>[];
  final organizations = <Organization>[];
  final websites = <Website>[];
  final socialMedias = <SocialMedia>[];
  final events = <Event>[];
  final relations = <Relation>[];
  final notes = <Note>[];
  Photo? photo;
  bool? isFavorite;
  String? customRingtone;
  bool? sendToVoicemail;

  void updateName({
    String? nickname,
    String? phoneticFirst,
    String? phoneticMiddle,
    String? phoneticLast,
  }) {
    name = (name ?? const Name()).copyWith(
      nickname: nickname,
      phoneticFirst: phoneticFirst,
      phoneticMiddle: phoneticMiddle,
      phoneticLast: phoneticLast,
    );
  }

  void updateOrganization({
    String? jobTitle,
    String? jobDescription,
    String? symbol,
    String? officeLocation,
    String? phoneticName,
  }) {
    if (organizations.isEmpty) {
      organizations.add(Organization());
    }
    organizations.last = organizations.last.copyWith(
      jobTitle: jobTitle,
      jobDescription: jobDescription,
      symbol: symbol,
      officeLocation: officeLocation,
      phoneticName: phoneticName,
    );
  }

  Contact build() => Contact(
    id: id,
    displayName: displayName,
    name: name,
    phones: phones,
    emails: emails,
    addresses: addresses,
    organizations: organizations,
    websites: websites,
    socialMedias: socialMedias,
    events: events,
    relations: relations,
    notes: notes,
    photo: photo,
    android:
        (isFavorite != null ||
            customRingtone != null ||
            sendToVoicemail != null)
        ? AndroidData(
            isFavorite: isFavorite,
            customRingtone: customRingtone,
            sendToVoicemail: sendToVoicemail,
          )
        : null,
  );
}
