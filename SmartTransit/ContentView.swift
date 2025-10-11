//
//  ContentView.swift
//  SmartTransit
//
//  Created by Rahul Gupta on 9/26/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var scheduleService = TransitScheduleService()
    @State private var selectedStop: TransitStop?
    @State private var showLocationPermissionAlert = false
    
    private var locationManager: LocationManager {
        scheduleService.getLocationManager()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Location permission banner
                if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                    LocationPermissionBanner(
                        onEnableLocation: {
                            showLocationPermissionAlert = true
                        }
                    )
                }
                
                if scheduleService.isLoading {
                    LoadingView()
                } else if let error = scheduleService.error {
                    ErrorView(error: error) {
                        scheduleService.refreshSchedule()
                    }
                } else if let schedule = scheduleService.schedule,
                          let nearestStop = scheduleService.getNearestStop() {
                    TransitScheduleView(
                        schedule: schedule,
                        nearestStop: nearestStop,
                        scheduleService: scheduleService
                    )
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle("Smart Transit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Location status indicator
                        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                            if locationManager.location != nil {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            } else {
                                Image(systemName: "location.slash")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: {
                            scheduleService.refreshSchedule()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
        .onAppear {
            requestLocationIfNeeded()
            if selectedStop == nil {
                selectedStop = scheduleService.getNearestStop()
            }
        }
        .alert("Location Services Disabled", isPresented: $showLocationPermissionAlert) {
            Button("Open Settings", role: .cancel) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable location services in Settings to see nearby transit stops.")
        }
    }
    
    private func requestLocationIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
}

struct TransitScheduleView: View {
    let schedule: TransitSchedule
    let nearestStop: TransitStop
    let scheduleService: TransitScheduleService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Stop header
                StopHeaderView(
                    stop: nearestStop,
                    lastUpdated: schedule.lastUpdated
                )
                
                // Schedule entries
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Upcoming Departures")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("Next 2 hours")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    let scheduleEntries = scheduleService.getScheduleForStop(stopId: nearestStop.id)
                        .filter { isWithinNextTwoHours($0.arrivalTime) }
                        .prefix(10)
                    
                    if scheduleEntries.isEmpty {
                        EmptyScheduleView()
                    } else {
                        ForEach(Array(scheduleEntries), id: \.id) { entry in
                            if let route = scheduleService.getRouteForId(entry.routeId) {
                                ScheduleRowView(scheduleEntry: entry, route: route)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            scheduleService.refreshSchedule()
        }
    }
    
    private func isWithinNextTwoHours(_ timeString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let scheduleTime = formatter.date(from: timeString) else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Get current time components
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        // Get schedule time components
        let scheduleHour = calendar.component(.hour, from: scheduleTime)
        let scheduleMinute = calendar.component(.minute, from: scheduleTime)
        
        // Create schedule datetime for today
        var scheduleComponents = calendar.dateComponents([.year, .month, .day], from: now)
        scheduleComponents.hour = scheduleHour
        scheduleComponents.minute = scheduleMinute
        scheduleComponents.second = 0
        
        guard let finalScheduleTime = calendar.date(from: scheduleComponents) else { return false }
        
        // If the schedule time is before current time, it might be for tomorrow
        // (This handles cases near midnight, but for most cases we want today's schedule)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        let scheduleTimeInMinutes = scheduleHour * 60 + scheduleMinute
        
        // If schedule time already passed today, skip it
        if scheduleTimeInMinutes < currentTimeInMinutes {
            return false
        }
        
        let twoHoursFromNow = calendar.date(byAdding: .hour, value: 2, to: now) ?? now
        
        return finalScheduleTime >= now && finalScheduleTime <= twoHoursFromNow
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading transit schedule...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Unable to load schedule")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tram")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("No Schedule Available")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Unable to load transit schedule data")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyScheduleView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No departures in the next 2 hours")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LocationPermissionBanner: View {
    let onEnableLocation: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.slash.fill")
                .font(.title3)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Location Services Off")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Enable to see nearby stops")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onEnableLocation) {
                Text("Enable")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.orange.opacity(0.3)),
            alignment: .bottom
        )
    }
}

#Preview {
    ContentView()
}
