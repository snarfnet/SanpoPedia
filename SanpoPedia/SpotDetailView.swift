import SwiftUI
import MapKit

struct SpotDetailView: View {
    let spot: SpotItem
    @EnvironmentObject var favorites: FavoritesStore

    var body: some View {
        ZStack {
            SanpoBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerImage

                    HStack {
                        Label(spot.category.rawValue, systemImage: spot.category.icon)
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color(hex: spot.category.color))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Spacer()

                        Label(formatDistance(spot.distance), systemImage: "figure.walk")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 9) {
                        Text(spot.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(SanpoTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(spot.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .background(.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(SanpoTheme.line, lineWidth: 1)
                    )

                    SectionHeaderLabel(title: "場所", subtitle: "現在地からの距離と地図")

                    Map {
                        Marker(spot.title, coordinate: spot.coordinate)
                            .tint(Color(hex: spot.category.color))
                    }
                    .frame(height: 176)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(SanpoTheme.line, lineWidth: 1)
                    )
                    .allowsHitTesting(false)

                    actionButtons
                }
                .padding(16)
            }
        }
        .navigationTitle(spot.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageURL = spot.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Image("WalkHero")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
            } else {
                Image("WalkHero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            LinearGradient(
                colors: [.black.opacity(0.28), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    favorites.toggle(spot.id)
                } label: {
                    Label(
                        favorites.isFavorite(spot.id) ? "保存済み" : "保存",
                        systemImage: favorites.isFavorite(spot.id) ? "heart.fill" : "heart"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(favorites.isFavorite(spot.id) ? SanpoTheme.vermilion : SanpoTheme.moss)

                if let url = URL(string: spot.wikiURL) {
                    Link(destination: url) {
                        Label("Wikipedia", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SanpoTheme.moss)
                }
            }

            Button {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinate))
                mapItem.name = spot.title
                mapItem.openInMaps()
            } label: {
                Label("マップで開く", systemImage: "map")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(SanpoTheme.sky)
        }
        .controlSize(.large)
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        }
        return String(format: "%.1fkm", meters / 1000)
    }
}
