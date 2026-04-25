# HabitJourney — Xcode Setup

## Quick Start (Windows → Codemagic)

No Xcode needed on your machine. The `.xcodeproj` is generated automatically on the Codemagic Mac build agent via **XcodeGen**.

### 1. Push to GitHub
```bash
cd C:\Users\kelam\HabitJourney
git init
git add .
git commit -m "Initial HabitJourney app"
# Create a GitHub repo, then:
git remote add origin https://github.com/YOUR_USERNAME/HabitJourney.git
git push -u origin main
```

### 2. Connect to Codemagic
1. Go to [codemagic.io](https://codemagic.io) → **Add application**
2. Connect your GitHub account → select **HabitJourney**
3. Codemagic will auto-detect `codemagic.yaml`
4. Click **Start new build** → choose **ios-simulator** workflow

### 3. Simulator build (no Apple account needed)
The `ios-simulator` workflow:
- Installs XcodeGen
- Runs `xcodegen generate` to create the `.xcodeproj`
- Builds for iPhone 16 Pro Simulator
- Emails you when done

### 4. TestFlight / Device build (needs Apple Developer account $99/yr)
Set up in Codemagic → Team → Integrations:
- Add **App Store Connect API key**
- Add **signing certificate + provisioning profile**
Then use the `ios-release` workflow (triggers on git tags like `v1.0.0`)

## Project Structure

```
HabitJourney/
├── HabitJourneyApp.swift       # App entry point
├── AppState.swift              # Shared state container
├── ContentView.swift           # Tab navigation
├── Models/
│   ├── Habit.swift             # Habit model + HabitCategory
│   ├── HabitEntry.swift        # Daily log entry + CompletionStatus
│   ├── JournalEntry.swift      # Journal entry + Mood
│   ├── Achievement.swift       # Achievement types & models
│   └── UserProfile.swift       # User stats, streaks, level
├── Persistence/
│   └── DataStore.swift         # JSON persistence via UserDefaults
├── ViewModels/
│   ├── HabitViewModel.swift    # Habit CRUD, stats, goal suggestions
│   ├── JournalViewModel.swift  # Journal management
│   └── GameViewModel.swift     # Streak, character position, achievements
├── Utilities/
│   ├── Extensions.swift        # Colors, Date helpers, View modifiers
│   └── NotificationManager.swift  # Local notifications
└── Views/
    ├── HomeView.swift           # Journey map + today's habits
    ├── HabitListView.swift      # Habit list with category filter
    ├── AddHabitView.swift       # Create habits with targets
    ├── LogTimeView.swift        # Log completed time
    ├── JournalView.swift        # Daily journal + mood tracking
    ├── ProfileView.swift        # Stats, achievements, settings
    └── Components/
        ├── CharacterView.swift      # Animated journey character
        ├── JourneyPathView.swift    # Winding path animation
        ├── HabitCardView.swift      # Habit card with status
        ├── ProgressRingView.swift   # Circular + bar progress
        └── AchievementBannerView.swift  # Unlock notification
```

## Features Implemented

### Core Habit Mechanics
- Create habits with weekly time targets (e.g. 5h/week)
- Log actual minutes completed each day
- Auto-calculates: 80%+ = Completed, 50-79% = Partial, <50% = Missed
- Character advances on path based on total active days

### Gamification
- Animated character with bounce + blink animations
- Winding journey path with milestone markers (drawn with SwiftUI Path)
- Partial completion still moves character forward
- Streak tracking (consecutive days with any habit logged)
- 11 achievement types with point rewards
- Level system (Seedling → Master) based on total points

### UX
- "How much did you complete today?" input (not yes/no)
- Quick time presets + ±5/±15 adjusters
- Goal adjustment suggestions when consistently under 50% or over 95%
- Confetti animation on goal completion
- Dark theme with purple + gold accents

### Journal
- Daily mood tracking (5 moods)
- Long-form reflection text
- 3 gratitude prompts
- Tomorrow's intention setting
- Mood trend graph (last 7 entries)
- Configurable daily reminder notifications

### Profile
- Editable name
- Level + XP progress bar
- Stats grid (streak, points, achievements)
- Achievement badge grid (locked/unlocked)
- Accountability Partners placeholder
- Journal reminder time picker

### Atomic Habits Integration
- Habit Stacking, 2-Minute Rule, Environment Design tips in Add Habit
- Category-based habit organization
- Daily target = weekly target ÷ 7
- Consistent small wins → character journey metaphor

## Minimum Requirements
- iOS 16.0+
- Xcode 15+
- No external dependencies
