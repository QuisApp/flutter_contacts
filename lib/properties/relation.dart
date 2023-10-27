import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts/vcard.dart';

/// Labeled Relation.
class Relation {
  /// Relation name.
  String name;

  /// Label (default [RelationLabel.relative]).
  RelationLabel label;

  /// Custom label, if [label] is [RelationLabel.custom].
  String customLabel;

  Relation(
    this.name, {
    this.label = RelationLabel.relative,
    this.customLabel = '',
  });

  factory Relation.fromJson(Map<String, dynamic> json) => Relation(
        (json['name'] as String?) ?? '',
        label: _stringToRelationLabel[json['label'] as String? ?? ''] ??
            RelationLabel.assistant,
        customLabel: (json['customLabel'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'label': _RelationLabelToString[label],
        'customLabel': customLabel,
      };

  @override
  int get hashCode => name.hashCode ^ label.hashCode ^ customLabel.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Relation &&
      o.name == name &&
      o.label == label &&
      o.customLabel == customLabel;

  @override
  String toString() =>
      'Relation(name=$name, label=$label, customLabel=$customLabel';

  List<String> toVCard() {
    // Related (V4): https://datatracker.ietf.org/doc/html/rfc6350#section-6.6.6
    // Relationship types: https://gmpg.org/xfn/11 also https://datatracker.ietf.org/doc/html/rfc6350#section-10.3.4

    if (FlutterContacts.config.vCardVersion != VCardVersion.v4) {
      // Not supported in v3
      // TODO could possibly support the ABRELATEDNAMES, e.g.
      //  item8.X-ABRELATEDNAMES:ABABA
      //  item8.X-ABLabel:ZZZZZ
      return [];
    }

    var s = 'RELATED';

    switch (label) {
      case RelationLabel.assistant:
        s += ';TYPE=co-worker';
        break;
      case RelationLabel.brother:
        s += ';TYPE=sibling';
        break;
      case RelationLabel.child:
        s += ';TYPE=child';
        break;
      case RelationLabel.daughter:
        s += ';TYPE=child';
        break;
      case RelationLabel.domesticPartner:
        s += ';TYPE=spouse';
        break;
      case RelationLabel.father:
        s += ';TYPE=parent';
        break;
      case RelationLabel.friend:
        s += ';TYPE=friend';
        break;
      case RelationLabel.manager:
        s += ';TYPE=co-worker';
        break;
      case RelationLabel.mother:
        s += ';TYPE=parent';
        break;
      case RelationLabel.parent:
        s += ';TYPE=parent';
        break;
      case RelationLabel.partner:
        s += ';TYPE=spouse';
        break;
      case RelationLabel.relative:
        s += ';TYPE=kin';
        break;
      case RelationLabel.sister:
        s += ';TYPE=sibling';
        break;
      case RelationLabel.son:
        s += ';TYPE=child';
        break;
      case RelationLabel.spouse:
        s += ';TYPE=spouse';
        break;
      default:
    }
    s += ':${vCardEncode(name)}';
    return [s];
  }
}

/// Relation labels.
///
/// | Label    | Android | iOS |
/// |----------|:-------:|:---:|
/// | assistant| ✔       | ✔   |
/// | brother  | ⨯       | ✔   |
/// | child    | ✔       | ✔   |
/// | daughter | ⨯       | ✔   |
/// | domestic_
/// |   partner| ✔       | ⨯   |
/// | father   | ✔       | ✔   |
/// | friend   | ✔       | ✔   |
/// | manager  | ✔       | ✔   |
/// | mother   | ✔       | ✔   |
/// | other    | ⨯       | ✔   |
/// | parent   | ✔       | ✔   |
/// | partner  | ✔       | ✔   |
/// | referred_
/// |     by   | ✔       | ⨯   |
/// | relative | ✔       | ⨯   |
/// | sister   | ✔       | ✔   |
/// | son      | ⨯       | ✔   |
/// | spouse   | ✔       | ✔   |
/// | custom   | ✔       | ✔   |
enum RelationLabel {
  assistant,
  brother,
  child,
  daughter,
  domesticPartner,
  father,
  friend,
  manager,
  mother,
  other,
  parent,
  partner,
  referredBy,
  relative,
  sister,
  son,
  spouse,
  custom,
}

final _RelationLabelToString = {
  RelationLabel.assistant: 'assistant',
  RelationLabel.brother: 'brother',
  RelationLabel.child: 'child',
  RelationLabel.daughter: 'daughter',
  RelationLabel.domesticPartner: 'domestic-partner',
  RelationLabel.father: 'father',
  RelationLabel.friend: 'friend',
  RelationLabel.manager: 'manager',
  RelationLabel.mother: 'mother',
  RelationLabel.other: 'other',
  RelationLabel.parent: 'parent',
  RelationLabel.partner: 'partner',
  RelationLabel.referredBy: 'referred-by',
  RelationLabel.relative: 'relative',
  RelationLabel.sister: 'sister',
  RelationLabel.son: 'son',
  RelationLabel.spouse: 'spouse',
  RelationLabel.custom: 'custom',
};

final _stringToRelationLabel = {
  'assistant': RelationLabel.assistant,
  'brother': RelationLabel.brother,
  'child': RelationLabel.child,
  'daughter': RelationLabel.daughter,
  'domestic-partner': RelationLabel.domesticPartner,
  'father': RelationLabel.father,
  'friend': RelationLabel.friend,
  'manager': RelationLabel.manager,
  'mother': RelationLabel.mother,
  'other': RelationLabel.other,
  'parent': RelationLabel.parent,
  'partner': RelationLabel.partner,
  'referred-by': RelationLabel.referredBy,
  'relative': RelationLabel.relative,
  'sister': RelationLabel.sister,
  'son': RelationLabel.son,
  'spouse': RelationLabel.spouse,
  'custom': RelationLabel.custom,
};
