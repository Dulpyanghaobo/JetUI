//
//  JetUIModuleExamplesApp.swift
//  JetUIModuleExamples
//

import SwiftUI
import UIKit
import JetUI

private enum ExampleProducts {
    static let weekly = "jetui.example.weekly"
    static let yearly = "jetui.example.yearly"
    static let all = [weekly, yearly]
}

@main
@MainActor
struct JetUIModuleExamplesApp: App {
    init() {
        JetUI.configureLogger(subsystem: "com.jetui.examples.modules")
        JetUI.configureAnalytics(enabled: false)
        JetUI.configureSubscription(
            JetSubscriptionConfig(
                productIds: ExampleProducts.all,
                proProductIds: Set(ExampleProducts.all),
                groupId: "jetui.example.pro",
                appIdentifier: "com.jetui.examples.modules"
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ModuleCatalogHomeView()
        }
    }
}

private struct ModuleCatalogHomeView: View {
    private let modules = JetUIModuleExampleCatalog.modules

    var body: some View {
        NavigationStack {
            List(modules) { module in
                NavigationLink(value: module) {
                    ModuleRow(module: module)
                }
            }
            .navigationDestination(for: JetUIModuleExample.self) { module in
                ModuleDetailView(module: module)
            }
            .navigationTitle("JetUI Modules")
        }
    }
}

private struct ModuleRow: View {
    let module: JetUIModuleExample

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: module.systemImage)
                .font(.title2)
                .foregroundStyle(AppColor.brandPrimary)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 5) {
                Text(module.title)
                    .font(.headline)
                Text(module.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct ModuleDetailView: View {
    let module: JetUIModuleExample

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ModuleHeader(module: module)
                moduleContent
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var moduleContent: some View {
        switch module.id {
        case "auth":
            AuthModuleExampleView()
        case "components":
            ComponentsModuleExampleView()
        case "core":
            CoreModuleExampleView()
        case "extensions":
            ExtensionsModuleExampleView()
        case "features":
            FeaturesModuleExampleView()
        case "firebase":
            FirebaseModuleExampleView()
        case "models":
            ModelsModuleExampleView()
        case "network":
            NetworkModuleExampleView()
        case "resources":
            ResourcesModuleExampleView()
        case "theme":
            ThemeModuleExampleView()
        default:
            EmptyStateView(text: "No example is registered for this module.")
        }
    }
}

private struct ModuleHeader: View {
    let module: JetUIModuleExample

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: module.systemImage)
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(AppColor.brandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(AppFont.headingM)
                    Text(module.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            FlowLayout(items: module.examples) { title in
                Text(title)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ExampleSection<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SnippetView: View {
    let text: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(text)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct EmptyStateView: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(24)
    }
}

// MARK: - Auth

private struct AuthModuleExampleView: View {
    @ObservedObject private var auth = AuthManager.shared
    @State private var noncePreview = ""

    var body: some View {
        ExampleSection(title: "AuthManager state", subtitle: "Reads local authentication state without starting a real login flow.") {
            VStack(alignment: .leading, spacing: 10) {
                Label(auth.isLoggedIn ? "Logged in" : "Guest session", systemImage: auth.isLoggedIn ? "checkmark.seal.fill" : "person.crop.circle")
                Label("Plan tier: \(auth.currentPlanTier)", systemImage: "crown")
                Label("Device type: \(auth.deviceType)", systemImage: "iphone")
                Label("App version: \(auth.appVersion)", systemImage: "number")

                Button("Generate nonce preview") {
                    noncePreview = String(auth.randomNonceString(length: 12).prefix(12))
                }
                .buttonStyle(.borderedProminent)

                if !noncePreview.isEmpty {
                    Text("Nonce: \(noncePreview)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
        }

        ExampleSection(title: "Configuration snippet") {
            SnippetView(text:
"""
JetUI.configureAuth(MyAPIConfiguration())
let signed = try AuthManager.shared.signDERBase64(for: content)
AuthSession.shared.save(loginResult)
"""
            )
        }
    }
}

// MARK: - Components

private struct ComponentsModuleExampleView: View {
    @State private var switchOn = true
    @State private var pillSwitchOn = false
    @State private var showToast = false
    @State private var showInputAlert = false
    @State private var inputText = "JetUI"
    @State private var showCustomAlert = false

    var body: some View {
        ExampleSection(title: "Controls and feedback") {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Square switch")
                    Spacer()
                    JetCustomSwitch.square(isOn: $switchOn)
                }

                HStack {
                    Text("Pill switch")
                    Spacer()
                    JetCustomSwitch.pill(isOn: $pillSwitchOn)
                }

                HStack(spacing: 12) {
                    Button("Toast") { showToast = true }
                        .buttonStyle(.borderedProminent)
                    Button("Input Alert") { showInputAlert = true }
                        .buttonStyle(.bordered)
                    Button("Custom Alert") { showCustomAlert = true }
                        .buttonStyle(.bordered)
                }

                Text("Input: \(inputText)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .toast(message: "JetToastView is active", type: .success, isPresented: $showToast)
        .textFieldAlert(
            isPresented: $showInputAlert,
            title: "Module note",
            message: "Edit the local example text.",
            text: $inputText,
            placeholder: "Example text",
            action: {}
        )
        .overlay {
            if showCustomAlert {
                JetCustomAlertView(
                    config: JetAlertConfig(
                        title: "JetCustomAlertView",
                        message: "This is the reusable alert component.",
                        buttonTitle: "Close",
                        themeColor: AppColor.brandPrimary,
                        onPrimary: { showCustomAlert = false },
                        onClose: { showCustomAlert = false }
                    )
                )
            }
        }

        ExampleSection(title: "Glass and cached image") {
            ZStack {
                LinearGradient(
                    colors: [AppColor.accentBlue, AppColor.accentPurple, AppColor.accentGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("JetGlassBackground")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Blur, border, and card surface in one modifier.")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(16)
                    .glassBackground(cornerRadius: 12)

                    JetCacheAsyncImage(
                        url: URL(string: "https://example.com/icon.png"),
                        imageLoader: ExampleImageLoader(),
                        placeholder: Color.white.opacity(0.16),
                        contentMode: .fit
                    )
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
        }
    }
}

private final class ExampleImageLoader: JetImageLoader {
    func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        completion(UIImage(systemName: "photo.fill"))
    }
}

// MARK: - Core

private struct CoreModuleExampleView: View {
    @State private var cacheValue = "No cache read yet"
    @State private var guardedCounter = 0
    private let now = Date()

    var body: some View {
        ExampleSection(title: "Date and logger utilities") {
            VStack(alignment: .leading, spacing: 10) {
                Label(now.jet_format("yyyy-MM-dd HH:mm"), systemImage: "calendar")
                Label(JetDateFormatter.time.string(from: now), systemImage: "clock")
                Label("Logger subsystem: \(CSLogger.subsystem)", systemImage: "terminal")

                Button("Write sample log") {
                    CSLogger.info("Module example log", category: .ui)
                }
                .buttonStyle(.bordered)
            }
        }

        ExampleSection(title: "Cache and state helpers") {
            VStack(alignment: .leading, spacing: 12) {
                Text(cacheValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Set cache") {
                        CacheManager.shared.set(key: "module-example", value: "Cached at \(Date().jet_format("HH:mm:ss"))", ttl: 120)
                        cacheValue = "Cache written"
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Read cache") {
                        cacheValue = CacheManager.shared.get(key: "module-example", as: String.self) ?? "Cache miss"
                    }
                    .buttonStyle(.bordered)
                }

                Button("setIfChangedNoLog counter") {
                    var next = guardedCounter
                    if setIfChangedNoLog(&next, guardedCounter + 1) {
                        guardedCounter = next
                    }
                }
                .buttonStyle(.bordered)

                Text("Counter: \(guardedCounter)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Extensions

private struct ExtensionsModuleExampleView: View {
    @State private var highlighted = true

    var body: some View {
        ExampleSection(title: "View extensions") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Apply jet_if highlight", isOn: $highlighted)

                Text("Conditional modifier")
                    .font(.headline)
                    .padding()
                    .jet_if(highlighted) { view in
                        view
                            .foregroundStyle(.white)
                            .background(AppColor.brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .jet_if(!highlighted) { view in
                        view
                            .foregroundStyle(.primary)
                            .jet_border(Color.gray.opacity(0.35), cornerRadius: 10)
                    }

                Text("jet_fillMaxWidth + jet_cardShadow + jet_border")
                    .font(.footnote)
                    .padding()
                    .jet_fillMaxWidth(alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .jet_border(Color.blue.opacity(0.25), cornerRadius: 10)
                    .jet_cardShadow()
            }
        }

        ExampleSection(title: "Image extension snippet") {
            SnippetView(text:
"""
let resized = image.jet_resized(to: CGSize(width: 120, height: 120))
let tinted = image.jet_tinted(.blue)
let fixed = image.jet_fixedOrientation()
"""
            )
        }
    }
}

// MARK: - Features

private struct FeaturesModuleExampleView: View {
    @State private var selected = "Onboarding"
    @State private var showPaywall = false

    var body: some View {
        ExampleSection(title: "Feature screens") {
            Picker("Feature", selection: $selected) {
                Text("Onboarding").tag("Onboarding")
                Text("Settings").tag("Settings")
                Text("Paywall").tag("Paywall")
            }
            .pickerStyle(.segmented)

            switch selected {
            case "Onboarding":
                JetOnboardingView<EmptyView>(
                    pages: [
                        JetOnboardingPage(systemImage: "sparkles", title: "Reusable Onboarding", subtitle: "Use SF Symbols or app assets."),
                        JetOnboardingPage(systemImage: "rectangle.stack", title: "Composable Pages", subtitle: "Attach final pages such as a paywall.")
                    ],
                    configuration: JetOnboardingConfiguration(
                        accentColor: AppColor.brandPrimary,
                        continueButtonText: "Next",
                        finishButtonText: "Finish",
                        textColor: .white
                    ),
                    onFinish: {}
                )
                .frame(height: 520)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            case "Settings":
                JetSettingsView(configuration: sampleSettingsConfiguration)
                    .frame(height: 520)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

            default:
                VStack(alignment: .leading, spacing: 12) {
                    JetMembershipCardView(
                        configuration: .gradientCard(
                            title: "JetUI Pro",
                            subtitle: "Membership card and paywall examples",
                            onTap: { showPaywall = true }
                        )
                    )
                    Button("Open Paywall") {
                        showPaywall = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            JetPaywall(
                style: .timeline,
                content: .exampleTimeProofTrial,
                source: "module_examples",
                onDismiss: { showPaywall = false }
            )
            .ignoresSafeArea()
        }
    }

    private var sampleSettingsConfiguration: JetSettingsConfiguration {
        JetSettingsConfiguration.alarmAppStyle(
            title: "Module Settings",
            membershipCard: .gradientCard(
                title: "Example Pro",
                subtitle: "Preview a reusable membership card",
                onTap: {}
            ),
            sections: [
                JetSettingSection(
                    header: "General",
                    items: [
                        JetSettingsItemBuilder.restorePurchase(action: {}),
                        JetSettingsItemBuilder.shareApp(action: {}),
                        JetSettingsItemBuilder.feedback(action: {})
                    ]
                )
            ],
            footer: .fromBundle(appName: "JetUI Module Examples")
        )
    }
}

// MARK: - Firebase

private struct FirebaseModuleExampleView: View {
    @State private var lastEvent = "Analytics disabled for this example app"

    var body: some View {
        ExampleSection(title: "Analytics wrapper") {
            VStack(alignment: .leading, spacing: 12) {
                Text(lastEvent)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Log safe no-op event") {
                    AnalyticsManager.logEvent("module_example_tap", parameters: ["module": "firebase"])
                    lastEvent = "Called AnalyticsManager.logEvent with isEnabled = \(AnalyticsManager.isEnabled)"
                }
                .buttonStyle(.borderedProminent)

                SnippetView(text:
"""
JetUI.configureAnalytics(enabled: true)
AnalyticsManager.logEvent("screen_view", parameters: ["screen": "home"])
AnalyticsManager.setUserID(userId)
"""
                )
            }
        }

        ExampleSection(title: "Storage wrapper snippet") {
            SnippetView(text:
"""
let url = try await JetStorageManager.shared.uploadImage(
    image,
    filename: "captures/example.jpg"
)
"""
            )
        }
    }
}

// MARK: - Models

private struct ModelsModuleExampleView: View {
    @MainActor
    private var apps: [JetAppItem] {
        JetAppItem.companyApps
    }

    var body: some View {
        ExampleSection(title: "JetAppItem presets", subtitle: "These models feed settings recommendations and cross-promotion UI.") {
            VStack(spacing: 10) {
                ForEach(apps) { item in
                    HStack(spacing: 12) {
                        Image(item.localIconName ?? "TimeProof_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.subheadline.weight(.semibold))
                            Text(item.actionURL.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Network

private struct NetworkModuleExampleView: View {
    @State private var decodedMessage = "Not decoded yet"

    var body: some View {
        ExampleSection(title: "Auth session and API response") {
            VStack(alignment: .leading, spacing: 12) {
                Label(AuthSession.shared.isLoggedIn ? "Token present" : "No access token", systemImage: "key")
                Label("Base URL: \(AuthSession.shared.baseURL.absoluteString)", systemImage: "link")

                Button("Decode sample APIResponse") {
                    decodedMessage = decodeSampleResponse()
                }
                .buttonStyle(.borderedProminent)

                Text(decodedMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleSection(title: "Network configuration snippet") {
            SnippetView(text:
"""
JetUI.configureAccount(baseURL: apiURL) {
    AuthSession.shared.accessToken
}
let response = try JSONDecoder().decode(APIResponse<MyDTO>.self, from: data)
"""
            )
        }
    }

    private func decodeSampleResponse() -> String {
        struct SampleDTO: Decodable {
            let name: String
        }

        let data = Data(#"{"code":0,"message":"ok","data":{"name":"JetUI"}}"#.utf8)
        do {
            let response = try JSONDecoder().decode(APIResponse<SampleDTO>.self, from: data)
            return "Decoded code \(response.code), data \(response.data?.name ?? "-")"
        } catch {
            return "Decode failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Resources

private struct ResourcesModuleExampleView: View {
    private let assetNames = ["TimeProof_icon", "JetFax_icon", "JetScan_icon", "Alarm_icon", "findMe_icon", "TimeStamp_icon"]

    var body: some View {
        ExampleSection(title: "Bundled media assets") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 74), spacing: 12)], spacing: 12) {
                ForEach(assetNames, id: \.self) { name in
                    VStack(spacing: 8) {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text(name.replacingOccurrences(of: "_icon", with: ""))
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }

        ExampleSection(title: "Localized subscription strings") {
            VStack(alignment: .leading, spacing: 8) {
                Label(SubL.Title.unlockPro, systemImage: "lock.open")
                Label(SubL.Button.continue, systemImage: "arrow.right.circle")
                Label(SubL.Legal.privacyPolicy, systemImage: "hand.raised")
                Label(SubL.Benefit.noAds, systemImage: "xmark.circle")
            }
        }
    }
}

// MARK: - Theme

private struct ThemeModuleExampleView: View {
    private let swatches: [(String, Color)] = [
        ("Brand", AppColor.brandPrimary),
        ("Success", AppColor.statusSuccess),
        ("Warning", AppColor.statusWarning),
        ("Error", AppColor.statusError),
        ("Gold", AppColor.accentGold),
        ("Blue", AppColor.accentBlue),
        ("Green", AppColor.accentGreen),
        ("Purple", AppColor.accentPurple)
    ]

    var body: some View {
        ExampleSection(title: "Color tokens") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                ForEach(swatches, id: \.0) { name, color in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                            .frame(height: 44)
                        Text(name)
                            .font(.caption.weight(.semibold))
                    }
                }
            }
        }

        ExampleSection(title: "Typography and layout") {
            VStack(alignment: .leading, spacing: \.m) {
                Text("Display")
                    .font(AppFont.displayL)
                Text("Heading")
                    .font(AppFont.headingM)
                Text("Body text uses semantic spacing and radius helpers.")
                    .font(AppFont.bodyM)
                    .foregroundStyle(.secondary)

                HStack(spacing: \.m) {
                    Text("jetPadding")
                        .jetPadding(.horizontal, \.m)
                        .jetPadding(.vertical, \.s)
                        .jetBackground(AppColor.surfaceSecondary, radius: \.small)

                    JetIconButton(\.settings, color: AppColor.brandPrimary) {}
                    JetIconButton(\.close, color: AppColor.statusError) {}
                }
            }
        }
    }
}

// MARK: - Flow Layout

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        let rows = makeRows()
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private func makeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        for item in items {
            if rows[rows.count - 1].count >= 3 {
                rows.append([item])
            } else {
                rows[rows.count - 1].append(item)
            }
        }
        return rows
    }
}

#Preview("Module Catalog") {
    ModuleCatalogHomeView()
}
