//
//  JetPriceRow.swift
//  JetUI
//
//  价格选项行组件 - 用于 Paywall 价格列表
//

import SwiftUI

/// 价格选项行
public struct JetPriceRow: View {
    
    // MARK: - Properties
    
    let title: String
    let message: String
    let price: String
    var isSelected: Bool = false
    var cornerTag: String? = nil
    var allowHighlight: Bool = false
    var accentColor: Color = .orange
    var action: () -> Void
    
    // MARK: - Initializer
    
    public init(
        title: String,
        message: String,
        price: String,
        isSelected: Bool = false,
        cornerTag: String? = nil,
        allowHighlight: Bool = false,
        accentColor: Color = .orange,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.price = price
        self.isSelected = isSelected
        self.cornerTag = cornerTag
        self.allowHighlight = allowHighlight
        self.accentColor = accentColor
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                if !message.isEmpty {
                    // 按英文逗号分割，前半部分高亮，后半部分白色
                    if allowHighlight, let commaIndex = message.firstIndex(of: ",") {
                        let firstPart = String(message[..<commaIndex])
                        let secondPart = String(message[message.index(after: commaIndex)...])
                        
                        (Text(firstPart)
                            .foregroundColor(accentColor) +
                         Text("," + secondPart)
                            .foregroundColor(.white.opacity(0.7)))
                            .font(.caption)
                    } else {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            Spacer()
            Text(price)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            ZStack {
                // 基础卡片
                RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.10))
                // 选中态透明层
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(accentColor.opacity(0.2))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
        )
        .overlay(alignment: .topTrailing) {
            if let tag = cornerTag, !tag.isEmpty {
                Text(tag)
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentColor)
                    )
                    .offset(x: 0, y: -12)
                    .padding(.trailing, 0)
            }
        }
        .onTapGesture { action() }
    }
}

// MARK: - Preview

#if DEBUG
struct JetPriceRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            VStack(spacing: 16) {
                JetPriceRow(
                    title: "Yearly",
                    message: "7 days free, then $29.99/year",
                    price: "$29.99",
                    isSelected: true,
                    cornerTag: "Save 75%",
                    allowHighlight: true
                ) {}
                
                JetPriceRow(
                    title: "Weekly",
                    message: "$2.99/week",
                    price: "$2.99",
                    isSelected: false
                ) {}
            }
            .padding()
        }
    }
}
#endif