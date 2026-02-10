//
//  JetDateFormatter.swift
//  JetUI
//
//  Date formatting utilities
//

import Foundation

// MARK: - Date Extension

public extension Date {
    /// Format date with a custom pattern
    /// - Parameter pattern: Date format pattern (e.g., "yyyy-MM-dd HH:mm:ss")
    /// - Returns: Formatted date string
    func jet_format(_ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter.string(from: self)
    }
    
    /// Format date with a custom pattern and locale
    /// - Parameters:
    ///   - pattern: Date format pattern
    ///   - locale: Locale for formatting
    /// - Returns: Formatted date string
    func jet_format(_ pattern: String, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        formatter.locale = locale
        return formatter.string(from: self)
    }
}

// MARK: - Predefined Formatters

public enum JetDateFormatter {
    
    /// Time formatter (HH:mm)
    public static let time: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    /// Full date formatter (dd-MM-yyyy EEEE)
    public static let fullDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy EEEE"
        return f
    }()
    
    /// Short date formatter (yyyy-MM-dd)
    public static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    /// ISO8601 formatter
    public static let iso8601: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    /// Create a custom formatter with pattern
    /// - Parameter pattern: Date format pattern
    /// - Returns: Configured DateFormatter
    public static func custom(_ pattern: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = pattern
        return f
    }
}