import Foundation

struct FeastWindow: Identifiable, Codable {
    var id = UUID()
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    var durationInHours: Double {
        duration / 3600
    }
    
    var formattedDuration: String {
        let hours = Int(durationInHours)
        return "\(hours)h"
    }
    
    var timeRemaining: TimeInterval {
        max(0, endDate.timeIntervalSince(Date()))
    }
    
    var timeRemainingFormatted: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: timeRemaining) ?? "00:00"
    }
    
    var progressPercentage: Double {
        if isActive {
            let elapsed = Date().timeIntervalSince(startDate)
            return min(1.0, max(0.0, elapsed / duration))
        } else {
            return 0.0
        }
    }
}
