import Contacts

@available(iOS 9.0, *)
struct Event {
    var date: String
    // one of: anniversary, birthday, other, custom
    var label: String = "birthday"
    var customLabel: String = ""
    var noYear: Bool = false

    static var dateFormatter = DateFormatter()

    @available(iOS 10.0, *)
    static var iso8601DateFormatter = ISO8601DateFormatter()

    static func initialize() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    }

    init(fromMap m: [String: Any]) {
        date = m["date"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
        noYear = m["noYear"] as! Bool
    }

    init(fromContact c: CNContact) {
        date = Event.dateFormatter.string(from: c.birthday!.date!)
        label = "birthday"
        noYear = c.birthday!.year == nil
    }

    init(fromDate d: CNLabeledValue<NSDateComponents>) {
        date = Event.dateFormatter.string(from: d.value.date!)
        switch d.label {
        case CNLabelDateAnniversary:
            label = "anniversary"
        case CNLabelOther:
            label = "other"
        default:
            label = "custom"
            customLabel = d.label ?? ""
        }
        // It seems like NSDateComponents use 2^64-1 as a value for year when there is
        // no year. This should cover similar edge cases.
        noYear = d.value.year < -100_000 || d.value.year > 100_000
    }

    func toMap() -> [String: Any] { [
        "date": date,
        "label": label,
        "customLabel": customLabel,
        "noYear": noYear,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        // Parse the ISO 8601 string ourselves. We could use ISO8601DateFormatter, but
        //   1) it's only available after iOS 10
        //   2) it doesn't support fractional seconds before iOS 11 so we'd have to
        //      process the string with regular expression as in
        //      https://stackoverflow.com/questions/41847672/iso8601dateformatter-doesnt-parse-iso-date-string
        //   3) we just need year/month/day
        //   4) I couldn't get it to work
        //
        // Flutter's toIso8601String returns "$y-$m-${d}T$h:$min:$sec.$ms$us" or
        // "$y-$m-${d}T$h:$min:$sec.$ms${us}Z" so we can just use that.

        let matches = Event.groups(for: "(\\d+)-(\\d+)-(\\d+).*", in: date)
        if let components = matches.first {
            if components.count == 4 {
                if let year = Int(components[1]),
                   let month = Int(components[2]),
                   let day = Int(components[3])
                {
                    var dateComponents: DateComponents
                    if noYear {
                        dateComponents = DateComponents(month: month, day: day)
                    } else {
                        dateComponents = DateComponents(year: year, month: month, day: day)
                    }
                    if label == "birthday" {
                        c.birthday = dateComponents
                    } else {
                        var labelInv: String
                        switch label {
                        case "anniversary":
                            labelInv = CNLabelDateAnniversary
                        case "other":
                            labelInv = CNLabelOther
                        case "custom":
                            labelInv = customLabel
                        default:
                            labelInv = label
                        }
                        c.dates.append(CNLabeledValue(label: labelInv, value: dateComponents as NSDateComponents))
                    }
                }
            }
        }
    }

    // https://stackoverflow.com/questions/42789953/swift-3-how-do-i-extract-captured-groups-in-regular-expressions
    private static func groups(for regexPattern: String, in regexString: String) -> [[String]] {
        do {
            let text = regexString
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                (0 ..< match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
