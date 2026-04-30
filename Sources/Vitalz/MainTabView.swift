import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tag(0)
                .tabItem {
                    Image(systemName: "dial.low") // Dial watch metaphor
                    Text("Dashboard")
                }
            
            MilestonesView()
                .tag(1)
                .tabItem {
                    Image(systemName: "flag.fill")
                    Text("Milestones")
                }
        }
        .accentColor(.vitalzBlue)
        // Global configuration to force TabBar to match our pure black luxury aesthetic
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.vitalzBackground)
            
            // Adjust unselected item color
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            
            // Apply appearances
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    MainTabView()
}
