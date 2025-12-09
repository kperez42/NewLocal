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

// MARK: - Header Style Configuration

enum HeaderStyle {
    case messages
    case matches
    case discover
    case saved
    case likes
    case settings
    case premium

    var gradientColors: [Color] {
        switch self {
        case .messages:
            return [.purple.opacity(0.9), .pink.opacity(0.7), .blue.opacity(0.6)]
        case .matches:
            return [.pink.opacity(0.9), .purple.opacity(0.7), .indigo.opacity(0.6)]
        case .discover:
            return [.blue.opacity(0.9), .purple.opacity(0.7), .pink.opacity(0.6)]
        case .saved:
            return [.orange.opacity(0.9), .pink.opacity(0.7), .purple.opacity(0.6)]
        case .likes:
            return [.pink.opacity(0.9), .red.opacity(0.7), .orange.opacity(0.6)]
        case .settings:
            return [.gray.opacity(0.9), .blue.opacity(0.7), .purple.opacity(0.6)]
        case .premium:
            return [.yellow.opacity(0.9), .orange.opacity(0.7), .pink.opacity(0.6)]
        }
    }

    var icon: String {
        switch self {
        case .messages: return "message.circle.fill"
        case .matches: return "heart.circle.fill"
        case .discover: return "sparkle.magnifyingglass"
        case .saved: return "bookmark.circle.fill"
        case .likes: return "heart.fill"
        case .settings: return "gearshape.fill"
        case .premium: return "crown.fill"
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
