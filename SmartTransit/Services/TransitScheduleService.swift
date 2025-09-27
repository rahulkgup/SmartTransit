//
//  TransitScheduleService.swift
//  SmartTransit
//
//  Created by Rahul Gupta on 9/26/25.
//

import Foundation
import Combine

class TransitScheduleService: ObservableObject {
    @Published var schedule: TransitSchedule?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSchedule()
    }
    
    func loadSchedule() {
        isLoading = true
        error = nil
        
        do {
            let schedule = try loadCSVData()
            
            DispatchQueue.main.async {
                self.schedule = schedule
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    private func loadCSVData() throws -> TransitSchedule {
        // Define stops based on CSV data
        let stops = [
            TransitStop(
                id: "north_springs",
                name: "North Springs Station",
                address: "North Springs MARTA Station",
                latitude: 33.9304,
                longitude: -84.3389,
                routes: ["route_140", "route_141", "route_143"]
            ),
            TransitStop(
                id: "windward_pnr",
                name: "Windward Park & Ride",
                address: "Windward Park & Ride",
                latitude: 34.0522,
                longitude: -84.2937,
                routes: ["route_140", "route_141", "route_143"]
            )
        ]
        
        // Define routes based on CSV data
        let routes = [
            TransitRoute(
                id: "route_140",
                name: "Route 140",
                shortName: "140",
                color: "#004E89",
                textColor: "#FFFFFF",
                direction: "Northbound/Southbound"
            ),
            TransitRoute(
                id: "route_141",
                name: "Route 141",
                shortName: "141",
                color: "#FF6B35",
                textColor: "#FFFFFF",
                direction: "Northbound/Southbound"
            ),
            TransitRoute(
                id: "route_143",
                name: "Route 143",
                shortName: "143",
                color: "#2ECC71",
                textColor: "#FFFFFF",
                direction: "Northbound/Southbound"
            )
        ]
        
        // Load and parse CSV data
        let northEntries = try parseCSVFile(filename: "North")
        let southEntries = try parseCSVFile(filename: "South")
        
        // Convert CSV entries to ScheduleEntry objects
        var scheduleEntries: [ScheduleEntry] = []
        var entryId = 1
        
        // Process northbound entries
        for entry in northEntries {
            let scheduleEntry = ScheduleEntry(
                id: "north_\(entryId)",
                routeId: "route_\(entry.route)",
                stopId: "north_springs",
                arrivalTime: entry.departureTime,
                departureTime: entry.arrivalTime,
                isRealTime: false,
                delay: nil
            )
            scheduleEntries.append(scheduleEntry)
            entryId += 1
        }
        
        // Process southbound entries
        for entry in southEntries {
            let scheduleEntry = ScheduleEntry(
                id: "south_\(entryId)",
                routeId: "route_\(entry.route)",
                stopId: "windward_pnr",
                arrivalTime: entry.departureTime,
                departureTime: entry.arrivalTime,
                isRealTime: false,
                delay: nil
            )
            scheduleEntries.append(scheduleEntry)
            entryId += 1
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let lastUpdated = formatter.string(from: Date())
        
        return TransitSchedule(
            stops: stops,
            routes: routes,
            scheduleEntries: scheduleEntries,
            lastUpdated: lastUpdated
        )
    }
    
    private func parseCSVFile(filename: String) throws -> [CSVTransitEntry] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "csv") else {
            throw TransitScheduleError.fileNotFound
        }
        
        let content = try String(contentsOf: url)
        let lines = content.components(separatedBy: .newlines)
        
        guard lines.count > 1 else {
            throw TransitScheduleError.invalidData
        }
        
        var entries: [CSVTransitEntry] = []
        
        // Skip header row, process data rows
        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            guard components.count >= 4 else { continue }
            
            let entry = CSVTransitEntry(
                bound: components[0].trimmingCharacters(in: .whitespacesAndNewlines),
                departureTime: components[1].trimmingCharacters(in: .whitespacesAndNewlines),
                arrivalTime: components[2].trimmingCharacters(in: .whitespacesAndNewlines),
                route: components[3].trimmingCharacters(in: .whitespacesAndNewlines)
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    func getScheduleForStop(stopId: String) -> [ScheduleEntry] {
        guard let schedule = schedule else { return [] }
        return schedule.scheduleEntries
            .filter { $0.stopId == stopId }
            .sorted { $0.arrivalTime < $1.arrivalTime }
    }
    
    func getRouteForId(_ routeId: String) -> TransitRoute? {
        return schedule?.routes.first { $0.id == routeId }
    }
    
    func getStopForId(_ stopId: String) -> TransitStop? {
        return schedule?.stops.first { $0.id == stopId }
    }
    
    func getNearestStop() -> TransitStop? {
        // For demo purposes, return the first stop
        // In a real app, you would use location services to find the nearest stop
        return schedule?.stops.first
    }
    
    func refreshSchedule() {
        loadSchedule()
    }
}

enum TransitScheduleError: Error, LocalizedError {
    case fileNotFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Schedule file not found"
        case .invalidData:
            return "Invalid schedule data"
        case .networkError:
            return "Network error occurred"
        }
    }
}
