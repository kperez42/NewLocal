//
//  OnboardingView.swift
//  NewLocal
//
//  Onboarding for relocation community app
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    private let imageUploadService = ImageUploadService.shared

    @StateObject private var viewModel = OnboardingViewModel()
    @StateObject private var personalizedManager = PersonalizedOnboardingManager.shared
    @StateObject private var profileScorer = ProfileQualityScorer.shared

    // Parameter to skip goal selection for existing users updating their profile
    var isEditingExistingProfile: Bool = false

    @State private var currentStep = 0
    @State private var progress: CGFloat = 0
    @State private var showGoalSelection = true
    @State private var showTutorial = false
    @State private var showCompletionCelebration = false
    @State private var hasLoadedExistingData = false
    @State private var existingPhotoURLs: [String] = [] // Track existing photos to avoid re-upload

    // Step 1: Basics
    @State private var fullName = ""
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var gender = "Male"

    // Step 2: Location & About
    @State private var bio = ""
    @State private var location = ""
    @State private var country = ""

    // Step 3: Photos
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var isUploadingPhotos = false

    // Step 4: Relocation Story (NewLocal)
    @State private var userType: String = "newcomer"  // local, newcomer, transplant
    @State private var movedFrom: String = ""
    @State private var movedToDate: Date = Date()
    @State private var whyMoved: String = ""
    @State private var selectedInterests: [String] = []
    @State private var selectedLanguages: [String] = []

    // Step 6: NewLocal Details
    @State private var neighborhood: String = ""
    @State private var profession: String = ""
    @State private var whatToExplore: [String] = []
    @State private var lookingToConnect: [String] = []
    @State private var maxDistance: Int = 50

    // Step 7: Professional (Optional)
    @State private var educationLevel: String = ""
    @State private var company: String = ""
    @State private var industry: String = ""

    // Step 8: More About You (Optional)
    @State private var pets: String = ""
    @State private var hasKids: Bool = false
    @State private var personalNote: String = ""

    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animateContent = false
    @State private var onboardingStartTime = Date()
    
    let genderOptions = ["Male", "Female", "Non-binary", "Other"]
    let totalSteps = 8

    // NewLocal - User Type Options
    let userTypeOptions = [
        ("local", "I'm a Local", "Been here 2+ years, want to help newcomers"),
        ("newcomer", "I'm a Newcomer", "Recently moved (< 1 year)"),
        ("transplant", "I'm a Transplant", "Moved here 1-2 years ago")
    ]

    // NewLocal - Why Moved Options
    let whyMovedOptions = [
        "Work/Career", "School/Education", "Family", "Partner/Spouse",
        "Fresh Start", "Weather/Climate", "Cost of Living", "Adventure",
        "Remote Work Freedom", "Other"
    ]

    // NewLocal - What to Explore Options
    let exploreOptions = [
        "Best Restaurants", "Hidden Gems", "Nightlife", "Outdoor Activities",
        "Coffee Shops", "Fitness & Gyms", "Art & Culture", "Local Events",
        "Neighborhoods", "Shopping", "Parks & Nature", "Family Activities",
        "Pet-Friendly Places", "Professional Networking", "Sports & Recreation"
    ]

    // NewLocal - Connection Goals
    let connectionGoalOptions = [
        "Find Local Guides", "Meet Other Newcomers", "Professional Networking",
        "Make New Friends", "Find Activity Partners", "Learn About Neighborhoods",
        "Get Local Recommendations", "Help Newcomers (if local)"
    ]

    // Professional Options
    let educationOptions = ["", "High School", "Some College", "Associate's Degree", "Bachelor's Degree", "Master's Degree", "Doctorate", "Trade School", "Other"]
    let industryOptions = ["", "Technology", "Healthcare", "Finance", "Education", "Creative/Arts", "Retail", "Hospitality", "Manufacturing", "Government", "Non-profit", "Other"]
    let petsOptions = ["", "Dog", "Cat", "Both", "Other pets", "No pets", "Want pets"]

    let availableInterests = [
        "Food & Restaurants", "Outdoor Activities", "Sports", "Fitness",
        "Art & Culture", "Music", "Tech & Startups", "Professional Networking", "Travel",
        "Hiking", "Coffee Shops", "Photography", "Local Events", "Gaming",
        "Cooking", "Reading", "Yoga", "Running", "Volunteering", "Nightlife"
    ]

    let availableLanguages = [
        "English", "Spanish", "French", "German", "Italian",
        "Portuguese", "Chinese", "Japanese", "Korean", "Arabic"
    ]

    let availableCountries = [
        "United States", "Canada", "Mexico", "United Kingdom", "Australia",
        "Germany", "France", "Spain", "Italy", "Brazil", "Argentina",
        "Japan", "South Korea", "China", "India", "Philippines", "Vietnam",
        "Thailand", "Netherlands", "Sweden", "Norway", "Denmark", "Switzerland",
        "Ireland", "New Zealand", "Singapore", "Other"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    colors: [
                        Color.teal.opacity(0.1),
                        Color.blue.opacity(0.05),
                        Color.green.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Animated progress bar
                    progressBar
                    
                    // Content with transitions
                    TabView(selection: $currentStep) {
                        step1View.tag(0)
                        step2View.tag(1)
                        step3View.tag(2)
                        step4View.tag(3)
                        step5View.tag(4)
                        step6View.tag(5)
                        step7View.tag(6)
                        step8View.tag(7)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .accessibleAnimation(.easeInOut, value: currentStep)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Onboarding step \(currentStep + 1) of \(totalSteps)")
                    
                    // Navigation buttons
                    navigationButtons
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Show X/Cancel button only on step 0 (when there's no Back button)
                // On steps 1-7, the Back button serves as navigation
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep == 0 {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.teal)
                        }
                        .accessibilityLabel("Close")
                        .accessibilityHint("Cancel onboarding and return to previous screen")
                        .accessibilityIdentifier(AccessibilityIdentifier.closeButton)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Step \(currentStep + 1)/\(totalSteps)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                onboardingStartTime = Date()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateContent = true
                    progress = CGFloat(currentStep + 1) / CGFloat(totalSteps)
                }

                // Skip goal selection for existing users editing their profile
                if isEditingExistingProfile {
                    showGoalSelection = false
                }
            }
            .task {
                // Load existing user data when editing profile
                if isEditingExistingProfile && !hasLoadedExistingData {
                    await loadExistingUserData()
                    hasLoadedExistingData = true
                }
            }
            .onChange(of: currentStep) { _, newStep in
                viewModel.trackStepCompletion(newStep)
                updateProfileQuality()
            }
            .sheet(isPresented: $showGoalSelection) {
                OnboardingGoalSelectionView { goal in
                    showGoalSelection = false
                    // Show tutorial if A/B test says so
                    if viewModel.showTutorialIfNeeded() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showTutorial = true
                        }
                    }
                }
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showTutorial) {
                let tutorials = personalizedManager.getPrioritizedTutorials().compactMap { tutorialId in
                    TutorialManager.getOnboardingTutorials().first { $0.id == tutorialId }
                }
                TutorialView(tutorials: tutorials.isEmpty ? TutorialManager.getOnboardingTutorials() : tutorials) {
                    showTutorial = false
                }
            }
            .sheet(isPresented: $showCompletionCelebration) {
                CompletionCelebrationView(
                    incentive: viewModel.completionIncentive,
                    profileScore: profileScorer.currentScore
                ) {
                    showCompletionCelebration = false
                    dismiss()
                }
            }
            .overlay {
                if viewModel.showMilestoneCelebration, let milestone = viewModel.currentMilestone {
                    MilestoneCelebrationView(milestone: milestone) {
                        viewModel.showMilestoneCelebration = false
                    }
                }
            }
        }
    }

    // MARK: - Profile Quality Update

    private func updateProfileQuality() {
        guard var user = authService.currentUser else { return }

        // Create temporary user with current onboarding data
        user.fullName = fullName
        user.age = calculateAge(from: birthday)
        user.bio = bio
        user.location = location
        user.interests = selectedInterests
        user.languages = selectedLanguages

        viewModel.updateProfileQuality(for: user)
    }
    
    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 16) {
            // Step indicator dots
            HStack(spacing: 12) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(
                            currentStep >= step ?
                            LinearGradient(
                                colors: [Color.teal, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: currentStep == step ? 14 : 10, height: currentStep == step ? 14 : 10)
                        .scaleEffect(currentStep == step ? 1.0 : 0.85)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Step indicator")
            .accessibilityValue("Step \(currentStep + 1) of \(totalSteps)")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stepTitle)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(stepSubtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Percentage
                Text("\(Int(CGFloat(currentStep + 1) / CGFloat(totalSteps) * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.teal, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .padding(20)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Basic Info"
        case 1: return "About You"
        case 2: return "Your Photos"
        case 3: return "Your Story"
        case 4: return "Interests"
        case 5: return "What to Explore"
        case 6: return "Connections"
        case 7: return "Final Details"
        default: return ""
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case 0: return "Tell us who you are"
        case 1: return "Share a bit about yourself"
        case 2: return "Help others recognize you"
        case 3: return "Local or newcomer?"
        case 4: return "What makes you unique"
        case 5: return "What do you want to discover?"
        case 6: return "Who do you want to meet?"
        case 7: return "Almost done!"
        default: return ""
        }
    }
    
    // MARK: - Step 1: Basics
    
    private var step1View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateContent ? 1 : 0.5)
                .opacity(animateContent ? 1 : 0)
                
                VStack(spacing: 8) {
                    Text("Let's Get Started")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We need a few details to create your profile")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    // Full Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your name", text: $fullName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                            )
                            .accessibilityLabel("Full name")
                            .accessibilityHint("Enter your full name")
                            .accessibilityIdentifier(AccessibilityIdentifier.nameField)
                    }
                    
                    // Birthday
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birthday")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        DatePicker(
                            "",
                            selection: $birthday,
                            in: ...Date().addingTimeInterval(-18 * 365 * 24 * 60 * 60),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                        )
                        .accessibilityLabel("Birthday")
                        .accessibilityHint("Select your date of birth. Must be 18 or older")
                        .accessibilityIdentifier("birthday_picker")
                    }
                    
                    // Gender
                    VStack(alignment: .leading, spacing: 12) {
                        Text("I am")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ForEach(genderOptions, id: \.self) { option in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    gender = option
                                    HapticManager.shared.selection()
                                }
                            } label: {
                                HStack {
                                    Text(option)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    if gender == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.teal)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                }
                                .padding()
                                .background(
                                    gender == option ?
                                    LinearGradient(
                                        colors: [Color.teal.opacity(0.1), Color.cyan.opacity(0.05)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            gender == option ? Color.teal.opacity(0.5) : Color.gray.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding(20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Step 2: About & Location

    private var step2View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                // Incentive Banner (if offered)
                if let incentive = viewModel.completionIncentive {
                    IncentiveBanner(incentive: incentive)
                }

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("About You")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Share a bit about yourself and where you're from")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Profile Quality Tips (if enabled)
                if viewModel.shouldShowProfileTips, let tip = profileScorer.getPriorityTip() {
                    ProfileQualityTipCard(tip: tip)
                }

                VStack(spacing: 20) {
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Bio")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            Text("*")
                                .foregroundColor(.red)
                                .font(.subheadline)

                            Spacer()

                            Text("\(bio.count)/500")
                                .font(.caption)
                                .foregroundColor(bio.count > 500 ? .red : .secondary)
                        }

                        TextEditor(text: $bio)
                            .frame(height: 140)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(bio.isEmpty ? Color.red.opacity(0.5) : Color.teal.opacity(0.2), lineWidth: 1)
                            )
                            .overlay(alignment: .topLeading) {
                                if bio.isEmpty {
                                    Text("Tell others about yourself...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 20)
                                        .padding(.leading, 16)
                                        .allowsHitTesting(false)
                                }
                            }
                            .onChange(of: bio) { _, newValue in
                                // SAFETY: Enforce bio character limit to prevent data overflow
                                if newValue.count > AppConstants.Limits.maxBioLength {
                                    bio = String(newValue.prefix(AppConstants.Limits.maxBioLength))
                                }
                            }
                            .accessibilityLabel("Bio")
                            .accessibilityHint("Write a short bio about yourself. Maximum 500 characters")
                            .accessibilityValue("\(bio.count) of 500 characters")
                            .accessibilityIdentifier(AccessibilityIdentifier.bioField)
                    }

                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("City")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            Text("*")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }

                        TextField("e.g. Los Angeles", text: $location)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(location.isEmpty ? Color.red.opacity(0.5) : Color.teal.opacity(0.2), lineWidth: 1)
                            )
                            .accessibilityLabel("City")
                            .accessibilityHint("Enter your city")
                            .accessibilityIdentifier(AccessibilityIdentifier.locationField)
                    }

                    // Country
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Country")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            Text("*")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }

                        Menu {
                            ForEach(availableCountries, id: \.self) { countryOption in
                                Button(countryOption) {
                                    country = countryOption
                                }
                            }
                        } label: {
                            HStack {
                                Text(country.isEmpty ? "Select Country" : country)
                                    .foregroundColor(country.isEmpty ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(country.isEmpty ? Color.red.opacity(0.5) : Color.teal.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .accessibilityLabel("Country")
                        .accessibilityHint("Select your country from the list")
                        .accessibilityValue(country.isEmpty ? "No country selected" : country)
                        .accessibilityIdentifier(AccessibilityIdentifier.countryField)
                    }

                    // Helper text showing what's needed
                    if bio.isEmpty || location.isEmpty || country.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Fill in all required fields (*) to continue")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Step 3: Photos

    private var step3View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("Show Your Best Self")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Great photos get 10x more matches")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Requirement badge
                    HStack(spacing: 6) {
                        Image(systemName: photoImages.count >= 2 ? "checkmark.circle.fill" : "info.circle.fill")
                            .font(.caption)
                        Text(photoImages.count >= 2 ? "Ready to continue!" : "Add at least 2 photos")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(photoImages.count >= 2 ? .green : .orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(photoImages.count >= 2 ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.top, 4)
                }

                // Photo Progress Card
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        // Progress circle
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                .frame(width: 50, height: 50)

                            Circle()
                                .trim(from: 0, to: CGFloat(photoImages.count) / 6.0)
                                .stroke(
                                    LinearGradient(
                                        colors: [.orange, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))

                            Text("\(photoImages.count)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(photoImages.count) of 6 photos")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(photoImages.count == 0 ? "Add photos to get started" :
                                 photoImages.count < 2 ? "Add \(2 - photoImages.count) more to continue" :
                                 photoImages.count < 6 ? "Add more for better matches" : "Maximum photos reached!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Photo quality indicator
                        if photoImages.count >= 2 {
                            VStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.title3)
                                    .foregroundColor(.yellow)
                                Text("Good")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .cyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

                // Photo Tips Card - Collapsible style
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 32, height: 32)
                            Image(systemName: "lightbulb.fill")
                                .font(.callout)
                                .foregroundColor(.yellow)
                        }
                        Text("Photo Tips for Success")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        photoTipRow(icon: "face.smiling.fill", text: "Show your smile - it's your best feature!", color: .green)
                        photoTipRow(icon: "sun.max.fill", text: "Good lighting makes you shine", color: .orange)
                        photoTipRow(icon: "camera.fill", text: "Mix it up with different angles", color: .blue)
                        photoTipRow(icon: "sparkles", text: "Be yourself - authenticity wins", color: .teal)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.08), Color.orange.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )

                // Photo grid - Main photo is larger and more prominent
                VStack(spacing: 12) {
                    // Main Profile Photo - Full width, taller
                    if photoImages.count > 0 {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: photoImages[0])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(20)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                            Text("Profile Picture")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.black.opacity(0.6))
                                        )
                                        .padding(12)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                )

                            Button {
                                withAnimation {
                                    photoImages.remove(at: 0)
                                    HapticManager.shared.impact(.light)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)).padding(4))
                                    .padding(12)
                            }
                        }
                    } else {
                        // Empty main photo slot
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.teal.opacity(0.1), Color.cyan.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 240)
                            .overlay(
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.teal.opacity(0.15))
                                            .frame(width: 70, height: 70)

                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .font(.system(size: 36))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.teal, .cyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }

                                    VStack(spacing: 4) {
                                        Text("Profile Picture")
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text("This will be your main photo")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.teal.opacity(0.5), .cyan.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 2, dash: [8])
                                    )
                            )
                    }

                    // Additional photos grid (2 columns)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(1..<6, id: \.self) { index in
                            if index < photoImages.count {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: photoImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 150)
                                        .clipped()
                                        .cornerRadius(16)

                                    Button {
                                        withAnimation {
                                            photoImages.remove(at: index)
                                            HapticManager.shared.impact(.light)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.5)).padding(4))
                                            .padding(8)
                                    }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .frame(height: 150)
                                    .overlay(
                                        VStack(spacing: 6) {
                                            Image(systemName: "plus")
                                                .font(.title2)
                                                .foregroundColor(.teal.opacity(0.4))

                                            Text("Photo \(index + 1)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                            .foregroundColor(.gray.opacity(0.3))
                                    )
                            }
                        }
                    }
                }

                // Add photos button
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 6 - photoImages.count,
                    matching: .images
                ) {
                    HStack(spacing: 12) {
                        if isUploadingPhotos {
                            ProgressView()
                                .tint(.white)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(photoImages.isEmpty ? "Add Photos" : "Add More Photos")
                                    .fontWeight(.semibold)
                                Text(photoImages.count >= 6 ? "Maximum reached" : "\(6 - photoImages.count) slots available")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                        }
                        Spacer()
                        if !isUploadingPhotos {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .opacity(0.8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: photoImages.count >= 6 ? [Color.gray, Color.gray.opacity(0.8)] : [Color.orange, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: photoImages.count >= 6 ? .clear : .orange.opacity(0.3), radius: 10, y: 5)
                }
                .disabled(photoImages.count >= 6 || isUploadingPhotos)
                .onChange(of: selectedPhotos) { _, newValue in
                    Task {
                        isUploadingPhotos = true
                        await loadPhotos(newValue)
                        isUploadingPhotos = false
                    }
                }

                // Photo count indicator with animation
                HStack(spacing: 6) {
                    ForEach(0..<6, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                index < photoImages.count ?
                                LinearGradient(colors: [.orange, .cyan], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: index < photoImages.count ? 24 : 16, height: 6)
                            .animation(.spring(response: 0.3), value: photoImages.count)
                    }
                }
                .padding(.top, 8)

                // Motivation card
                HStack(spacing: 12) {
                    Image(systemName: "heart.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("First impressions matter")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Profiles with 3+ photos get 5x more likes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cyan.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding(20)
            .padding(.top, 20)
        }
    }

    private func photoTipRow(icon: String, text: String, color: Color = .teal) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundColor(.green.opacity(0.6))
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Step 4: Your Story (NewLocal)

    private var step4View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "map.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("Your Story")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Tell us about your journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 20) {
                    // User Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Are you a local or newcomer?")
                            .font(.headline)
                            .foregroundColor(.primary)

                        ForEach(userTypeOptions, id: \.0) { option in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    userType = option.0
                                    HapticManager.shared.selection()
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.1)
                                            .fontWeight(.semibold)
                                        Text(option.2)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if userType == option.0 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.teal)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                }
                                .padding()
                                .background(
                                    userType == option.0 ?
                                    LinearGradient(
                                        colors: [Color.teal.opacity(0.1), Color.blue.opacity(0.05)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            userType == option.0 ? Color.teal.opacity(0.5) : Color.gray.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                            }
                            .foregroundColor(.primary)
                        }
                    }

                    // Show relocation questions only for newcomers/transplants
                    if userType != "local" {
                        // Where did you move from?
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Where did you move from?")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)

                                Text("*")
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                            }

                            TextField("e.g. Chicago, IL or London, UK", text: $movedFrom)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(movedFrom.isEmpty ? Color.red.opacity(0.5) : Color.teal.opacity(0.2), lineWidth: 1)
                                )
                        }

                        // When did you move?
                        VStack(alignment: .leading, spacing: 8) {
                            Text("When did you move here?")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            DatePicker(
                                "",
                                selection: $movedToDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                            )
                        }

                        // Why did you move?
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Why did you move?")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            FlowLayout3(spacing: 8) {
                                ForEach(whyMovedOptions, id: \.self) { reason in
                                    Button {
                                        withAnimation {
                                            whyMoved = reason
                                            HapticManager.shared.selection()
                                        }
                                    } label: {
                                        Text(reason)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(whyMoved == reason ? .white : .teal)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                whyMoved == reason ?
                                                LinearGradient(
                                                    colors: [Color.teal, Color.blue],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ) :
                                                LinearGradient(colors: [Color.teal.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                            )
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }

                    // Neighborhood
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What neighborhood are you in?")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        TextField("e.g. Downtown, Westside, etc.", text: $neighborhood)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                            )
                    }
                }

                // Info card
                HStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                        .foregroundColor(.teal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(userType == "local" ? "Help newcomers!" : "Connect with locals!")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(userType == "local" ?
                             "Share your knowledge and help people settle in" :
                             "Get tips and recommendations from people who know the city")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.teal.opacity(0.1), Color.blue.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Step 5: Interests & Languages
    
    private var step5View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Almost Done!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Add your interests and languages")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Interests
                VStack(alignment: .leading, spacing: 12) {
                    Text("Interests (Optional)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout3(spacing: 8) {
                        ForEach(availableInterests, id: \.self) { interest in
                            Button {
                                withAnimation {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.removeAll { $0 == interest }
                                    } else {
                                        selectedInterests.append(interest)
                                    }
                                    HapticManager.shared.selection()
                                }
                            } label: {
                                Text(interest)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedInterests.contains(interest) ? .white : .teal)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedInterests.contains(interest) ?
                                        LinearGradient(
                                            colors: [Color.teal, Color.cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(colors: [Color.teal.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                
                // Languages
                VStack(alignment: .leading, spacing: 12) {
                    Text("Languages (Optional)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout3(spacing: 8) {
                        ForEach(availableLanguages, id: \.self) { language in
                            Button {
                                withAnimation {
                                    if selectedLanguages.contains(language) {
                                        selectedLanguages.removeAll { $0 == language }
                                    } else {
                                        selectedLanguages.append(language)
                                    }
                                    HapticManager.shared.selection()
                                }
                            } label: {
                                Text(language)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedLanguages.contains(language) ? .white : .blue)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedLanguages.contains(language) ?
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(colors: [Color.blue.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.top, 20)
        }
    }

    // MARK: - Step 6: What to Explore (NewLocal)

    private var step6View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "binoculars.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("What to Explore")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("What do you want to discover in your city?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Selection count
                    HStack(spacing: 6) {
                        Image(systemName: whatToExplore.count >= 3 ? "checkmark.circle.fill" : "info.circle.fill")
                            .font(.caption)
                        Text(whatToExplore.count >= 3 ? "\(whatToExplore.count) selected" : "Select at least 3")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(whatToExplore.count >= 3 ? .green : .orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(whatToExplore.count >= 3 ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.top, 4)
                }

                // Explore Options
                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to find...")
                        .font(.headline)
                        .foregroundColor(.primary)

                    FlowLayout3(spacing: 10) {
                        ForEach(exploreOptions, id: \.self) { option in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    if whatToExplore.contains(option) {
                                        whatToExplore.removeAll { $0 == option }
                                    } else {
                                        whatToExplore.append(option)
                                    }
                                    HapticManager.shared.selection()
                                }
                            } label: {
                                Text(option)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(whatToExplore.contains(option) ? .white : .orange)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        whatToExplore.contains(option) ?
                                        LinearGradient(
                                            colors: [Color.orange, Color.yellow.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(colors: [Color.orange.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(whatToExplore.contains(option) ? Color.clear : Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Max Distance for Connections
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.blue)
                        Text("Discovery Distance")
                            .font(.headline)

                        Spacer()

                        Text("\(maxDistance) miles")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Slider(
                            value: Binding(
                                get: { Double(maxDistance) },
                                set: { maxDistance = Int($0) }
                            ),
                            in: 5...100,
                            step: 5
                        )
                        .tint(.blue)

                        HStack {
                            Text("5 miles")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("100 miles")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                }

                // Benefit card
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personalized Recommendations")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("We'll match you with locals who know the best spots for what you want to explore!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(20)
            .padding(.top, 20)
        }
    }

    // MARK: - Step 7: Connection Goals (NewLocal)

    private var step7View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "person.2.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("Connection Goals")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("What kind of connections are you looking for?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Connection Goal Options
                VStack(alignment: .leading, spacing: 12) {
                    Text("I'm looking to...")
                        .font(.headline)
                        .foregroundColor(.primary)

                    ForEach(connectionGoalOptions, id: \.self) { goal in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                if lookingToConnect.contains(goal) {
                                    lookingToConnect.removeAll { $0 == goal }
                                } else {
                                    lookingToConnect.append(goal)
                                }
                                HapticManager.shared.selection()
                            }
                        } label: {
                            HStack {
                                Text(goal)
                                    .fontWeight(.medium)

                                Spacer()

                                if lookingToConnect.contains(goal) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.teal)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray.opacity(0.3))
                                }
                            }
                            .padding()
                            .background(
                                lookingToConnect.contains(goal) ?
                                LinearGradient(
                                    colors: [Color.teal.opacity(0.1), Color.cyan.opacity(0.05)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        lookingToConnect.contains(goal) ? Color.teal.opacity(0.5) : Color.gray.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .foregroundColor(.primary)
                    }
                }

                // Professional Info (Optional)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(.blue)
                        Text("Your Profession (Optional)")
                            .font(.headline)
                    }

                    TextField("e.g. Software Engineer, Teacher, etc.", text: $profession)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )

                    Text("Great for professional networking with others in your field")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Info card
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Smart Matching")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("We'll connect you with people who share your goals and can help you settle in!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(20)
            .padding(.top, 20)
        }
    }

    // MARK: - Step 8: Final Details (NewLocal)

    private var step8View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("Almost Done!")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("A few optional details to complete your profile")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Optional badge
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                        Text("Optional - Skip anytime")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.top, 4)
                }

                VStack(spacing: 20) {
                    // Education
                    lifestyleOptionSelector(
                        title: "Education",
                        icon: "graduationcap.fill",
                        color: .blue,
                        options: educationOptions,
                        selection: $educationLevel
                    )

                    // Industry
                    lifestyleOptionSelector(
                        title: "Industry",
                        icon: "building.2.fill",
                        color: .teal,
                        options: industryOptions,
                        selection: $industry
                    )

                    // Pets
                    lifestyleOptionSelector(
                        title: "Pets",
                        icon: "pawprint.fill",
                        color: .brown,
                        options: petsOptions,
                        selection: $pets
                    )

                    // Personal Note (optional fun fact)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "quote.bubble.fill")
                                .foregroundColor(.orange)
                            Text("Fun Fact (Optional)")
                                .font(.headline)
                        }

                        TextField("Something interesting about you...", text: $personalNote)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            )
                    }
                }

                // Completion stats
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        statBadge(icon: "person.2.fill", value: "3x", label: "More Connections", color: .teal)
                        statBadge(icon: "map.fill", value: "Better", label: "Recommendations", color: .orange)
                    }

                    Text("Complete profiles help you connect with the right people!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.teal.opacity(0.1), Color.orange.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .padding(20)
            .padding(.top, 20)
        }
    }

    // MARK: - Lifestyle Helper Views

    private func lifestyleOptionSelector(title: String, icon: String, color: Color, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option.isEmpty ? "Prefer not to say" : option) {
                        selection.wrappedValue = option
                        HapticManager.shared.selection()
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue.isEmpty ? "Select \(title.lowercased())..." : selection.wrappedValue)
                        .foregroundColor(selection.wrappedValue.isEmpty ? .gray : .primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep -= 1
                        HapticManager.shared.impact(.light)
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.teal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.teal, lineWidth: 2)
                    )
                }
                .accessibilityLabel("Back")
                .accessibilityHint("Go back to previous step")
                .accessibilityIdentifier(AccessibilityIdentifier.backButton)
            }
            
            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep += 1
                        HapticManager.shared.impact(.medium)
                    }
                } else {
                    completeOnboarding()
                }
            } label: {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(currentStep < totalSteps - 1 ? "Continue" : "Complete")
                            .fontWeight(.semibold)

                        if currentStep < totalSteps - 1 {
                            Image(systemName: "chevron.right")
                        } else {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canProceed ?
                    LinearGradient(
                        colors: [Color.teal, Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: canProceed ? .teal.opacity(0.3) : .clear, radius: 10, y: 5)
            }
            .disabled(!canProceed || isLoading)
            .accessibilityLabel(currentStep < totalSteps - 1 ? "Continue" : "Complete onboarding")
            .accessibilityHint(currentStep < totalSteps - 1 ? "Continue to next step" : "Finish onboarding and create profile")
            .accessibilityIdentifier(currentStep < totalSteps - 1 ? "continue_button" : "complete_button")
        }
        .padding(20)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 5, y: -2)
    }
    
    // MARK: - Helper Functions
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !fullName.isEmpty && calculateAge(from: birthday) >= 18
        case 1:
            return !bio.isEmpty && !location.isEmpty && !country.isEmpty && bio.count <= 500
        case 2:
            return photoImages.count >= 2
        case 3:
            // NewLocal: user type is required, and if not local, movedFrom is required
            if userType != "local" {
                return !movedFrom.isEmpty
            }
            return true
        case 4:
            return true // Interests are optional
        case 5:
            return true // What to explore is optional
        case 6:
            return true // Connection goals are optional
        case 7:
            return true // Final details are optional
        default:
            return false
        }
    }
    
    private func calculateAge(from birthday: Date) -> Int {
        Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
    }
    
    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    if photoImages.count < 6 {
                        photoImages.append(image)
                    }
                }
            }
        }
        selectedPhotos = []
    }
    
    private func completeOnboarding() {
        isLoading = true

        Task {
            do {
                guard var user = authService.currentUser else { return }
                guard let userId = user.id else { return }

                // PERFORMANCE FIX: Upload photos in parallel while preserving order
                // This reduces upload time from 30s (6 photos × 5s) to ~5s
                // Using indexed tuples to maintain original photo order (first photo = profile pic)
                let photoURLs = try await withThrowingTaskGroup(of: (Int, String).self) { group in
                    // Add upload task for each photo with its index
                    for (index, image) in photoImages.enumerated() {
                        group.addTask {
                            let url = try await imageUploadService.uploadProfileImage(image, userId: userId)
                            return (index, url)
                        }
                    }

                    // Collect all URLs with their indices
                    var indexedURLs: [(Int, String)] = []
                    for try await result in group {
                        indexedURLs.append(result)
                    }

                    // Sort by original index to preserve order (first photo = profile picture)
                    return indexedURLs.sorted { $0.0 < $1.0 }.map { $0.1 }
                }

                // Update user - Basic Info
                user.fullName = fullName
                user.age = calculateAge(from: birthday)
                user.gender = gender
                user.bio = bio
                user.location = location
                user.country = country
                user.photos = photoURLs
                user.profileImageURL = photoURLs.first ?? ""
                user.interests = selectedInterests
                user.languages = selectedLanguages

                // NewLocal - Relocation Info (Step 4)
                user.userType = userType
                if userType != "local" {
                    user.movedFrom = movedFrom
                    user.movedToDate = movedToDate
                    user.whyMoved = whyMoved.isEmpty ? nil : whyMoved
                }
                user.neighborhood = neighborhood.isEmpty ? nil : neighborhood

                // NewLocal - What to Explore & Connection Goals (Steps 6-7)
                user.whatToExplore = whatToExplore
                user.lookingToConnect = lookingToConnect
                user.maxDistance = maxDistance

                // NewLocal - Professional & Additional (Steps 7-8)
                user.profession = profession.isEmpty ? nil : profession
                if !educationLevel.isEmpty { user.educationLevel = educationLevel }
                if !industry.isEmpty { user.industry = industry }
                if !pets.isEmpty { user.pets = pets }

                try await authService.updateUser(user)

                // Refresh user data to ensure profile shows updated photos immediately
                await authService.fetchUser()

                // Track onboarding completion analytics
                let timeSpent = Date().timeIntervalSince(onboardingStartTime)
                await MainActor.run {
                    viewModel.trackOnboardingCompleted(timeSpent: timeSpent)

                    // Update activation metrics
                    ActivationMetrics.shared.trackProfileUpdate(user: user)

                    isLoading = false
                    HapticManager.shared.notification(.success)

                    // Show completion celebration if profile quality is good
                    if profileScorer.currentScore >= 70 {
                        showCompletionCelebration = true
                    } else {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    // MARK: - Load Existing User Data

    /// Pre-populate all fields with existing user data for profile editing
    /// This ensures data is preserved when users navigate back and forth
    private func loadExistingUserData() async {
        guard let user = authService.currentUser else { return }

        await MainActor.run {
            // Step 1: Basics
            fullName = user.fullName ?? ""
            gender = user.gender ?? "Male"

            // Calculate birthday from age (approximate)
            if user.age > 0 {
                let calendar = Calendar.current
                birthday = calendar.date(byAdding: .year, value: -user.age, to: Date()) ?? birthday
            }

            // Step 2: About & Location
            bio = user.bio ?? ""
            location = user.location ?? ""
            country = user.country ?? ""

            // Step 4: NewLocal - Relocation Info
            userType = user.userType ?? "newcomer"
            movedFrom = user.movedFrom ?? ""
            movedToDate = user.movedToDate ?? Date()
            whyMoved = user.whyMoved ?? ""
            neighborhood = user.neighborhood ?? ""

            // Step 5: Interests & Languages
            selectedInterests = user.interests ?? []
            selectedLanguages = user.languages ?? []

            // Step 6: What to Explore
            whatToExplore = user.whatToExplore ?? []
            maxDistance = user.maxDistance ?? 50

            // Step 7: Connection Goals
            lookingToConnect = user.lookingToConnect ?? []
            profession = user.profession ?? ""

            // Step 8: Additional Info
            educationLevel = user.educationLevel ?? ""
            industry = user.industry ?? ""
            pets = user.pets ?? ""

            // Store existing photo URLs to avoid re-uploading unchanged photos
            existingPhotoURLs = user.photos ?? []
        }

        // Load existing photos as UIImages for display
        if let photoURLs = authService.currentUser?.photos, !photoURLs.isEmpty {
            await loadExistingPhotos(from: photoURLs)
        }
    }

    /// Load existing photos from URLs into UIImages for display in the photo picker
    private func loadExistingPhotos(from urls: [String]) async {
        var loadedImages: [UIImage] = []

        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
            } catch {
                Logger.shared.error("Failed to load existing photo: \(urlString)", category: .storage, error: error)
            }
        }

        await MainActor.run {
            photoImages = loadedImages
        }
    }
}

// MARK: - Supporting Views

struct IncentiveBanner: View {
    let incentive: OnboardingViewModel.CompletionIncentive

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: incentive.icon)
                .font(.title2)
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("Complete your profile!")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(incentive.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ProfileQualityTipCard: View {
    let tip: ProfileQualityScorer.ProfileQualityTip

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tip.impact.icon)
                .font(.title3)
                .foregroundColor(tip.impact.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(tip.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("+\(tip.points)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding()
        .background(tip.impact.color.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tip.impact.color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CompletionCelebrationView: View {
    let incentive: OnboardingViewModel.CompletionIncentive?
    let profileScore: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var confettiCounter = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 32) {
                // Celebration Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.teal.opacity(0.2), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Text("🏡")
                        .font(.system(size: 60))
                }
                .scaleEffect(scale)
                .opacity(opacity)

                VStack(spacing: 12) {
                    Text("Welcome to NewLocal!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("You're ready to connect with your community!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Profile Score
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)

                            Circle()
                                .trim(from: 0, to: CGFloat(profileScore) / 100)
                                .stroke(
                                    LinearGradient(
                                        colors: [.teal, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))

                            Text("\(profileScore)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Profile Quality")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("Excellent!")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }
                .opacity(opacity)

                // Incentive Reward (if any)
                if let incentive = incentive {
                    VStack(spacing: 12) {
                        Divider()

                        HStack(spacing: 12) {
                            Image(systemName: incentive.icon)
                                .font(.title2)
                                .foregroundColor(.yellow)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reward Unlocked!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("\(incentive.amount) \(incentive.type.displayName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .opacity(opacity)
                }

                Button {
                    onDismiss()
                } label: {
                    Text("Start Connecting!")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .opacity(opacity)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 20)
            .padding(40)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            // Trigger confetti animation
            for i in 0..<20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    confettiCounter += 1
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthService.shared)
}

