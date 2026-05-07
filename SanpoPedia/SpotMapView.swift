import SwiftUI
import MapKit

struct SpotMapView: View {
    let spots: [SpotItem]
    @ObservedObject var favorites: FavoritesStore
    @State private var selectedSpot: SpotItem?
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $position) {
                UserAnnotation()
                ForEach(spots) { spot in
                    Annotation(spot.title, coordinate: spot.coordinate) {
                        Button {
                            selectedSpot = spot
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 42, height: 42)
                                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                                Circle()
                                    .fill(Color(hex: spot.category.color))
                                    .frame(width: 34, height: 34)
                                Image(systemName: spot.category.icon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("地図で見る")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SanpoTheme.ink)
                Text("ピンを押すと詳細を開けます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(16)
        }
        .sheet(item: $selectedSpot) { spot in
            NavigationStack {
                SpotDetailView(spot: spot)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("閉じる") { selectedSpot = nil }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
