//
//  DiscoveryFilters.swift
//  NewLocal
//
//  Discovery filter preferences for relocation community app
//

import Foundation

@MainActor
class DiscoveryFilters: ObservableObject {
    static let shared = DiscoveryFilters()

    // Basic Filters
    @Published var maxDistance: Double = 50 // miles
    @Published var minAge: Int = 18
    @Published var maxAge: Int = 65
    @Published var showVerifiedOnly: Bool = false
    @Published var selectedInterests: Set<String> = []

    // NewLocal Filters
    @Published var userTypes: Set<String> = []  // "local", "newcomer", "transplant"
    @Published var neighborhoods: Set<String> = []
    @Published var professions: Set<String> = []
    @Published var movedFromCities: Set<String> = []  // Connect with people from same hometown
    @Published var whatToExplore: Set<String> = []  // Filter by exploration interests
    @Published var connectionGoals: Set<String> = []  // "Find local guides", "Meet newcomers", etc.

    // Time in City Filter
    @Published var showNewArrivals: Bool = false  // Less than 3 months
    @Published var showRecentMovers: Bool = false  // 3-12 months
    @Published var showEstablished: Bool = false  // 1+ years

    // Education (kept for professional networking)
    @Published var educationLevels: Set<String> = []

    private init() {
        loadFromUserDefaults()
    }

    // MARK: - Filter Logic

    func matchesFilters(user: User, currentUserLocation: (lat: Double, lon: Double)?) -> Bool {
        // Validate age bounds to prevent crashes
        guard user.age > 0, user.age < 150 else {
            Logger.shared.warning("Invalid user age: \(user.age)", category: .matching)
            return false
        }

        // Age filter
        if user.age < minAge || user.age > maxAge {
            return false
        }

        // Verification filter
        if showVerifiedOnly && !user.isVerified {
            return false
        }

        // Distance filter
        if let currentLocation = currentUserLocation,
           let userLat = user.latitude,
           let userLon = user.longitude {
            let distance = calculateDistance(
                from: currentLocation,
                to: (userLat, userLon)
            )
            if distance > maxDistance {
                return false
            }
        }

        // Interest filter (if any selected, user must have at least one match)
        if !selectedInterests.isEmpty {
            let userInterests = Set(user.interests)
            if selectedInterests.intersection(userInterests).isEmpty {
                return false
            }
        }

        // User type filter (local, newcomer, transplant)
        if !userTypes.isEmpty {
            if !userTypes.contains(user.userType) {
                return false
            }
        }

        // Neighborhood filter
        if !neighborhoods.isEmpty {
            if !neighborhoods.contains(where: { user.neighborhood.lowercased().contains($0.lowercased()) }) {
                return false
            }
        }

        // Profession filter
        if !professions.isEmpty {
            if !professions.contains(where: { user.profession.lowercased().contains($0.lowercased()) }) {
                return false
            }
        }

        // Moved from filter (connect with people from same hometown)
        if !movedFromCities.isEmpty {
            if !movedFromCities.contains(where: { user.movedFrom.lowercased().contains($0.lowercased()) }) {
                return false
            }
        }

        // What to explore filter
        if !whatToExplore.isEmpty {
            let userExplore = Set(user.whatToExplore)
            if whatToExplore.intersection(userExplore).isEmpty {
                return false
            }
        }

        // Connection goals filter
        if !connectionGoals.isEmpty {
            let userGoals = Set(user.lookingToConnect)
            if connectionGoals.intersection(userGoals).isEmpty {
                return false
            }
        }

        // Time in city filter
        if showNewArrivals || showRecentMovers || showEstablished {
            guard let movedDate = user.movedToDate else {
                // If user type is "local", they don't have a moved date
                if user.userType == "local" {
                    if !showEstablished {
                        return false
                    }
                } else {
                    return false
                }
            }

            if let movedDate = user.movedToDate {
                let months = Calendar.current.dateComponents([.month], from: movedDate, to: Date()).month ?? 0

                if showNewArrivals && months < 3 {
                    // Pass - new arrival
                } else if showRecentMovers && months >= 3 && months < 12 {
                    // Pass - recent mover
                } else if showEstablished && months >= 12 {
                    // Pass - established
                } else if !showNewArrivals && !showRecentMovers && !showEstablished {
                    // No time filter active, pass
                } else {
                    return false
                }
            }
        }

        // Education level filter
        if !educationLevels.isEmpty {
            guard let userEducation = user.educationLevel else {
                return false
            }
            if !educationLevels.contains(userEducation) {
                return false
            }
        }

        return true
    }

    private func calculateDistance(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> Double {
        // Validate coordinates
        guard isValidLatitude(from.lat), isValidLongitude(from.lon),
              isValidLatitude(to.lat), isValidLongitude(to.lon) else {
            Logger.shared.warning("Invalid coordinates: from(\(from.lat), \(from.lon)) to(\(to.lat), \(to.lon))", category: .matching)
            return Double.infinity // Return max distance for invalid coordinates
        }

        let earthRadiusMiles = 3958.8

        let lat1 = from.lat * .pi / 180
        let lon1 = from.lon * .pi / 180
        let lat2 = to.lat * .pi / 180
        let lon2 = to.lon * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))

        let distance = earthRadiusMiles * c

        // Validate result
        guard distance.isFinite, distance >= 0 else {
            Logger.shared.warning("Invalid distance calculation result: \(distance)", category: .matching)
            return Double.infinity
        }

        return distance
    }

    private func isValidLatitude(_ lat: Double) -> Bool {
        return lat >= -90 && lat <= 90 && lat.isFinite
    }

    private func isValidLongitude(_ lon: Double) -> Bool {
        return lon >= -180 && lon <= 180 && lon.isFinite
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        UserDefaults.standard.set(maxDistance, forKey: "maxDistance")
        UserDefaults.standard.set(minAge, forKey: "minAge")
        UserDefaults.standard.set(maxAge, forKey: "maxAge")
        UserDefaults.standard.set(showVerifiedOnly, forKey: "showVerifiedOnly")
        UserDefaults.standard.set(Array(selectedInterests), forKey: "selectedInterests")

        // NewLocal Filters
        UserDefaults.standard.set(Array(userTypes), forKey: "userTypes")
        UserDefaults.standard.set(Array(neighborhoods), forKey: "neighborhoods")
        UserDefaults.standard.set(Array(professions), forKey: "professions")
        UserDefaults.standard.set(Array(movedFromCities), forKey: "movedFromCities")
        UserDefaults.standard.set(Array(whatToExplore), forKey: "whatToExplore")
        UserDefaults.standard.set(Array(connectionGoals), forKey: "connectionGoals")
        UserDefaults.standard.set(showNewArrivals, forKey: "showNewArrivals")
        UserDefaults.standard.set(showRecentMovers, forKey: "showRecentMovers")
        UserDefaults.standard.set(showEstablished, forKey: "showEstablished")
        UserDefaults.standard.set(Array(educationLevels), forKey: "educationLevels")
    }

    private func loadFromUserDefaults() {
        if let distance = UserDefaults.standard.object(forKey: "maxDistance") as? Double {
            maxDistance = distance
        }
        if let min = UserDefaults.standard.object(forKey: "minAge") as? Int {
            minAge = min
        }
        if let max = UserDefaults.standard.object(forKey: "maxAge") as? Int {
            maxAge = max
        }
        showVerifiedOnly = UserDefaults.standard.bool(forKey: "showVerifiedOnly")
        if let interests = UserDefaults.standard.array(forKey: "selectedInterests") as? [String] {
            selectedInterests = Set(interests)
        }

        // NewLocal Filters
        if let types = UserDefaults.standard.array(forKey: "userTypes") as? [String] {
            userTypes = Set(types)
        }
        if let neighborhoods = UserDefaults.standard.array(forKey: "neighborhoods") as? [String] {
            self.neighborhoods = Set(neighborhoods)
        }
        if let professions = UserDefaults.standard.array(forKey: "professions") as? [String] {
            self.professions = Set(professions)
        }
        if let cities = UserDefaults.standard.array(forKey: "movedFromCities") as? [String] {
            movedFromCities = Set(cities)
        }
        if let explore = UserDefaults.standard.array(forKey: "whatToExplore") as? [String] {
            whatToExplore = Set(explore)
        }
        if let goals = UserDefaults.standard.array(forKey: "connectionGoals") as? [String] {
            connectionGoals = Set(goals)
        }
        showNewArrivals = UserDefaults.standard.bool(forKey: "showNewArrivals")
        showRecentMovers = UserDefaults.standard.bool(forKey: "showRecentMovers")
        showEstablished = UserDefaults.standard.bool(forKey: "showEstablished")
        if let education = UserDefaults.standard.array(forKey: "educationLevels") as? [String] {
            educationLevels = Set(education)
        }
    }

    func resetFilters() {
        maxDistance = 50
        minAge = 18
        maxAge = 65
        showVerifiedOnly = false
        selectedInterests.removeAll()

        // Reset NewLocal Filters
        userTypes.removeAll()
        neighborhoods.removeAll()
        professions.removeAll()
        movedFromCities.removeAll()
        whatToExplore.removeAll()
        connectionGoals.removeAll()
        showNewArrivals = false
        showRecentMovers = false
        showEstablished = false
        educationLevels.removeAll()

        saveToUserDefaults()
    }

    var hasActiveFilters: Bool {
        return minAge > 18 || maxAge < 65 || showVerifiedOnly || !selectedInterests.isEmpty ||
               !userTypes.isEmpty || !neighborhoods.isEmpty || !professions.isEmpty ||
               !movedFromCities.isEmpty || !whatToExplore.isEmpty || !connectionGoals.isEmpty ||
               showNewArrivals || showRecentMovers || showEstablished || !educationLevels.isEmpty
    }

    // MARK: - Quick Filter Presets

    /// Show only locals who can help newcomers
    func showLocalsOnly() {
        resetFilters()
        userTypes = ["local"]
        saveToUserDefaults()
    }

    /// Show only newcomers (less than 6 months)
    func showNewcomersOnly() {
        resetFilters()
        userTypes = ["newcomer"]
        showNewArrivals = true
        showRecentMovers = true
        saveToUserDefaults()
    }

    /// Show people from same hometown
    func showSameHometown(_ hometown: String) {
        resetFilters()
        movedFromCities = [hometown]
        saveToUserDefaults()
    }

    /// Show people in same neighborhood
    func showSameNeighborhood(_ neighborhood: String) {
        resetFilters()
        neighborhoods = [neighborhood]
        saveToUserDefaults()
    }

    /// Show people with same profession for networking
    func showSameProfession(_ profession: String) {
        resetFilters()
        professions = [profession]
        saveToUserDefaults()
    }
}
