import SwiftUI
import GoogleMobileAds

class ArcanaCodexAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        DispatchQueue.main.async {
            MobileAds.shared.start()
        }
        return true
    }
}

@main
struct ArcanaCodexApp: App {
    @UIApplicationDelegateAdaptor(ArcanaCodexAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
