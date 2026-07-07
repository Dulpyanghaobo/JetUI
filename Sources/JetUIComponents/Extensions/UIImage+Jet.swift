//
//  UIImage+Jet.swift
//  JetUI
//
//  UIImage extension utilities for cropping, downsampling, and tinting
//

import UIKit
import SwiftUI

// MARK: - CGImage Aspect Crop

public extension CGImage {
    /// Crop to specific aspect ratio, keeping center region
    /// - Parameter ratio: Target aspect ratio (width / height)
    /// - Returns: Cropped CGImage or nil if cropping fails
    func jet_cropped(to ratio: CGFloat) -> CGImage? {
        let w = CGFloat(width), h = CGFloat(height)
        var cropW = w, cropH = h
        if ratio > w / h {
            cropH = w / ratio
        } else {
            cropW = h * ratio
        }
        let rect = CGRect(
            x: (w - cropW) * 0.5,
            y: (h - cropH) * 0.5,
            width: cropW,
            height: cropH
        )
        return cropping(to: rect)
    }
}

// MARK: - UIImage Crop & Downsample

public extension UIImage {
    
    /// Crop image to specific aspect ratio
    /// - Parameter ratio: Target aspect ratio (width / height)
    /// - Returns: Cropped UIImage
    func jet_cropped(to ratio: CGFloat) -> UIImage {
        guard let cg = self.cgImage,
              let sub = cg.jet_cropped(to: ratio) else { return self }
        return UIImage(cgImage: sub, scale: scale, orientation: imageOrientation)
    }
    
    /// Downsample image from Data with maximum pixel size
    /// - Parameters:
    ///   - data: Image data
    ///   - maxPixel: Maximum pixel size for longest edge
    /// - Returns: Downsampled UIImage or nil
    static func jet_downsampled(from data: Data, maxPixel: Int) -> UIImage? {
        let cfData = data as CFData
        guard let src = CGImageSourceCreateWithData(cfData, nil) else { return nil }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ]
        
        guard let cgImg = CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImg)
    }
}

// MARK: - UIImage Tinting

public extension UIImage {
    
    /// Tint image with UIColor (template rendering)
    /// - Parameter color: Tint color
    /// - Returns: Tinted UIImage
    func jet_tinted(_ color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        let fmt = UIGraphicsImageRendererFormat()
        fmt.scale = scale
        fmt.opaque = false
        return UIGraphicsImageRenderer(size: size, format: fmt).image { _ in
            // Fill with color first
            color.setFill()
            UIRectFill(rect)
            // Use original image alpha as mask
            self.draw(in: rect, blendMode: .destinationIn, alpha: 1)
        }
    }
    
    /// Tint image with SwiftUI Color
    /// - Parameter color: SwiftUI Color
    /// - Returns: Tinted UIImage
    func jet_tinted(_ color: Color) -> UIImage {
        jet_tinted(UIColor(color))
    }
}

// MARK: - UIImage Resize

public extension UIImage {
    
    /// Resize image to target size
    /// - Parameters:
    ///   - targetSize: Target size
    ///   - contentMode: Content mode for resizing
    /// - Returns: Resized UIImage
    func jet_resized(to targetSize: CGSize, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        let horizontalRatio = targetSize.width / size.width
        let verticalRatio = targetSize.height / size.height
        
        let ratio: CGFloat
        switch contentMode {
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            ratio = min(horizontalRatio, verticalRatio)
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// Scale image by factor
    /// - Parameter factor: Scale factor (1.0 = original size)
    /// - Returns: Scaled UIImage
    func jet_scaled(by factor: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * factor, height: size.height * factor)
        return jet_resized(to: newSize)
    }
}

// MARK: - UIImage Orientation Fix

public extension UIImage {
    
    /// Fix image orientation to .up
    /// - Returns: UIImage with fixed orientation
    func jet_fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}

// MARK: - UIImage JPEG Compression

public extension UIImage {
    
    /// 将图片压缩到目标大小（KB）。必要时先等比缩小，再二分搜索JPEG质量。
    /// - Parameters:
    ///   - targetKB: 目标大小（单位KB）
    ///   - minQuality: 最低JPEG质量下限（0~1）
    ///   - initialMaxSide: 初始最长边限制（例如 1600；nil 表示不限制）
    ///   - stepDownRatio: 若仍超出大小，则继续按该比例递减最长边再试
    ///   - maxStepDownTimes: 最多缩小几轮（防止过度循环）
    /// - Returns: 符合大小的JPEG数据；若无法满足，则返回最小可达的数据
    func jet_jpegData(
        targetKB: Int,
        minQuality: CGFloat = 0.2,
        initialMaxSide: CGFloat? = 1600,
        stepDownRatio: CGFloat = 0.85,
        maxStepDownTimes: Int = 3
    ) -> Data? {
        let targetBytes = targetKB * 1024
        guard targetBytes > 0 else { return nil }
        
        // 生成指定最长边的等比缩放图
        func resizedImage(maxSide: CGFloat?) -> UIImage {
            guard let maxSide, maxSide > 0 else { return self }
            let w = size.width, h = size.height
            let longSide = max(w, h)
            guard longSide > maxSide else { return self }
            let scale = maxSide / longSide
            let newSize = CGSize(width: floor(w * scale), height: floor(h * scale))
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1 // 避免再按屏幕scale放大像素
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            return renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
        
        // 在 [low, high] 内二分搜索满足大小的质量
        func binarySearchJPEG(_ img: UIImage,
                              low: CGFloat = minQuality,
                              high: CGFloat = 0.95) -> Data? {
            var lo = low, hi = high
            var bestData: Data? = nil
            // 限制迭代次数，避免极端情况
            for _ in 0..<12 {
                let mid = (lo + hi) / 2
                guard let d = img.jpegData(compressionQuality: mid) else { break }
                if d.count > targetBytes {
                    // 太大 -> 降低质量
                    hi = mid - 0.05
                } else {
                    // 符合 -> 记录最佳，尝试更高质量
                    bestData = d
                    lo = mid + 0.05
                }
                if hi < lo { break }
            }
            // 如果 0.2 也大于目标，返回最低质量的结果（尽力）
            if bestData == nil, let d = img.jpegData(compressionQuality: low), d.count <= targetBytes {
                bestData = d
            }
            return bestData
        }
        
        // 逐步缩小尺寸 + 二分质量
        var currentMaxSide = initialMaxSide
        var attemptImage = resizedImage(maxSide: currentMaxSide)
        if let data = binarySearchJPEG(attemptImage) { return data }
        
        // 继续按比例降低分辨率再试几轮
        var times = 0
        var lastBest: Data? = attemptImage.jpegData(compressionQuality: minQuality)
        while times < maxStepDownTimes {
            times += 1
            if let ms = currentMaxSide {
                currentMaxSide = ms * stepDownRatio
            } else {
                currentMaxSide = max(size.width, size.height) * stepDownRatio
            }
            attemptImage = resizedImage(maxSide: currentMaxSide)
            if let data = binarySearchJPEG(attemptImage) {
                return data
            } else {
                // 记录一下当前能达到的最小数据，作为兜底返回
                if let d = attemptImage.jpegData(compressionQuality: minQuality),
                   let last = lastBest, d.count < last.count {
                    lastBest = d
                }
            }
        }
        return lastBest
    }
}
