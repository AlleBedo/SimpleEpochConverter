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
        // Rimuovi spazi e caratteri non numerici
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Prova a estrarre il numero
        guard let epochValue = extractEpochValue(from: cleanText) else {
            print("Impossibile estrarre un valore epoch valido da: \(cleanText)")
            return
        }
        
        // Determina se è in secondi o millisecondi
        let timeInterval: TimeInterval
        let epochString: String
        
        if epochValue > 9999999999 {
            // Millisecondi
            timeInterval = TimeInterval(epochValue) / 1000.0
            epochString = "\(epochValue) ms"
        } else {
            // Secondi
            timeInterval = TimeInterval(epochValue)
            epochString = "\(epochValue) s"
        }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        
        // Formatta la data
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.locale = Locale(identifier: "it_IT")
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        
        // Calcola il tempo relativo
        let relativeString = getRelativeTime(from: date)
        
        // Aggiorna il risultato
        DispatchQueue.main.async {
            self.lastConversion = ConversionResult(
                epoch: epochString,
                date: dateString,
                relativeTime: relativeString
            )
        }
    }
    
    private func extractEpochValue(from text: String) -> Int64? {
        // Estrae solo i numeri dal testo
        let numbersOnly = text.filter { $0.isNumber }
        return Int64(numbersOnly)
    }
    
    private func getRelativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 0 {
            // Data futura
            let futureInterval = -interval
            if futureInterval < 60 {
                return "tra \(Int(futureInterval)) secondi"
            } else if futureInterval < 3600 {
                let minutes = Int(futureInterval / 60)
                return "tra \(minutes) minut\(minutes == 1 ? "o" : "i")"
            } else if futureInterval < 86400 {
                let hours = Int(futureInterval / 3600)
                return "tra \(hours) or\(hours == 1 ? "a" : "e")"
            } else if futureInterval < 2592000 {
                let days = Int(futureInterval / 86400)
                return "tra \(days) giorn\(days == 1 ? "o" : "i")"
            } else if futureInterval < 31536000 {
                let months = Int(futureInterval / 2592000)
                return "tra \(months) mes\(months == 1 ? "e" : "i")"
            } else {
                let years = Int(futureInterval / 31536000)
                return "tra \(years) ann\(years == 1 ? "o" : "i")"
            }
        } else {
            // Data passata
            if interval < 60 {
                return "\(Int(interval)) secondi fa"
            } else if interval < 3600 {
                let minutes = Int(interval / 60)
                return "\(minutes) minut\(minutes == 1 ? "o" : "i") fa"
            } else if interval < 86400 {
                let hours = Int(interval / 3600)
                return "\(hours) or\(hours == 1 ? "a" : "e") fa"
            } else if interval < 2592000 {
                let days = Int(interval / 86400)
                return "\(days) giorn\(days == 1 ? "o" : "i") fa"
            } else if interval < 31536000 {
                let months = Int(interval / 2592000)
                return "\(months) mes\(months == 1 ? "e" : "i") fa"
            } else {
                let years = Int(interval / 31536000)
                return "\(years) ann\(years == 1 ? "o" : "i") fa"
            }
        }
    }
}
