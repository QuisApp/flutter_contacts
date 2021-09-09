/// Group (called label on Android and group on iOS).
///
/// A contact may belong to zero, one or more groups.
class Group {
  String id;
  String name;

  Group(this.id, this.name);

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        (json['id'] as String?) ?? '',
        (json['name'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'Group(id=$id, name=$name)';
}
