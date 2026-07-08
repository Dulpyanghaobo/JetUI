//
//  JetDateProvider.swift
//  JetUI
//
//  Testable date boundary for product modules.
//

import Foundation

public protocol JetDateProvider {
    func now() -> Date
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool
    func daysBetween(_ date1: Date, _ date2: Date) -> Int
    func weeksBetween(_ date1: Date, _ date2: Date) -> Int
}

public final class JetSystemDateProvider: JetDateProvider {
    public static let shared = JetSystemDateProvider()

    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func now() -> Date {
        Date()
    }

    public func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    public func daysBetween(_ date1: Date, _ date2: Date) -> Int {
        abs(calendar.dateComponents([.day], from: date1, to: date2).day ?? 0)
    }

    public func weeksBetween(_ date1: Date, _ date2: Date) -> Int {
        abs(calendar.dateComponents([.weekOfYear], from: date1, to: date2).weekOfYear ?? 0)
    }
}
