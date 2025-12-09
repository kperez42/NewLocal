//
//  PersonalizedOnboardingManager.swift
//  NewLocal
//
//  Manages personalized onboarding paths based on newcomer goals and preferences
//  Adapts the onboarding experience for people relocating to a new city
//

import Foundation
import SwiftUI

/// Manages personalized onboarding experiences based on newcomer goals
@MainActor
class PersonalizedOnboardingManager: ObservableObject {

    static let shared = PersonalizedOnboardingManager()

    @Published var selectedGoal: NewcomerGoal?
    @Published var recommendedPath: OnboardingPath?
    @Published var customizations: [String: Any] = [:]

    private let userDefaultsKey = "selected_onboarding_goal"

    // MARK: - Models

    enum NewcomerGoal: String, Codable, CaseIterable {
        case findLocalFriends = "find_local_friends"
        case exploreCity = "explore_city"
        case findExpats = "find_expats"
        case networking = "professional_networking"
        case settleIn = "settle_in"

        var displayName: String {
            switch self {
            case .findLocalFriends: return "Find local friends"
            case .exploreCity: return "Explore the city"
            case .findExpats: return "Connect with fellow newcomers"
            case .networking: return "Professional networking"
            case .settleIn: return "Get settled in my new home"
            }
        }

        var icon: String {
            switch self {
            case .findLocalFriends: return "person.2.fill"
            case .exploreCity: return "map.fill"
            case .findExpats: return "globe"
            case .networking: return "briefcase.fill"
            case .settleIn: return "house.fill"
            }
        }

        var description: String {
            switch self {
            case .findLocalFriends:
                return "Meet locals who can show you around"
            case .exploreCity:
                return "Discover hidden gems and local favorites"
            case .findExpats:
                return "Connect with others who recently moved here"
            case .networking:
                return "Build your professional network in the city"
            case .settleIn:
                return "Find roommates, tips, and community support"
            }
        }

        var color: Color {
            switch self {
            case .findLocalFriends: return .blue
            case .exploreCity: return .orange
            case .findExpats: return .teal
            case .networking: return .purple
            case .settleIn: return .green
            }
        }
    }

    struct OnboardingPath {
        let goal: NewcomerGoal
        let steps: [OnboardingPathStep]
        let focusAreas: [FocusArea]
        let recommendedFeatures: [String]
        let tutorialPriority: [String] // Tutorial IDs in priority order

        enum FocusArea: String {
            case profileDepth = "profile_depth"
            case photoQuality = "photo_quality"
            case bioOptimization = "bio_optimization"
            case interestMatching = "interest_matching"
            case locationAccuracy = "location_accuracy"
            case verificationTrust = "verification_trust"
            case neighborhoodInfo = "neighborhood_info"
            case relocationDetails = "relocation_details"
        }
    }

    struct OnboardingPathStep {
        let id: String
        let title: String
        let description: String
        let importance: StepImportance
        let tips: [String]

        enum StepImportance {
            case critical
            case recommended
            case optional
        }
    }

    // MARK: - Initialization

    init() {
        loadSavedGoal()
    }

    // MARK: - Goal Selection

    func selectGoal(_ goal: NewcomerGoal) {
        selectedGoal = goal
        recommendedPath = generatePath(for: goal)
        saveGoal()

        // Track analytics
        AnalyticsManager.shared.logEvent(.onboardingStepCompleted, parameters: [
            "step": "goal_selection",
            "goal": goal.rawValue,
            "goal_name": goal.displayName
        ])

        Logger.shared.info("User selected onboarding goal: \(goal.displayName)", category: .onboarding)
    }

    // MARK: - Path Generation

    private func generatePath(for goal: NewcomerGoal) -> OnboardingPath {
        switch goal {
        case .findLocalFriends:
            return createFindLocalFriendsPath()
        case .exploreCity:
            return createExploreCityPath()
        case .findExpats:
            return createFindExpatsPath()
        case .networking:
            return createNetworkingPath()
        case .settleIn:
            return createSettleInPath()
        }
    }

    private func createFindLocalFriendsPath() -> OnboardingPath {
        OnboardingPath(
            goal: .findLocalFriends,
            steps: [
                OnboardingPathStep(
                    id: "friendly_profile",
                    title: "Create Your Local Profile",
                    description: "Show locals who you are and what you're looking for",
                    importance: .critical,
                    tips: [
                        "Share where you moved from and when",
                        "Highlight activities you want to try in the city",
                        "Mention your neighborhood or area"
                    ]
                ),
                OnboardingPathStep(
                    id: "interests_activities",
                    title: "Share Your Interests",
                    description: "Connect with locals who share your hobbies",
                    importance: .critical,
                    tips: [
                        "Select activities you want to explore",
                        "Mention places you want to discover",
                        "Be genuine about your interests"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_profile",
                    title: "Verify Your Profile",
                    description: "Build trust in your new community",
                    importance: .recommended,
                    tips: [
                        "Verified profiles get 2x more connections",
                        "Shows you're authentic",
                        "Takes less than 2 minutes"
                    ]
                )
            ],
            focusAreas: [.interestMatching, .locationAccuracy, .neighborhoodInfo, .bioOptimization],
            recommendedFeatures: ["Ask a Local", "Neighborhood Guide", "Local Events"],
            tutorialPriority: ["welcome", "discovery", "connecting", "messaging", "profile_quality"]
        )
    }

    private func createExploreCityPath() -> OnboardingPath {
        OnboardingPath(
            goal: .exploreCity,
            steps: [
                OnboardingPathStep(
                    id: "explorer_profile",
                    title: "Create Your Explorer Profile",
                    description: "Show what you want to discover in your new city",
                    importance: .critical,
                    tips: [
                        "Add photos that show your adventurous side",
                        "List places and activities you want to try",
                        "Mention your favorite things to explore"
                    ]
                ),
                OnboardingPathStep(
                    id: "exploration_interests",
                    title: "What Do You Want to Explore?",
                    description: "Find people to explore the city with",
                    importance: .critical,
                    tips: [
                        "Select activities like food, nightlife, culture",
                        "Be specific about neighborhoods to explore",
                        "Show your enthusiasm for the city"
                    ]
                )
            ],
            focusAreas: [.interestMatching, .locationAccuracy, .photoQuality],
            recommendedFeatures: ["Explore Together", "Local Tips", "Hidden Gems"],
            tutorialPriority: ["discovery", "connecting", "messaging", "profile_quality"]
        )
    }

    private func createFindExpatsPath() -> OnboardingPath {
        OnboardingPath(
            goal: .findExpats,
            steps: [
                OnboardingPathStep(
                    id: "newcomer_profile",
                    title: "Share Your Story",
                    description: "Connect with others who understand the newcomer experience",
                    importance: .critical,
                    tips: [
                        "Share where you moved from",
                        "Explain why you moved to this city",
                        "Mention how long you've been here"
                    ]
                ),
                OnboardingPathStep(
                    id: "newcomer_challenges",
                    title: "What Are You Looking For?",
                    description: "Find support from fellow newcomers",
                    importance: .critical,
                    tips: [
                        "Share challenges you're facing",
                        "Mention what tips you need",
                        "Connect over shared experiences"
                    ]
                )
            ],
            focusAreas: [.relocationDetails, .bioOptimization, .interestMatching],
            recommendedFeatures: ["Newcomer Events", "Expat Groups", "Moving Tips"],
            tutorialPriority: ["welcome", "discovery", "connecting", "messaging"]
        )
    }

    private func createNetworkingPath() -> OnboardingPath {
        OnboardingPath(
            goal: .networking,
            steps: [
                OnboardingPathStep(
                    id: "professional_profile",
                    title: "Create a Professional Profile",
                    description: "Build your network in your new city",
                    importance: .critical,
                    tips: [
                        "Share your professional background",
                        "Mention your industry and interests",
                        "Keep photos professional yet approachable"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_credentials",
                    title: "Verify Your Profile",
                    description: "Build professional credibility",
                    importance: .recommended,
                    tips: [
                        "Verification builds trust in professional contexts",
                        "Shows you're a serious networker",
                        "Increases connection rate"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .locationAccuracy],
            recommendedFeatures: ["Professional Meetups", "Industry Connections", "Career Events"],
            tutorialPriority: ["profile_quality", "connecting", "messaging"]
        )
    }

    private func createSettleInPath() -> OnboardingPath {
        OnboardingPath(
            goal: .settleIn,
            steps: [
                OnboardingPathStep(
                    id: "settling_profile",
                    title: "Tell Us About Your Move",
                    description: "Get help settling into your new city",
                    importance: .critical,
                    tips: [
                        "Share when you arrived",
                        "Mention what you need help with",
                        "Be specific about your neighborhood"
                    ]
                ),
                OnboardingPathStep(
                    id: "needs_assessment",
                    title: "What Do You Need?",
                    description: "Find people who can help you settle in",
                    importance: .critical,
                    tips: [
                        "Looking for a roommate? Mention it!",
                        "Need local tips? Ask the community",
                        "Want to find services? Connect with locals"
                    ]
                )
            ],
            focusAreas: [.relocationDetails, .neighborhoodInfo, .locationAccuracy],
            recommendedFeatures: ["Roommate Finder", "Local Services", "Neighborhood Guide"],
            tutorialPriority: ["welcome", "discovery", "connecting", "messaging", "profile_quality"]
        )
    }

    // MARK: - Customizations

    func getCustomTips() -> [String] {
        guard let path = recommendedPath else { return [] }
        return path.steps.flatMap { $0.tips }
    }

    func shouldEmphasize(focusArea: OnboardingPath.FocusArea) -> Bool {
        guard let path = recommendedPath else { return false }
        return path.focusAreas.contains(focusArea)
    }

    func getPrioritizedTutorials() -> [String] {
        guard let path = recommendedPath else {
            return ["welcome", "scrolling", "matching", "messaging"]
        }
        return path.tutorialPriority
    }

    func getRecommendedFeatures() -> [String] {
        return recommendedPath?.recommendedFeatures ?? []
    }

    // MARK: - Persistence

    private func saveGoal() {
        if let goal = selectedGoal,
           let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedGoal() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let goal = try? JSONDecoder().decode(NewcomerGoal.self, from: data) {
            selectedGoal = goal
            recommendedPath = generatePath(for: goal)
        }
    }
}

// MARK: - SwiftUI View for Goal Selection

struct OnboardingGoalSelectionView: View {
    @ObservedObject var manager = PersonalizedOnboardingManager.shared
    @Environment(\.dismiss) var dismiss

    let onGoalSelected: (PersonalizedOnboardingManager.NewcomerGoal) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Welcome to Your New City!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("What are you hoping to find here?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Goal Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PersonalizedOnboardingManager.NewcomerGoal.allCases, id: \.self) { goal in
                        GoalCard(goal: goal, isSelected: manager.selectedGoal == goal) {
                            withAnimation(.spring(response: 0.3)) {
                                manager.selectGoal(goal)
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                .padding(24)
            }

            // Continue Button
            if manager.selectedGoal != nil {
                Button {
                    if let goal = manager.selectedGoal {
                        onGoalSelected(goal)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text("Let's Get Started")
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.teal, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .teal.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.teal.opacity(0.05), Color.blue.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct GoalCard: View {
    let goal: PersonalizedOnboardingManager.NewcomerGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(goal.color.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: goal.icon)
                            .font(.title2)
                            .foregroundColor(goal.color)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? goal.color : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? goal.color.opacity(0.2) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingGoalSelectionView { goal in
        print("Selected goal: \(goal.displayName)")
    }
}
