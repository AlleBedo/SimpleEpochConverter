import Foundation
import SwiftUI

struct ConversionResult {
    let epoch: String
    let date: String
    let relativeTime: String
}

class EpochConverter: ObservableObject {
    static let shared = EpochConverter()
    
    @Published var lastConversion: ConversionResult?
    
    private init() {}
    
    func convertEpoch(_ text: String) {
        // Remove spaces and non-numeric characters
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to extract the number
        guard let epochValue = extractEpochValue(from: cleanText) else {
            print("Unable to extract a valid epoch value from: \(cleanText)")
            return
        }
        
        // Determine if it's in seconds or milliseconds
        let timeInterval: TimeInterval
        let epochString: String
        
        if epochValue > 9999999999 {
            // Milliseconds
            timeInterval = TimeInterval(epochValue) / 1000.0
            epochString = "\(epochValue) ms"
        } else {
            // Seconds
            timeInterval = TimeInterval(epochValue)
            epochString = "\(epochValue) s"
        }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        
        // Calculate relative time
        let relativeString = getRelativeTime(from: date)
        
        // Update the result
        DispatchQueue.main.async {
            self.lastConversion = ConversionResult(
                epoch: epochString,
                date: dateString,
                relativeTime: relativeString
            )
        }
    }
    
    private func extractEpochValue(from text: String) -> Int64? {
        // Extract only numbers from text
        let numbersOnly = text.filter { $0.isNumber }
        return Int64(numbersOnly)
    }
    
    private func getRelativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 0 {
            // Future date
            let futureInterval = -interval
            if futureInterval < 60 {
                return "in \(Int(futureInterval)) seconds"
            } else if futureInterval < 3600 {
                let minutes = Int(futureInterval / 60)
                return "in \(minutes) minute\(minutes == 1 ? "" : "s")"
            } else if futureInterval < 86400 {
                let hours = Int(futureInterval / 3600)
                return "in \(hours) hour\(hours == 1 ? "" : "s")"
            } else if futureInterval < 2592000 {
                let days = Int(futureInterval / 86400)
                return "in \(days) day\(days == 1 ? "" : "s")"
            } else if futureInterval < 31536000 {
                let months = Int(futureInterval / 2592000)
                return "in \(months) month\(months == 1 ? "" : "s")"
            } else {
                let years = Int(futureInterval / 31536000)
                return "in \(years) year\(years == 1 ? "" : "s")"
            }
        } else {
            // Past date
            if interval < 60 {
                return "\(Int(interval)) seconds ago"
            } else if interval < 3600 {
                let minutes = Int(interval / 60)
                return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
            } else if interval < 86400 {
                let hours = Int(interval / 3600)
                return "\(hours) hour\(hours == 1 ? "" : "s") ago"
            } else if interval < 2592000 {
                let days = Int(interval / 86400)
                return "\(days) day\(days == 1 ? "" : "s") ago"
            } else if interval < 31536000 {
                let months = Int(interval / 2592000)
                return "\(months) month\(months == 1 ? "" : "s") ago"
            } else {
                let years = Int(interval / 31536000)
                return "\(years) year\(years == 1 ? "" : "s") ago"
            }
        }
    }
}
