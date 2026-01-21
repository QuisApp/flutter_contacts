import Contacts
import Foundation

enum RelationLabel: String, CaseIterable {
    case assistant
    case aunt
    case boyfriend
    case brother
    case brotherInLaw
    case child
    case childInLaw
    case colleague
    case cousin
    case daughter
    case domesticPartner
    case father
    case fatherInLaw
    case friend
    case girlfriend
    case grandchild
    case granddaughter
    case grandfather
    case grandmother
    case grandparent
    case grandson
    case husband
    case manager
    case mother
    case motherInLaw
    case nephew
    case niece
    case parent
    case parentInLaw
    case partner
    case referredBy
    case relative
    case sibling
    case siblingInLaw
    case sister
    case sisterInLaw
    case son
    case spouse
    case stepbrother
    case stepchild
    case stepdaughter
    case stepfather
    case stepmother
    case stepparent
    case stepsister
    case stepson
    case teacher
    case uncle
    case wife
    case other
    case custom

    private static let CN_TO_LABEL: [String: RelationLabel] = [
        CNLabelOther: .other,
        CNLabelContactRelationAssistant: .assistant,
        CNLabelContactRelationAunt: .aunt,
        CNLabelContactRelationBoyfriend: .boyfriend,
        CNLabelContactRelationBrother: .brother,
        CNLabelContactRelationBrotherInLaw: .brotherInLaw,
        CNLabelContactRelationChild: .child,
        CNLabelContactRelationChildInLaw: .childInLaw,
        CNLabelContactRelationColleague: .colleague,
        CNLabelContactRelationCousin: .cousin,
        CNLabelContactRelationDaughter: .daughter,
        CNLabelContactRelationFather: .father,
        CNLabelContactRelationFatherInLaw: .fatherInLaw,
        CNLabelContactRelationFriend: .friend,
        CNLabelContactRelationGirlfriend: .girlfriend,
        CNLabelContactRelationGrandchild: .grandchild,
        CNLabelContactRelationGranddaughter: .granddaughter,
        CNLabelContactRelationGrandfather: .grandfather,
        CNLabelContactRelationGrandmother: .grandmother,
        CNLabelContactRelationGrandparent: .grandparent,
        CNLabelContactRelationGrandson: .grandson,
        CNLabelContactRelationHusband: .husband,
        CNLabelContactRelationManager: .manager,
        CNLabelContactRelationMother: .mother,
        CNLabelContactRelationMotherInLaw: .motherInLaw,
        CNLabelContactRelationNephew: .nephew,
        CNLabelContactRelationNiece: .niece,
        CNLabelContactRelationParent: .parent,
        CNLabelContactRelationParentInLaw: .parentInLaw,
        CNLabelContactRelationPartner: .partner,
        CNLabelContactRelationSibling: .sibling,
        CNLabelContactRelationSiblingInLaw: .siblingInLaw,
        CNLabelContactRelationSister: .sister,
        CNLabelContactRelationSisterInLaw: .sisterInLaw,
        CNLabelContactRelationSon: .son,
        CNLabelContactRelationSpouse: .spouse,
        CNLabelContactRelationStepbrother: .stepbrother,
        CNLabelContactRelationStepchild: .stepchild,
        CNLabelContactRelationStepdaughter: .stepdaughter,
        CNLabelContactRelationStepfather: .stepfather,
        CNLabelContactRelationStepmother: .stepmother,
        CNLabelContactRelationStepparent: .stepparent,
        CNLabelContactRelationStepsister: .stepsister,
        CNLabelContactRelationStepson: .stepson,
        CNLabelContactRelationTeacher: .teacher,
        CNLabelContactRelationUncle: .uncle,
        CNLabelContactRelationWife: .wife,
    ]

    private static let LABEL_TO_CN: [RelationLabel: String] = [
        .other: CNLabelOther,
        .assistant: CNLabelContactRelationAssistant,
        .aunt: CNLabelContactRelationAunt,
        .boyfriend: CNLabelContactRelationBoyfriend,
        .brother: CNLabelContactRelationBrother,
        .brotherInLaw: CNLabelContactRelationBrotherInLaw,
        .child: CNLabelContactRelationChild,
        .childInLaw: CNLabelContactRelationChildInLaw,
        .colleague: CNLabelContactRelationColleague,
        .cousin: CNLabelContactRelationCousin,
        .daughter: CNLabelContactRelationDaughter,
        .father: CNLabelContactRelationFather,
        .fatherInLaw: CNLabelContactRelationFatherInLaw,
        .friend: CNLabelContactRelationFriend,
        .girlfriend: CNLabelContactRelationGirlfriend,
        .grandchild: CNLabelContactRelationGrandchild,
        .granddaughter: CNLabelContactRelationGranddaughter,
        .grandfather: CNLabelContactRelationGrandfather,
        .grandmother: CNLabelContactRelationGrandmother,
        .grandparent: CNLabelContactRelationGrandparent,
        .grandson: CNLabelContactRelationGrandson,
        .husband: CNLabelContactRelationHusband,
        .manager: CNLabelContactRelationManager,
        .mother: CNLabelContactRelationMother,
        .motherInLaw: CNLabelContactRelationMotherInLaw,
        .nephew: CNLabelContactRelationNephew,
        .niece: CNLabelContactRelationNiece,
        .parent: CNLabelContactRelationParent,
        .parentInLaw: CNLabelContactRelationParentInLaw,
        .partner: CNLabelContactRelationPartner,
        .sibling: CNLabelContactRelationSibling,
        .siblingInLaw: CNLabelContactRelationSiblingInLaw,
        .sister: CNLabelContactRelationSister,
        .sisterInLaw: CNLabelContactRelationSisterInLaw,
        .son: CNLabelContactRelationSon,
        .spouse: CNLabelContactRelationSpouse,
        .stepbrother: CNLabelContactRelationStepbrother,
        .stepchild: CNLabelContactRelationStepchild,
        .stepdaughter: CNLabelContactRelationStepdaughter,
        .stepfather: CNLabelContactRelationStepfather,
        .stepmother: CNLabelContactRelationStepmother,
        .stepparent: CNLabelContactRelationStepparent,
        .stepsister: CNLabelContactRelationStepsister,
        .stepson: CNLabelContactRelationStepson,
        .teacher: CNLabelContactRelationTeacher,
        .uncle: CNLabelContactRelationUncle,
        .wife: CNLabelContactRelationWife,
    ]

    static func fromCN(_ cnLabel: String?) -> Label<RelationLabel> {
        return LabelConverter.fromCN(cnLabel, labelMap: CN_TO_LABEL, defaultLabel: .other)
    }

    func toCNLabel(customLabel: String?) -> String {
        return LabelConverter.toCN(self, customLabel: customLabel, labelMap: RelationLabel.LABEL_TO_CN)
    }
}
