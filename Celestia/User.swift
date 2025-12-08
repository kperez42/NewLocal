//
//  User.swift
//  NewLocal
//
//  Core user model for relocation community app
//
//  PROFILE STATUS FLOW:
//  --------------------
//  profileStatus controls user visibility and app access:
//
//  1. "pending"   - New account awaiting admin approval (SignUpView.swift)
//                   User sees: PendingApprovalView
//                   Hidden from: Other users in Discover, Likes, Search
//
//  2. "active"    - Approved and visible to others
//                   User sees: MainTabView (full app access)
//                   Set by: AdminModerationDashboard.approveProfile()
//
//  3. "rejected"  - Rejected, user must fix issues
//                   User sees: ProfileRejectionFeedbackView
//                   Set by: AdminModerationDashboard.rejectProfile()
//                   Properties: profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions
//
//  4. "flagged"   - Under extended moderator review
//                   User sees: FlaggedAccountView
//                   Set by: AdminModerationDashboard.flagProfile()
//                   Hidden from: Other users during review
//
//  5. "suspended" - Temporarily blocked (with end date)
//                   User sees: SuspendedAccountView
//                   Properties: isSuspended, suspendedAt, suspendedUntil, suspendReason
//
//  6. "banned"    - Permanently blocked
//                   User sees: BannedAccountView
//                   Properties: isBanned, bannedAt, banReason
//
//  Routing handled by: ContentView.swift (updateAuthenticationState)
//  Filtering handled by: UserService.swift, LikesView, SavedProfilesView, etc.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    // Manual ID for test data (bypasses @DocumentID restrictions)
    // This is used when creating test users in DEBUG mode
    private var _manualId: String?

    // Computed property that returns manual ID if set, otherwise @DocumentID value
    var effectiveId: String? {
        _manualId ?? id
    }

    // Equatable implementation - compare by id
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.effectiveId == rhs.effectiveId
    }
    
    // Basic Info
    var email: String
    var fullName: String
    var age: Int
    var gender: String
    var bio: String

    // Current Location
    var location: String  // Current city
    var country: String
    var neighborhood: String = ""
    var latitude: Double?
    var longitude: Double?

    // Relocation Info
    var userType: String = "newcomer"  // "local", "newcomer", "transplant"
    var movedFrom: String = ""  // Previous city
    var movedFromCountry: String = ""
    var movedToDate: Date?  // When they moved to current city
    var timeInCity: String = ""  // How long they've been in the city (maps to TimeInCity enum)
    var relocationType: String = ""  // Why they moved (maps to RelocationType enum)
    var whyMoved: String = ""  // Detailed reason for relocation
    var profession: String = ""
    var company: String = ""
    var whatToExplore: [String] = []  // Things they want to discover in their new city
    var localTips: [String] = []  // Tips they can share (for established residents)
    var bestLocalFind: String = ""  // Their favorite discovery in the city
    var connectionTypes: [String] = []  // Types of connections they're looking for
    var newcomerGoals: [String] = []  // Their goals as a newcomer
    
    // Profile Details
    var languages: [String]
    var interests: [String]
    var photos: [String]
    var profileImageURL: String
    
    // Timestamps
    var timestamp: Date
    var lastActive: Date
    var isOnline: Bool = false
    
    // Premium & Verification
    var isPremium: Bool
    var isVerified: Bool = false
    var premiumTier: String?
    var subscriptionExpiryDate: Date?

    // ID Verification Rejection (when ID verification is rejected)
    var idVerificationRejected: Bool = false
    var idVerificationRejectedAt: Date?
    var idVerificationRejectionReason: String?

    // Admin Access (for moderation dashboard)
    var isAdmin: Bool = false

    // Profile Status (for content moderation quarantine)
    // "pending" = new account, not shown in Discover until approved by admin
    // "active" = approved, visible to other users
    // "rejected" = rejected, user must fix issues
    // "suspended" = temporarily or permanently blocked
    // "flagged" = under review by moderators
    var profileStatus: String = "pending"
    var profileStatusReason: String?           // User-friendly message
    var profileStatusReasonCode: String?       // Machine-readable code (e.g., "no_face_photo")
    var profileStatusFixInstructions: String?  // Detailed fix instructions for user
    var profileStatusUpdatedAt: Date?

    // Suspension Info (set by admin when suspending user)
    var isSuspended: Bool = false
    var suspendedAt: Date?
    var suspendedUntil: Date?
    var suspendReason: String?

    // Ban Info (permanent ban set by admin)
    var isBanned: Bool = false
    var bannedAt: Date?
    var banReason: String?

    // Warnings (accumulated from reports)
    var warningCount: Int = 0
    var hasUnreadWarning: Bool = false         // Show warning notice to user
    var lastWarningReason: String?             // Most recent warning reason
    
    // Preferences
    var ageRangeMin: Int
    var ageRangeMax: Int
    var maxDistance: Int
    var showMeInSearch: Bool = true
    
    // Stats
    var connectionsSent: Int = 0
    var connectionsReceived: Int = 0
    var connectionCount: Int = 0
    var profileViews: Int = 0

    // Daily Limits (Free Users)
    var connectionsRemainingToday: Int = 20  // Free users get 20 connections/day
    var lastConnectionResetDate: Date = Date()

    // Notifications
    var fcmToken: String?
    var notificationsEnabled: Bool = true

    // Advanced Profile Fields
    var educationLevel: String?
    var pets: String?
    var hobbies: [String] = []
    var lookingToConnect: [String] = []  // "make friends", "find local guides", "professional networking", "explore together"

    // Profile Prompts
    var prompts: [ProfilePrompt] = []

    // Referral System
    var referralStats: ReferralStats = ReferralStats()
    var referredByCode: String?  // Code used during signup

    // PERFORMANCE: Lowercase fields for efficient Firestore prefix matching
    // These should be updated whenever fullName/country changes
    // See: UserService.searchUsers() for usage
    var fullNameLowercase: String = ""
    var countryLowercase: String = ""
    var locationLowercase: String = ""

    // Helper computed property for backward compatibility
    var name: String {
        get { fullName }
        set { fullName = newValue }
    }

    // Update lowercase fields when main fields change
    mutating func updateSearchFields() {
        fullNameLowercase = fullName.lowercased()
        countryLowercase = country.lowercased()
        locationLowercase = location.lowercased()
    }

    // Custom encoding to handle nil values properly for Firebase
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(age, forKey: .age)
        try container.encode(gender, forKey: .gender)
        try container.encode(bio, forKey: .bio)
        try container.encode(location, forKey: .location)
        try container.encode(country, forKey: .country)
        try container.encode(neighborhood, forKey: .neighborhood)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)

        // Relocation Info
        try container.encode(userType, forKey: .userType)
        try container.encode(movedFrom, forKey: .movedFrom)
        try container.encode(movedFromCountry, forKey: .movedFromCountry)
        try container.encodeIfPresent(movedToDate, forKey: .movedToDate)
        try container.encode(timeInCity, forKey: .timeInCity)
        try container.encode(relocationType, forKey: .relocationType)
        try container.encode(whyMoved, forKey: .whyMoved)
        try container.encode(profession, forKey: .profession)
        try container.encode(company, forKey: .company)
        try container.encode(whatToExplore, forKey: .whatToExplore)
        try container.encode(localTips, forKey: .localTips)
        try container.encode(bestLocalFind, forKey: .bestLocalFind)
        try container.encode(connectionTypes, forKey: .connectionTypes)
        try container.encode(newcomerGoals, forKey: .newcomerGoals)

        try container.encode(languages, forKey: .languages)
        try container.encode(interests, forKey: .interests)
        try container.encode(photos, forKey: .photos)
        try container.encode(profileImageURL, forKey: .profileImageURL)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(lastActive, forKey: .lastActive)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(isAdmin, forKey: .isAdmin)
        try container.encodeIfPresent(premiumTier, forKey: .premiumTier)
        try container.encodeIfPresent(subscriptionExpiryDate, forKey: .subscriptionExpiryDate)
        try container.encode(idVerificationRejected, forKey: .idVerificationRejected)
        try container.encodeIfPresent(idVerificationRejectedAt, forKey: .idVerificationRejectedAt)
        try container.encodeIfPresent(idVerificationRejectionReason, forKey: .idVerificationRejectionReason)
        try container.encode(profileStatus, forKey: .profileStatus)
        try container.encodeIfPresent(profileStatusReason, forKey: .profileStatusReason)
        try container.encodeIfPresent(profileStatusReasonCode, forKey: .profileStatusReasonCode)
        try container.encodeIfPresent(profileStatusFixInstructions, forKey: .profileStatusFixInstructions)
        try container.encodeIfPresent(profileStatusUpdatedAt, forKey: .profileStatusUpdatedAt)
        try container.encode(isSuspended, forKey: .isSuspended)
        try container.encodeIfPresent(suspendedAt, forKey: .suspendedAt)
        try container.encodeIfPresent(suspendedUntil, forKey: .suspendedUntil)
        try container.encodeIfPresent(suspendReason, forKey: .suspendReason)
        try container.encode(isBanned, forKey: .isBanned)
        try container.encodeIfPresent(bannedAt, forKey: .bannedAt)
        try container.encodeIfPresent(banReason, forKey: .banReason)
        try container.encode(warningCount, forKey: .warningCount)
        try container.encode(hasUnreadWarning, forKey: .hasUnreadWarning)
        try container.encodeIfPresent(lastWarningReason, forKey: .lastWarningReason)
        try container.encode(ageRangeMin, forKey: .ageRangeMin)
        try container.encode(ageRangeMax, forKey: .ageRangeMax)
        try container.encode(maxDistance, forKey: .maxDistance)
        try container.encode(showMeInSearch, forKey: .showMeInSearch)
        try container.encode(connectionsSent, forKey: .connectionsSent)
        try container.encode(connectionsReceived, forKey: .connectionsReceived)
        try container.encode(connectionCount, forKey: .connectionCount)
        try container.encode(profileViews, forKey: .profileViews)
        try container.encodeIfPresent(fcmToken, forKey: .fcmToken)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encodeIfPresent(educationLevel, forKey: .educationLevel)
        try container.encodeIfPresent(pets, forKey: .pets)
        try container.encode(hobbies, forKey: .hobbies)
        try container.encode(lookingToConnect, forKey: .lookingToConnect)
        try container.encode(prompts, forKey: .prompts)
        try container.encode(referralStats, forKey: .referralStats)
        try container.encodeIfPresent(referredByCode, forKey: .referredByCode)

        // Encode lowercase search fields
        try container.encode(fullNameLowercase, forKey: .fullNameLowercase)
        try container.encode(countryLowercase, forKey: .countryLowercase)
        try container.encode(locationLowercase, forKey: .locationLowercase)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email, fullName, age, gender, bio
        case location, country, neighborhood, latitude, longitude
        case userType, movedFrom, movedFromCountry, movedToDate
        case timeInCity, relocationType
        case whyMoved, profession, company, whatToExplore
        case localTips, bestLocalFind, connectionTypes, newcomerGoals
        case languages, interests, photos, profileImageURL
        case timestamp, lastActive, isOnline
        case isPremium, isVerified, isAdmin, premiumTier, subscriptionExpiryDate
        case idVerificationRejected, idVerificationRejectedAt, idVerificationRejectionReason
        case profileStatus, profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions, profileStatusUpdatedAt
        case isSuspended, suspendedAt, suspendedUntil, suspendReason
        case isBanned, bannedAt, banReason
        case warningCount, hasUnreadWarning, lastWarningReason
        case ageRangeMin, ageRangeMax, maxDistance, showMeInSearch
        case connectionsSent, connectionsReceived, connectionCount, profileViews
        case fcmToken, notificationsEnabled
        case educationLevel, pets, hobbies, lookingToConnect
        case prompts
        case referralStats, referredByCode
        // Performance: Lowercase search fields
        case fullNameLowercase, countryLowercase, locationLowercase
    }
    
    // Initialize from dictionary (for legacy code)
    init(dictionary: [String: Any]) {
        let dictId = dictionary["id"] as? String
        self.id = dictId
        self._manualId = dictId  // Also set manual ID for effectiveId to work
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? dictionary["name"] as? String ?? ""
        self.age = dictionary["age"] as? Int ?? 18
        self.gender = dictionary["gender"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        self.neighborhood = dictionary["neighborhood"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double

        // Relocation Info
        self.userType = dictionary["userType"] as? String ?? "newcomer"
        self.movedFrom = dictionary["movedFrom"] as? String ?? ""
        self.movedFromCountry = dictionary["movedFromCountry"] as? String ?? ""
        if let movedToDateTs = dictionary["movedToDate"] as? Timestamp {
            self.movedToDate = movedToDateTs.dateValue()
        }
        self.timeInCity = dictionary["timeInCity"] as? String ?? ""
        self.relocationType = dictionary["relocationType"] as? String ?? ""
        self.whyMoved = dictionary["whyMoved"] as? String ?? ""
        self.profession = dictionary["profession"] as? String ?? ""
        self.company = dictionary["company"] as? String ?? ""
        self.whatToExplore = dictionary["whatToExplore"] as? [String] ?? []
        self.localTips = dictionary["localTips"] as? [String] ?? []
        self.bestLocalFind = dictionary["bestLocalFind"] as? String ?? ""
        self.connectionTypes = dictionary["connectionTypes"] as? [String] ?? []
        self.newcomerGoals = dictionary["newcomerGoals"] as? [String] ?? []

        self.languages = dictionary["languages"] as? [String] ?? []
        self.interests = dictionary["interests"] as? [String] ?? []
        self.photos = dictionary["photos"] as? [String] ?? []
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""

        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }

        if let lastActive = dictionary["lastActive"] as? Timestamp {
            self.lastActive = lastActive.dateValue()
        } else {
            self.lastActive = Date()
        }

        self.isOnline = dictionary["isOnline"] as? Bool ?? false
        self.isPremium = dictionary["isPremium"] as? Bool ?? false
        self.isVerified = dictionary["isVerified"] as? Bool ?? false
        self.isAdmin = dictionary["isAdmin"] as? Bool ?? false
        self.premiumTier = dictionary["premiumTier"] as? String

        if let expiryDate = dictionary["subscriptionExpiryDate"] as? Timestamp {
            self.subscriptionExpiryDate = expiryDate.dateValue()
        }

        // ID Verification rejection info
        self.idVerificationRejected = dictionary["idVerificationRejected"] as? Bool ?? false
        if let rejectedAt = dictionary["idVerificationRejectedAt"] as? Timestamp {
            self.idVerificationRejectedAt = rejectedAt.dateValue()
        }
        self.idVerificationRejectionReason = dictionary["idVerificationRejectionReason"] as? String

        // Profile Status (for moderation quarantine)
        self.profileStatus = dictionary["profileStatus"] as? String ?? "pending"
        self.profileStatusReason = dictionary["profileStatusReason"] as? String
        self.profileStatusReasonCode = dictionary["profileStatusReasonCode"] as? String
        self.profileStatusFixInstructions = dictionary["profileStatusFixInstructions"] as? String
        if let statusUpdatedAt = dictionary["profileStatusUpdatedAt"] as? Timestamp {
            self.profileStatusUpdatedAt = statusUpdatedAt.dateValue()
        }

        // Suspension info
        self.isSuspended = dictionary["isSuspended"] as? Bool ?? false
        if let suspendedAtTs = dictionary["suspendedAt"] as? Timestamp {
            self.suspendedAt = suspendedAtTs.dateValue()
        }
        if let suspendedUntilTs = dictionary["suspendedUntil"] as? Timestamp {
            self.suspendedUntil = suspendedUntilTs.dateValue()
        }
        self.suspendReason = dictionary["suspendReason"] as? String

        self.isBanned = dictionary["isBanned"] as? Bool ?? false
        if let bannedAtTs = dictionary["bannedAt"] as? Timestamp {
            self.bannedAt = bannedAtTs.dateValue()
        }
        self.banReason = dictionary["banReason"] as? String

        // Warnings
        self.warningCount = dictionary["warningCount"] as? Int ?? 0
        self.hasUnreadWarning = dictionary["hasUnreadWarning"] as? Bool ?? false
        self.lastWarningReason = dictionary["lastWarningReason"] as? String

        self.ageRangeMin = dictionary["ageRangeMin"] as? Int ?? 18
        self.ageRangeMax = dictionary["ageRangeMax"] as? Int ?? 99
        self.maxDistance = dictionary["maxDistance"] as? Int ?? 100
        self.showMeInSearch = dictionary["showMeInSearch"] as? Bool ?? true

        self.connectionsSent = dictionary["connectionsSent"] as? Int ?? 0
        self.connectionsReceived = dictionary["connectionsReceived"] as? Int ?? 0
        self.connectionCount = dictionary["connectionCount"] as? Int ?? 0
        self.profileViews = dictionary["profileViews"] as? Int ?? 0

        self.fcmToken = dictionary["fcmToken"] as? String
        self.notificationsEnabled = dictionary["notificationsEnabled"] as? Bool ?? true

        // Advanced Profile Fields
        self.educationLevel = dictionary["educationLevel"] as? String
        self.pets = dictionary["pets"] as? String
        self.hobbies = dictionary["hobbies"] as? [String] ?? []
        self.lookingToConnect = dictionary["lookingToConnect"] as? [String] ?? []

        // Profile Prompts
        if let promptsData = dictionary["prompts"] as? [[String: Any]] {
            self.prompts = promptsData.compactMap { promptDict in
                guard let question = promptDict["question"] as? String,
                      let answer = promptDict["answer"] as? String else {
                    return nil
                }
                let id = promptDict["id"] as? String ?? UUID().uuidString
                return ProfilePrompt(id: id, question: question, answer: answer)
            }
        } else {
            self.prompts = []
        }

        // Referral System
        if let referralStatsDict = dictionary["referralStats"] as? [String: Any] {
            self.referralStats = ReferralStats(dictionary: referralStatsDict)
        } else {
            self.referralStats = ReferralStats()
        }
        self.referredByCode = dictionary["referredByCode"] as? String

        // Initialize lowercase search fields (for backward compatibility with old data)
        self.fullNameLowercase = (dictionary["fullNameLowercase"] as? String) ?? fullName.lowercased()
        self.countryLowercase = (dictionary["countryLowercase"] as? String) ?? country.lowercased()
        self.locationLowercase = (dictionary["locationLowercase"] as? String) ?? location.lowercased()
    }
    
    // Standard initializer
    init(
        id: String? = nil,
        email: String,
        fullName: String,
        age: Int,
        gender: String,
        bio: String = "",
        location: String,
        country: String,
        neighborhood: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        userType: String = "newcomer",
        movedFrom: String = "",
        movedFromCountry: String = "",
        movedToDate: Date? = nil,
        timeInCity: String = "",
        relocationType: String = "",
        whyMoved: String = "",
        profession: String = "",
        company: String = "",
        whatToExplore: [String] = [],
        localTips: [String] = [],
        bestLocalFind: String = "",
        connectionTypes: [String] = [],
        newcomerGoals: [String] = [],
        languages: [String] = [],
        interests: [String] = [],
        photos: [String] = [],
        profileImageURL: String = "",
        timestamp: Date = Date(),
        isPremium: Bool = false,
        isVerified: Bool = false,
        lastActive: Date = Date(),
        ageRangeMin: Int = 18,
        ageRangeMax: Int = 99,
        maxDistance: Int = 100
    ) {
        self.id = id
        self._manualId = id  // Store manual ID for test users
        self.email = email
        self.fullName = fullName
        self.age = age
        self.gender = gender
        self.bio = bio
        self.location = location
        self.country = country
        self.neighborhood = neighborhood
        self.latitude = latitude
        self.longitude = longitude
        self.userType = userType
        self.movedFrom = movedFrom
        self.movedFromCountry = movedFromCountry
        self.movedToDate = movedToDate
        self.timeInCity = timeInCity
        self.relocationType = relocationType
        self.whyMoved = whyMoved
        self.profession = profession
        self.company = company
        self.whatToExplore = whatToExplore
        self.localTips = localTips
        self.bestLocalFind = bestLocalFind
        self.connectionTypes = connectionTypes
        self.newcomerGoals = newcomerGoals
        self.languages = languages
        self.interests = interests
        self.photos = photos
        self.profileImageURL = profileImageURL
        self.timestamp = timestamp
        self.isPremium = isPremium
        self.isVerified = isVerified
        self.lastActive = lastActive
        self.ageRangeMin = ageRangeMin
        self.ageRangeMax = ageRangeMax
        self.maxDistance = maxDistance

        // Initialize lowercase search fields
        self.fullNameLowercase = fullName.lowercased()
        self.countryLowercase = country.lowercased()
        self.locationLowercase = location.lowercased()
    }
}

// MARK: - User Factory Methods

extension User {
    /// Factory method to create a minimal User object for notifications
    /// Validates required fields before creating
    static func createMinimal(
        id: String,
        fullName: String,
        from data: [String: Any]
    ) throws -> User {
        // Validate required fields
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        guard let age = data["age"] as? Int, age >= AppConstants.Limits.minAge, age <= AppConstants.Limits.maxAge else {
            throw UserCreationError.invalidField("age", "Must be between \(AppConstants.Limits.minAge) and \(AppConstants.Limits.maxAge)")
        }

        guard let gender = data["gender"] as? String, !gender.isEmpty else {
            throw UserCreationError.missingRequiredField("gender")
        }

        // Create with validated data and safe defaults
        return User(
            id: id,
            email: email,
            fullName: fullName,
            age: age,
            gender: gender,
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }

    /// Factory method to create User from Firestore data with validation
    static func fromFirestore(id: String, data: [String: Any]) throws -> User {
        // Validate all required fields
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        guard let fullName = data["fullName"] as? String, !fullName.isEmpty else {
            throw UserCreationError.missingRequiredField("fullName")
        }

        guard let age = data["age"] as? Int, age >= AppConstants.Limits.minAge, age <= AppConstants.Limits.maxAge else {
            throw UserCreationError.invalidField("age", "Must be between \(AppConstants.Limits.minAge) and \(AppConstants.Limits.maxAge)")
        }

        guard let gender = data["gender"] as? String, !gender.isEmpty else {
            throw UserCreationError.missingRequiredField("gender")
        }

        // Create with validated data
        return User(
            id: id,
            email: email,
            fullName: fullName,
            age: age,
            gender: gender,
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }
}

// MARK: - User Creation Errors

enum UserCreationError: LocalizedError {
    case missingRequiredField(String)
    case invalidField(String, String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidField(let field, let reason):
            return "Invalid field '\(field)': \(reason)"
        }
    }
}
