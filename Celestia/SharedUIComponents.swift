//
//  SharedUIComponents.swift
//  Celestia
//
//  Shared UI components used across the app
//

import SwiftUI

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String?
    let color: Color

    init(title: String, value: String, icon: String? = nil, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }

    var body: some View {
        VStack(spacing: 12) {
            // Icon with gradient background
            if let icon = icon {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: icon != nil ? 24 : 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.1), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color

    init(icon: String, text: String, color: Color = .purple) {
        self.icon = icon
        self.text = text
        self.color = color
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - App Header View

/// Reusable header view with gradient background and consistent styling
/// Used across Messages, Matches, SavedProfiles, and other main views
struct AppHeaderView<TrailingContent: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    let gradientColors: [Color]
    let stats: [(icon: String, value: String, label: String)]?
    let trailingContent: () -> TrailingContent

    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        gradientColors: [Color] = [.purple.opacity(0.9), .pink.opacity(0.7), .blue.opacity(0.6)],
        stats: [(icon: String, value: String, label: String)]? = nil,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradientColors = gradientColors
        self.stats = stats
        self.trailingContent = trailingContent
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative elements
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                    .offset(x: -30, y: 20)

                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .blur(radius: 15)
                    .offset(x: geo.size.width - 50, y: 40)
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack(alignment: .center) {
                    // Title section
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: icon)
                            .font(.system(size: 36))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .yellow.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .white.opacity(0.4), radius: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.largeTitle.weight(.bold))
                                .foregroundColor(.white)

                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                    }

                    Spacer()

                    // Trailing content (buttons, etc.)
                    trailingContent()
                }

                // Stats row
                if let stats = stats, !stats.isEmpty {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                            HStack(spacing: 4) {
                                Image(systemName: stat.icon)
                                    .font(.caption2)
                                Text(stat.value)
                                    .font(.caption.bold())
                                Text(stat.label)
                                    .font(.caption2)
                            }
                            .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .frame(height: stats != nil ? 130 : 100)
    }
}

// MARK: - Header Style Configuration (NewLocal Community App)

enum HeaderStyle {
    case messages
    case connections  // Renamed from matches - these are community connections
    case discover
    case saved
    case locals  // People who can show you around
    case newcomers  // Fellow newcomers
    case settings
    case premium

    var gradientColors: [Color] {
        switch self {
        case .messages:
            return [.blue.opacity(0.9), .cyan.opacity(0.7), .teal.opacity(0.6)]
        case .connections:
            return [.green.opacity(0.9), .teal.opacity(0.7), .blue.opacity(0.6)]
        case .discover:
            return [.purple.opacity(0.9), .blue.opacity(0.7), .cyan.opacity(0.6)]
        case .saved:
            return [.orange.opacity(0.9), .yellow.opacity(0.7), .green.opacity(0.6)]
        case .locals:
            return [.green.opacity(0.9), .blue.opacity(0.7), .purple.opacity(0.6)]
        case .newcomers:
            return [.cyan.opacity(0.9), .blue.opacity(0.7), .indigo.opacity(0.6)]
        case .settings:
            return [.gray.opacity(0.9), .blue.opacity(0.7), .cyan.opacity(0.6)]
        case .premium:
            return [.yellow.opacity(0.9), .orange.opacity(0.7), .green.opacity(0.6)]
        }
    }

    var icon: String {
        switch self {
        case .messages: return "message.circle.fill"
        case .connections: return "person.2.circle.fill"
        case .discover: return "map.circle.fill"
        case .saved: return "bookmark.circle.fill"
        case .locals: return "figure.wave.circle.fill"
        case .newcomers: return "suitcase.rolling.fill"
        case .settings: return "gearshape.fill"
        case .premium: return "star.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .messages: return "Messages"
        case .connections: return "Connections"
        case .discover: return "Explore"
        case .saved: return "Saved"
        case .locals: return "Local Guides"
        case .newcomers: return "Newcomers"
        case .settings: return "Settings"
        case .premium: return "Premium"
        }
    }
}

// MARK: - Simple Section Header

/// Lightweight section header for lists
struct SectionHeaderView: View {
    let title: String
    let icon: String?
    let action: (() -> Void)?
    let actionLabel: String?

    init(
        title: String,
        icon: String? = nil,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.actionLabel = actionLabel
    }

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            Spacer()

            if let action = action, let label = actionLabel {
                Button(action: action) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Empty State View

/// Reusable empty state view with icon, title, and message
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    let iconColor: Color

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        iconColor: Color = .gray
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.iconColor = iconColor
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.2), iconColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xxl)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            LinearGradient(
                                colors: [iconColor, iconColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(DesignSystem.CornerRadius.button)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxxl)
    }
}

// MARK: - Loading State View

/// Reusable loading state with pulse animation
struct LoadingStateView: View {
    let message: String

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.5 : 1.0)

                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.accentColor)
            }

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - NewLocal User Type Badge

/// Badge showing user type (Local, Newcomer, Transplant)
struct UserTypeBadge: View {
    let userType: String

    var badgeColor: Color {
        switch userType.lowercased() {
        case "local": return .green
        case "newcomer": return .blue
        case "transplant": return .purple
        default: return .gray
        }
    }

    var badgeIcon: String {
        switch userType.lowercased() {
        case "local": return "mappin.circle.fill"
        case "newcomer": return "airplane.arrival"
        case "transplant": return "house.and.flag.fill"
        default: return "person.fill"
        }
    }

    var badgeText: String {
        switch userType.lowercased() {
        case "local": return "Local"
        case "newcomer": return "Newcomer"
        case "transplant": return "Transplant"
        default: return userType.capitalized
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: badgeIcon)
                .font(.caption2)
            Text(badgeText)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(badgeColor)
        )
    }
}

// MARK: - Time In City Badge

/// Shows how long someone has been in the city
struct TimeInCityBadge: View {
    let movedDate: Date?

    var timeText: String {
        guard let movedDate = movedDate else { return "New here" }

        let months = Calendar.current.dateComponents([.month], from: movedDate, to: Date()).month ?? 0

        if months < 1 {
            return "Just arrived"
        } else if months == 1 {
            return "1 month"
        } else if months < 12 {
            return "\(months) months"
        } else {
            let years = months / 12
            return years == 1 ? "1 year" : "\(years) years"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption2)
            Text(timeText)
                .font(.caption.weight(.medium))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Relocation Info Card

/// Shows relocation information for a user
struct RelocationInfoCard: View {
    let movedFrom: String
    let currentCity: String
    let neighborhood: String
    let profession: String
    let whyMoved: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Moved from section
            if !movedFrom.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "airplane.departure")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Moved from")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(movedFrom)
                            .font(.subheadline.weight(.medium))
                    }
                }
            }

            // Current location
            if !currentCity.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Now in")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(neighborhood.isEmpty ? currentCity : "\(neighborhood), \(currentCity)")
                            .font(.subheadline.weight(.medium))
                    }
                }
            }

            // Profession
            if !profession.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "briefcase.fill")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .frame(width: 24)

                    Text(profession)
                        .font(.subheadline)
                }
            }

            // Why moved
            if !whyMoved.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.caption)
                        .foregroundColor(.purple)
                        .frame(width: 24)

                    Text(whyMoved)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(DesignSystem.CornerRadius.card)
    }
}

// MARK: - What To Explore Tags

/// Shows what the user wants to explore in their new city
struct ExploreInterestsView: View {
    let interests: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Wants to explore")
                    .font(.subheadline.weight(.semibold))
            }

            FlowLayout(spacing: 6) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                        )
                }
            }
        }
    }
}

// MARK: - Flow Layout for Tags

/// A simple flow layout that wraps content to new lines
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            height = y + lineHeight
        }
    }
}
