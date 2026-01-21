import 'dart:io';

/// Relationship label types.
///
/// | Label            | Android | iOS |
/// |------------------|:-------:|:---:|
/// | assistant        | ✔       | ✔   |
/// | aunt             | ⨯       | ✔   |
/// | boyfriend        | ⨯       | ✔   |
/// | brother          | ✔       | ✔   |
/// | brotherInLaw     | ⨯       | ✔   |
/// | child            | ✔       | ✔   |
/// | childInLaw       | ⨯       | ✔   |
/// | colleague        | ⨯       | ✔   |
/// | cousin           | ⨯       | ✔   |
/// | daughter         | ⨯       | ✔   |
/// | domesticPartner  | ✔       | ⨯   |
/// | father           | ✔       | ✔   |
/// | fatherInLaw      | ⨯       | ✔   |
/// | friend           | ✔       | ✔   |
/// | girlfriend       | ⨯       | ✔   |
/// | grandchild       | ⨯       | ✔   |
/// | granddaughter    | ⨯       | ✔   |
/// | grandfather      | ⨯       | ✔   |
/// | grandmother      | ⨯       | ✔   |
/// | grandparent      | ⨯       | ✔   |
/// | grandson         | ⨯       | ✔   |
/// | husband          | ⨯       | ✔   |
/// | manager          | ✔       | ✔   |
/// | mother           | ✔       | ✔   |
/// | motherInLaw      | ⨯       | ✔   |
/// | nephew           | ⨯       | ✔   |
/// | niece            | ⨯       | ✔   |
/// | parent           | ✔       | ✔   |
/// | parentInLaw      | ⨯       | ✔   |
/// | partner          | ✔       | ✔   |
/// | referredBy       | ✔       | ⨯   |
/// | relative         | ✔       | ⨯   |
/// | sibling          | ⨯       | ✔   |
/// | siblingInLaw     | ⨯       | ✔   |
/// | sister           | ✔       | ✔   |
/// | sisterInLaw      | ⨯       | ✔   |
/// | son              | ⨯       | ✔   |
/// | spouse           | ✔       | ✔   |
/// | stepbrother      | ⨯       | ✔   |
/// | stepchild        | ⨯       | ✔   |
/// | stepdaughter     | ⨯       | ✔   |
/// | stepfather       | ⨯       | ✔   |
/// | stepmother       | ⨯       | ✔   |
/// | stepparent       | ⨯       | ✔   |
/// | stepsister       | ⨯       | ✔   |
/// | stepson          | ⨯       | ✔   |
/// | teacher          | ⨯       | ✔   |
/// | uncle            | ⨯       | ✔   |
/// | wife             | ⨯       | ✔   |
/// | other            | ✔       | ✔   |
/// | custom           | ✔       | ✔   |
///
/// iOS defines many more relationship labels. Unsupported labels are automatically mapped to
/// [RelationLabel.custom] with the original string preserved.
enum RelationLabel {
  assistant,
  aunt,
  boyfriend,
  brother,
  brotherInLaw,
  child,
  childInLaw,
  colleague,
  cousin,
  daughter,
  domesticPartner,
  father,
  fatherInLaw,
  friend,
  girlfriend,
  grandchild,
  granddaughter,
  grandfather,
  grandmother,
  grandparent,
  grandson,
  husband,
  manager,
  mother,
  motherInLaw,
  nephew,
  niece,
  parent,
  parentInLaw,
  partner,
  referredBy,
  relative,
  sibling,
  siblingInLaw,
  sister,
  sisterInLaw,
  son,
  spouse,
  stepbrother,
  stepchild,
  stepdaughter,
  stepfather,
  stepmother,
  stepparent,
  stepsister,
  stepson,
  teacher,
  uncle,
  wife,
  other,
  custom;

  static const _android = {
    RelationLabel.assistant,
    RelationLabel.brother,
    RelationLabel.child,
    RelationLabel.domesticPartner,
    RelationLabel.father,
    RelationLabel.friend,
    RelationLabel.manager,
    RelationLabel.mother,
    RelationLabel.parent,
    RelationLabel.partner,
    RelationLabel.referredBy,
    RelationLabel.relative,
    RelationLabel.sister,
    RelationLabel.spouse,
    RelationLabel.other,
    RelationLabel.custom,
  };

  bool get isSupported {
    if (Platform.isAndroid) return _android.contains(this);
    return true;
  }
}
