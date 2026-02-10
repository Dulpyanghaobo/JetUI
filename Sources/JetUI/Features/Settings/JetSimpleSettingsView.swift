//
//  JetSimpleSettingsView.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI
import StoreKit

// MARK: - Simple Settings View
/// 简化版设置页面
/// 用户只需提供 JetAppConfig 配置，无需关心具体的 UI 实现细节
public struct JetSimpleSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    let config: JetAppConfig
    
    // Internal State
    @State private var showRestoreSuccess = false
    @State private var restoreInProgress = false
    @State private var errorMessage: String?
    @State private var showPaywall = false
    
    public init(config: JetAppConfig) {
        self.config = config
    }
    
    public var body: some View {
        NavigationStack {
            contentView
                .background(backgroundColor)
                .toolbar {
                    toolbarContent
                }
        }
        .alert(JetStrings.shared.restoreFailed(),
               isPresented: Binding(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
               ),
               actions: { Button(JetStrings.shared.ok(), role: .cancel) {} },
               message: { Text(errorMessage ?? "") })
        .alert(JetStrings.shared.restoreSuccessful(), isPresented: $showRestoreSuccess) {
            Button(JetStrings.shared.ok(), role: .cancel) {}
        } message: {
            Text(JetStrings.shared.purchasesRestored())
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch config.style {
        case .dark, .darkWithMembership:
            darkContent
        case .lightCard:
            lightCardContent
        case .standard:
            standardContent
        }
    }
    
    // MARK: - Dark Content
    private var darkContent: some View {
        VStack(spacing: 24) {
            List {
                Section(header: sectionHeader) {
                    // Restore Purchase
                    settingRow(
                        icon: "creditcard.fill",
                        title: JetStrings.shared.restorePurchase()
                    ) {
                        Task { await restorePurchases() }
                    }
                    .disabled(restoreInProgress)
                    .opacity(restoreInProgress ? 0.6 : 1)
                    
                    // Share
                    settingRow(
                        icon: "square.and.arrow.up",
                        title: JetStrings.shared.shareToFriends()
                    ) {
                        shareApp()
                    }
                    
                    // Rate
                    settingRow(
                        icon: "star.fill",
                        title: JetStrings.shared.rateUs()
                    ) {
                        requestReview()
                    }
                    
                    // Terms
                    settingRow(
                        icon: "doc.text.fill",
                        title: JetStrings.shared.termsOfUse()
                    ) {
                        JetSettingsActions.openURL(config.termsOfUseURL)
                    }
                    
                    // Privacy
                    settingRow(
                        icon: "lock.shield.fill",
                        title: JetStrings.shared.privacyPolicy()
                    ) {
                        JetSettingsActions.openURL(config.privacyPolicyURL)
                    }
                    
                    // Feedback
                    settingRow(
                        icon: "envelope.fill",
                        title: JetStrings.shared.feedback()
                    ) {
                        sendFeedback()
                    }
                }
                
                // Recommendations
                Section {
                    JetRecommendationsView()
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Light Card Content
    private var lightCardContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(JetStrings.shared.settings())
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                
                // Settings Group
                JetSettingsGroupCard {
                    lightSettingRow(icon: "creditcard.fill", title: JetStrings.shared.restorePurchase()) {
                        Task { await restorePurchases() }
                    }
                    Divider().padding(.leading, 68)
                    lightSettingRow(icon: "square.and.arrow.up", title: JetStrings.shared.shareToFriends()) {
                        shareApp()
                    }
                    Divider().padding(.leading, 68)
                    lightSettingRow(icon: "star.fill", title: JetStrings.shared.rateUs()) {
                        requestReview()
                    }
                }
                .padding(.horizontal, 20)
                
                // Legal Group
                JetSettingsGroupCard {
                    lightSettingRow(icon: "doc.text.fill", title: JetStrings.shared.termsOfUse()) {
                        JetSettingsActions.openURL(config.termsOfUseURL)
                    }
                    Divider().padding(.leading, 68)
                    lightSettingRow(icon: "lock.shield.fill", title: JetStrings.shared.privacyPolicy()) {
                        JetSettingsActions.openURL(config.privacyPolicyURL)
                    }
                    Divider().padding(.leading, 68)
                    lightSettingRow(icon: "envelope.fill", title: JetStrings.shared.feedback()) {
                        sendFeedback()
                    }
                }
                .padding(.horizontal, 20)
                
                // Recommendations
                JetRecommendationsView()
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Standard Content
    private var standardContent: some View {
        List {
            Section {
                standardRow(icon: "creditcard.fill", title: JetStrings.shared.restorePurchase()) {
                    Task { await restorePurchases() }
                }
                standardRow(icon: "square.and.arrow.up", title: JetStrings.shared.shareToFriends()) {
                    shareApp()
                }
                standardRow(icon: "star.fill", title: JetStrings.shared.rateUs()) {
                    requestReview()
                }
            }
            
            Section {
                standardRow(icon: "doc.text.fill", title: JetStrings.shared.termsOfUse()) {
                    JetSettingsActions.openURL(config.termsOfUseURL)
                }
                standardRow(icon: "lock.shield.fill", title: JetStrings.shared.privacyPolicy()) {
                    JetSettingsActions.openURL(config.privacyPolicyURL)
                }
                standardRow(icon: "envelope.fill", title: JetStrings.shared.feedback()) {
                    sendFeedback()
                }
            }
            
            Section(header: Text("App Recommendations")) {
                JetRecommendationsView()
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .navigationTitle(JetStrings.shared.settings())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        switch config.style {
        case .dark, .darkWithMembership:
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                }
                .padding(8)
            }
        case .lightCard:
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        case .standard:
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(JetStrings.shared.done()) {
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Section Header
    private var sectionHeader: some View {
        Text(JetStrings.shared.settings())
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.bottom, 4)
    }
    
    // MARK: - Background Color
    private var backgroundColor: Color {
        switch config.style {
        case .dark, .darkWithMembership:
            return .black
        case .lightCard:
            return Color(UIColor.systemGroupedBackground)
        case .standard:
            return Color(UIColor.systemBackground)
        }
    }
    
    // MARK: - Row Views
    private func settingRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .frame(height: 72)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.bottom, 16)
    }
    
    private func lightSettingRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Text(title)
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .frame(minHeight: 56)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
    
    private func standardRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(size: 17))
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Actions
    private func restorePurchases() async {
        restoreInProgress = true
        defer { restoreInProgress = false }
        
        do {
            try await AppStore.sync()
            showRestoreSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func shareApp() {
        JetSettingsActions.shareApp(text: config.shareText, appStoreURL: config.appStoreURL)
    }
    
    @MainActor
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
    
    private func sendFeedback() {
        JetSettingsActions.sendFeedbackEmail(
            to: config.feedbackEmail,
            subject: config.feedbackSubject,
            appName: config.appName
        )
    }
}

// MARK: - Preview
#if DEBUG
struct JetSimpleSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Dark Style
        JetSimpleSettingsView(config: JetAppConfig(
            appName: "TimeProof",
            appStoreURL: "https://apps.apple.com/app/id123456789",
            shareText: "Check out TimeProof!",
            privacyPolicyURL: "https://example.com/privacy",
            feedbackEmail: "support@example.com",
            style: .dark
        ))
        .previewDisplayName("Dark Style")
        
        // Light Card Style
        JetSimpleSettingsView(config: JetAppConfig(
            appName: "Awake",
            appStoreURL: "https://apps.apple.com/app/id123456789",
            shareText: "Check out Awake!",
            privacyPolicyURL: "https://example.com/privacy",
            feedbackEmail: "support@example.com",
            style: .lightCard
        ))
        .previewDisplayName("Light Card Style")
        
        // Standard Style
        JetSimpleSettingsView(config: JetAppConfig(
            appName: "DocScan",
            appStoreURL: "https://apps.apple.com/app/id123456789",
            shareText: "Check out DocScan!",
            privacyPolicyURL: "https://example.com/privacy",
            feedbackEmail: "support@example.com",
            style: .standard
        ))
        .previewDisplayName("Standard Style")
    }
}
#endif
