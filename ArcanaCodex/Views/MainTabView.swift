import SwiftUI

struct MainTabView: View {
    @StateObject private var vm = ArcanaViewModel()

    var body: some View {
        TabView {
            SymbolsListView(vm: vm)
                .tabItem {
                    Label("象徴", systemImage: "sparkles")
                }

            TreeOfLifeView(vm: vm)
                .tabItem {
                    Label("生命の樹", systemImage: "point.3.connected.trianglepath.dotted")
                }

            ScholarsView(vm: vm)
                .tabItem {
                    Label("古書", systemImage: "books.vertical")
                }

            ElementsView(vm: vm)
                .tabItem {
                    Label("四元素", systemImage: "flame")
                }

            AstrologyView(vm: vm)
                .tabItem {
                    Label("天体", systemImage: "moon.stars")
                }
        }
        .tint(Color(hex: AppDesign.cyan))
    }
}
