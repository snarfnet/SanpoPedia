import SwiftUI
import MapKit

struct SpotMapView: View {
    let spots: [SpotItem]
    @ObservedObject var favorites: FavoritesStore
    @State private var selectedSpot: SpotItem?
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(spots) { spot in
                Annotation(spot.title, coordinate: spot.coordinate) {
                    Button {
                        selectedSpot = spot
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: spot.category.color))
                                .frame(width: 32, height: 32)
                            Image(systemName: spot.category.icon)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
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
