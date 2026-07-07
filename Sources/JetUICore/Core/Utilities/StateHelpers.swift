//
//  StateHelpers.swift
//  JetUI
//
//  Safe state update helper functions for SwiftUI
//  Prevents unnecessary UI updates by checking if value actually changed
//
//  Migrated from TimeProof/App/PublishedGuard.swift
//

import Foundation

/// Safely update a value only if it has changed
/// Prevents unnecessary UI updates in SwiftUI
/// - Parameters:
///   - old: Reference to the existing value
///   - newValue: The new value to set
///   - name: Optional name for debugging (unused in release builds)
@MainActor
public func setIfChanged<T: Equatable>(_ old: inout T, _ newValue: T, _ name: String = "") {
    guard old != newValue else { return }
    old = newValue
}

/// Safely update a value only if it has changed, returning whether an update occurred
/// - Parameters:
///   - old: Reference to the existing value
///   - newValue: The new value to set
/// - Returns: `true` if the value was changed, `false` otherwise
@MainActor
public func setIfChangedNoLog<T: Equatable>(_ old: inout T, _ newValue: T) -> Bool {
    guard old != newValue else { return false }
    old = newValue
    return true
}

/// Batch update multiple values, only triggering one UI update
/// - Parameters:
///   - updates: A closure containing multiple state updates
@MainActor
public func batchUpdate(_ updates: () -> Void) {
    updates()
}

// MARK: - Optional Extensions

extension Optional where Wrapped: Equatable {
    /// Update the optional value only if different
    @MainActor
    public mutating func setIfDifferent(_ newValue: Wrapped?) -> Bool {
        guard self != newValue else { return false }
        self = newValue
        return true
    }
}

// MARK: - Collection Extensions

extension Array where Element: Equatable {
    /// Update the array only if elements are different
    @MainActor
    public mutating func setIfDifferent(_ newValue: [Element]) -> Bool {
        guard self != newValue else { return false }
        self = newValue
        return true
    }
}

// MARK: - Publisher Guard Property Wrapper

import Combine

/// Property wrapper that guards @Published updates to only fire when value actually changes
/// Use this to prevent unnecessary SwiftUI view updates
///
/// Example:
/// ```swift
/// class MyViewModel: ObservableObject {
///     @PublishedGuard var count: Int = 0
/// }
/// ```
@propertyWrapper
public class PublishedGuard<Value: Equatable> {
    private var value: Value
    private let subject = PassthroughSubject<Value, Never>()
    
    public var wrappedValue: Value {
        get { value }
        set {
            guard value != newValue else { return }
            value = newValue
            subject.send(newValue)
        }
    }
    
    public var projectedValue: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}

// MARK: - Debounced State Update

/// Debounce rapid state updates to prevent UI thrashing
public actor DebouncedStateUpdater<T: Sendable> {
    private var pendingValue: T?
    private var task: Task<Void, Never>?
    private let delay: Duration
    private let onUpdate: @Sendable (T) async -> Void
    
    public init(
        delay: Duration = .milliseconds(100),
        onUpdate: @escaping @Sendable (T) async -> Void
    ) {
        self.delay = delay
        self.onUpdate = onUpdate
    }
    
    /// Schedule a debounced update
    public func update(_ value: T) {
        pendingValue = value
        
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            
            guard !Task.isCancelled, let value = pendingValue else { return }
            pendingValue = nil
            await onUpdate(value)
        }
    }
    
    /// Cancel pending update
    public func cancel() {
        task?.cancel()
        pendingValue = nil
    }
    
    /// Execute immediately without debouncing
    public func executeNow(_ value: T) async {
        task?.cancel()
        pendingValue = nil
        await onUpdate(value)
    }
}