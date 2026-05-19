import SwiftUI
import UIKit
import GoogleMobileAds

private enum AdMobConfig {
    static let bannerUnitID = "ca-app-pub-9404799280370656/1668004141"
}

struct AdBannerView: View {
    var body: some View {
        GeometryReader { geometry in
            BannerContainer(width: geometry.size.width)
                .frame(width: geometry.size.width, height: 60)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 60)
        .background(Color(hex: AppDesign.ink).opacity(0.94))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(hex: AppDesign.antiqueGold).opacity(0.18))
                .frame(height: 1)
        }
    }
}

private struct BannerContainer: UIViewRepresentable {
    let width: CGFloat

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: largeAnchoredAdaptiveBanner(width: max(width, 320)))
        banner.adUnitID = AdMobConfig.bannerUnitID
        banner.rootViewController = UIApplication.shared.topViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ banner: BannerView, context: Context) {
        banner.adSize = largeAnchoredAdaptiveBanner(width: max(width, 320))
        banner.rootViewController = UIApplication.shared.topViewController
    }
}

private extension UIApplication {
    var topViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topMostViewController
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController ?? navigationController
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController ?? tabBarController
        }
        return self
    }
}
