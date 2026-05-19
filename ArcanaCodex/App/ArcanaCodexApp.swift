import SwiftUI
import GoogleMobileAds

@main
struct ArcanaCodexApp: App {
    init() {
        MobileAds.shared.start { _ in }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
