import Foundation
import CoreLocation

class WikipediaService {
    static let shared = WikipediaService()
    private let baseURL = "https://ja.wikipedia.org/w/api.php"

    func fetchNearbySpots(location: CLLocationCoordinate2D, radius: Int = 5000) async throws -> [SpotItem] {
        // Step 1: Geosearch
        let geoURL = "\(baseURL)?action=query&list=geosearch&gscoord=\(location.latitude)|\(location.longitude)&gsradius=\(radius)&gslimit=50&format=json"

        guard let url = URL(string: geoURL) else { throw WikiError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue("SanpoPedia/1.0 (iOS App)", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let geoResponse = try JSONDecoder().decode(GeoSearchResponse.self, from: data)

        guard let results = geoResponse.query?.geosearch, !results.isEmpty else {
            return []
        }

        // Step 2: Get details for each page
        let pageIds = results.map { String($0.pageid) }.joined(separator: "|")
        let detailURL = "\(baseURL)?action=query&pageids=\(pageIds)&prop=extracts|pageimages|categories|coordinates&exintro=true&explaintext=true&piprop=thumbnail&pithumbsize=400&cllimit=50&format=json"

        guard let detURL = URL(string: detailURL) else { throw WikiError.invalidURL }
        var detRequest = URLRequest(url: detURL)
        detRequest.setValue("SanpoPedia/1.0 (iOS App)", forHTTPHeaderField: "User-Agent")

        let (detData, _) = try await URLSession.shared.data(for: detRequest)
        let detResponse = try JSONDecoder().decode(GeoSearchResponse.self, from: detData)

        let pages = detResponse.query?.pages ?? [:]

        // Build SpotItems
        var spots: [SpotItem] = []
        for geoResult in results {
            guard let page = pages[String(geoResult.pageid)] else { continue }
            let extract = page.extract ?? ""
            if extract.isEmpty { continue }

            let categories = page.categories?.map { $0.title } ?? []
            let category = classifyCategories(title: page.title, categories: categories, extract: extract)

            let spot = SpotItem(
                id: geoResult.pageid,
                title: page.title,
                description: extract,
                imageURL: page.thumbnail?.source,
                coordinate: geoResult.coordinate,
                distance: geoResult.dist ?? 0,
                category: category,
                wikiURL: "https://ja.wikipedia.org/wiki/\(page.title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? page.title)"
            )
            spots.append(spot)
        }

        return spots.sorted { $0.distance < $1.distance }
    }

    private func classifyCategories(title: String, categories: [String], extract: String) -> SpotCategory {
        let text = (categories.joined(separator: " ") + " " + title + " " + extract).lowercased()

        // Play
        if text.contains("公園") || text.contains("遊園") || text.contains("動物園") ||
           text.contains("水族館") || text.contains("美術館") || text.contains("博物館") ||
           text.contains("テーマパーク") || text.contains("レジャー") {
            return .play
        }
        // Eat
        if text.contains("料理") || text.contains("食") || text.contains("レストラン") ||
           text.contains("酒蔵") || text.contains("老舗") || text.contains("名物") ||
           text.contains("ラーメン") || text.contains("菓子") {
            return .eat
        }
        // Nature
        if text.contains("山") || text.contains("川") || text.contains("湖") ||
           text.contains("温泉") || text.contains("海岸") || text.contains("渓谷") ||
           text.contains("滝") || text.contains("森林") {
            return .nature
        }
        // History
        if text.contains("城") || text.contains("神社") || text.contains("寺") ||
           text.contains("史跡") || text.contains("古墳") || text.contains("遺跡") ||
           text.contains("文化財") || text.contains("歴史") {
            return .history
        }
        // Culture
        if text.contains("祭") || text.contains("伝統") || text.contains("工芸") ||
           text.contains("芸能") || text.contains("民俗") {
            return .culture
        }
        // Useful
        if text.contains("駅") || text.contains("郵便局") || text.contains("図書館") ||
           text.contains("病院") || text.contains("学校") || text.contains("役所") ||
           text.contains("交番") {
            return .useful
        }
        // Architecture
        if text.contains("建築") || text.contains("タワー") || text.contains("橋") ||
           text.contains("ビル") || text.contains("設計") {
            return .architecture
        }
        // Sports
        if text.contains("スタジアム") || text.contains("競技場") || text.contains("体育館") ||
           text.contains("球場") || text.contains("スポーツ") {
            return .sports
        }
        // Legend
        if text.contains("伝説") || text.contains("民話") || text.contains("怪談") ||
           text.contains("心霊") || text.contains("妖怪") {
            return .legend
        }
        // Incident
        if text.contains("事件") || text.contains("災害") || text.contains("戦争") ||
           text.contains("空襲") {
            return .incident
        }
        // Filming
        if text.contains("ロケ地") || text.contains("撮影") || text.contains("舞台") ||
           text.contains("聖地巡礼") {
            return .filming
        }
        // Trivia (地名由来 etc)
        if text.contains("由来") || text.contains("出身") || text.contains("発祥") {
            return .trivia
        }

        return .other
    }
}

enum WikiError: Error, LocalizedError {
    case invalidURL
    case serverError
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URLが無効です"
        case .serverError: return "サーバーエラー"
        case .noResults: return "周辺情報が見つかりません"
        }
    }
}
