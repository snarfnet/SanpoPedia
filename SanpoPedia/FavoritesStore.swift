import Foundation

class FavoritesStore: ObservableObject {
    @Published var favoriteIds: Set<Int> = []

    private let key = "sanpo_favorites"

    init() {
        let saved = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
        favoriteIds = Set(saved)
    }

    func toggle(_ id: Int) {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
        UserDefaults.standard.set(Array(favoriteIds), forKey: key)
    }

    func isFavorite(_ id: Int) -> Bool {
        favoriteIds.contains(id)
    }
}
