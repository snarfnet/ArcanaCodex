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

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard !context.coordinator.didLoad else { return }
        guard let rootVC = UIApplication.shared.arcanaRootViewController else { return }

        let banner = BannerView(adSize: largeAnchoredAdaptiveBanner(width: max(width, 320)))
        banner.adUnitID = AdMobConfig.bannerUnitID
        banner.rootViewController = rootVC
        banner.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: uiView.centerYAnchor)
        ])
        banner.load(Request())
        context.coordinator.didLoad = true
    }

    final class Coordinator {
        var didLoad = false
    }
}

private extension UIApplication {
    var arcanaRootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .keyWindow?
            .rootViewController
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
