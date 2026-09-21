import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !DataManager.shared.isOnboardingComplete() {
                OnboardingView()
                    .environmentObject(appState)
            } else {
                MainDashboard()
                    .environmentObject(appState)
            }
        }
        .onAppear {
            appState.loadData()
        }
    }
}
