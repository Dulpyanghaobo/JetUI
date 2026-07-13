//
//  JetAppItem.swift
//  JetUI
//
//  Created by i564407 on 2/8/26.
//

import Foundation

// 定义推荐App的数据模型
public struct JetAppItem: Identifiable, Hashable {
    public let id = UUID()
    /// Stable product identity for Jet-owned products. Leave `nil` for host-defined items.
    public let product: JetProduct?
    public let name: String
    public let subtitle: String?
    public let actionTitle: String?
    /// Optional six-digit RGB color used by the recommendation action button.
    /// When omitted, the host recommendation appearance supplies the color.
    public let actionBackgroundColorHex: UInt32?
    /// Optional six-digit RGB text color used by the recommendation action button.
    public let actionTextColorHex: UInt32?
    public let iconURL: URL? // 支持网络图片配置
    public let localIconName: String? // 支持本地图片（如果图片打包在库里）
    public let actionURL: URL // 优先打开的链接（通常为 Deep Link）
    public let fallbackURL: URL? // 优先链接打不开时的兜底链接（通常为 App Store）
    public let showsDisclosureIndicator: Bool
    
    // 初始化方法
    public init(
        product: JetProduct? = nil,
        name: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        actionBackgroundColorHex: UInt32? = nil,
        actionTextColorHex: UInt32? = nil,
        iconURL: URL? = nil,
        localIconName: String? = nil,
        actionURL: URL,
        fallbackURL: URL? = nil,
        showsDisclosureIndicator: Bool = true
    ) {
        self.product = product
        self.name = name
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.actionBackgroundColorHex = actionBackgroundColorHex
        self.actionTextColorHex = actionTextColorHex
        self.iconURL = iconURL
        self.localIconName = localIconName
        self.actionURL = actionURL
        self.fallbackURL = fallbackURL
        self.showsDisclosureIndicator = showsDisclosureIndicator
    }
}
