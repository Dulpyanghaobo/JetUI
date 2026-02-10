//
//  CircuitBreaker.swift
//  JetUI
//
//  Circuit Breaker Pattern implementation for resilient service calls
//  Prevents cascade failures by temporarily blocking calls to failing services
//
//  Migrated from TimeProof/App/CircuitBreaker.swift
//

import Foundation

/// Circuit Breaker State
public enum CircuitState: String {
    case closed      // Normal operation - requests pass through
    case open        // Failure state - requests blocked
    case halfOpen    // Testing state - limited requests allowed
}

/// Circuit Breaker Configuration
public struct CircuitBreakerConfig {
    /// Number of failures before opening the circuit
    public let failureThreshold: Int
    
    /// Time to wait before transitioning from open to half-open (seconds)
    public let recoveryTimeout: TimeInterval
    
    /// Number of successful calls required in half-open state to close circuit
    public let successThreshold: Int
    
    /// Time window for counting failures (seconds)
    public let failureWindow: TimeInterval
    
    public init(
        failureThreshold: Int = 5,
        recoveryTimeout: TimeInterval = 30,
        successThreshold: Int = 2,
        failureWindow: TimeInterval = 60
    ) {
        self.failureThreshold = failureThreshold
        self.recoveryTimeout = recoveryTimeout
        self.successThreshold = successThreshold
        self.failureWindow = failureWindow
    }
    
    /// Default configuration
    public static let `default` = CircuitBreakerConfig()
    
    /// Aggressive configuration for critical services
    public static let aggressive = CircuitBreakerConfig(
        failureThreshold: 3,
        recoveryTimeout: 15,
        successThreshold: 1,
        failureWindow: 30
    )
    
    /// Lenient configuration for non-critical services
    public static let lenient = CircuitBreakerConfig(
        failureThreshold: 10,
        recoveryTimeout: 60,
        successThreshold: 3,
        failureWindow: 120
    )
}

/// Circuit Breaker Error
public enum CircuitBreakerError: Error, LocalizedError {
    case circuitOpen(name: String)
    case executionFailed(underlying: Error)
    
    public var errorDescription: String? {
        switch self {
        case .circuitOpen(let name):
            return "Circuit '\(name)' is open - service temporarily unavailable"
        case .executionFailed(let error):
            return "Execution failed: \(error.localizedDescription)"
        }
    }
}

/// Circuit Breaker implementation
@MainActor
public final class CircuitBreaker {
    
    // MARK: - Properties
    
    public let name: String
    public let config: CircuitBreakerConfig
    
    private(set) public var state: CircuitState = .closed
    private var failureCount: Int = 0
    private var successCount: Int = 0
    private var lastFailureTime: Date?
    private var lastStateChangeTime: Date = Date()
    private var failureTimestamps: [Date] = []
    
    /// Optional logger for debugging
    public var logger: ((String) -> Void)?
    
    /// State change callback
    public var onStateChange: ((CircuitState, CircuitState) -> Void)?
    
    // MARK: - Initialization
    
    public init(name: String, config: CircuitBreakerConfig = .default) {
        self.name = name
        self.config = config
    }
    
    // MARK: - Private Logging
    
    private func log(_ message: String) {
        logger?(message)
        #if DEBUG
        print(message)
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Execute an operation through the circuit breaker
    public func execute<T>(_ operation: () async throws -> T) async throws -> T {
        // Check if we should allow the request
        guard canExecute() else {
            log("🔴 [CircuitBreaker:\(name)] Circuit OPEN - blocking request")
            throw CircuitBreakerError.circuitOpen(name: name)
        }
        
        do {
            let result = try await operation()
            recordSuccess()
            return result
        } catch {
            recordFailure()
            throw CircuitBreakerError.executionFailed(underlying: error)
        }
    }
    
    /// Execute a synchronous operation through the circuit breaker
    public func executeSync<T>(_ operation: () throws -> T) throws -> T {
        guard canExecute() else {
            log("🔴 [CircuitBreaker:\(name)] Circuit OPEN - blocking request")
            throw CircuitBreakerError.circuitOpen(name: name)
        }
        
        do {
            let result = try operation()
            recordSuccess()
            return result
        } catch {
            recordFailure()
            throw CircuitBreakerError.executionFailed(underlying: error)
        }
    }
    
    /// Check if the circuit allows execution
    public func canExecute() -> Bool {
        switch state {
        case .closed:
            return true
            
        case .open:
            // Check if recovery timeout has passed
            let timeSinceOpen = Date().timeIntervalSince(lastStateChangeTime)
            if timeSinceOpen >= config.recoveryTimeout {
                transitionTo(.halfOpen)
                return true
            }
            return false
            
        case .halfOpen:
            // Allow limited requests in half-open state
            return true
        }
    }
    
    /// Manually reset the circuit breaker
    public func reset() {
        log("🔄 [CircuitBreaker:\(name)] Manual reset")
        failureCount = 0
        successCount = 0
        failureTimestamps.removeAll()
        transitionTo(.closed)
    }
    
    /// Force open the circuit (for maintenance or manual intervention)
    public func forceOpen() {
        log("⚠️ [CircuitBreaker:\(name)] Forced OPEN")
        transitionTo(.open)
    }
    
    /// Get circuit breaker statistics
    public func statistics() -> CircuitBreakerStatistics {
        cleanupOldFailures()
        return CircuitBreakerStatistics(
            name: name,
            state: state,
            failureCount: failureCount,
            successCount: successCount,
            recentFailures: failureTimestamps.count,
            lastFailureTime: lastFailureTime,
            lastStateChangeTime: lastStateChangeTime,
            timeUntilRetry: timeUntilRetry()
        )
    }
    
    // MARK: - Private Methods
    
    private func recordSuccess() {
        successCount += 1
        
        switch state {
        case .halfOpen:
            if successCount >= config.successThreshold {
                log("✅ [CircuitBreaker:\(name)] Recovery successful - closing circuit")
                transitionTo(.closed)
            }
        case .closed:
            // Reset failure count on success in closed state
            if failureCount > 0 {
                failureCount = max(0, failureCount - 1)
            }
        case .open:
            break
        }
    }
    
    private func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()
        failureTimestamps.append(Date())
        
        // Cleanup old failures outside the window
        cleanupOldFailures()
        
        switch state {
        case .closed:
            if failureTimestamps.count >= config.failureThreshold {
                log("⚠️ [CircuitBreaker:\(name)] Failure threshold reached (\(failureTimestamps.count)/\(config.failureThreshold)) - opening circuit")
                transitionTo(.open)
            }
        case .halfOpen:
            log("⚠️ [CircuitBreaker:\(name)] Failure in half-open state - reopening circuit")
            transitionTo(.open)
        case .open:
            break
        }
    }
    
    private func transitionTo(_ newState: CircuitState) {
        guard state != newState else { return }
        
        let oldState = state
        state = newState
        lastStateChangeTime = Date()
        
        switch newState {
        case .closed:
            failureCount = 0
            successCount = 0
            failureTimestamps.removeAll()
        case .open:
            successCount = 0
        case .halfOpen:
            successCount = 0
        }
        
        log("🔄 [CircuitBreaker:\(name)] State: \(oldState.rawValue) → \(newState.rawValue)")
        onStateChange?(oldState, newState)
    }
    
    private func cleanupOldFailures() {
        let cutoff = Date().addingTimeInterval(-config.failureWindow)
        failureTimestamps = failureTimestamps.filter { $0 > cutoff }
    }
    
    private func timeUntilRetry() -> TimeInterval? {
        guard state == .open else { return nil }
        let timeSinceOpen = Date().timeIntervalSince(lastStateChangeTime)
        let remaining = config.recoveryTimeout - timeSinceOpen
        return remaining > 0 ? remaining : 0
    }
}

// MARK: - Supporting Types

/// Circuit Breaker Statistics
public struct CircuitBreakerStatistics {
    public let name: String
    public let state: CircuitState
    public let failureCount: Int
    public let successCount: Int
    public let recentFailures: Int
    public let lastFailureTime: Date?
    public let lastStateChangeTime: Date
    public let timeUntilRetry: TimeInterval?
    
    public var isHealthy: Bool {
        state == .closed
    }
    
    public var description: String {
        var desc = "[\(name)] State: \(state.rawValue), Failures: \(failureCount), Recent: \(recentFailures)"
        if let retry = timeUntilRetry {
            desc += ", Retry in: \(Int(retry))s"
        }
        return desc
    }
}

// MARK: - Circuit Breaker Registry

/// Registry for managing multiple circuit breakers
@MainActor
public final class CircuitBreakerRegistry {
    
    public static let shared = CircuitBreakerRegistry()
    
    private var breakers: [String: CircuitBreaker] = [:]
    
    private init() {}
    
    /// Get or create a circuit breaker
    public func breaker(
        for name: String,
        config: CircuitBreakerConfig = .default
    ) -> CircuitBreaker {
        if let existing = breakers[name] {
            return existing
        }
        
        let breaker = CircuitBreaker(name: name, config: config)
        breakers[name] = breaker
        return breaker
    }
    
    /// Get existing circuit breaker
    public func get(_ name: String) -> CircuitBreaker? {
        breakers[name]
    }
    
    /// Remove a circuit breaker
    public func remove(_ name: String) {
        breakers.removeValue(forKey: name)
    }
    
    /// Reset all circuit breakers
    public func resetAll() {
        breakers.values.forEach { $0.reset() }
    }
    
    /// Get statistics for all circuit breakers
    public func allStatistics() -> [CircuitBreakerStatistics] {
        breakers.values.map { $0.statistics() }
    }
    
    /// Get all unhealthy circuit breakers
    public func unhealthyBreakers() -> [CircuitBreaker] {
        breakers.values.filter { $0.state != .closed }
    }
}