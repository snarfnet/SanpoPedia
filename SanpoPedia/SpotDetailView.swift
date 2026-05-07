import SwiftUI
import MapKit

struct SpotDetailView: View {
    let spot: SpotItem
    @EnvironmentObject var favorites: FavoritesStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header image
                if let imageURL = spot.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        default:
                            Color(.systemGray5)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }

                // Category & distance
                HStack {
                    Label(spot.category.rawValue, systemImage: spot.category.icon)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: spot.category.color))
                        .clipShape(Capsule())

                    Spacer()

                    Text(formatDistance(spot.distance))
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }

                // Title
                Text(spot.title)
                    .font(.title2.bold())

                // Description
                Text(spot.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)

                // Mini map
                Map {
                    Marker(spot.title, coordinate: spot.coordinate)
                        .tint(Color(hex: spot.category.color))
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)

                // Actions
                HStack(spacing: 12) {
                    Button {
                        favorites.toggle(spot.id)
                    } label: {
                        Label(
                            favorites.isFavorite(spot.id) ? "お気に入り解除" : "お気に入り",
                            systemImage: favorites.isFavorite(spot.id) ? "heart.fill" : "heart"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(favorites.isFavorite(spot.id) ? .red : .gray)

                    if let url = URL(string: spot.wikiURL) {
                        Link(destination: url) {
                            Label("Wikipedia", systemImage: "safari")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                // Open in Maps
                Button {
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinate))
                    mapItem.name = spot.title
                    mapItem.openInMaps()
                } label: {
                    Label("マップで開く", systemImage: "map")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle(spot.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        }
        return String(format: "%.1fkm", meters / 1000)
    }
}
