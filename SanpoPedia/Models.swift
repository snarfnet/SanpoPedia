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
        case .legend: return "ghost"
        case .filming: return "film"
        case .other: return "mappin"
        }
    }

    var color: String {
        switch self {
        case .play: return "4CAF50"
        case .useful: return "2196F3"
        case .eat: return "FF9800"
        case .history: return "795548"
        case .trivia: return "FFC107"
        case .nature: return "66BB6A"
        case .culture: return "9C27B0"
        case .incident: return "F44336"
        case .architecture: return "607D8B"
        case .sports: return "00BCD4"
        case .legend: return "673AB7"
        case .filming: return "E91E63"
        case .other: return "9E9E9E"
        }
    }
}

enum ViewMode {
    case list
    case map
}
