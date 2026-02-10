//
//  MemoryMonitor.swift
//  JetUI
//
//  Memory monitoring utility for optimization
//  Track and log application memory usage
//
//  Migrated from TimeProof/App/MemoryMonitor.swift
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Memory monitoring utility - tracks and logs app memory usage
public class MemoryMonitor {
    
    // MARK: - Singleton
    
    public static let shared = MemoryMonitor()
    
    // MARK: - Properties
    
    /// Optional logger callback
    public var logger: ((String) -> Void)?
    
    /// Optional analytics callback for logging events
    public var analyticsLogger: ((String, [String: Any]) -> Void)?
    
    private init() {
        #if canImport(UIKit) && !os(watchOS)
        setupMemoryWarningObserver()
        #endif
    }
    
    // MARK: - Private Logging
    
    private func log(_ message: String) {
        logger?(message)
        #if DEBUG
        print(message)
        #endif
    }
    
    private func logAnalytics(_ event: String, parameters: [String: Any]) {
        analyticsLogger?(event, parameters)
    }
    
    // MARK: - Memory Tracking
    
    /// Get current memory usage (MB)
    public static func currentMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            shared.log("⚠️ [MemoryMonitor] Failed to get memory info")
            return 0
        }
        
        return Double(info.resident_size) / 1024 / 1024
    }
    
    /// Log current memory usage
    public static func logMemoryUsage(tag: String = "") {
        let usedMB = currentMemoryUsage()
        let tagPrefix = tag.isEmpty ? "" : "[\(tag)] "
        shared.log("📊 [MemoryMonitor] \(tagPrefix)Memory: \(String(format: "%.2f", usedMB)) MB")
        
        shared.logAnalytics("memory_usage", parameters: [
            "memory_mb": usedMB,
            "tag": tag
        ])
    }
    
    /// Get memory usage percentage (relative to physical memory)
    public static func memoryUsagePercentage() -> Double? {
        let physicalMemory = Double(ProcessInfo.processInfo.physicalMemory)
        let usedMemory = currentMemoryUsage() * 1024 * 1024 // Convert to bytes
        
        guard physicalMemory > 0 else { return nil }
        
        return (usedMemory / physicalMemory) * 100
    }
    
    // MARK: - Memory Pressure Detection
    
    /// Check if under memory pressure
    public static func isUnderMemoryPressure() -> Bool {
        let usedMB = currentMemoryUsage()
        
        // Over 150MB is considered memory pressure
        let threshold: Double = 150.0
        
        return usedMB > threshold
    }
    
    /// Get memory pressure level
    public static func memoryPressureLevel() -> MemoryPressureLevel {
        let usedMB = currentMemoryUsage()
        
        switch usedMB {
        case 0..<100:
            return .normal
        case 100..<150:
            return .warning
        case 150..<200:
            return .critical
        default:
            return .severe
        }
    }
    
    // MARK: - Memory Warning Observer
    
    #if canImport(UIKit) && !os(watchOS)
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        let beforeMB = Self.currentMemoryUsage()
        log("⚠️ [MemoryMonitor] System memory warning received!")
        log("⚠️ [MemoryMonitor] Current usage: \(String(format: "%.2f", beforeMB)) MB")
        
        logAnalytics("system_memory_warning", parameters: [
            "memory_before_mb": beforeMB
        ])
        
        // Wait a bit for cleanup to happen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let afterMB = Self.currentMemoryUsage()
            let freed = beforeMB - afterMB
            self?.log("✅ [MemoryMonitor] After cleanup: \(String(format: "%.2f", afterMB)) MB")
            self?.log("✅ [MemoryMonitor] Freed: \(String(format: "%.2f", freed)) MB")
            
            self?.logAnalytics("memory_cleanup_completed", parameters: [
                "memory_after_mb": afterMB,
                "memory_freed_mb": freed
            ])
        }
    }
    #endif
    
    // MARK: - Profiling
    
    /// Measure memory usage change of a code block
    public static func profile<T>(
        _ operation: String,
        block: () throws -> T
    ) rethrows -> T {
        let beforeMB = currentMemoryUsage()
        shared.log("🔍 [MemoryMonitor] Starting: \(operation)")
        shared.log("🔍 [MemoryMonitor] Memory before: \(String(format: "%.2f", beforeMB)) MB")
        
        let result = try block()
        
        let afterMB = currentMemoryUsage()
        let delta = afterMB - beforeMB
        let deltaSign = delta >= 0 ? "+" : ""
        
        shared.log("🔍 [MemoryMonitor] Completed: \(operation)")
        shared.log("🔍 [MemoryMonitor] Memory after: \(String(format: "%.2f", afterMB)) MB")
        shared.log("🔍 [MemoryMonitor] Delta: \(deltaSign)\(String(format: "%.2f", delta)) MB")
        
        shared.logAnalytics("memory_profile", parameters: [
            "operation": operation,
            "memory_before_mb": beforeMB,
            "memory_after_mb": afterMB,
            "memory_delta_mb": delta
        ])
        
        return result
    }
    
    /// Async measure memory usage change of a code block
    public static func profileAsync(
        _ operation: String,
        block: @escaping () async throws -> Void
    ) async rethrows {
        let beforeMB = currentMemoryUsage()
        shared.log("🔍 [MemoryMonitor] Starting (async): \(operation)")
        shared.log("🔍 [MemoryMonitor] Memory before: \(String(format: "%.2f", beforeMB)) MB")
        
        try await block()
        
        let afterMB = currentMemoryUsage()
        let delta = afterMB - beforeMB
        let deltaSign = delta >= 0 ? "+" : ""
        
        shared.log("🔍 [MemoryMonitor] Completed (async): \(operation)")
        shared.log("🔍 [MemoryMonitor] Memory after: \(String(format: "%.2f", afterMB)) MB")
        shared.log("🔍 [MemoryMonitor] Delta: \(deltaSign)\(String(format: "%.2f", delta)) MB")
        
        shared.logAnalytics("memory_profile_async", parameters: [
            "operation": operation,
            "memory_before_mb": beforeMB,
            "memory_after_mb": afterMB,
            "memory_delta_mb": delta
        ])
    }
    
    // MARK: - Reporting
    
    /// Generate memory usage report
    public static func generateReport() -> MemoryReport {
        let usedMB = currentMemoryUsage()
        let percentage = memoryUsagePercentage()
        let pressureLevel = memoryPressureLevel()
        
        return MemoryReport(
            usedMB: usedMB,
            usagePercentage: percentage,
            pressureLevel: pressureLevel,
            timestamp: Date()
        )
    }
    
    /// Print detailed report
    public static func printDetailedReport() {
        let report = generateReport()
        
        shared.log("📊 [MemoryMonitor] ===== Memory Report =====")
        shared.log("📊 [MemoryMonitor] Used: \(String(format: "%.2f", report.usedMB)) MB")
        
        if let percentage = report.usagePercentage {
            shared.log("📊 [MemoryMonitor] Percentage: \(String(format: "%.1f", percentage))%")
        }
        
        shared.log("📊 [MemoryMonitor] Pressure: \(report.pressureLevel.description)")
        shared.log("📊 [MemoryMonitor] Time: \(report.timestamp)")
        shared.log("📊 [MemoryMonitor] ========================")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Supporting Types

/// Memory pressure level
public enum MemoryPressureLevel: String, Sendable {
    case normal = "Normal"      // < 100 MB
    case warning = "Warning"    // 100-150 MB
    case critical = "Critical"  // 150-200 MB
    case severe = "Severe"      // > 200 MB
    
    public var description: String {
        switch self {
        case .normal:
            return "🟢 Normal"
        case .warning:
            return "🟡 Warning"
        case .critical:
            return "🟠 Critical"
        case .severe:
            return "🔴 Severe"
        }
    }
    
    public var isHealthy: Bool {
        self == .normal || self == .warning
    }
}

/// Memory usage report
public struct MemoryReport: Sendable {
    public let usedMB: Double
    public let usagePercentage: Double?
    public let pressureLevel: MemoryPressureLevel
    public let timestamp: Date
    
    public var isHealthy: Bool {
        pressureLevel.isHealthy
    }
}