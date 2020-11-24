import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

/// Account is only available on Android and represent raw contacts.
///
/// This is only exposed for information and debugging purposes and should be
/// ignored in most cases.
///
/// Raw contacts are aggregated into unified contacts (which are the ones we
/// usually care about). For example a single contact can have multiple raw
/// contacts, one from Google, one from Skype, one from WhatsApp, etc.
///
/// If you have two Google accounts (e.g. two Gmail addresses registered on the
/// phone) it's possible to have two raw contacts, part of the same contact,
/// both with [type] `com.google` but with a different [name].
@JsonSerializable(disallowUnrecognizedKeys: true)
class Account {
  /// The ID of the raw contact. It's different from the contact ID.
  @JsonKey(required: true)
  String rawId;

  /// The "type" of account, for example `com.google` for Google,
  /// `com.facebook.messenger` for Facebook Messenger.
  @JsonKey(required: true)
  String type;

  /// The "name" of the account, type-specific. For example it's the Gmail
  /// address for `com.google`, but just "WhatsApp" for WhatsApp.
  @JsonKey(required: true)
  String name;

  /// Which data types are contributed to by this account.
  ///
  /// For example a Gmail
  /// account can provide data of mime types `vnd.android.cursor.item/email_v2`,
  /// `vnd.android.cursor.item/identity`, or `vnd.android.cursor.item/note`.
  ///
  /// They can also be type-specific, for example Skype provides types
  /// `vnd.android.cursor.item/com.skype4life.phone` and
  /// `vnd.android.cursor.item/com.skype4life.name`.
  @JsonKey(defaultValue: const [])
  List<String> mimetypes;

  Account(this.rawId, this.type, this.name, [this.mimetypes = const []]);

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
