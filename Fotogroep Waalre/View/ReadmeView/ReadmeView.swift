//
//  ReadmeView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 26/03/2022.
//

import SwiftUI

struct ReadmeView: View {

    private static let paddingAmount: CGFloat = 20
    private let title = String(localized: "Readme", comment: "Title of Readme page")
    @Environment(\.dismiss) var dismiss: DismissAction // \.dismiss requires iOS 15

    var body: some View {
        GeometryReader { geo in
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        VStack { // extra hierarchy level because container View can handle max 10 Views
                            SectionHeader("The Club", comment: "Section title on Readme page", geo: geo)

                            Image("Waalre_map")
                                .resizable()
                                .border(.gray, width: 1)
                                .scaledToFit()
                                .frame(width: 293, height: 375, alignment: .center)
                            Text(verbatim: "Waalre\n")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)

                            Paragraph("1.1", comment: "First paragraph in The Club section of Readme page", geo: geo)
                        }

                        VStack {
                            SectionHeader("Portfolios", comment: "Section title on Readme page", geo: geo)

                            Image("Waalre_AppIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.2, alignment: .center)
                                .border(.gray, width: 1)
                            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                    Text("App version \(version) (build \(build))",
                                         comment: "Shown on Readme page.")
                                        .font(.callout.italic())
                                        .frame(width: geo.size.width, alignment: .center)
                                    Text("")
                                }
                            }

                            Paragraph("2.1", comment: "First paragraph in The App section of Readme page", geo: geo)
                            Paragraph("2.2", comment: "Second paragraph in The App section of Readme page", geo: geo)
                            Paragraph("2.3", comment: "Third paragraph in The App section of Readme page", geo: geo)
                            Paragraph("2.4", comment: "Fourth paragraph in the App section of Readme page", geo: geo)
                            Paragraph("2.5", comment: "Fifth paragraph in the App section of Readme page", geo: geo)
                            Paragraph("2.6", comment: "Sixth paragraph in the App section of Readme page", geo: geo)
                            Paragraph("2.7", comment: "Seventh paragraph in the App section of Readme page", geo: geo)
                        }

                        VStack {
                            SectionHeader("Features and tips", comment: "Section title on Readme page", geo: geo)

                            Image("Localizations")
                                .resizable()
                                .frame(width: 315, height: 64, alignment: .center)
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width, alignment: .center)
                            Text("List of supported languages",
                                 comment: "Caption of Localizations image on Readme page")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)
                            Text("")

                            Paragraph("3.1",
                                      comment: "First paragraph in The Features section of Readme page", geo: geo)
                            Paragraph("3.2",
                                      comment: "Second paragraph in The Features section of Readme page", geo: geo)
                            Paragraph("3.3",
                                      comment: "Third paragraph in The Features section of Readme page", geo: geo)
                        }

                        VStack {
                            SectionHeader("The Animation", comment: "Section title on Readme page", geo: geo)

                            Image("2021_FotogroepWaalre_058")
                                .resizable()
                                .frame(width: 250, height: 375, alignment: .center)
                                .scaledToFill()
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "?? 2021 Greetje van Son\n")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)

                            Paragraph("4.1", comment: "First paragraph in Animation section of Readme page", geo: geo)
                            Paragraph("4.2", comment: "Second paragraph in Animation section of Readme page", geo: geo)
                            Paragraph("4.3", comment: "Third paragraph in Animation section of Readme page", geo: geo)
                        }

                        VStack {
                            SectionHeader("Supported Platforms", comment: "Section title on Readme page", geo: geo)

                            Image("2006_Stilleven_054")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 375, alignment: .center)
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width, alignment: .center)
                            Text("Apple", comment: "Name of the fruit, not the company.")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)
                            Text("")

                            Paragraph("5.1", comment: "First paragraph in Platforms section of Readme page", geo: geo)
                            Paragraph("5.2", comment: "Second paragraph in Platforms section of Readme page", geo: geo)
                            Paragraph("5.3", comment: "Third paragraph in Platforms section of Readme page", geo: geo)
                            Paragraph("5.4", comment: "Fourth paragraph in Platforms section of Readme page", geo: geo)
                            Paragraph("5.5", comment: "Fifth paragraph in Platforms section of Readme page", geo: geo)
                            Paragraph("5.6", comment: "Sixth paragraph in Platforms section of Readme page", geo: geo)
                        }

                        VStack {
                            SectionHeader("Developers wanted", comment: "Section title on Readme page", geo: geo)

                            VStack {
                                Image("Swift_enum")
                                    .resizable()
                                    .border(.gray, width: 1)
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.8, alignment: .center)
                                Text("Fragment of the Swift source code", comment: "Caption for image on Readme page")
                                    .font(.callout.italic())
                                    .frame(width: geo.size.width, alignment: .center)
                                Text("")
                            }

                            Paragraph("6.1", comment: "First paragraph in OpenSource section of Readme page", geo: geo)
                            Paragraph("6.2", comment: "Second paragraph in OpenSource section of Readme page", geo: geo)
                            Paragraph("6.3", comment: "Third paragraph in OpenSource section of Readme page", geo: geo)
                            Paragraph("6.4", comment: "Fourth paragraph in OpenSource section of Readme page", geo: geo)
                            Paragraph("6.5", comment: "Sixth paragraph in OpenSource section of Readme page", geo: geo)
                            Paragraph("6.6", comment: "Fifth paragraph in OpenSource section of Readme page", geo: geo)
                        }

                        VStack {
                            SectionHeader("The Model", comment: "Section title on Readme page", geo: geo)

                            VStack {
                                Image("Schema")
                                    .resizable()
                                    .border(.gray, width: 1)
                                    .scaledToFit()
                                    .frame(width: 250, alignment: .center)
                                Text("Partial model", comment: "Caption for image on Readme page")
                                    .font(.callout.italic())
                                    .frame(width: geo.size.width, alignment: .center)
                                Text("")
                            }

                            Paragraph("7.1", comment: "First paragraph in Model section of Readme page", geo: geo)
                            Paragraph("7.2", comment: "Second paragraph in Model section of Readme page", geo: geo)
                        }

                        SectionHeader("", comment: "", geo: geo)

                    } // outer VStack

                } // ScrollView
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(UIDevice.isIPhone ? .inline : .large)
                .toolbar {
                    ToolbarItemGroup(placement: ToolbarItemPlacement.confirmationAction) {
                        Button { // actual saving done in .onDisappear
                            dismiss()
                        } label: {
                            Text("Done",
                                 comment: "Button to close Info page.")
                        }
                    }
                }
            } // NavigationView
            .padding(.init(top: 0, leading: 0, bottom: 15, trailing: 0))
            .frame(minWidth: geo.size.width*0.2, idealWidth: geo.size.width*0.5, maxWidth: geo.size.width,
                   minHeight: geo.size.height*0.5, idealHeight: geo.size.height, maxHeight: geo.size.height)
        } // GeometryReader
    }

//    func getAppIcon() -> UIImage {
//        // https://medium.com/macoclock/swift-how-to-get-current-app-icon-in-ios-2b3adbeedf16
//        var appIcon: UIImage! {
//            guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
//                  let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
//                  let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
//                  let lastIcon = iconFiles.last else { return nil }
//            return UIImage(named: lastIcon)
//        }
//        return appIcon
//    }

    struct SectionHeader: View {
        let localizedStringKey: LocalizedStringKey
        let comment: StaticString
        let geo: GeometryProxy

        // explicit init() used here just to suppress localizedStringKey argument label
        init(_ localizedStringKey: LocalizedStringKey, comment: StaticString, geo: GeometryProxy) {
            self.localizedStringKey = localizedStringKey
            self.comment = comment
            self.geo = geo
        }

        var body: some View {
            let boxCount: Int = UIDevice.isIPad ? 8 : 3
            let const1: CGFloat = 0.8
            let const2: CGFloat = 0.05
            let const3: CGFloat = const1 - const2 * CGFloat(boxCount - 1)

            HStack {
                ForEach(0..<boxCount, id: \.self) { integer in
                    Image(systemName: "square.fill")
                        .foregroundColor((boxCount-integer-1) % 3 == 0 ? .fgwBlue :
                                         (boxCount-integer-1) % 3 == 1 ? .fgwGreen : .fgwRed)
//                      .scaleEffect(const1 - const2 * CGFloat(boxCount-integer-1))
                        .scaleEffect(const3 + const2 * CGFloat(integer))
                }
                Text(localizedStringKey, comment: comment) // can receive an empty string
                    .foregroundColor(.linkColor)
                    .allowsTightening(true)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                ForEach(0..<boxCount, id: \.self) { integer in
                    Image(systemName: "square.fill")
                        .foregroundColor(integer % 3 == 0 ? .fgwBlue :
                                         integer % 3 == 1 ? .fgwGreen : .fgwRed)
                        .scaleEffect(const1 - const2 * CGFloat(integer))
                }
            }
            .frame(width: geo.size.width * 0.9, height: 50, alignment: .center)
            .padding(Edge.Set([.horizontal]), paddingAmount)
        }
    }

    // struct to define some standard view modifiers for use in Readme paragraphs
    struct Paragraph: View {
        var localizedStringKey: LocalizedStringKey
        let comment: StaticString
        let geo: GeometryProxy

        // explicit init() used here just to suppress localizedStringKey argument label
        init(_ localizedStringKeySuffix: String, comment: StaticString, geo: GeometryProxy) {
            let localizedStringKey: String = "Paragraph_" + localizedStringKeySuffix // extra strep needed
            self.localizedStringKey = LocalizedStringKey(localizedStringKey)
            self.comment = comment
            self.geo = geo
        }

        var body: some View {
            Text(localizedStringKey, comment: comment)
                .padding([.horizontal, .bottom], paddingAmount)
                .frame(width: geo.size.width, alignment: .leading)
                .fixedSize() // magic to get Text to wrap
        }
    }

}

struct ReadmeView_Previews: PreviewProvider {
    @State static private var title = "Info Preview"

    static var previews: some View {
        ReadmeView()
            .preferredColorScheme(.light)
            .navigationTitle(title)
            .navigationViewStyle(.stack)
            .previewInterfaceOrientation(.portrait)
    }
}
