//
//  ContentView.swift
//  SmartTransit
//
//  Created by Rahul Gupta on 9/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var scheduleService = TransitScheduleService()
    @State private var selectedStop: TransitStop?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                    Button(action: {
                        scheduleService.refreshSchedule()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            if selectedStop == nil {
                selectedStop = scheduleService.getNearestStop()
            }
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
        let twoHoursFromNow = calendar.date(byAdding: .hour, value: 2, to: now) ?? now
        
        let today = calendar.startOfDay(for: now)
        let scheduleDateTime = calendar.date(byAdding: .hour, value: calendar.component(.hour, from: scheduleTime), to: today) ?? now
        let finalScheduleTime = calendar.date(byAdding: .minute, value: calendar.component(.minute, from: scheduleTime), to: scheduleDateTime) ?? now
        
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

#Preview {
    ContentView()
}
