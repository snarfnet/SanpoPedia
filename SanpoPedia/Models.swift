import Foundation
import CoreLocation

// Wikipedia geosearch response
struct GeoSearchResponse: Codable {
    let query: GeoQuery?
}

struct GeoQuery: Codable {
    let geosearch: [GeoResult]?
    let pages: [String: PageDetail]?
}

struct GeoResult: Codable, Identifiable {
    let pageid: Int
    let title: String
    let lat: Double
    let lon: Double
    let dist: Double?

    var id: Int { pageid }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct PageDetail: Codable {
    let pageid: Int
    let title: String
    let extract: String?
    let thumbnail: PageThumbnail?
    let categories: [PageCategory]?
    let coordinates: [PageCoordinate]?
}

struct PageThumbnail: Codable {
    let source: String
    let width: Int
    let height: Int
}

struct PageCategory: Codable {
    let title: String
}

struct PageCoordinate: Codable {
    let lat: Double
    let lon: Double
}

// App models
struct SpotItem: Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let imageURL: String?
    let coordinate: CLLocationCoordinate2D
    let distance: Double
    let category: SpotCategory
    let wikiURL: String
    var isFavorite: Bool = false

    static func == (lhs: SpotItem, rhs: SpotItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum SpotCategory: String, CaseIterable, Identifiable {
    case play = "遊ぶ"
    case useful = "便利"
    case eat = "食べる"
    case history = "歴史"
    case trivia = "豆知識"
    case nature = "自然"
    case culture = "文化"
    case incident = "事件"
    case architecture = "建築"
    case sports = "スポーツ"
    case legend = "伝説"
    case filming = "ロケ地"
    case other = "その他"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .play: return "figure.play"
        case .useful: return "building.2"
        case .eat: return "fork.knife"
        case .history: return "clock.arrow.circlepath"
        case .trivia: return "lightbulb"
        case .nature: return "leaf"
        case .culture: return "theatermasks"
        case .incident: return "exclamationmark.triangle"
        case .architecture: return "building.columns"
        case .sports: return "sportscourt"
        case .legend: return "sparkles"
        case .filming: return "film"
        case .other: return "mappin"
        }
    }

    var color: String {
        switch self {
        case .play: return "2F8F5B"
        case .useful: return "3D95B8"
        case .eat: return "D9783A"
        case .history: return "8A6848"
        case .trivia: return "C89D2D"
        case .nature: return "126A3F"
        case .culture: return "7D5B9A"
        case .incident: return "C94D46"
        case .architecture: return "586F78"
        case .sports: return "268C98"
        case .legend: return "6F6AB2"
        case .filming: return "C95F78"
        case .other: return "7B837D"
        }
    }
}

enum ViewMode {
    case list
    case map
}
