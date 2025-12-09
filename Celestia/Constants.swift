//
//  Constants.swift
//  NewLocal
//
//  Centralized constants for the relocation community app
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - App Identity
    static let appName = "NewLocal"
    static let appTagline = "Your community in a new city"
    static let appDescription = "Connect with locals who can show you around and other newcomers who share your journey"

    // MARK: - API Configuration
    enum API {
        static let baseURL = "https://api.newlocal.app"
        static let timeout: TimeInterval = 30
        static let retryAttempts = 3
    }
    
    // MARK: - Content Limits
    enum Limits {
        static let maxBioLength = 500
        static let maxMessageLength = 1000
        static let maxInterestMessage = 300
        static let maxInterests = 10
        static let maxLanguages = 5
        static let maxPhotos = 6
        static let minAge = 18
        static let maxAge = 99
        static let minPasswordLength = 8
        static let maxNameLength = 50
    }
    
    // MARK: - Pagination
    enum Pagination {
        static let usersPerPage = 20
        static let messagesPerPage = 50
        static let matchesPerPage = 30
        static let interestsPerPage = 20
    }
    
    // MARK: - Premium Pricing
    enum Premium {
        static let monthlyPrice = 7.99
        static let sixMonthPrice = 39.99
        static let yearlyPrice = 59.99

        // Features - Community focused
        static let freeConnectionsPerDay = 10  // Free users get 10 connections/day
        static let premiumUnlimitedConnections = true
        static let premiumSeeWhoViewed = true
        static let premiumAdvancedFilters = true
        static let premiumPriorityMatching = true  // Get matched with locals faster
        static let premiumNeighborhoodInsights = true  // Detailed neighborhood guides
        static let premiumEventAccess = true  // Priority access to NewLocal meetups
    }
    
    // MARK: - Colors
    enum Colors {
        static let primary = Color.purple
        static let secondary = Color.blue
        static let accent = Color.pink
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        
        static let gradientStart = Color.purple
        static let gradientEnd = Color.blue
        
        static func primaryGradient() -> LinearGradient {
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func accentGradient() -> LinearGradient {
            LinearGradient(
                colors: [Color.purple, Color.pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // MARK: - Animation Durations
    enum Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let splash: TimeInterval = 2.0
    }
    
    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 10
        static let largeCornerRadius: CGFloat = 20
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
    }
    
    // MARK: - Image Sizes
    enum ImageSize {
        static let thumbnail: CGFloat = 50
        static let small: CGFloat = 70
        static let medium: CGFloat = 100
        static let large: CGFloat = 150
        static let profile: CGFloat = 130
        static let hero: CGFloat = 400
    }
    
    // MARK: - Feature Flags
    // Note: These flags control local features. Remote feature flags in FeatureFlagManager take precedence.
    enum Features {
        static let voiceMessagesEnabled = false  // Not implemented yet
        static let videoCallsEnabled = false  // Not implemented yet
        static let storiesEnabled = false  // Not implemented yet
        static let groupChatsEnabled = false  // Not implemented yet
        static let gifSupportEnabled = false  // Not implemented yet - requires Giphy SDK
        static let stickersEnabled = false  // Not implemented yet
        static let locationTrackingEnabled = true
    }
    
    // MARK: - Firebase Collections
    enum Collections {
        static let users = "users"
        static let matches = "matches"
        static let messages = "messages"
        static let interests = "interests"
        static let reports = "reports"
        static let blockedUsers = "blocked_users"
        static let analytics = "analytics"
    }
    
    // MARK: - Storage Paths
    enum StoragePaths {
        static let profileImages = "profile_images"
        static let chatImages = "chat_images"
        static let userPhotos = "user_photos"
        static let voiceMessages = "voice_messages"
        static let videoMessages = "video_messages"
    }
    
    // MARK: - Rate Limiting
    // PRODUCTION: These limits apply to free users only
    // Premium users bypass these limits entirely (check in RateLimiter)
    enum RateLimit {
        static let messageInterval: TimeInterval = 0.5
        static let connectionInterval: TimeInterval = 1.0
        static let searchInterval: TimeInterval = 0.3
        static let maxMessagesPerMinute = 30
        static let maxConnectionsPerDay = 20 // Free users get 20 connections per day, premium unlimited
        static let maxDailyMessagesForFreeUsers = 20 // Free users get 20 messages per day total, premium unlimited
    }
    
    // MARK: - Cache
    enum Cache {
        static let maxImageCacheSize = 100
        static let imageCacheDuration: TimeInterval = 3600 // 1 hour
        static let userDataCacheDuration: TimeInterval = 300 // 5 minutes
    }
    
    // MARK: - Notifications
    enum Notifications {
        static let newConnectionTitle = "New Connection!"
        static let newMessageTitle = "New Message"
        static let newInterestTitle = "Someone wants to connect!"
        static let localGuideTitle = "A local wants to help!"
        static let newcomerConnectionTitle = "Meet a fellow newcomer!"
    }

    // MARK: - User Types
    enum UserTypes {
        static let local = "local"
        static let newcomer = "newcomer"
        static let transplant = "transplant"

        static let localDescription = "I've lived here for years and love showing people around"
        static let newcomerDescription = "I just moved here and want to explore my new city"
        static let transplantDescription = "I moved here a while ago and know my way around"
    }

    // MARK: - Connection Types
    enum ConnectionTypes {
        static let findLocalGuide = "Find local guides"
        static let meetNewcomers = "Meet other newcomers"
        static let professionalNetwork = "Professional networking"
        static let exploreTogether = "Explore together"
        static let makeFriends = "Make friends"
        static let neighborhoodTips = "Get neighborhood tips"
    }

    // MARK: - Why Moved Options
    enum WhyMovedOptions {
        static let work = "Work/Career"
        static let family = "Family"
        static let education = "Education"
        static let adventure = "Adventure"
        static let lifestyle = "Lifestyle change"
        static let partner = "Following partner"
        static let retirement = "Retirement"
        static let other = "Other"

        static let allOptions = [work, family, education, adventure, lifestyle, partner, retirement, other]
    }

    // MARK: - Explore Categories
    enum ExploreCategories {
        static let restaurants = "Best restaurants"
        static let nightlife = "Nightlife & bars"
        static let outdoors = "Outdoor activities"
        static let fitness = "Gyms & fitness"
        static let arts = "Arts & culture"
        static let shopping = "Shopping spots"
        static let cafes = "Coffee shops"
        static let events = "Local events"
        static let sports = "Sports & recreation"
        static let neighborhoods = "Neighborhoods"
        static let publicTransit = "Public transit tips"
        static let hiddenGems = "Hidden gems"

        static let allCategories = [restaurants, nightlife, outdoors, fitness, arts, shopping, cafes, events, sports, neighborhoods, publicTransit, hiddenGems]
    }
    
    // MARK: - Analytics Events
    enum AnalyticsEvents {
        static let appLaunched = "app_launched"
        static let userSignedUp = "user_signed_up"
        static let userSignedIn = "user_signed_in"
        static let profileViewed = "profile_viewed"
        static let connectionCreated = "connection_created"
        static let messageSent = "message_sent"
        static let connectionRequestSent = "connection_request_sent"
        static let profileSaved = "profile_saved"
        static let profilePassed = "profile_passed"
        static let profileEdited = "profile_edited"
        static let premiumViewed = "premium_viewed"
        static let premiumPurchased = "premium_purchased"
        // NewLocal specific events
        static let localGuideConnected = "local_guide_connected"
        static let newcomerMet = "newcomer_met"
        static let neighborhoodExplored = "neighborhood_explored"
        static let cityTipShared = "city_tip_shared"
    }
    
    // MARK: - Error Messages
    enum ErrorMessages {
        static let networkError = "Please check your internet connection and try again."
        static let genericError = "Something went wrong. Please try again."
        static let authError = "Authentication failed. Please try again."
        static let invalidEmail = "Please enter a valid email address."
        static let weakPassword = "Password must be at least 8 characters with numbers and letters."
        static let passwordMismatch = "Passwords do not match."
        static let accountNotFound = "No account found with this email."
        static let emailInUse = "This email is already registered."
        static let invalidAge = "You must be at least 18 years old."
        static let bioTooLong = "Bio must be less than 500 characters."
        static let messageTooLong = "Message must be less than 1000 characters."
    }
    
    // MARK: - URLs
    enum URLs {
        static let privacyPolicy = "https://newlocal.app/privacy"
        static let termsOfService = "https://newlocal.app/terms"
        static let support = "mailto:support@newlocal.app"
        static let website = "https://newlocal.app"
        static let instagramURL = "https://instagram.com/newlocal"
        static let twitterURL = "https://twitter.com/newlocal"
    }
    
    // MARK: - Debug
    enum Debug {
        #if DEBUG
        static let loggingEnabled = true
        static let showDebugInfo = true
        #else
        static let loggingEnabled = false
        static let showDebugInfo = false
        #endif
    }
}

// MARK: - Convenience Extensions

extension AppConstants {
    static func log(_ message: String, category: String = "General") {
        if Debug.loggingEnabled {
            print("[\(category)] \(message)")
        }
    }
    
    static func logError(_ error: Error, context: String = "") {
        if Debug.loggingEnabled {
            print("❌ [\(context)] Error: \(error.localizedDescription)")
        }
    }
}
