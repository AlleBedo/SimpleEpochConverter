import Foundation
import SwiftUI

struct ConversionResult {
    let epoch: String
    let date: String
    let relativeTime: String
    let utcDate: String?
}

struct ReverseConversionResult {
    let date: String
    let utcDate: String?
    let epochSeconds: String
    let epochMilliseconds: String
}

class EpochConverter: ObservableObject {
    static let shared = EpochConverter()
    
    @Published var lastConversion: ConversionResult?
    @Published var lastReverseConversion: ReverseConversionResult?

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
        
        if abs(epochValue) > 9999999999 {
            // Milliseconds
            timeInterval = TimeInterval(epochValue) / 1000.0
            epochString = "\(epochValue) ms"
        } else {
            // Seconds
            timeInterval = TimeInterval(epochValue)
            epochString = "\(epochValue) s"
        }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        let settings = AppSettings.shared

        // Format the date in English
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = settings.activeDateFormat
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)

        // Format UTC date if enabled
        var utcString: String? = nil
        if settings.showUTC {
            let utcFormatter = DateFormatter()
            utcFormatter.dateFormat = settings.activeDateFormat
            utcFormatter.locale = Locale(identifier: "en_US")
            utcFormatter.timeZone = TimeZone(identifier: "UTC")
            utcString = utcFormatter.string(from: date)
        }

        // Calculate relative time
        let relativeString = getRelativeTime(from: date)

        // Update the result
        DispatchQueue.main.async {
            self.lastConversion = ConversionResult(
                epoch: epochString,
                date: dateString,
                relativeTime: relativeString,
                utcDate: utcString
            )
        }
    }
    
    private func extractEpochValue(from text: String) -> Int64? {
        // Match an optional minus sign followed by a contiguous sequence of digits
        guard let match = text.range(of: "-?\\d+", options: .regularExpression) else {
            return nil
        }
        return Int64(text[match])
    }
    
    func convertDateToEpoch(_ date: Date) {
        let epochSeconds = Int64(date.timeIntervalSince1970)
        let epochMilliseconds = Int64(date.timeIntervalSince1970 * 1000)
        let settings = AppSettings.shared

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = settings.activeDateFormat
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)

        var utcString: String? = nil
        if settings.showUTC {
            let utcFormatter = DateFormatter()
            utcFormatter.dateFormat = settings.activeDateFormat
            utcFormatter.locale = Locale(identifier: "en_US")
            utcFormatter.timeZone = TimeZone(identifier: "UTC")
            utcString = utcFormatter.string(from: date)
        }

        DispatchQueue.main.async {
            self.lastReverseConversion = ReverseConversionResult(
                date: dateString,
                utcDate: utcString,
                epochSeconds: "\(epochSeconds)",
                epochMilliseconds: "\(epochMilliseconds)"
            )
        }
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
