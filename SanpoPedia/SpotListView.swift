import SwiftUI

struct SpotListView: View {
    let spots: [SpotItem]
    @ObservedObject var favorites: FavoritesStore

    var body: some View {
        List {
            Section {
                ForEach(spots) { spot in
                    NavigationLink(destination: SpotDetailView(spot: spot)) {
                        SpotRowView(spot: spot, isFavorite: favorites.isFavorite(spot.id))
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .swipeActions(edge: .trailing) {
                        Button {
                            favorites.toggle(spot.id)
                        } label: {
                            Image(systemName: favorites.isFavorite(spot.id) ? "heart.slash" : "heart")
                        }
                        .tint(favorites.isFavorite(spot.id) ? .gray : SanpoTheme.vermilion)
                    }
                }
            } header: {
                SectionHeaderLabel(title: "近くで見つかった場所", subtitle: "距離が近い順に表示しています")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}

struct SpotRowView: View {
    let spot: SpotItem
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: 12) {
            CategoryBadge(category: spot.category)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(spot.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SanpoTheme.ink)
                        .lineLimit(1)
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(SanpoTheme.vermilion)
                    }
                }
                Text(spot.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .lineSpacing(2)
                HStack(spacing: 6) {
                    Label(spot.category.rawValue, systemImage: spot.category.icon)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color(hex: spot.category.color))
                    Spacer()
                    Label(formatDistance(spot.distance), systemImage: "figure.walk")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(SanpoTheme.line)
        }
        .padding(14)
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(SanpoTheme.line, lineWidth: 1)
        )
        .shadow(color: SanpoTheme.ink.opacity(0.07), radius: 10, x: 0, y: 5)
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        }
        return String(format: "%.1fkm", meters / 1000)
    }
}

struct CategoryBadge: View {
    let category: SpotCategory

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: category.color).opacity(0.13))
                .frame(width: 52, height: 52)
            Image(systemName: category.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: category.color))
        }
    }
}
