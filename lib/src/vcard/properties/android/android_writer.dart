import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';

/// Writes Android-specific properties (X-ANDROID-*).
void writeAndroidProperties(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version,
) {
  if (contact.isFavorite == true) {
    writeProperty(buffer, 'X-ANDROID-STARRED', '1', version: version);
  }
  writeProperty(
    buffer,
    'X-ANDROID-CUSTOM-RINGTONE',
    contact.customRingtone,
    version: version,
  );
  if (contact.sendToVoicemail == true) {
    writeProperty(buffer, 'X-ANDROID-SEND-TO-VOICEMAIL', '1', version: version);
  }
}
