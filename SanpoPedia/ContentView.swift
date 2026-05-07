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
            ZStack {
                SanpoBackground()
                VStack(spacing: 0) {
                    HomeHeader(
                        spotCount: viewModel.spots.count,
                        filteredCount: filteredSpots.count,
                        selectedCategory: selectedCategory
                    )

                    CategoryFilterView(selected: $selectedCategory)

                    Group {
                        if viewModel.isLoading {
                            LoadingStateView()
                        } else if viewModel.spots.isEmpty {
                            EmptyStateView(locationManager: locationManager)
                        } else {
                            switch viewMode {
                            case .list:
                                SpotListView(spots: filteredSpots, favorites: favorites)
                            case .map:
                                SpotMapView(spots: filteredSpots, favorites: favorites)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    BannerAdView()
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                }
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
                    .frame(width: 112)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await viewModel.refresh(location: locationManager.location?.coordinate) }
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
            if let loc = newLoc?.coordinate, viewModel.spots.isEmpty {
                Task { await viewModel.loadSpots(location: loc) }
            }
        }
        .task {
            // Fallback: if no location after 8 seconds, use Tokyo Station
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            if viewModel.spots.isEmpty && !viewModel.isLoading {
                let fallback = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
                await viewModel.loadSpots(location: fallback)
            }
        }
    }
}

struct HomeHeader: View {
    let spotCount: Int
    let filteredCount: Int
    let selectedCategory: SpotCategory?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomLeading) {
                Image("WalkHero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.36), .black.opacity(0.05)],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    )

                VStack(alignment: .leading, spacing: 7) {
                    Text("今いる場所の物語を探す")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Wikipediaから近くの名所、公共施設、豆知識を集めます")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(2)
                }
                .padding(16)
            }

            HStack(spacing: 10) {
                MetricPill(icon: "mappin.and.ellipse", title: "周辺", value: "\(spotCount)件")
                MetricPill(
                    icon: selectedCategory?.icon ?? "square.grid.2x2",
                    title: selectedCategory?.rawValue ?? "すべて",
                    value: "\(filteredCount)件"
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
}

struct MetricPill: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(SanpoTheme.moss)
                .frame(width: 26, height: 26)
                .background(SanpoTheme.mist)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SanpoTheme.ink)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(SanpoTheme.line, lineWidth: 1)
        )
    }
}

struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(SanpoTheme.moss)
                .scaleEffect(1.15)
            Text("周辺情報を集めています")
                .font(.headline.weight(.semibold))
                .foregroundStyle(SanpoTheme.ink)
            Text("近くの記事と公共施設をWikipediaから確認中です")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }
}

struct EmptyStateView: View {
    let locationManager: LocationManager

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: locationManager.authorizationStatus == .denied ? "location.slash" : "location.magnifyingglass")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(SanpoTheme.moss)
                .frame(width: 86, height: 86)
                .background(SanpoTheme.mist)
                .clipShape(Circle())
            if locationManager.authorizationStatus == .denied {
                Text("位置情報を許可してください")
                    .font(.headline.weight(.semibold))
                Text("設定 > プライバシー > 位置情報サービス")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("位置情報を取得中...")
                    .font(.headline.weight(.semibold))
                Text("現在地がわかると、近くの記事を自動で表示します")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
        .background(.white.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(SanpoTheme.line, lineWidth: 1)
        )
        .padding(24)
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
