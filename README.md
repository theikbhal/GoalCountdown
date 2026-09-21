# GoalCountdown

**2-Year Mission to ₹20 Lakhs** - macOS Countdown App

A gamified macOS countdown app that tracks your 2-year journey to earning ₹20,00,000. Built with SwiftUI.

## Features

- ⏱️ **Live Countdown** - Real-time days/hours/minutes/seconds to deadline
- ✅ **Daily Check-In** - Track attendance, mood, energy levels
- 📔 **Daily Journal** - Document wins, learnings, setbacks
- ⚔️ **Enemy Battles** - Fight bad habits (procrastination, doubt, fear)
- 📊 **Gamification** - XP, levels, coins, achievements, streaks
- 💰 **Revenue Tracker** - Track earnings toward ₹20L goal
- 🔔 **Notifications** - Daily morning + evening reminders
- 🔄 **Auto-Start** - Launches on login via LaunchAgent

## Quick Start

```bash
./Scripts/install.sh
```

This will:
1. Build the app
2. Install to `/Applications/`
3. Create desktop shortcut
4. Enable auto-start on login
5. Launch the app

## Manual Build

```bash
./Scripts/build.sh
open build/GoalCountdown.app
```

## Requirements

- macOS 13.0+
- Swift 5.9+

## Goal Breakdown

| Target | Amount |
|--------|--------|
| Total | ₹20,00,000 |
| Monthly | ₹83,334 |
| Daily | ₹2,778 |

## Architecture

```
Sources/GoalCountdown/
├── GoalCountdownApp.swift    # App entry point
├── Models/
│   ├── AppState.swift        # Data models
│   └── AppState+ViewModel.swift
├── Views/
│   ├── ContentView.swift     # Root view
│   ├── OnboardingView.swift  # Setup wizard
│   ├── MainDashboard.swift   # Navigation
│   ├── CountdownView.swift   # Main countdown
│   ├── AttendanceView.swift  # Daily check-in
│   ├── JournalView.swift     # Daily journal
│   ├── BattleView.swift      # Enemy battles
│   ├── InventoryView.swift   # Profile & inventory
│   ├── RevenueView.swift     # Revenue tracking
│   └── SettingsView.swift    # App settings
└── Managers/
    ├── DataManager.swift     # Persistence
    ├── NotificationManager.swift
    ├── GamificationManager.swift
    └── LaunchAgentManager.swift
```

## License

MIT
