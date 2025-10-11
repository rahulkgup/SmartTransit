//
//  ScheduleRowView.swift
//  SmartTransit
//
//  Created by Rahul Gupta on 9/26/25.
//

import SwiftUI

struct ScheduleRowView: View {
    let scheduleEntry: ScheduleEntry
    let route: TransitRoute?
    
    var body: some View {
        HStack(spacing: 12) {
            // Route indicator
            if let route = route {
                VStack(spacing: 2) {
                    Text(route.shortName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: route.textColor))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: route.color))
                        .clipShape(Circle())
                    
                    Text(route.direction)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Time information
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(scheduleEntry.formattedArrivalTime)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if scheduleEntry.isDelayed {
                        Text(scheduleEntry.delayText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    if scheduleEntry.isRealTime {
                        Image(systemName: "wifi")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                if let route = route {
                    Text(route.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status indicator
            VStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(statusText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var statusColor: Color {
        if scheduleEntry.isDelayed {
            return .red
        } else if scheduleEntry.isRealTime {
            return .green
        } else {
            return .orange
        }
    }
    
    private var statusText: String {
        if scheduleEntry.isDelayed {
            return "Delayed"
        } else if scheduleEntry.isRealTime {
            return "Live"
        } else {
            return "Scheduled"
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    let sampleRoute = TransitRoute(
        id: "route_001",
        name: "Downtown Express",
        shortName: "DX",
        color: "#FF6B35",
        textColor: "#FFFFFF",
        direction: "Northbound"
    )
    
    let sampleEntry = ScheduleEntry(
        id: "entry_001",
        routeId: "route_001",
        stopId: "stop_001",
        arrivalTime: "08:15",
        departureTime: "08:17",
        isRealTime: true,
        delay: 2
    )
    
    return ScheduleRowView(scheduleEntry: sampleEntry, route: sampleRoute)
        .padding()
}

