import SwiftUI

struct SpotListView: View {
    let spots: [SpotItem]
    @ObservedObject var favorites: FavoritesStore

    var body: some View {
        List(spots) { spot in
            NavigationLink(destination: SpotDetailView(spot: spot)) {
                SpotRowView(spot: spot, isFavorite: favorites.isFavorite(spot.id))
            }
            .swipeActions(edge: .trailing) {
                Button {
                    favorites.toggle(spot.id)
                } label: {
                    Image(systemName: favorites.isFavorite(spot.id) ? "heart.slash" : "heart")
                }
                .tint(favorites.isFavorite(spot.id) ? .gray : .red)
            }
        }
        .listStyle(.plain)
    }
}

struct SpotRowView: View {
    let spot: SpotItem
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color(hex: spot.category.color).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: spot.category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: spot.category.color))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(spot.title)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                Text(spot.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Distance
            Text(formatDistance(spot.distance))
                .font(.caption2.bold())
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        }
        return String(format: "%.1fkm", meters / 1000)
    }
}
