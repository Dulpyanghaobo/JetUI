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
    public let name: String
    public let iconURL: URL? // 支持网络图片配置
    public let localIconName: String? // 支持本地图片（如果图片打包在库里）
    public let actionURL: URL // 点击跳转的链接 (DeepLink 或 AppStore)
    
    // 初始化方法
    public init(name: String, iconURL: URL? = nil, localIconName: String? = nil, actionURL: URL) {
        self.name = name
        self.iconURL = iconURL
        self.localIconName = localIconName
        self.actionURL = actionURL
    }
}
