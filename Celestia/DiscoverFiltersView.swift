//
//  DiscoverFiltersView.swift
//  NewLocal
//
//  Filter settings for discovering locals and newcomers in your community
//

import SwiftUI

struct DiscoverFiltersView: View {
    @ObservedObject var filters = DiscoveryFilters.shared
    @Environment(\.dismiss) var dismiss

    // Section expansion state
    @State private var expandedSections: Set<FilterSection> = [.userType, .interests]

    enum FilterSection: String, CaseIterable {
        case userType = "Who to Meet"
        case location = "Location & Neighborhood"
        case interests = "Interests"
        case professional = "Professional"
        case timeInCity = "Time in City"
    }

    // NewLocal Categories
    let userTypeOptions = [
        ("local", "Locals", "People who know the city well"),
        ("newcomer", "Newcomers", "Recently moved (< 1 year)"),
        ("transplant", "Transplants", "Moved 1-2 years ago")
    ]

    let connectionGoalOptions = [
        "Find Local Guides", "Meet Other Newcomers", "Professional Networking",
        "Make New Friends", "Find Activity Partners", "Learn About Neighborhoods",
        "Get Local Recommendations", "Help Newcomers"
    ]

    let exploreOptions = [
        "Best Restaurants", "Hidden Gems", "Nightlife", "Outdoor Activities",
        "Coffee Shops", "Fitness & Gyms", "Art & Culture", "Local Events",
        "Neighborhoods", "Shopping", "Parks & Nature", "Family Activities",
        "Pet-Friendly Places", "Professional Networking", "Sports & Recreation"
    ]

    let commonInterests = [
        "Food & Restaurants", "Outdoor Activities", "Sports", "Fitness",
        "Art & Culture", "Music", "Tech & Startups", "Professional Networking",
        "Travel", "Hiking", "Coffee Shops", "Photography", "Local Events",
        "Gaming", "Cooking", "Reading", "Yoga", "Running", "Volunteering"
    ]

    let professionOptions = [
        "Technology", "Healthcare", "Finance", "Education", "Creative/Arts",
        "Retail", "Hospitality", "Manufacturing", "Government", "Non-profit",
        "Consulting", "Legal", "Marketing", "Real Estate", "Startup"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Quick Filters
                    quickFiltersSection

                    // Active Filters Summary
                    if filters.hasActiveFilters {
                        activeFiltersSummary
                    }

                    // Filter Sections
                    VStack(spacing: 12) {
                        // User Type Section
                        filterSection(
                            section: .userType,
                            icon: "person.2.fill",
                            content: {
                                VStack(spacing: 20) {
                                    userTypeSection
                                    Divider().padding(.horizontal)
                                    connectionGoalsSection
                                }
                            }
                        )

                        // Location Section
                        filterSection(
                            section: .location,
                            icon: "mappin.circle.fill",
                            content: {
                                VStack(spacing: 20) {
                                    neighborhoodSection
                                    Divider().padding(.horizontal)
                                    hometownSection
                                    Divider().padding(.horizontal)
                                    distanceSection
                                }
                            }
                        )

                        // Interests Section
                        filterSection(
                            section: .interests,
                            icon: "star.circle.fill",
                            content: {
                                VStack(spacing: 20) {
                                    interestsSection
                                    Divider().padding(.horizontal)
                                    exploreSection
                                }
                            }
                        )

                        // Professional Section
                        filterSection(
                            section: .professional,
                            icon: "briefcase.fill",
                            content: {
                                professionsSection
                            }
                        )

                        // Time in City Section
                        filterSection(
                            section: .timeInCity,
                            icon: "calendar.circle.fill",
                            content: {
                                timeInCitySection
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Reset button
                    if filters.hasActiveFilters {
                        resetButton
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 32)
                    } else {
                        Spacer().frame(height: 32)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.medium)
                        filters.saveToUserDefaults()
                        dismiss()
                    } label: {
                        Text("Apply")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [.teal, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // MARK: - Quick Filters

    private var quickFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                QuickFilterChip(
                    title: "Locals Only",
                    icon: "house.fill",
                    isActive: filters.userTypes == ["local"],
                    color: .teal
                ) {
                    HapticManager.shared.impact(.light)
                    filters.showLocalsOnly()
                }

                QuickFilterChip(
                    title: "Newcomers Only",
                    icon: "airplane.arrival",
                    isActive: filters.userTypes.contains("newcomer"),
                    color: .orange
                ) {
                    HapticManager.shared.impact(.light)
                    filters.showNewcomersOnly()
                }

                QuickFilterChip(
                    title: "Verified",
                    icon: "checkmark.seal.fill",
                    isActive: filters.showVerifiedOnly,
                    color: .green
                ) {
                    HapticManager.shared.impact(.light)
                    filters.showVerifiedOnly.toggle()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Active Filters Summary

    private var activeFiltersSummary: some View {
        let activeCount = countActiveFilters()

        return HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(.teal)

            Text("\(activeCount) filter\(activeCount == 1 ? "" : "s") active")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Button {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.3)) {
                    filters.resetFilters()
                }
            } label: {
                Text("Clear All")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.teal)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.teal.opacity(0.08))
    }

    // MARK: - Filter Section Container

    private func filterSection<Content: View>(
        section: FilterSection,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // Section Header
            Button {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if expandedSections.contains(section) {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32)

                    Text(section.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // Section filter count badge
                    if let count = sectionFilterCount(section), count > 0 {
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [.teal, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(expandedSections.contains(section) ? 90 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            // Section Content
            if expandedSections.contains(section) {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - User Type Section

    private var userTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Show me")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.userTypes.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.userTypes.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.teal)
                }
            }

            ForEach(userTypeOptions, id: \.0) { option in
                Button {
                    HapticManager.shared.impact(.light)
                    if filters.userTypes.contains(option.0) {
                        filters.userTypes.remove(option.0)
                    } else {
                        filters.userTypes.insert(option.0)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.1)
                                .fontWeight(.medium)
                            Text(option.2)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: filters.userTypes.contains(option.0) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(filters.userTypes.contains(option.0) ? .teal : .gray.opacity(0.3))
                    }
                    .padding()
                    .background(
                        filters.userTypes.contains(option.0) ?
                        Color.teal.opacity(0.1) : Color(.systemGray6)
                    )
                    .cornerRadius(12)
                }
                .foregroundColor(.primary)
            }
        }
    }

    // MARK: - Connection Goals Section

    private var connectionGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("I'm looking to...")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.connectionGoals.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.connectionGoals.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.teal)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(connectionGoalOptions, id: \.self) { goal in
                    SelectableFilterChip(
                        title: goal,
                        isSelected: filters.connectionGoals.contains(goal),
                        accentColor: .teal
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.connectionGoals.contains(goal) {
                            filters.connectionGoals.remove(goal)
                        } else {
                            filters.connectionGoals.insert(goal)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Neighborhood Section

    private var neighborhoodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Neighborhoods")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.neighborhoods.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.neighborhoods.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.teal)
                }
            }

            Text("Enter neighborhood names to filter")
                .font(.caption)
                .foregroundColor(.secondary)

            // Display selected neighborhoods as chips
            if !filters.neighborhoods.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(filters.neighborhoods), id: \.self) { neighborhood in
                        HStack(spacing: 4) {
                            Text(neighborhood)
                                .font(.subheadline)

                            Button {
                                filters.neighborhoods.remove(neighborhood)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .background(Color.teal)
                        .cornerRadius(16)
                    }
                }
            }
        }
    }

    // MARK: - Hometown Section

    private var hometownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("From Same Hometown")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.movedFromCities.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.movedFromCities.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.teal)
                }
            }

            Text("Connect with people from your hometown")
                .font(.caption)
                .foregroundColor(.secondary)

            // Display selected hometowns as chips
            if !filters.movedFromCities.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(filters.movedFromCities), id: \.self) { city in
                        HStack(spacing: 4) {
                            Text(city)
                                .font(.subheadline)

                            Button {
                                filters.movedFromCities.remove(city)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(16)
                    }
                }
            }
        }
    }

    // MARK: - Distance Section

    private var distanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Maximum Distance")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(filters.maxDistance)) miles")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.teal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(8)
            }

            Slider(value: $filters.maxDistance, in: 5...100, step: 5)
                .tint(.teal)
        }
    }

    // MARK: - Interests Section

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Shared Interests")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.selectedInterests.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.selectedInterests.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.teal)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(commonInterests, id: \.self) { interest in
                    SelectableFilterChip(
                        title: interest,
                        isSelected: filters.selectedInterests.contains(interest),
                        accentColor: .teal
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.selectedInterests.contains(interest) {
                            filters.selectedInterests.remove(interest)
                        } else {
                            filters.selectedInterests.insert(interest)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Explore Section

    private var exploreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("What They Want to Explore")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.whatToExplore.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.whatToExplore.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.teal)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(exploreOptions, id: \.self) { option in
                    SelectableFilterChip(
                        title: option,
                        isSelected: filters.whatToExplore.contains(option),
                        accentColor: .orange
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.whatToExplore.contains(option) {
                            filters.whatToExplore.remove(option)
                        } else {
                            filters.whatToExplore.insert(option)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Professions Section

    private var professionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Industry/Profession")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.professions.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.professions.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.teal)
                }
            }

            Text("Connect with people in your industry")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(professionOptions, id: \.self) { profession in
                    SelectableFilterChip(
                        title: profession,
                        isSelected: filters.professions.contains(profession),
                        accentColor: .blue
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.professions.contains(profession) {
                            filters.professions.remove(profession)
                        } else {
                            filters.professions.insert(profession)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Time in City Section

    private var timeInCitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How long they've been here")
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(spacing: 10) {
                TimeInCityToggle(
                    title: "New Arrivals",
                    subtitle: "Less than 3 months",
                    isOn: $filters.showNewArrivals,
                    color: .orange
                )

                TimeInCityToggle(
                    title: "Recent Movers",
                    subtitle: "3-12 months",
                    isOn: $filters.showRecentMovers,
                    color: .teal
                )

                TimeInCityToggle(
                    title: "Established",
                    subtitle: "1+ years",
                    isOn: $filters.showEstablished,
                    color: .green
                )
            }
        }
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button {
            HapticManager.shared.notification(.warning)
            withAnimation(.spring(response: 0.3)) {
                filters.resetFilters()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.body.weight(.medium))
                Text("Reset All Filters")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.red)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Helper Functions

    private func countActiveFilters() -> Int {
        var count = 0
        count += filters.userTypes.count
        count += filters.connectionGoals.count
        count += filters.neighborhoods.count
        count += filters.movedFromCities.count
        count += filters.selectedInterests.count
        count += filters.whatToExplore.count
        count += filters.professions.count
        if filters.showNewArrivals { count += 1 }
        if filters.showRecentMovers { count += 1 }
        if filters.showEstablished { count += 1 }
        if filters.showVerifiedOnly { count += 1 }
        return count
    }

    private func sectionFilterCount(_ section: FilterSection) -> Int? {
        switch section {
        case .userType:
            let count = filters.userTypes.count + filters.connectionGoals.count
            return count > 0 ? count : nil
        case .location:
            let count = filters.neighborhoods.count + filters.movedFromCities.count
            return count > 0 ? count : nil
        case .interests:
            let count = filters.selectedInterests.count + filters.whatToExplore.count
            return count > 0 ? count : nil
        case .professional:
            return filters.professions.isEmpty ? nil : filters.professions.count
        case .timeInCity:
            var count = 0
            if filters.showNewArrivals { count += 1 }
            if filters.showRecentMovers { count += 1 }
            if filters.showEstablished { count += 1 }
            return count > 0 ? count : nil
        }
    }
}

// MARK: - Time In City Toggle

struct TimeInCityToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding()
        .background(isOn ? color.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Quick Filter Chip

struct QuickFilterChip: View {
    let title: String
    let icon: String
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundColor(isActive ? .white : color)
            .background(
                isActive ?
                AnyShapeStyle(color) :
                AnyShapeStyle(color.opacity(0.1))
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(isActive ? 0 : 0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Selectable Filter Chip

struct SelectableFilterChip: View {
    let title: String
    let isSelected: Bool
    var accentColor: Color = .teal
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .primary)
                .background(
                    isSelected ?
                    accentColor :
                    Color(.systemGray6)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Interest Chip (Legacy support)

struct InterestChip: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableFilterChip(title: interest, isSelected: isSelected, action: action)
    }
}

#Preview {
    DiscoverFiltersView()
}
