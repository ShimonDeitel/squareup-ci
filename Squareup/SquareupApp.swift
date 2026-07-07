import SwiftUI

@main
struct SquareupApp: App {
    @StateObject private var store = SquareupStore()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
        }
    }
}
