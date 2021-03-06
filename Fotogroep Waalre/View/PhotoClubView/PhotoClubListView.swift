//
//  PhotoClubListView.swift
//  Fotogroep Waalre 2
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI

struct PhotoClubListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingPhotographers = false
    @State private var showingMembers = false
    @EnvironmentObject var deviceOwner: DeviceOwner
    @StateObject var model = SettingsViewModel()

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.priority_, order: .reverse), // highest priority first
                          SortDescriptor(\.name_, order: .forward)],
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>

    private let title = String(localized: "Photo Club Waalre", comment: "Title used in Navigation View")

    var body: some View {
        VStack {
            List { // lists are "Lazy" automatically
                PhotoClubs(predicate: model.settings.photoClubPredicate)
            }
            .refreshable {
                FGWMembersProvider.foundAnOwner = false // for pull-to-refresh
                _ = FGWMembersProvider(fullOwnerName: deviceOwner.fullOwnerName)
                _ = BIMembersProvider()
                _ = TestMembersProvider()
            }
        }
        .navigationTitle(String(localized: "Photo clubs", comment: "Title of page with clubs and maps"))
        .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
    }

}

struct PhotoClubListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoClubListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
