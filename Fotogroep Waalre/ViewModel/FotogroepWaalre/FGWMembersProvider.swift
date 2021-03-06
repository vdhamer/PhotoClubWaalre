//
//  FGWMembersProvider.swift
//  FGWMembersProvider
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for NSManagedObjectContext

class FGWMembersProvider { // WWDC21 Earthquakes also uses a Class here

    private let fullOwnerName: String?
    private static let photoClubID: (name: String, town: String) = ("Fotogroep Waalre", "Waalre")

//    /// A shared member provider for use within the main app bundle.
//    static let shared = FotogroepWaalreMembersProvider()

    init(fullOwnerName: String? = nil) {
        self.fullOwnerName = fullOwnerName

        let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        insertSomeMembers(fgwBackgroundContext: fgwBackgroundContext, commit: true)

        let privateURL: URL = URL(string: FGWMembersProvider.privateMembersURL)!
        Task {
            await loadPrivateMembersFromWebsite( backgroundContext: fgwBackgroundContext,
                                                 privateMemberURL: privateURL,
                                                 photoClubID: FGWMembersProvider.photoClubID,
                                                 commit: true,
                                                 fullOwnerName: fullOwnerName
            )
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Load ex-members array (including name and URLs) from internal website page

    // Example fragment from middle of PRIVATELEDENURL file
    // <table>
    // <tbody>
    // <tr>
    // <th>Ex-lid</th>
    // <th>E-mail</th>
    // <th>Telefoon</th>
    // </tr>
    // <tr>
    // <td>Aad Schoenmakers</td>
    // <td><a href="mailto:aad@fotograad.nl">aad@fotograad.nl</a></td>
    // <td>06-10859556</td>
    // </tr>
    // <tr>
    // <td>Hans van Steensel (aspirantlid)</td>
    // <td><a href="mailto:info@vansteenselconsultants.nl">info@vansteenselconsultants.nl</a></td>
    // <td>06-53952538</td>
    // </tr>

    enum HTMLPageLoadingState: String {
        // rawValues are target search strings in the HTML file
        case tableStart     = "<table>"
        case tableHeader    = "Groepslid" // "Ex-lid" "Groepslid""
        case rowStart       = "<tr>"
        case personName     = "<td>"
        case eMail          = "<td><a href"
        case phoneNumber    = "<td"            // strings have to be unique, otherwise <td> would be more obvious
        case externalURL    = "<td><a title"

        // compute next state for given state
        func nextState() -> HTMLPageLoadingState {
            switch self {
            case .tableStart:    return .tableHeader
            case .tableHeader:   return .rowStart
            case .rowStart:      return .personName
            case .personName:    return .eMail
            case .eMail:         return .phoneNumber
            case .phoneNumber:   return .externalURL
            case .externalURL:   return .rowStart
            }
        }

        // myState.targetString() alternative to myState.rawValue
        func targetString() -> String {
            return self.rawValue
        }
    }

    func loadPrivateMembersFromWebsite( backgroundContext: NSManagedObjectContext,
                                        privateMemberURL: URL,
                                        photoClubID: (name: String, town: String),
                                        commit: Bool,
                                        fullOwnerName: String? ) async {

        var results: (utfContent: Data?, urlResponse: URLResponse?)? = (nil, nil)
        results = try? await URLSession.shared.data(from: privateMemberURL)
        if results != nil, results?.utfContent != nil {
            let htmlContent = String(data: results!.utfContent! as Data,
                                     encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            parseHTMLContent(backgroundContext: backgroundContext, htmlContent: htmlContent, photoClubID: photoClubID)
            if commit {
                do {
                    if backgroundContext.hasChanges {
                        try backgroundContext.save()
                    }
                 } catch {
                    print("Could not save backgroundContext in FotogroepWaalreMembersProvider.init()")
                }
            }
        } else {
            DispatchQueue.main.async {
                print("loading from \(privateMemberURL) in loadPrivateMembersFromWebsite() failed")
                // print(results?.urlResponse)
                // if let errorcode: HTTPURLResponse = results?.urlResponse {
                    // print("\nHTTP status code: \(errorcode.statusCode)")
            }
        }
    }

    private func parseHTMLContent(backgroundContext: NSManagedObjectContext, htmlContent: String,
                                  photoClubID: (name: String, town: String)) {
        var targetState: HTMLPageLoadingState = .tableStart        // initial entry point on loop of states

        var eMail = "", phoneNumber: String?, externalURL: String = ""
        var familyName = "", givenName = "", personName  = ""

        let photoClub: PhotoClub = PhotoClub.findCreateUpdate(context: backgroundContext,
                                                              name: photoClubID.name, town: photoClubID.town)

        htmlContent.enumerateLines { (line, _ stop) -> Void in
            if line.contains(targetState.targetString()) {
                switch targetState {

                case .tableStart: break   // find start of table (only happens once)
                case .tableHeader: break  // find head of table (only happens once)
                case .rowStart: break     // find start of a table row defintion (may contain <td> or <th>)

                case .personName:       // find first cell in row
                    personName = self.stripOffTagsFromName(taggedString: line) // cleanup
                    (givenName, familyName) = self.componentizePersonName(name: personName, printName: false)

                case .eMail:                      // then find 2nd cell in row
                    eMail = self.stripOffTagsFromEMail(taggedString: line) // store url after cleanup

                case .phoneNumber:                  // then find 3rd cell in row
                    phoneNumber = self.stripOffTagsFromPhone(taggedString: line) // store url after cleanup

                case .externalURL:
                    externalURL = self.stripOffTagsFromExternalURL(taggedString: line) // url after cleanup

                    let photographer = Photographer.findCreateUpdate(
                        context: backgroundContext, givenName: givenName, familyName: familyName,
                        memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [
                            .deceased: !self.isStillAlive(phone: phoneNumber) ]),
                        phoneNumber: phoneNumber, eMail: eMail,
                        photographerWebsite: URL(string: externalURL)
                    )

                    let (givenName, familyName) = self.componentizePersonName(name: personName, printName: false)
                    _ = Member.findCreateUpdate(
                        context: backgroundContext, photoClub: photoClub, photographer: photographer,
                        memberRolesAndStatus: MemberRolesAndStatus(
                            role: [:],
                            stat: [
                                .former: !self.isCurrentMember(name: personName, includeCandidates: true),
                                .coach: self.isMentor(name: personName),
                                .prospective: self.isProspectiveMember(name: personName),
                                .deviceOwner: self.isDeviceOwner(fullOwnerName: self.fullOwnerName,
                                                                 givenName: givenName, familyName: familyName,
                                                                 phoneNumber: phoneNumber)
                            ]
                        ),
                        memberWebsite: self.generateInternalURL(using: "\(givenName) \(familyName)")
                    )

                }

                targetState = targetState.nextState()
            }
        }

    }
}

extension FGWMembersProvider { // private utitity functions

    private func stripOffTagsFromPhone(taggedString: String) -> String? {
        // <td>2213761</td>
        // <td>06-22479317</td>
        // <td>[overleden]</td>
        // <td>[mentor]</td>

        let REGEX: String = "<td>(\\[mentor\\]|\\[overleden\\]|[0-9\\-\\?]+)<\\/td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            if result[0] != "?" {
                return result[0]
            } else {
                return nil
            }
        } else {
            return "Error: \(taggedString)"
        }
    }

    private func stripOffTagsFromEMail(taggedString: String) -> String {
        // <td><a href="mailto:bsteek@gmail.com">bsteek@gmail.com</a></td>

        let REGEX: String = "<td><a href=\"[^\"]+\">([^<]+)<\\/a><\\/td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            print("Error: \(taggedString)")
            return "Error: \(taggedString)"
        }
    }

    private func stripOffTagsFromName(taggedString: String) -> String {
        // <td>Ariejan van Twisk</td>

        let REGEX: String = "<td>([^<]+)<\\/td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "Error: \(taggedString)"
        }
    }

    private func stripOffTagsFromExternalURL(taggedString: String) -> String {
        // swiftlint:disable:next line_length
        // <td><a title="Ariejan van Twisk fotografie" href="http://www.ariejanvantwiskfotografie.nl" target="_blank">extern</a></td>
        // <td><a title="" href="" target="_blank"></a></td>

        let REGEX: String = " href=\"([^\"]*)\""
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "Error: \(taggedString)"
        }
    }

    // Split a String containing a name into PersonNameComponents
    // This is done manually instead of using the iOS 10
    // formatter.personNameComponents() function to handle last names like Henny Looren de Jong
    // An optional suffix like (lid), (aspirantlid) or (mentor) is removed
    // This is done in 2 stages using regular expressions because I coudn't get it to work in one stage
    private func componentizePersonName(name: String, printName: Bool) -> (givenName: String, familyName: String) {
        var components = PersonNameComponents()
        var strippedNameString: String
        if name.contains(" (lid)") {
            let REGEX: String = "([^(]*) \\(lid\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else if name.contains(" (aspirantlid)") {
            let REGEX: String = "([^(]*) \\(aspirantlid\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else if name.contains(" (mentor)") {
            let REGEX: String = "([^(]*) \\(mentor\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else {
            strippedNameString = name
        }
        let REGEX: String = "([^ ]+) (.*)" // split on first space
        let result = strippedNameString.capturedGroups(withRegex: REGEX)
        if result.count > 1 {
            components.givenName  = result[0]
            components.familyName = result[1]
            if printName {
                print("Name found: \(components.givenName!) \(components.familyName!)")
            }
            return (components.givenName!, components.familyName!)
        } else {
            if printName {
                print("Error in componentizePersonName() while handling \(name)")
            }
           return ("Bad member name: ", "rawNameString")
        }
    }

    private func isStillAlive(phone: String?) -> Bool {
        return phone != "[overleden]"
    }

    private func isCurrentMember(name: String, includeCandidates: Bool) -> Bool {
        let REGEX: String = ".* (\\(lid\\))"
        let result = name.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return true
        } else if !includeCandidates {
            return false
        } else {
            return isProspectiveMember(name: name)
        }
    }

    private func isMentor(name: String) -> Bool {
        let REGEX: String = ".* (\\(mentor\\))"
        let result = name.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return true
        } else {
            return false
        }
    }

    private func isProspectiveMember(name: String) -> Bool {
        let REGEX: String = ".* (\\(aspirantlid\\))"
        let result = name.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return true
        } else {
            return false
        }
    }

    static var foundAnOwner: Bool = false // first match is returned, to prevent multiple matches

    private func isDeviceOwner(fullOwnerName: String?, givenName: String, familyName: String,
                               phoneNumber: String?) -> Bool {
        guard let fullOwnerName = fullOwnerName else { return false } // don't know the owner -> give up
        guard isStillAlive(phone: phoneNumber) else { return false } // don't select deceased members
        guard !FGWMembersProvider.foundAnOwner else { return false } // only select one member
        if fullOwnerName == "\(givenName) \(familyName)" { // if last name of owner known, use it
            FGWMembersProvider.foundAnOwner = true
            return true
        }
        if fullOwnerName == givenName {
            FGWMembersProvider.foundAnOwner = true
            return true
        }
        return false
    }

    private func generateInternalURL(using name: String) -> URL? {
        let     baseURL = "https://www.fotogroepwaalre.nl/fotos/"
        var tweakedName = name.replacingOccurrences(of: " ", with: "_")
        tweakedName = tweakedName.replacingOccurrences(of: "??", with: "a") // Istv??n_Nagy
        tweakedName = tweakedName.replacingOccurrences(of: "??", with: "e") // Jos??_Dani??ls
        tweakedName = tweakedName.replacingOccurrences(of: "??", with: "e") // Jos??_Dani??ls and Henri??tte van Ekert
        tweakedName = tweakedName.replacingOccurrences(of: "??", with: "c") // Fran??ois_Hermans

        if tweakedName.contains("_(lid)") {
            let REGEX: String = "([^(]*)_\\(lid\\).*"
            tweakedName = tweakedName.capturedGroups(withRegex: REGEX)[0]
        } else if tweakedName.contains("_(aspirantlid)") {
            let REGEX: String = "([^(]*)_\\(aspirantlid\\).*"
            tweakedName = tweakedName.capturedGroups(withRegex: REGEX)[0]
        }
        return URL(string: baseURL + tweakedName + "/")
    }

}
