//
//  Extensions-Date+Time.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//
import Foundation

extension Date {
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)
        
        if let day = components.day, day > 0 {
            if day == 1 { return "yesterday" }
            if day < 7 { return "\(day) days ago" }
            return self.formatted(date: .abbreviated, time: .omitted)
        }
        
        if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        }
        
        if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        }
        
        return "just now"
    }
}
