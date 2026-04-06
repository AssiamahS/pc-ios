import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray.fill")
                }

            RolesView()
                .tabItem {
                    Label("Roles", systemImage: "person.2.fill")
                }

            DirectoryView()
                .tabItem {
                    Label("Directory", systemImage: "book.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.red)
    }
}
