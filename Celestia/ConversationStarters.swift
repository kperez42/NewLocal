//
//  ConversationStarters.swift
//  NewLocal
//
//  Service for generating smart conversation starters for newcomers and locals
//

import Foundation

// MARK: - Conversation Starter Model

struct ConversationStarter: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
    let category: StarterCategory

    enum StarterCategory {
        case sharedInterest
        case location
        case relocation
        case neighborhood
        case localTips
        case generic
    }
}

// MARK: - Conversation Starters Service

class ConversationStarters {
    static let shared = ConversationStarters()

    private init() {}

    func generateStarters(currentUser: User, otherUser: User) -> [ConversationStarter] {
        var starters: [ConversationStarter] = []

        // Shared interests - great for finding activity buddies
        let sharedInterests = Set(currentUser.interests).intersection(Set(otherUser.interests))
        if let interest = sharedInterests.first {
            starters.append(ConversationStarter(
                text: "I see you're into \(interest) too! Know any good spots in the city for that?",
                icon: "star.fill",
                category: .sharedInterest
            ))
        }

        // Relocation-based starters
        if let timeInCity = otherUser.timeInCity {
            if timeInCity == "local" || timeInCity == "3_years_plus" {
                starters.append(ConversationStarter(
                    text: "You've been here a while! What's your favorite hidden gem in the city?",
                    icon: "mappin.and.ellipse",
                    category: .localTips
                ))
            } else if timeInCity == "just_arrived" || timeInCity == "less_than_3_months" {
                starters.append(ConversationStarter(
                    text: "How's the move going? What's been the best discovery so far?",
                    icon: "box.truck.fill",
                    category: .relocation
                ))
            }
        }

        // If they moved from same place
        if let currentMovedFrom = currentUser.movedFrom,
           let otherMovedFrom = otherUser.movedFrom,
           currentMovedFrom.lowercased() == otherMovedFrom.lowercased() {
            starters.append(ConversationStarter(
                text: "No way, you're from \(currentMovedFrom) too! What brought you here?",
                icon: "airplane.arrival",
                category: .relocation
            ))
        }

        // Same neighborhood
        if let currentNeighborhood = currentUser.neighborhood,
           let otherNeighborhood = otherUser.neighborhood,
           !currentNeighborhood.isEmpty && currentNeighborhood == otherNeighborhood {
            starters.append(ConversationStarter(
                text: "Hey neighbor! Know any good coffee spots or hangouts in \(currentNeighborhood)?",
                icon: "house.fill",
                category: .neighborhood
            ))
        }

        // Location-based
        if !otherUser.location.isEmpty {
            starters.append(ConversationStarter(
                text: "What's been your favorite thing about \(otherUser.location) so far?",
                icon: "mappin.circle.fill",
                category: .location
            ))
        }

        // Bio-based starters for newcomers
        if !otherUser.bio.isEmpty {
            if otherUser.bio.lowercased().contains("explore") || otherUser.bio.lowercased().contains("adventure") {
                starters.append(ConversationStarter(
                    text: "Love your explorer spirit! What's next on your list to check out?",
                    icon: "binoculars.fill",
                    category: .generic
                ))
            } else if otherUser.bio.lowercased().contains("food") || otherUser.bio.lowercased().contains("coffee") || otherUser.bio.lowercased().contains("restaurant") {
                starters.append(ConversationStarter(
                    text: "Fellow foodie here! What's the best meal you've had in the city?",
                    icon: "fork.knife",
                    category: .generic
                ))
            } else if otherUser.bio.lowercased().contains("hiking") || otherUser.bio.lowercased().contains("outdoor") {
                starters.append(ConversationStarter(
                    text: "Always looking for outdoor buddies! Found any good trails nearby?",
                    icon: "figure.hiking",
                    category: .generic
                ))
            }
        }

        // Community-focused generic starters
        let genericStarters = [
            ConversationStarter(
                text: "What made you decide to move here?",
                icon: "arrow.right.circle.fill",
                category: .generic
            ),
            ConversationStarter(
                text: "What's one thing you wish you knew before moving here?",
                icon: "lightbulb.fill",
                category: .generic
            ),
            ConversationStarter(
                text: "Looking for any recommendations - coffee shops, gyms, restaurants?",
                icon: "magnifyingglass",
                category: .generic
            ),
            ConversationStarter(
                text: "What's been the biggest adjustment since moving?",
                icon: "arrow.triangle.2.circlepath",
                category: .generic
            ),
            ConversationStarter(
                text: "Found any good spots to meet people in the city?",
                icon: "person.2.fill",
                category: .generic
            ),
            ConversationStarter(
                text: "What neighborhood are you in? I'm still learning the city!",
                icon: "map.fill",
                category: .generic
            )
        ]

        // Add generic starters to fill up to 5 total
        let remainingCount = max(0, 5 - starters.count)
        starters.append(contentsOf: genericStarters.shuffled().prefix(remainingCount))

        return Array(starters.prefix(5))
    }
}
