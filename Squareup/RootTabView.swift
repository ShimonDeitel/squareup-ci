import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            JarView()
                .tabItem {
                    Label("Home", systemImage: "takeoutbag.and.cup.and.straw.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.mintDeep)
    }
}

#Preview {
    RootTabView()
        .environmentObject(SquareupStore())
        .environmentObject(PurchaseManager())
}
