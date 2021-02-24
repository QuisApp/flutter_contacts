/// Raw Android account.
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
class Account {
  /// Raw account ID.
  String rawId;

  /// Account type, e.g. com.google or com.facebook.messenger.
  String type;

  /// Account name, e.g. john.doe@gmail.com.
  String name;

  /// Android mimetypes provided by this account.
  List<String> mimetypes;

  Account(this.rawId, this.type, this.name, this.mimetypes);

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        (json['rawId'] as String) ?? '',
        (json['type'] as String) ?? '',
        (json['name'] as String) ?? '',
        (json['mimetypes'] as List)?.map((e) => e as String)?.toList() ?? [],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'rawId': rawId,
        'type': type,
        'name': name,
        'mimetypes': mimetypes,
      };

  @override
  String toString() =>
      'Account(rawId=$rawId, type=$type, name=$name, mimetypes=$mimetypes)';
}
