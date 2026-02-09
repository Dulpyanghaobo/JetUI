//
//  JetMembershipCardView.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI

// MARK: - Membership Card View
/// 可配置样式的会员卡片组件
public struct JetMembershipCardView: View {
    let configuration: JetMembershipCardConfiguration
    let theme: JetSettingsTheme
    
    @State private var isSubscribed: Bool = false
    
    public init(
        configuration: JetMembershipCardConfiguration,
        theme: JetSettingsTheme = .standard
    ) {
        self.configuration = configuration
        self.theme = theme
    }
    
    public var body: some View {
        if configuration.isEnabled {
            Button(action: configuration.onTap) {
                cardContent
            }
            .buttonStyle(.plain)
            .onAppear {
                isSubscribed = configuration.isSubscribed()
            }
        }
    }
    
    @ViewBuilder
    private var cardContent: some View {
        switch configuration.style {
        case .gradient(let colors, let startPoint, let endPoint):
            gradientCard(colors: colors, startPoint: startPoint, endPoint: endPoint)
        case .image(let imageName):
            imageCard(imageName: imageName)
        case .solid(let color):
            solidCard(color: color)
        case .custom(let view):
            view
        }
    }
    
    // MARK: - Gradient Card (AlarmApp Style)
    private func gradientCard(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) -> some View {
        ZStack(alignment: .center) {
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .frame(height: 104)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            HStack(alignment: .center) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(configuration.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text(configuration.subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Image Card (WatermarkCamera Style)
    private func imageCard(imageName: String) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(configuration.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("PRO")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.accentColor)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black)
                        )
                    
                    Spacer()
                }
                
                Text(configuration.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if isSubscribed {
                    Text(configuration.activatedTitle)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    activateButton
                }
            }
            .padding()
            .frame(height: 164)
            .background(
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - Solid Card
    private func solidCard(color: Color) -> some View {
        HStack {
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(configuration.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                if !configuration.subtitle.isEmpty {
                    Text(configuration.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
        }
        .padding()
        .background(color)
        .cornerRadius(12)
    }
    
    // MARK: - Activate Button
    private var activateButton: some View {
        Text(configuration.buttonTitle)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.5),
                        Color.white
                    ]),
                    startPoint: .trailing,
                    endPoint: .leading
                )
            )
            .cornerRadius(4)
    }
}

// MARK: - Preview
#if DEBUG
struct JetMembershipCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Gradient Style (AlarmApp)
            JetMembershipCardView(
                configuration: JetMembershipCardConfiguration(
                    isEnabled: true,
                    style: .gradient(
                        colors: [
                            Color(red: 0.83, green: 0.52, blue: 0.96),
                            Color(red: 0.99, green: 0.55, blue: 0.37)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    title: "Awake Pro",
                    subtitle: "Upgrade for all missions, briefings\n& features.",
                    onTap: {}
                )
            )
            
            // Solid Style (DocumentScan)
            JetMembershipCardView(
                configuration: JetMembershipCardConfiguration(
                    isEnabled: true,
                    style: .solid(Color(.secondarySystemBackground)),
                    title: "Subscription Membership",
                    subtitle: "",
                    onTap: {}
                )
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
#endif