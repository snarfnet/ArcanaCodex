import SwiftUI

struct TreeOfLifeView: View {
    @ObservedObject var vm: ArcanaViewModel
    @State private var selectedPath: ArcanaSymbol?

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        ChapterBanner(
                            title: "生命の樹",
                            subtitle: "22のパスを、大アルカナとヘブライ文字の対応で読む。",
                            icon: "point.3.connected.trianglepath.dotted"
                        )
                        .padding(.horizontal)

                        // Interactive Tree
                        treeCanvas
                            .frame(minHeight: 400, maxHeight: 600)
                            .padding()

                        // Path list
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "22のパス", icon: "line.3.crossed.swirl.circle")
                                .padding(.horizontal)

                            ForEach(vm.majorArcana) { symbol in
                                if let path = symbol.treeOfLifePath,
                                   let conn = symbol.treeOfLifeSephiroth {
                                    pathRow(symbol: symbol, path: path, from: conn.0, to: conn.1)
                                        .onTapGesture { selectedPath = symbol }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("生命の樹")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedPath) { symbol in
                SymbolDetailView(symbol: symbol)
            }
        }
    }

    private var treeCanvas: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Draw paths (lines between sephiroth)
                ForEach(vm.majorArcana) { symbol in
                    if let conn = symbol.treeOfLifeSephiroth {
                        let from = sephirahPosition(name: conn.0, width: w, height: h)
                        let to = sephirahPosition(name: conn.1, width: w, height: h)
                        if let from, let to {
                            Path { p in
                                p.move(to: from)
                                p.addLine(to: to)
                            }
                            .stroke(Color(hex: AppDesign.antiqueGold).opacity(0.30), lineWidth: 1)
                        }
                    }
                }

                // Draw sephiroth
                ForEach(Sephirah.all) { seph in
                    let pos = CGPoint(x: seph.position.x * w, y: seph.position.y * h)
                    VStack(spacing: 2) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: AppDesign.ink).opacity(0.76))
                                .frame(width: 36, height: 36)
                            Circle()
                                .stroke(Color(hex: AppDesign.antiqueGold).opacity(0.72), lineWidth: 1.5)
                                .frame(width: 36, height: 36)
                            Text(seph.nameHe)
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                        }
                        Text(seph.nameJa)
                            .font(.system(size: 9).bold())
                            .foregroundStyle(Color(hex: AppDesign.textPrimary))
                    }
                    .position(pos)
                }
            }
        }
    }

    private func sephirahPosition(name: String, width: CGFloat, height: CGFloat) -> CGPoint? {
        // Extract Japanese name from format "ケテル (Crown)"
        let jaName = name.components(separatedBy: " (").first ?? name
        guard let seph = Sephirah.all.first(where: { $0.nameJa == jaName }) else { return nil }
        return CGPoint(x: seph.position.x * width, y: seph.position.y * height)
    }

    private func pathRow(symbol: ArcanaSymbol, path: String, from: String, to: String) -> some View {
        CosmicCard {
            HStack(spacing: 12) {
                Text("\(symbol.number)")
                    .font(.caption.bold().monospaced())
                    .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(symbol.nameJa) — \(symbol.nameEn)")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(hex: AppDesign.textPrimary))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    HStack(spacing: 4) {
                        Text(path)
                            .font(.caption)
                            .foregroundStyle(Color(hex: AppDesign.goldLight))
                        Text("·")
                            .foregroundStyle(Color(hex: AppDesign.textSecondary))
                        if let hebrew = symbol.hebrewLetter {
                            Text(hebrew)
                                .font(.caption)
                                .foregroundStyle(Color(hex: AppDesign.verdigrisLight))
                        }
                    }
                }

                Spacer()

                Text(symbol.emoji)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
    }
}
