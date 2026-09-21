import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var stepIndex: Int = 0
    @State private var goalTitle = "Earn ₹20 Lakhs"
    @State private var startDate = Date()
    @State private var playerName = "Warrior"

    let onboardingSteps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome, Warrior",
            subtitle: "Your 2-Year Mission Begins Now",
            icon: "🎯",
            content: "This is your countdown. Every day matters. You have 730 days to transform your life.",
            color: .blue
        ),
        OnboardingStep(
            title: "Your Resources",
            subtitle: "What You Already Have",
            icon: "💎",
            content: "SKILLS: Serial entrepreneur experience\nNETWORK: People who know you\nBRAND: Your story is unique\nSTORY: Failed but never defeated\nCONTENT: Ready to create\nROADMAP: This app is your guide",
            color: .purple
        ),
        OnboardingStep(
            title: "The Mission",
            subtitle: "₹20 Lakhs Minimum",
            icon: "💰",
            content: "Goal: Earn ₹20,00,000 minimum in 2 years.\n\nBreak it down:\n• ₹83,334/month\n• ₹2,778/day\n• Start building NOW\n\nTirupati to the world. Let's go.",
            color: .green
        ),
        OnboardingStep(
            title: "Daily Battle System",
            subtitle: "Check In. Fight. Win.",
            icon: "⚔️",
            content: "• Daily check-in = XP + Coins\n• Journal your progress\n• Fight enemies (bad habits)\n• Level up your character\n• Build unstoppable streaks\n\nDiscipline > Motivation",
            color: .orange
        ),
        OnboardingStep(
            title: "You Are Not Alone",
            subtitle: "Your Story Matters",
            icon: "🌙",
            content: "40 years old. Father. Husband. Son.\nDepression. ADHD. Failed ventures.\n\nBut you're still here. Still fighting.\nThat takes more courage than anyone knows.\n\nBismillah. Let's begin.",
            color: .red
        )
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if stepIndex < onboardingSteps.count {
                onboardingStepView(onboardingSteps[stepIndex])
            } else {
                setupView
            }
        }
    }

    func onboardingStepView(_ step: OnboardingStep) -> some View {
        VStack(spacing: 30) {
            Spacer()

            Text(step.icon)
                .font(.system(size: 80))

            Text(step.title)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(step.subtitle)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(step.color)

            Text(step.content)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
                .lineSpacing(4)

            Spacer()

            HStack {
                if stepIndex > 0 {
                    Button("Back") { withAnimation { stepIndex -= 1 } }
                        .buttonStyle(.bordered)
                        .foregroundColor(.white)
                }

                Button(stepIndex == onboardingSteps.count - 1 ? "Set Up Goal →" : "Next →") {
                    withAnimation { stepIndex += 1 }
                }
                .buttonStyle(.borderedProminent)
                .tint(step.color)
            }
            .padding(.bottom, 50)
        }
    }

    var setupView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("⚙️")
                .font(.system(size: 60))

            Text("Setup Your Mission")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                HStack {
                    Text("Your Name:")
                        .foregroundColor(.gray)
                        .frame(width: 120, alignment: .trailing)
                    TextField("Warrior", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                }

                HStack {
                    Text("Goal:")
                        .foregroundColor(.gray)
                        .frame(width: 120, alignment: .trailing)
                    TextField("Earn ₹20 Lakhs", text: $goalTitle)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                }

                HStack {
                    Text("Start Date:")
                        .foregroundColor(.gray)
                        .frame(width: 120, alignment: .trailing)
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .frame(width: 250)
                }
            }
            .padding(30)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))

            Spacer()

            Button("🚀 Launch Mission") {
                let endDate = Calendar.current.date(byAdding: .year, value: 2, to: startDate) ?? Date()

                let goal = Goal(
                    title: goalTitle,
                    targetAmount: 2000000,
                    currency: "₹",
                    startDate: startDate,
                    endDate: endDate,
                    iconName: "target",
                    createdAt: Date()
                )

                var player = PlayerProfile.empty
                player.name = playerName
                player.currentTitle = "Newcomer"
                player.titles = ["Newcomer"]

                DataManager.shared.saveGoal(goal)
                DataManager.shared.savePlayer(player)
                DataManager.shared.completeOnboarding()

                LaunchAgentManager.shared.installLaunchAgent()
                NotificationManager.shared.requestAuthorization()
                NotificationManager.shared.scheduleDailyReminder()

                appState.loadData()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .font(.system(size: 18, weight: .bold))

            Spacer()
        }
    }
}
