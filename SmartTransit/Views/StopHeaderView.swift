//
//  StopHeaderView.swift
//  SmartTransit
//
//  Created by Rahul Gupta on 9/26/25.
//

import SwiftUI

struct StopHeaderView: View {
    let stop: TransitStop
    let lastUpdated: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stop.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(stop.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    Text("Nearest Stop")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Last updated: \(formatLastUpdated(lastUpdated))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(stop.routes.count) routes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatLastUpdated(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return "Unknown"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

#Preview {
    let sampleStop = TransitStop(
        id: "stop_001",
        name: "Downtown Transit Center",
        address: "123 Main St, Downtown",
        latitude: 37.7749,
        longitude: -122.4194,
        routes: ["route_001", "route_002", "route_003"]
    )
    
    return StopHeaderView(
        stop: sampleStop,
        lastUpdated: "2025-01-26T08:00:00Z"
    )
    .padding()
}
