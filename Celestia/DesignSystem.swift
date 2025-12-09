//
//  DesignSystem.swift
//  Celestia
//
//  Design system for consistent styling across the app
//  Eliminates magic numbers and provides centralized design tokens
//

import SwiftUI

/// Central design system for Celestia app
/// Provides consistent spacing, colors, typography, and component styles
enum DesignSystem {

    // MARK: - Spacing

    enum Spacing {
        /// 4pt - Minimum spacing for tight layouts
        static let xxs: CGFloat = 4
        /// 8pt - Extra small spacing
        static let xs: CGFloat = 8
        /// 12pt - Small spacing
        static let sm: CGFloat = 12
        /// 16pt - Medium spacing (most common)
        static let md: CGFloat = 16
        /// 20pt - Large spacing
        static let lg: CGFloat = 20
        /// 24pt - Extra large spacing
        static let xl: CGFloat = 24
        /// 32pt - Double extra large spacing
        static let xxl: CGFloat = 32
        /// 40pt - Triple extra large spacing
        static let xxxl: CGFloat = 40
        /// 48pt - Quadruple extra large spacing
        static let xxxxl: CGFloat = 48

        // Common combinations
        static let cardPadding: CGFloat = md
        static let sectionSpacing: CGFloat = xl
        static let screenPadding: CGFloat = lg
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        /// 4pt - Subtle rounding
        static let xs: CGFloat = 4
        /// 8pt - Small rounding
        static let sm: CGFloat = 8
        /// 12pt - Medium rounding (most common)
        static let md: CGFloat = 12
        /// 16pt - Large rounding
        static let lg: CGFloat = 16
        /// 20pt - Extra large rounding
        static let xl: CGFloat = 20
        /// 24pt - Double extra large rounding
        static let xxl: CGFloat = 24

        // Component-specific
        static let button: CGFloat = md
        static let card: CGFloat = lg
        static let sheet: CGFloat = xl
        static let avatar: CGFloat = .infinity // Circular
    }

    // MARK: - Opacity

    enum Opacity {
        /// 0.1 - Very subtle
        static let xxs: Double = 0.1
        /// 0.2 - Subtle
        static let xs: Double = 0.2
        /// 0.3 - Light
        static let sm: Double = 0.3
        /// 0.4 - Medium-light
        static let md: Double = 0.4
        /// 0.5 - Medium
        static let mediumOpacity: Double = 0.5
        /// 0.6 - Medium-strong
        static let lg: Double = 0.6
        /// 0.7 - Strong
        static let xl: Double = 0.7
        /// 0.8 - Very strong
        static let xxl: Double = 0.8
        /// 0.9 - Nearly opaque
        static let xxxl: Double = 0.9

        // Semantic
        static let disabled: Double = sm
        static let placeholder: Double = lg
        static let overlay: Double = md
    }

    // MARK: - Font Sizes

    enum FontSize {
        /// 10pt - Caption 2
        static let xxs: CGFloat = 10
        /// 12pt - Caption
        static let xs: CGFloat = 12
        /// 14pt - Footnote
        static let sm: CGFloat = 14
        /// 16pt - Body (default)
        static let md: CGFloat = 16
        /// 18pt - Callout
        static let lg: CGFloat = 18
        /// 20pt - Title 3
        static let xl: CGFloat = 20
        /// 24pt - Title 2
        static let xxl: CGFloat = 24
        /// 28pt - Title 1
        static let xxxl: CGFloat = 28
        /// 34pt - Large Title
        static let xxxxl: CGFloat = 34

        // Semantic
        static let caption: CGFloat = xs
        static let body: CGFloat = md
        static let headline: CGFloat = lg
        static let title: CGFloat = xxl
        static let largeTitle: CGFloat = xxxl
    }

    // MARK: - Icon Sizes

    enum IconSize {
        /// 16pt - Small icon
        static let sm: CGFloat = 16
        /// 20pt - Medium icon
        static let md: CGFloat = 20
        /// 24pt - Large icon
        static let lg: CGFloat = 24
        /// 32pt - Extra large icon
        static let xl: CGFloat = 32
        /// 40pt - Double extra large icon
        static let xxl: CGFloat = 40
        /// 48pt - Triple extra large icon
        static let xxxl: CGFloat = 48
        /// 64pt - Quadruple extra large icon
        static let xxxxl: CGFloat = 64

        // Semantic
        static let button: CGFloat = lg
        static let tabBar: CGFloat = lg
        static let avatar: CGFloat = xxxl
    }

    // MARK: - Shadows

    enum Shadow {
        case none
        case sm
        case md
        case lg
        case xl

        var radius: CGFloat {
            switch self {
            case .none: return 0
            case .sm: return 2
            case .md: return 4
            case .lg: return 8
            case .xl: return 12
            }
        }

        var offset: CGSize {
            switch self {
            case .none: return .zero
            case .sm: return CGSize(width: 0, height: 1)
            case .md: return CGSize(width: 0, height: 2)
            case .lg: return CGSize(width: 0, height: 4)
            case .xl: return CGSize(width: 0, height: 6)
            }
        }

        var opacity: Double {
            switch self {
            case .none: return 0
            case .sm: return 0.1
            case .md: return 0.15
            case .lg: return 0.2
            case .xl: return 0.25
            }
        }
    }

    // MARK: - Animation

    enum Animation {
        /// 0.15s - Quick animation
        static let quick: Double = 0.15
        /// 0.25s - Standard animation
        static let standard: Double = 0.25
        /// 0.35s - Slow animation
        static let slow: Double = 0.35
        /// 0.5s - Very slow animation
        static let verySlow: Double = 0.5

        // Spring animations
        static let spring: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.7)
        static let smoothSpring: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.8)
    }

    // MARK: - Layout

    enum Layout {
        /// Maximum content width for readability
        static let maxContentWidth: CGFloat = 600
        /// Standard card height
        static let cardHeight: CGFloat = 120
        /// Standard button height
        static let buttonHeight: CGFloat = 50
        /// Standard text field height
        static let textFieldHeight: CGFloat = 44
        /// Navigation bar height
        static let navBarHeight: CGFloat = 44
        /// Tab bar height
        static let tabBarHeight: CGFloat = 49
    }

    // MARK: - Colors (Semantic)

    enum Colors {
        // Primary brand colors
        static let primary = Color("AccentColor")
        static let secondary = Color.gray

        // Semantic colors
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        static let info = Color.blue

        // Gradients
        static let primaryGradient = LinearGradient(
            colors: [Color.teal, Color.cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let cardGradient = LinearGradient(
            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply standard card style
    func cardStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.cardPadding)
            .background(Color(.systemBackground))
            .cornerRadius(DesignSystem.CornerRadius.card)
            .shadow(
                color: Color.black.opacity(DesignSystem.Shadow.md.opacity),
                radius: DesignSystem.Shadow.md.radius,
                x: DesignSystem.Shadow.md.offset.width,
                y: DesignSystem.Shadow.md.offset.height
            )
    }

    /// Apply primary button style
    func primaryButtonStyle() -> some View {
        self
            .frame(height: DesignSystem.Layout.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .font(.system(size: DesignSystem.FontSize.headline, weight: .semibold))
    }

    /// Apply secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .frame(height: DesignSystem.Layout.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .font(.system(size: DesignSystem.FontSize.headline, weight: .semibold))
    }

    /// Apply standard section spacing
    func sectionSpacing() -> some View {
        self.padding(.bottom, DesignSystem.Spacing.sectionSpacing)
    }

    /// Apply screen padding
    func screenPadding() -> some View {
        self.padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
}

// MARK: - Common Component Styles

/// Standard card modifier
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.card
    var shadow: DesignSystem.Shadow = .md

    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing.cardPadding)
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(shadow.opacity),
                radius: shadow.radius,
                x: shadow.offset.width,
                y: shadow.offset.height
            )
    }
}

extension View {
    func card(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.card,
        shadow: DesignSystem.Shadow = .md
    ) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, shadow: shadow))
    }

    /// Apply gradient border
    func gradientBorder(
        colors: [Color] = [.teal, .cyan],
        lineWidth: CGFloat = 2
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .strokeBorder(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
        )
    }

    /// Apply shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }

    /// Apply press effect animation
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }

    /// Apply standard list row style
    func listRowStyle() -> some View {
        self
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(Color(.systemBackground))
    }
}

// MARK: - Shimmer Effect Modifier

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.5),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 2)
                        .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                    }
                )
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Press Effect Modifier

struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Avatar View

/// Reusable avatar view with consistent styling
struct AvatarView: View {
    let imageURL: String?
    let size: CGFloat
    let showBorder: Bool
    let borderColors: [Color]
    let fallbackIcon: String

    init(
        imageURL: String?,
        size: CGFloat = DesignSystem.IconSize.avatar,
        showBorder: Bool = false,
        borderColors: [Color] = [.teal, .cyan],
        fallbackIcon: String = "person.circle.fill"
    ) {
        self.imageURL = imageURL
        self.size = size
        self.showBorder = showBorder
        self.borderColors = borderColors
        self.fallbackIcon = fallbackIcon
    }

    var body: some View {
        Group {
            if let url = imageURL, let imageUrl = URL(string: url) {
                CachedAsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(
                    showBorder ? LinearGradient(
                        colors: borderColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                    lineWidth: showBorder ? 3 : 0
                )
        )
    }

    private var placeholderView: some View {
        Image(systemName: fallbackIcon)
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .padding(size * 0.2)
            .background(Color(.systemGray5))
    }
}

// MARK: - Badge View

/// Notification badge with count
struct BadgeView: View {
    let count: Int
    let maxDisplay: Int
    let color: Color

    init(count: Int, maxDisplay: Int = 99, color: Color = .red) {
        self.count = count
        self.maxDisplay = maxDisplay
        self.color = color
    }

    var body: some View {
        if count > 0 {
            Text(count > maxDisplay ? "\(maxDisplay)+" : "\(count)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(color)
                )
        }
    }
}

// MARK: - Tag View

/// Pill-shaped tag for categories, interests, etc.
struct TagView: View {
    let text: String
    let icon: String?
    let color: Color
    let isSelected: Bool
    let action: (() -> Void)?

    init(
        text: String,
        icon: String? = nil,
        color: Color = .accentColor,
        isSelected: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(text)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .foregroundColor(isSelected ? .white : color)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

// MARK: - Divider with Label

/// Custom divider with optional centered label
struct LabeledDivider: View {
    let label: String?

    init(_ label: String? = nil) {
        self.label = label
    }

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)

            if let label = label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
            }

            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)
        }
    }
}

// MARK: - Gradient Button Style

struct GradientButtonStyle: ButtonStyle {
    let colors: [Color]
    let cornerRadius: CGFloat

    init(
        colors: [Color] = [.teal, .cyan],
        cornerRadius: CGFloat = DesignSystem.CornerRadius.button
    ) {
        self.colors = colors
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Outline Button Style

struct OutlineButtonStyle: ButtonStyle {
    let color: Color
    let cornerRadius: CGFloat

    init(
        color: Color = .accentColor,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.button
    ) {
        self.color = color
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}
