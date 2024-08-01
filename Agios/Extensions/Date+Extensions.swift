//
//  Date+Extensions.swift
//  Natega
//
//  Created by Nikola Veljanovski on 21.12.22.
//

import Foundation
extension Date {
    // This date format is needed for the url.
    var formattedDateForAPI: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: Date())
    }
    
    static var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }
    
    func localDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let date = dateFormatter.date(from: dateFormatter.dateFormat)
        else { return Date() }
        return date
    }
    
    func formatDateShort(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: date)
    }
    
    static func copticDate() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let monthName = calendar.monthSymbols[month - 1]

        return "\(monthName) \(day)"
    }
    
    static func from(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? Date()
    }
}
