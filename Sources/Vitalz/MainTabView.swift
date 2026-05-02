import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @AppStorage("accentTheme") private var accentTheme: String = AccentTheme.electricBlue.rawValue

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tag(0)
                .tabItem {
                    Image(systemName: "dial.low")
                    Text("Dashboard")
                }

            FriendsView()
                .tag(1)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }

            MilestonesView()
                .tag(2)
                .tabItem {
                    Image(systemName: "flag.fill")
                    Text("Milestones")
                }
        }
        .accentColor(Color.vitalzAccent)
        .id(accentTheme)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.vitalzBackground)

            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ProfileStore())
}
