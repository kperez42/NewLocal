//
//  ProfilePrompt.swift
//  NewLocal
//
//  Prompts for relocation community profiles
//

import Foundation

struct ProfilePrompt: Codable, Identifiable, Equatable {
    var id: String
    var question: String
    var answer: String

    init(id: String = UUID().uuidString, question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }

    func toDictionary() -> [String: String] {
        return [
            "id": id,
            "question": question,
            "answer": answer
        ]
    }
}

// MARK: - Available Prompts

struct PromptLibrary {
    static let allPrompts: [String] = [
        // Relocation Story
        "I moved here because...",
        "The biggest surprise about my new city is...",
        "What I miss most from home is...",
        "The best thing about starting fresh is...",
        "My first week here was...",
        "The hardest part of moving was...",
        "I knew this city was right when...",

        // Exploring the City
        "I'm dying to explore...",
        "A hidden gem I've discovered is...",
        "My favorite neighborhood so far is...",
        "I need recommendations for...",
        "My weekend plans usually include...",
        "The local food I'm obsessed with is...",
        "A spot I keep going back to is...",

        // Making Connections
        "I'm looking to meet people who...",
        "The best way to get to know me is...",
        "I can show you around...",
        "Ask me about...",
        "Let's connect if you...",
        "I'm hoping to find friends who...",
        "Together we could explore...",

        // Work & Professional
        "I work in...",
        "My dream project here is...",
        "I'm building connections in...",
        "Career-wise, I'm excited about...",
        "I'd love to meet others in...",

        // Lifestyle & Interests
        "On weekends you'll find me...",
        "My go-to way to unwind is...",
        "I'm currently learning...",
        "A hobby I'm picking up here is...",
        "My ideal Sunday in the city is...",
        "I'm searching for the best...",

        // Local Life
        "As a local, I recommend...",
        "The insider tip I'd give newcomers is...",
        "My favorite thing about living here is...",
        "The neighborhood I know best is...",
        "I've been here for X years and...",
        "What makes this city special is...",

        // Settling In
        "I'm still figuring out...",
        "The biggest adjustment has been...",
        "I finally feel at home when...",
        "My routine here includes...",
        "The community I'm building...",

        // Fun & Personal
        "A random fact about me is...",
        "Something that always makes me happy is...",
        "My comfort food when I'm homesick is...",
        "The language barrier story is...",
        "My expat/transplant advice is...",
        "Before I moved, I never imagined...",

        // Goals & Dreams
        "By the end of this year, I want to...",
        "My bucket list for this city includes...",
        "In 5 years, I hope to...",
        "The experience I'm chasing is...",
        "I'm determined to...",

        // Getting Help
        "I need a local friend who can...",
        "If you know anything about X, let's talk!",
        "Help me find...",
        "I'm on the hunt for..."
    ]

    static let categories: [String: [String]] = [
        "Relocation Story": [
            "I moved here because...",
            "The biggest surprise about my new city is...",
            "What I miss most from home is...",
            "My first week here was..."
        ],
        "Exploring": [
            "I'm dying to explore...",
            "A hidden gem I've discovered is...",
            "My favorite neighborhood so far is...",
            "I need recommendations for..."
        ],
        "Making Connections": [
            "I'm looking to meet people who...",
            "The best way to get to know me is...",
            "I can show you around...",
            "Let's connect if you..."
        ],
        "Local Tips": [
            "As a local, I recommend...",
            "The insider tip I'd give newcomers is...",
            "My favorite thing about living here is...",
            "What makes this city special is..."
        ],
        "Settling In": [
            "I'm still figuring out...",
            "The biggest adjustment has been...",
            "I finally feel at home when...",
            "My routine here includes..."
        ],
        "Goals": [
            "By the end of this year, I want to...",
            "My bucket list for this city includes...",
            "The experience I'm chasing is...",
            "I'm determined to..."
        ]
    ]

    static func randomPrompts(count: Int = 5) -> [String] {
        return Array(allPrompts.shuffled().prefix(count))
    }

    static func suggestedPrompts() -> [String] {
        // Return a curated mix of prompts for new users
        return [
            "I moved here because...",
            "I'm dying to explore...",
            "I'm looking to meet people who...",
            "On weekends you'll find me...",
            "My bucket list for this city includes..."
        ]
    }

    static func promptsForUserType(_ userType: String) -> [String] {
        switch userType {
        case "local":
            return [
                "As a local, I recommend...",
                "The insider tip I'd give newcomers is...",
                "My favorite thing about living here is...",
                "The neighborhood I know best is...",
                "I can show you around..."
            ]
        case "newcomer":
            return [
                "I moved here because...",
                "I'm dying to explore...",
                "I need recommendations for...",
                "The biggest surprise about my new city is...",
                "I'm looking to meet people who..."
            ]
        case "transplant":
            return [
                "I moved here X years ago because...",
                "My favorite thing about living here is...",
                "A hidden gem I've discovered is...",
                "My expat/transplant advice is...",
                "Together we could explore..."
            ]
        default:
            return suggestedPrompts()
        }
    }
}
