/// Group (called label on Android and group on iOS).
///
/// A contact may belong to zero, one or more groups.
class Group {
  String id;
  String name;
  String accountId;

  Group(this.id, this.name, this.accountId);

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        (json['id'] as String?) ?? '',
        (json['name'] as String?) ?? '',
        (json['accountId'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'accountId': accountId,
      };

  @override
  String toString() => 'Group(id=$id, name=$name)';
}
