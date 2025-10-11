//
//  TransitModels.swift
//  SmartTransit
//
//  Created by Rahul Gupta on 9/26/25.
//

import Foundation

struct TransitStop: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let routes: [String] // Route IDs that serve this stop
}

struct TransitRoute: Identifiable, Codable {
    let id: String
    let name: String
    let shortName: String
    let color: String
    let textColor: String
    let direction: String
}

struct ScheduleEntry: Identifiable, Codable {
    let id: String
    let routeId: String
    let stopId: String
    let arrivalTime: String // Format: "HH:mm"
    let departureTime: String // Format: "HH:mm"
    let isRealTime: Bool
    let delay: Int? // Delay in minutes, nil if on time
}

struct TransitSchedule: Codable {
    let stops: [TransitStop]
    let routes: [TransitRoute]
    let scheduleEntries: [ScheduleEntry]
    let lastUpdated: String
}

// CSV Data Models
struct CSVTransitEntry: Codable {
    let bound: String
    let departureTime: String
    let arrivalTime: String
    let route: String
}

// Helper extension for time formatting
extension ScheduleEntry {
    var formattedArrivalTime: String {
        return arrivalTime
    }
    
    var formattedDepartureTime: String {
        return departureTime
    }
    
    var isDelayed: Bool {
        return delay != nil && delay! > 0
    }
    
    var delayText: String {
        guard let delay = delay, delay > 0 else { return "" }
        return "+\(delay) min"
    }
}

