import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = SpotsViewModel()
    @StateObject private var favorites = FavoritesStore()
    @State private var viewMode: ViewMode = .list
    @State private var selectedCategory: SpotCategory? = nil

    var filteredSpots: [SpotItem] {
        if let cat = selectedCategory {
            return viewModel.spots.filter { $0.category == cat }
        }
        return viewModel.spots
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                CategoryFilterView(selected: $selectedCategory)

                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("周辺情報を収集中...")
                        .font(.headline)
                    Spacer()
                } else if viewModel.spots.isEmpty {
                    Spacer()
                    EmptyStateView(locationManager: locationManager)
                    Spacer()
                } else {
                    switch viewMode {
                    case .list:
                        SpotListView(spots: filteredSpots, favorites: favorites)
                    case .map:
                        SpotMapView(spots: filteredSpots, favorites: favorites)
                    }
                }

                // Ad banner
                BannerAdView()
                    .frame(height: 50)
            }
            .navigationTitle("散歩ペディア")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("表示", selection: $viewMode) {
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                        Image(systemName: "map").tag(ViewMode.map)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await viewModel.refresh(location: locationManager.location) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .environmentObject(favorites)
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.location) { _, newLoc in
            if let loc = newLoc, viewModel.spots.isEmpty {
                Task { await viewModel.loadSpots(location: loc) }
            }
        }
    }
}

struct EmptyStateView: View {
    let locationManager: LocationManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            if locationManager.authorizationStatus == .denied {
                Text("位置情報を許可してください")
                    .font(.headline)
                Text("設定 > プライバシー > 位置情報サービス")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("位置情報を取得中...")
                    .font(.headline)
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
class SpotsViewModel: ObservableObject {
    @Published var spots: [SpotItem] = []
    @Published var isLoading = false

    func loadSpots(location: CLLocationCoordinate2D) async {
        isLoading = true
        do {
            spots = try await WikipediaService.shared.fetchNearbySpots(location: location)
        } catch {
            print("Error: \(error)")
        }
        isLoading = false
    }

    func refresh(location: CLLocationCoordinate2D?) async {
        guard let loc = location else { return }
        await loadSpots(location: loc)
    }
}
