//
//  JetRecommendationsView.swift
//  JetUI
//
//  Created by i564407 on 2/8/26.
//

import SwiftUI

public struct JetRecommendationsView: View {
    // 数据源
    let items: [JetAppItem]
    // 标题
    let title: String
    
    // 自定义点击回调
    var onAppTap: ((JetAppItem) -> Void)?
    
    public init(title: String = "App Recommendations", items: [JetAppItem] = JetAppItem.companyApps, onAppTap: ((JetAppItem) -> Void)? = nil) {
        self.items = items
        self.title = title
        self.onAppTap = onAppTap
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. 标题栏
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.leading, 4)
            
            // 2. 容器背景区域
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        AppIconView(item: item)
                            .onTapGesture {
                                handleTap(item)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(white: 0.15))
            .cornerRadius(16)
        }
    }
    
    // 处理点击
    private func handleTap(_ item: JetAppItem) {
        onAppTap?(item)
        #if canImport(UIKit)
        UIApplication.shared.open(item.actionURL)
        #endif
    }
}

// 内部私有子视图：单个App图标
private struct AppIconView: View {
    let item: JetAppItem
    
    var body: some View {
        VStack {
            // Call the builder here, which now returns 'some View'
            iconView
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    // Changed return type to 'some View' and moved .resizable() inside
    @ViewBuilder
    var iconView: some View {
        if let localName = item.localIconName {
             // Local Image
            Image(localName, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let url = item.iconURL {
            if #available(iOS 15.0, *) {
                // Using AsyncImage for iOS 15+
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        // Error State
                        Color.gray // Background for error
                            .overlay(
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.white)
                            )
                    } else {
                        // Loading State
                        Color.gray.opacity(0.3)
                            .overlay(ProgressView())
                    }
                }
            } else {
                // Fallback for older iOS versions
                Image(systemName: "app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
            }
        } else {
            // Default placeholder
            Image(systemName: "questionmark.app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(12) // Optional padding for symbol
                .background(Color.gray.opacity(0.2))
        }
    }
}
