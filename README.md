# 🚌 SmartTransit

> Your personal transit companion that always knows where you are and when to leave.

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2015.6%2B-lightgrey.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**SmartTransit** is an intelligent iOS app that uses your location to show you the nearest transit stops and upcoming schedules in real-time. No more guessing which stop is closer or scrolling through endless timetables—SmartTransit does the thinking for you!

---

## ✨ What Makes It Smart?

### 📍 Location-Aware Magic
The app automatically detects your location and shows you the **nearest transit stop**. Moving around? No problem! SmartTransit updates dynamically as you move.

- **Real-time GPS tracking** with 100m accuracy
- **Automatic stop switching** when you change locations
- **Distance-based calculations** using the Haversine formula

### ⏰ Time Intelligence
Only see what matters—departures happening in the **next 2 hours**. Past schedules? Gone. Irrelevant future times? Hidden. Just what you need, when you need it.

- **Smart time filtering** shows only upcoming departures
- **Auto-refresh every 60 seconds** keeps data current
- **No stale data** to confuse your commute

### 🎨 Beautiful UI
A clean, modern interface that gets out of your way:

- **Pull-to-refresh** for instant updates
- **Color-coded routes** for easy identification
- **Status indicators** showing real-time vs scheduled
- **Location permission prompts** that actually make sense

---

## 🎯 Features at a Glance

| Feature | Description |
|---------|-------------|
| 🗺️ **Smart Location** | Automatically finds your nearest stop |
| ⏱️ **Live Updates** | Refreshes every 60 seconds automatically |
| 🎨 **Route Colors** | Each route has its own distinctive color |
| 🔔 **Permission-Friendly** | Helpful prompts with clear explanations |
| 📱 **Native SwiftUI** | Smooth, responsive, and modern |
| 🔋 **Battery Efficient** | Only tracks location when app is active |

---

## 🚀 Quick Start

### Prerequisites

- **Xcode 15.0+**
- **iOS 15.6+**
- **Swift 5.0+**
- An iPhone (or simulator with location simulation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rahulkgup/SmartTransit.git
   cd SmartTransit
   ```

2. **Open in Xcode**
   ```bash
   open SmartTransit.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `⌘R` or click the Run button
   - Grant location permissions when prompted

4. **Test with Custom Locations** (Simulator)
   - Features → Location → Custom Location
   - Try these coordinates:
     - **Windward P&R**: `34.0754, -84.2941`
     - **North Springs**: `33.9409, -84.3516`

---

## 🏗️ Architecture

SmartTransit follows clean architecture principles with SwiftUI and Combine:

```
📱 Views (SwiftUI)
    ↓
🎮 Services (ObservableObject)
    ├── LocationManager (CoreLocation)
    └── TransitScheduleService (Business Logic)
        ↓
📊 Models (Data Structures)
    ├── TransitStop
    ├── TransitRoute
    └── ScheduleEntry
        ↓
📁 Data Sources (CSV Files)
```

### Key Components

#### 🗺️ LocationManager
Handles all GPS functionality with CoreLocation:
- Real-time location tracking
- Permission management
- Distance calculations
- Battery-efficient updates

#### 🚌 TransitScheduleService
The brain of the app:
- Loads and parses CSV schedule data
- Calculates nearest stop based on your location
- Filters schedules by current time
- Auto-refreshes every minute

#### 🎨 ContentView
Beautiful SwiftUI interface that:
- Reacts to location and data changes
- Shows helpful permission banners
- Displays location status indicators
- Provides manual refresh capability

---

## 📊 How It Works

### Finding Your Nearest Stop

```swift
1. Get your GPS coordinates → (34.0754°N, 84.2941°W)
2. Calculate distance to all stops:
   - Windward P&R: 2.6 km ✅
   - North Springs: 17.8 km
3. Show schedule for Windward P&R
```

The app uses the **Haversine formula** to calculate accurate distances on Earth's curved surface.

### Time Filtering Logic

```swift
Current Time: 10:30 AM
Next 2 Hours: 10:30 AM - 12:30 PM

Schedule Times:
✗ 9:45 AM  → Past (hidden)
✓ 10:45 AM → Show
✓ 11:30 AM → Show
✓ 12:15 PM → Show
✗ 1:00 PM  → Too far (hidden)
```

---

## 🗺️ Supported Routes & Stops

### Current Coverage

#### 🚏 North Springs Station
- **Location**: North Springs MARTA Station
- **Coordinates**: 33.9304°N, 84.3389°W
- **Routes**: 140, 141, 143

#### 🚏 Windward Park & Ride
- **Location**: Windward Park & Ride
- **Coordinates**: 34.0522°N, 84.2937°W
- **Routes**: 140, 141, 143

### Route Details

| Route | Color | Direction | Type |
|-------|-------|-----------|------|
| **140** | Blue `#004E89` | Northbound/Southbound | Express |
| **141** | Orange `#FF6B35` | Northbound/Southbound | Local |
| **143** | Green `#2ECC71` | Northbound/Southbound | Limited |

---

## 🛠️ Technical Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Combine
- **Location**: CoreLocation
- **Minimum iOS**: 15.6
- **Data Format**: CSV

### Dependencies

✨ **Zero external dependencies!** Pure Swift and native frameworks only.

---

## 📱 Screenshots

### Main Features

**Location-Aware Stop Selection**
- Automatically shows your nearest stop
- Green location icon = GPS active
- Real-time updates as you move

**Smart Schedule Display**
- Color-coded route badges
- Time-filtered departures
- Status indicators (Live, Scheduled, Delayed)

**Permission Handling**
- Friendly permission prompts
- Orange banner when location is disabled
- One-tap to Settings

---

## 🔮 Future Enhancements

Want to contribute? Here are some ideas:

- [ ] 🗺️ **Map View** - Visual map showing stop locations
- [ ] 🚶 **Walking Directions** - Navigation to nearest stop
- [ ] 📏 **Distance Display** - Show "0.5 miles away"
- [ ] 🔔 **Push Notifications** - Alert when bus is approaching
- [ ] 🎨 **Dark Mode Optimization** - Enhanced dark mode support
- [ ] 📍 **Favorite Stops** - Pin your frequently used stops
- [ ] 🚌 **Live Bus Tracking** - Real-time vehicle positions
- [ ] 📊 **Arrival Predictions** - ML-based arrival time predictions

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/SmartTransit.git

# Create a branch
git checkout -b feature/my-new-feature

# Make your changes, test thoroughly

# Commit with a clear message
git commit -am 'Add: New feature description'

# Push and create a PR
git push origin feature/my-new-feature
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Rahul Gupta**

- GitHub: [@rahulkgup](https://github.com/rahulkgup)
- Email: rahulkgup@gmail.com

---

## 🙏 Acknowledgments

- Thanks to **Apple** for CoreLocation and SwiftUI
- Inspired by the need for better transit apps
- Built with ☕ and determination

---

## 📚 Learn More

### Documentation

- [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Detailed technical documentation
- [Apple CoreLocation Docs](https://developer.apple.com/documentation/corelocation)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Related Projects

Looking for more transit-related projects? Check out:
- [Transit App](https://transitapp.com/)
- [Moovit](https://moovitapp.com/)
- [Google Maps Transit](https://www.google.com/maps)

---

## 💡 Pro Tips

### For Testing

**Simulate Location Changes (Xcode Simulator)**
1. Run the app
2. Debug → Location → Custom Location
3. Enter coordinates and watch the app update!

**Test Different Scenarios**
- Grant location permission → See automatic stop detection
- Deny location permission → See helpful banner
- Pull to refresh → Manual data update
- Wait 60 seconds → Auto-refresh kicks in

### For Users

- **Keep location services enabled** for best experience
- **Pull down to refresh** anytime you want fresh data
- **Green location icon** = Everything working perfectly
- **Orange banner** = Time to enable location services

---

<div align="center">

### 🌟 If you find this project useful, please consider giving it a star!

**Made with ❤️ for better commuting**

[Report Bug](https://github.com/rahulkgup/SmartTransit/issues) · [Request Feature](https://github.com/rahulkgup/SmartTransit/issues)

</div>

