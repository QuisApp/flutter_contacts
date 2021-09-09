/// Account information, which is exposed for information and debugging purposes
/// and should be ignored in most cases.
///
/// On Android this is the raw account, and there can be several accounts per
/// unified contact (for example one for Gmail, one for Skype and one for
/// WhatsApp). On iOS it is called container, and there can be only one
/// container per contact.
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
        (json['rawId'] as String?) ?? '',
        (json['type'] as String?) ?? '',
        (json['name'] as String?) ?? '',
        (json['mimetypes'] as List?)?.map((e) => e as String).toList() ?? [],
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
