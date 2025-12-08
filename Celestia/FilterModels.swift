//
//  FilterModels.swift
//  NewLocal
//
//  Data models for advanced search and filtering for relocation community app
//

import Foundation
import CoreLocation

// MARK: - Search Filter

struct SearchFilter: Codable, Equatable {

    // MARK: - Location
    var distanceRadius: Int = 50 // miles (1-100)
    var location: CLLocationCoordinate2D?
    var useCurrentLocation: Bool = true

    // MARK: - Demographics
    var ageRange: AgeRange = AgeRange(min: 18, max: 99)
    var heightRange: HeightRange? // Optional, nil = any height
    var gender: GenderFilter = .all
    var showMe: ShowMeFilter = .everyone

    // MARK: - Background
    var educationLevels: [EducationLevel] = []
    var ethnicities: [Ethnicity] = []
    var religions: [Religion] = []
    var languages: [Language] = []

    // MARK: - Lifestyle
    var smoking: LifestyleFilter = .any
    var drinking: LifestyleFilter = .any
    var pets: PetPreference = .any
    var hasChildren: LifestyleFilter = .any
    var wantsChildren: LifestyleFilter = .any
    var exercise: ExerciseFrequency = .any
    var diet: DietPreference = .any

    // MARK: - Relocation & Community
    var newcomerGoals: [NewcomerGoal] = []
    var connectionTypes: [ConnectionType] = []
    var timeInCity: TimeInCity?
    var relocationType: RelocationType?
    var movedFromCity: String?
    var movedFromCountry: String?
    var neighborhood: String?
    var showLocalsOnly: Bool = false
    var showNewcomersOnly: Bool = false

    // MARK: - Preferences
    var verifiedOnly: Bool = false
    var withPhotosOnly: Bool = true
    var activeInLastDays: Int? // nil = any, or 1, 7, 30
    var newUsers: Bool = false // Joined in last 30 days

    // MARK: - Advanced
    var zodiacSigns: [ZodiacSign] = []
    var politicalViews: [PoliticalView] = []
    var occupations: [String] = []

    // MARK: - Metadata
    var id: String = UUID().uuidString
    var createdAt: Date = Date()
    var lastUsed: Date = Date()

    // MARK: - Helper Methods

    /// Check if filter is default (no custom filtering)
    var isDefault: Bool {
        return distanceRadius == 50 &&
               ageRange.min == 18 &&
               ageRange.max == 99 &&
               heightRange == nil &&
               educationLevels.isEmpty &&
               ethnicities.isEmpty &&
               religions.isEmpty &&
               smoking == .any &&
               drinking == .any &&
               pets == .any &&
               newcomerGoals.isEmpty &&
               connectionTypes.isEmpty &&
               timeInCity == nil &&
               relocationType == nil &&
               !showLocalsOnly &&
               !showNewcomersOnly &&
               !verifiedOnly
    }

    /// Count active filters
    var activeFilterCount: Int {
        var count = 0

        if distanceRadius != 50 { count += 1 }
        if ageRange.min != 18 || ageRange.max != 99 { count += 1 }
        if heightRange != nil { count += 1 }
        if !educationLevels.isEmpty { count += 1 }
        if !ethnicities.isEmpty { count += 1 }
        if !religions.isEmpty { count += 1 }
        if smoking != .any { count += 1 }
        if drinking != .any { count += 1 }
        if pets != .any { count += 1 }
        if hasChildren != .any { count += 1 }
        if wantsChildren != .any { count += 1 }
        if !newcomerGoals.isEmpty { count += 1 }
        if !connectionTypes.isEmpty { count += 1 }
        if timeInCity != nil { count += 1 }
        if relocationType != nil { count += 1 }
        if movedFromCity != nil { count += 1 }
        if movedFromCountry != nil { count += 1 }
        if neighborhood != nil { count += 1 }
        if showLocalsOnly { count += 1 }
        if showNewcomersOnly { count += 1 }
        if verifiedOnly { count += 1 }
        if activeInLastDays != nil { count += 1 }
        if newUsers { count += 1 }

        return count
    }

    /// Reset to default
    mutating func reset() {
        self = SearchFilter()
    }
}

// MARK: - Age Range

struct AgeRange: Codable, Equatable {
    var min: Int // 18-99
    var max: Int // 18-99

    init(min: Int = 18, max: Int = 99) {
        self.min = Swift.max(18, Swift.min(99, min))
        self.max = Swift.max(18, Swift.min(99, max))
    }

    func contains(_ age: Int) -> Bool {
        return age >= min && age <= max
    }
}

// MARK: - Height Range

struct HeightRange: Codable, Equatable {
    var minInches: Int // 48-96 inches (4'0" - 8'0")
    var maxInches: Int

    init(minInches: Int = 48, maxInches: Int = 96) {
        self.minInches = Swift.max(48, Swift.min(96, minInches))
        self.maxInches = Swift.max(48, Swift.min(96, maxInches))
    }

    func contains(_ heightInches: Int) -> Bool {
        return heightInches >= minInches && heightInches <= maxInches
    }

    // Helper: Convert inches to feet/inches display
    static func formatHeight(_ inches: Int) -> String {
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }
}

// MARK: - Gender Filter

enum GenderFilter: String, Codable, CaseIterable {
    case all = "all"
    case men = "men"
    case women = "women"
    case nonBinary = "non_binary"

    var displayName: String {
        switch self {
        case .all: return "Everyone"
        case .men: return "Men"
        case .women: return "Women"
        case .nonBinary: return "Non-Binary"
        }
    }
}

// MARK: - Show Me Filter

enum ShowMeFilter: String, Codable, CaseIterable {
    case everyone = "everyone"
    case men = "men"
    case women = "women"
    case nonBinary = "non_binary"

    var displayName: String {
        switch self {
        case .everyone: return "Everyone"
        case .men: return "Men"
        case .women: return "Women"
        case .nonBinary: return "Non-Binary"
        }
    }
}

// MARK: - Education Level

enum EducationLevel: String, Codable, CaseIterable {
    case highSchool = "high_school"
    case someCollege = "some_college"
    case bachelors = "bachelors"
    case masters = "masters"
    case doctorate = "doctorate"
    case tradeSchool = "trade_school"

    var displayName: String {
        switch self {
        case .highSchool: return "High School"
        case .someCollege: return "Some College"
        case .bachelors: return "Bachelor's Degree"
        case .masters: return "Master's Degree"
        case .doctorate: return "Doctorate"
        case .tradeSchool: return "Trade School"
        }
    }

    var icon: String {
        switch self {
        case .highSchool: return "building.2"
        case .someCollege: return "book"
        case .bachelors: return "graduationcap"
        case .masters: return "graduationcap.fill"
        case .doctorate: return "star.fill"
        case .tradeSchool: return "hammer"
        }
    }
}

// MARK: - Ethnicity

enum Ethnicity: String, Codable, CaseIterable {
    case asian = "asian"
    case black = "black"
    case hispanic = "hispanic"
    case middleEastern = "middle_eastern"
    case nativeAmerican = "native_american"
    case pacificIslander = "pacific_islander"
    case white = "white"
    case mixed = "mixed"
    case other = "other"

    var displayName: String {
        switch self {
        case .asian: return "Asian"
        case .black: return "Black / African"
        case .hispanic: return "Hispanic / Latino"
        case .middleEastern: return "Middle Eastern"
        case .nativeAmerican: return "Native American"
        case .pacificIslander: return "Pacific Islander"
        case .white: return "White / Caucasian"
        case .mixed: return "Mixed"
        case .other: return "Other"
        }
    }
}

// MARK: - Religion

enum Religion: String, Codable, CaseIterable {
    case agnostic = "agnostic"
    case atheist = "atheist"
    case buddhist = "buddhist"
    case catholic = "catholic"
    case christian = "christian"
    case hindu = "hindu"
    case jewish = "jewish"
    case muslim = "muslim"
    case spiritual = "spiritual"
    case other = "other"

    var displayName: String {
        switch self {
        case .agnostic: return "Agnostic"
        case .atheist: return "Atheist"
        case .buddhist: return "Buddhist"
        case .catholic: return "Catholic"
        case .christian: return "Christian"
        case .hindu: return "Hindu"
        case .jewish: return "Jewish"
        case .muslim: return "Muslim"
        case .spiritual: return "Spiritual"
        case .other: return "Other"
        }
    }
}

// MARK: - Language

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"
    case russian = "ru"
    case hindi = "hi"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .arabic: return "Arabic"
        case .russian: return "Russian"
        case .hindi: return "Hindi"
        }
    }
}

// MARK: - Lifestyle Filter

enum LifestyleFilter: String, Codable, CaseIterable {
    case any = "any"
    case yes = "yes"
    case no = "no"
    case sometimes = "sometimes"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .yes: return "Yes"
        case .no: return "No"
        case .sometimes: return "Sometimes"
        }
    }
}

// MARK: - Pet Preference

enum PetPreference: String, Codable, CaseIterable {
    case any = "any"
    case hasDogs = "has_dogs"
    case hasCats = "has_cats"
    case hasPets = "has_pets"
    case noPets = "no_pets"
    case allergicToPets = "allergic"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .hasDogs: return "Has Dog(s)"
        case .hasCats: return "Has Cat(s)"
        case .hasPets: return "Has Pets"
        case .noPets: return "No Pets"
        case .allergicToPets: return "Allergic to Pets"
        }
    }

    var icon: String {
        switch self {
        case .any: return "pawprint"
        case .hasDogs: return "dog"
        case .hasCats: return "cat"
        case .hasPets: return "pawprint.fill"
        case .noPets: return "nosign"
        case .allergicToPets: return "bandage"
        }
    }
}

// MARK: - Exercise Frequency

enum ExerciseFrequency: String, Codable, CaseIterable {
    case any = "any"
    case daily = "daily"
    case often = "often"
    case sometimes = "sometimes"
    case rarely = "rarely"
    case never = "never"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .daily: return "Daily"
        case .often: return "Often (3-5x/week)"
        case .sometimes: return "Sometimes (1-2x/week)"
        case .rarely: return "Rarely"
        case .never: return "Never"
        }
    }
}

// MARK: - Diet Preference

enum DietPreference: String, Codable, CaseIterable {
    case any = "any"
    case vegan = "vegan"
    case vegetarian = "vegetarian"
    case pescatarian = "pescatarian"
    case kosher = "kosher"
    case halal = "halal"
    case glutenFree = "gluten_free"
    case omnivore = "omnivore"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .pescatarian: return "Pescatarian"
        case .kosher: return "Kosher"
        case .halal: return "Halal"
        case .glutenFree: return "Gluten-Free"
        case .omnivore: return "Omnivore"
        }
    }
}

// MARK: - Newcomer Goal

enum NewcomerGoal: String, Codable, CaseIterable {
    case findLocalFriends = "find_local_friends"
    case exploreCity = "explore_city"
    case findRoommate = "find_roommate"
    case getLocalTips = "get_local_tips"
    case findExpats = "find_expats"
    case professionalNetworking = "professional_networking"
    case findActivityBuddies = "find_activity_buddies"
    case joinCommunityGroups = "join_community_groups"
    case discoverNeighborhood = "discover_neighborhood"
    case findFoodSpots = "find_food_spots"

    var displayName: String {
        switch self {
        case .findLocalFriends: return "Find Local Friends"
        case .exploreCity: return "Explore the City"
        case .findRoommate: return "Find a Roommate"
        case .getLocalTips: return "Get Local Tips"
        case .findExpats: return "Connect with Expats"
        case .professionalNetworking: return "Professional Networking"
        case .findActivityBuddies: return "Find Activity Buddies"
        case .joinCommunityGroups: return "Join Community Groups"
        case .discoverNeighborhood: return "Discover My Neighborhood"
        case .findFoodSpots: return "Find Food Spots"
        }
    }

    var icon: String {
        switch self {
        case .findLocalFriends: return "person.2.fill"
        case .exploreCity: return "map.fill"
        case .findRoommate: return "house.fill"
        case .getLocalTips: return "lightbulb.fill"
        case .findExpats: return "globe"
        case .professionalNetworking: return "briefcase.fill"
        case .findActivityBuddies: return "figure.run"
        case .joinCommunityGroups: return "person.3.fill"
        case .discoverNeighborhood: return "building.2.fill"
        case .findFoodSpots: return "fork.knife"
        }
    }

    var description: String {
        switch self {
        case .findLocalFriends: return "Meet people who live in your new city"
        case .exploreCity: return "Discover hidden gems and local favorites"
        case .findRoommate: return "Find someone to share housing with"
        case .getLocalTips: return "Learn insider tips from locals"
        case .findExpats: return "Connect with others from your home country"
        case .professionalNetworking: return "Expand your professional network"
        case .findActivityBuddies: return "Find people to do activities with"
        case .joinCommunityGroups: return "Join groups based on interests"
        case .discoverNeighborhood: return "Get to know your neighborhood"
        case .findFoodSpots: return "Discover local restaurants and cafes"
        }
    }
}

// MARK: - Connection Type

enum ConnectionType: String, Codable, CaseIterable {
    case localGuide = "local_guide"
    case fellowNewcomer = "fellow_newcomer"
    case neighborhoodFriend = "neighborhood_friend"
    case activityBuddy = "activity_buddy"
    case foodiePartner = "foodie_partner"
    case explorationBuddy = "exploration_buddy"
    case professionalContact = "professional_contact"
    case roommateSearch = "roommate_search"
    case eventCompanion = "event_companion"

    var displayName: String {
        switch self {
        case .localGuide: return "Local Guide"
        case .fellowNewcomer: return "Fellow Newcomer"
        case .neighborhoodFriend: return "Neighborhood Friend"
        case .activityBuddy: return "Activity Buddy"
        case .foodiePartner: return "Foodie Partner"
        case .explorationBuddy: return "Exploration Buddy"
        case .professionalContact: return "Professional Contact"
        case .roommateSearch: return "Roommate Search"
        case .eventCompanion: return "Event Companion"
        }
    }

    var icon: String {
        switch self {
        case .localGuide: return "mappin.and.ellipse"
        case .fellowNewcomer: return "person.2.wave.2.fill"
        case .neighborhoodFriend: return "house.and.flag.fill"
        case .activityBuddy: return "figure.hiking"
        case .foodiePartner: return "fork.knife.circle.fill"
        case .explorationBuddy: return "binoculars.fill"
        case .professionalContact: return "briefcase.fill"
        case .roommateSearch: return "bed.double.fill"
        case .eventCompanion: return "ticket.fill"
        }
    }

    var description: String {
        switch self {
        case .localGuide: return "Someone who knows the city well"
        case .fellowNewcomer: return "Someone who also recently moved here"
        case .neighborhoodFriend: return "Someone in your area to hang out with"
        case .activityBuddy: return "Someone to do hobbies and sports with"
        case .foodiePartner: return "Someone to try restaurants with"
        case .explorationBuddy: return "Someone to explore the city with"
        case .professionalContact: return "Someone for career networking"
        case .roommateSearch: return "Someone looking for housing together"
        case .eventCompanion: return "Someone to attend events with"
        }
    }
}

// MARK: - Time in City

enum TimeInCity: String, Codable, CaseIterable {
    case justArrived = "just_arrived"
    case lessThan3Months = "less_than_3_months"
    case lessThan1Year = "less_than_1_year"
    case oneToThreeYears = "1_to_3_years"
    case threeYearsPlus = "3_years_plus"
    case local = "local"

    var displayName: String {
        switch self {
        case .justArrived: return "Just Arrived"
        case .lessThan3Months: return "Less than 3 months"
        case .lessThan1Year: return "Less than 1 year"
        case .oneToThreeYears: return "1-3 years"
        case .threeYearsPlus: return "3+ years"
        case .local: return "Local / Born here"
        }
    }

    var icon: String {
        switch self {
        case .justArrived: return "airplane.arrival"
        case .lessThan3Months: return "calendar.badge.clock"
        case .lessThan1Year: return "calendar"
        case .oneToThreeYears: return "calendar.circle"
        case .threeYearsPlus: return "calendar.circle.fill"
        case .local: return "house.fill"
        }
    }

    var badgeText: String {
        switch self {
        case .justArrived: return "New!"
        case .lessThan3Months: return "< 3mo"
        case .lessThan1Year: return "< 1yr"
        case .oneToThreeYears: return "1-3yr"
        case .threeYearsPlus: return "3yr+"
        case .local: return "Local"
        }
    }
}

// MARK: - Relocation Type

enum RelocationType: String, Codable, CaseIterable {
    case work = "work"
    case school = "school"
    case family = "family"
    case adventure = "adventure"
    case retirement = "retirement"
    case remote = "remote"

    var displayName: String {
        switch self {
        case .work: return "Work / Career"
        case .school: return "School / Education"
        case .family: return "Family"
        case .adventure: return "Adventure / New Start"
        case .retirement: return "Retirement"
        case .remote: return "Remote Work / Digital Nomad"
        }
    }

    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .school: return "graduationcap.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .adventure: return "star.fill"
        case .retirement: return "sun.max.fill"
        case .remote: return "laptopcomputer"
        }
    }
}

// MARK: - Zodiac Sign

enum ZodiacSign: String, Codable, CaseIterable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var displayName: String {
        return rawValue.capitalized
    }

    var symbol: String {
        switch self {
        case .aries: return "♈︎"
        case .taurus: return "♉︎"
        case .gemini: return "♊︎"
        case .cancer: return "♋︎"
        case .leo: return "♌︎"
        case .virgo: return "♍︎"
        case .libra: return "♎︎"
        case .scorpio: return "♏︎"
        case .sagittarius: return "♐︎"
        case .capricorn: return "♑︎"
        case .aquarius: return "♒︎"
        case .pisces: return "♓︎"
        }
    }
}

// MARK: - Political View

enum PoliticalView: String, Codable, CaseIterable {
    case liberal = "liberal"
    case moderate = "moderate"
    case conservative = "conservative"
    case notPolitical = "not_political"
    case other = "other"

    var displayName: String {
        switch self {
        case .liberal: return "Liberal"
        case .moderate: return "Moderate"
        case .conservative: return "Conservative"
        case .notPolitical: return "Not Political"
        case .other: return "Other"
        }
    }
}

// MARK: - Filter Preset

struct FilterPreset: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var filter: SearchFilter
    var createdAt: Date
    var lastUsed: Date
    var usageCount: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        filter: SearchFilter,
        createdAt: Date = Date(),
        lastUsed: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.filter = filter
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.usageCount = usageCount
    }
}

// MARK: - Search History Entry

struct SearchHistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let filter: SearchFilter
    let timestamp: Date
    let resultsCount: Int

    init(
        id: String = UUID().uuidString,
        filter: SearchFilter,
        timestamp: Date = Date(),
        resultsCount: Int
    ) {
        self.id = id
        self.filter = filter
        self.timestamp = timestamp
        self.resultsCount = resultsCount
    }
}

// MARK: - CLLocationCoordinate2D Extension

extension CLLocationCoordinate2D: @retroactive Codable, @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }


    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
