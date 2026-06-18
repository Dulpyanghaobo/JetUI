//
//  JetUIExampleApp.swift
//  JetUIExampleApp
//
//  Unified example app: every JetUI module has an interactive example screen.
//  Tab 1 — Modules: catalog of all module examples (Auth, Components, Core, …)
//  Tab 2 — Paywall: StoreKit 2 paywall layouts (Trial Timeline, Full Paywall)
//

import SwiftUI
import UIKit
import JetUI

// MARK: - Entry Point

private enum ExampleProducts {
    static let weekly = "jetui.example.weekly"
    static let yearly = "jetui.example.yearly"
    static let all    = [weekly, yearly]
}

@main
@MainActor
struct JetUIExampleApp: App {
    init() {
        JetUI.configureLogger(subsystem: "com.jetui.examples.app")
        JetUI.configureAnalytics(enabled: false)
        JetUI.configureSubscription(
            JetSubscriptionConfig(
                productIds: ExampleProducts.all,
                proProductIds: Set(ExampleProducts.all),
                groupId: "jetui.example.pro",
                appIdentifier: "com.jetui.examples.app"
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

// MARK: - Root Tab

private struct RootTabView: View {
    var body: some View {
        TabView {
            ModuleCatalogTab()
                .tabItem { Label("Modules", systemImage: "square.grid.2x2") }

            PaywallTab()
                .tabItem { Label("Paywall", systemImage: "creditcard") }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Tab 1: Module Catalog
// ─────────────────────────────────────────────

private struct ModuleCatalogTab: View {
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
                Text(module.title).font(.headline)
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
        case "auth":        AuthExampleView()
        case "components":  ComponentsExampleView()
        case "core":        CoreExampleView()
        case "extensions":  ExtensionsExampleView()
        case "features":    FeaturesExampleView()
        case "firebase":    FirebaseExampleView()
        case "models":      ModelsExampleView()
        case "network":     NetworkExampleView()
        case "resources":   ResourcesExampleView()
        case "theme":       ThemeExampleView()
        default:            EmptyStateView(text: "No example registered for \(module.id).")
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
                    Text(module.title).font(AppFont.headingM)
                    Text(module.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            FlowTagsView(items: module.examples) { tag in
                Text(tag)
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

// ─────────────────────────────────────────────
// MARK: - Tab 2: Paywall
// ─────────────────────────────────────────────

private enum PaywallScenario: String, CaseIterable, Identifiable {
    case trial, full
    var id: String { rawValue }

    var title: String {
        switch self {
        case .trial: return "Trial Timeline"
        case .full:  return "Full Paywall"
        }
    }

    var subtitle: String {
        switch self {
        case .trial: return "JetPaywallContent.exampleTimeProofTrial — timeline layout"
        case .full:  return "JetPaywallContent.exampleTimeProofFull — list layout"
        }
    }

    var icon: String {
        switch self {
        case .trial: return "calendar.badge.clock"
        case .full:  return "list.bullet.rectangle.portrait"
        }
    }

    var style: JetPaywallStyle {
        switch self {
        case .trial: return .timeline
        case .full:  return .list
        }
    }

    var content: JetPaywallContent {
        switch self {
        case .trial: return .exampleTimeProofTrial
        case .full:  return .exampleTimeProofFull
        }
    }
}

private struct PaywallTab: View {
    @State private var active: PaywallScenario?
    @State private var lastEvent = "No purchase event yet"

    var body: some View {
        NavigationStack {
            List {
                Section("Paywall layouts") {
                    ForEach(PaywallScenario.allCases) { scenario in
                        Button { active = scenario } label: {
                            HStack(spacing: 12) {
                                Image(systemName: scenario.icon)
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scenario.title).font(.headline).foregroundStyle(.primary)
                                    Text(scenario.subtitle).font(.footnote).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }

                Section("Example product IDs") {
                    Text(ExampleProducts.weekly)
                    Text(ExampleProducts.yearly)
                }

                Section("Last callback") {
                    Text(lastEvent).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Paywall")
            .fullScreenCover(item: $active) { scenario in
                JetPaywall(
                    style: scenario.style,
                    content: scenario.content,
                    source: "jetui_example_\(scenario.rawValue)",
                    onSuccess: {
                        lastEvent = "✅ Success — \(scenario.title)"
                        active = nil
                    },
                    onDismiss: {
                        lastEvent = "↩︎ Dismissed — \(scenario.title)"
                        active = nil
                    }
                )
                .ignoresSafeArea()
            }
        }
    }
}

// ═════════════════════════════════════════════
// MARK: - Module Example Views
// ═════════════════════════════════════════════

// MARK: Auth

private struct AuthExampleView: View {
    @ObservedObject private var auth = AuthManager.shared
    @State private var nonce = ""

    var body: some View {
        ExampleSection(title: "Auth state", subtitle: "Reads local state — no network call.") {
            VStack(alignment: .leading, spacing: 10) {
                Label(
                    auth.isLoggedIn ? "Logged in" : "Guest session",
                    systemImage: auth.isLoggedIn ? "checkmark.seal.fill" : "person.crop.circle"
                )
                Label("Plan tier: \(auth.currentPlanTier)", systemImage: "crown")
                Label("Device type: \(auth.deviceType)", systemImage: "iphone")
                Label("App version: \(auth.appVersion)", systemImage: "number")
                Label("Device ID prefix: \(String(auth.deviceId.prefix(8)))…", systemImage: "cpu")

                Button("Generate nonce (12 chars)") {
                    nonce = auth.randomNonceString(length: 12)
                }
                .buttonStyle(.borderedProminent)

                if !nonce.isEmpty {
                    SnippetView(text: "Nonce: \(nonce)")
                }
            }
        }

        ExampleSection(title: "Apple Sign-In flow") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(JetAuthExamples.appleSignInFlow, id: \.step) { step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(step.step)")
                            .font(.caption.weight(.bold))
                            .frame(width: 22, height: 22)
                            .background(AppColor.brandPrimary)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.title).font(.subheadline.weight(.semibold))
                            Text(step.detail).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }

        ExampleSection(title: "Keychain keys") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(JetAuthExamples.keychainKeys, id: \.key) { info in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(info.key).font(.caption.monospaced()).foregroundStyle(AppColor.brandPrimary)
                        Text(info.description).font(.caption).foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }

        ExampleSection(title: "Configuration snippet") {
            SnippetView(text:
"""
JetUI.configureAuth(MyAPIConfiguration())
AuthManager.shared.configureAppleRequest(request)
AuthManager.shared.saveLoginResult(loginResult)
"""
            )
        }
    }
}

// MARK: Components

private struct ComponentsExampleView: View {
    @State private var squareOn = true
    @State private var pillOn = false
    @State private var showToast = false
    @State private var toastConfig = JetToastExamples.successSaved
    @State private var showInput = false
    @State private var inputText = "JetUI"
    @State private var showAlert = false

    var body: some View {
        ExampleSection(title: "Switches") {
            VStack(spacing: 14) {
                HStack {
                    Text("Square switch")
                    Spacer()
                    JetCustomSwitch.square(isOn: $squareOn)
                }
                HStack {
                    Text("Pill switch")
                    Spacer()
                    JetCustomSwitch.pill(isOn: $pillOn)
                }
            }
        }

        ExampleSection(title: "Toast notifications") {
            VStack(alignment: .leading, spacing: 10) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(JetToastExamples.all, id: \.message) { cfg in
                            Button(cfg.type == .success ? "Success" :
                                   cfg.type == .error   ? "Error"   :
                                   cfg.type == .warning ? "Warning" : "Info"
                            ) {
                                toastConfig = cfg
                                showToast = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .toast(message: toastConfig.message, type: toastConfig.type, isPresented: $showToast, duration: toastConfig.duration)

        ExampleSection(title: "Alerts") {
            HStack(spacing: 12) {
                Button("Input Alert") { showInput = true }.buttonStyle(.bordered)
                Button("Custom Alert") { showAlert = true }.buttonStyle(.bordered)
            }
            if !inputText.isEmpty {
                Text("Input: \(inputText)").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .textFieldAlert(
            isPresented: $showInput,
            title: "Edit example text",
            message: "Type anything and confirm.",
            text: $inputText,
            placeholder: "Example text",
            action: {}
        )
        .overlay {
            if showAlert {
                JetCustomAlertView(
                    config: JetAlertConfig(
                        title: "JetCustomAlertView",
                        message: "Fully customisable alert with branded colours.",
                        buttonTitle: "Close",
                        themeColor: AppColor.brandPrimary,
                        onPrimary: { showAlert = false },
                        onClose: { showAlert = false }
                    )
                )
            }
        }

        ExampleSection(title: "Glass background + cached image") {
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
                            .font(.headline).foregroundStyle(.white)
                        Text("Blur, border, surface in one modifier.")
                            .font(.footnote).foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(14)
                    .glassBackground(cornerRadius: 12)

                    JetCacheAsyncImage(
                        url: URL(string: "https://picsum.photos/seed/jet/72/72"),
                        imageLoader: SystemSymbolLoader(),
                        placeholder: Color.white.opacity(0.18),
                        contentMode: .fill
                    )
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
        }
    }
}

private final class SystemSymbolLoader: JetImageLoader {
    func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        completion(UIImage(systemName: "photo.fill"))
    }
}

// MARK: Core

private struct CoreExampleView: View {
    @State private var cacheHit = "Not read yet"
    @State private var counter = 0
    private let now = Date()

    var body: some View {
        ExampleSection(title: "Date utilities") {
            VStack(alignment: .leading, spacing: 10) {
                Label(now.jet_format("yyyy-MM-dd"), systemImage: "calendar")
                Label(now.jet_format("HH:mm:ss"), systemImage: "clock")
                Label(JetDateFormatter.time.string(from: now), systemImage: "clock.badge")

                ForEach(JetDateExamples.iso8601Strings, id: \.self) { iso in
                    Text(iso).font(.caption.monospaced()).foregroundStyle(.secondary)
                }
            }
        }

        ExampleSection(title: "Logger") {
            VStack(alignment: .leading, spacing: 10) {
                Label("Subsystem: \(CSLogger.subsystem)", systemImage: "terminal")
                ForEach(JetLoggerExamples.samples, id: \.message) { s in
                    HStack(spacing: 8) {
                        Text("[\(s.level)]")
                            .font(.caption.monospaced())
                            .foregroundStyle(s.level == "warning" ? .orange : .secondary)
                        Text(s.message).font(.caption).foregroundStyle(.primary)
                    }
                }
                Button("Write log (UI category)") {
                    CSLogger.info("Module example tap", category: .ui)
                }
                .buttonStyle(.bordered)
            }
        }

        ExampleSection(title: "CacheManager") {
            VStack(alignment: .leading, spacing: 12) {
                Text(cacheHit).font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    Button("Set (TTL 120 s)") {
                        CacheManager.shared.set(
                            key: JetCacheExamples.keys.userPrefs,
                            value: JetCacheExamples.examplePreferences,
                            ttl: JetCacheExamples.shortTTL
                        )
                        cacheHit = "Written"
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Read") {
                        let v = CacheManager.shared.get(
                            key: JetCacheExamples.keys.userPrefs,
                            as: JetCacheExamples.UserPreferences.self
                        )
                        cacheHit = v.map { "Hit — userId: \($0.userId)" } ?? "Cache miss"
                    }
                    .buttonStyle(.bordered)

                    Button("Clear") {
                        CacheManager.shared.clearAll()
                        cacheHit = "Cleared"
                    }
                    .buttonStyle(.bordered)
                }

                let stats = CacheManager.shared.statistics()
                Text("Entries: \(stats.validEntries) valid / \(stats.totalEntries) total · \(String(format: "%.1f", stats.memorySizeKB)) KB")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }

        ExampleSection(title: "Circuit breaker configs") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(JetCircuitBreakerExamples.all, id: \.name) { cfg in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cfg.name).font(.subheadline.weight(.semibold))
                        Text("Threshold: \(cfg.failureThreshold) · Reset: \(Int(cfg.resetTimeout))s")
                            .font(.caption.monospaced()).foregroundStyle(AppColor.brandPrimary)
                        Text(cfg.description).font(.caption).foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }
    }
}

// MARK: Extensions

private struct ExtensionsExampleView: View {
    @State private var highlighted = true

    var body: some View {
        ExampleSection(title: "View extensions — live demo") {
            VStack(alignment: .leading, spacing: 14) {
                Toggle("jet_if highlight", isOn: $highlighted)

                Text("Conditional modifier")
                    .font(.headline)
                    .padding()
                    .jet_if(highlighted) { $0.foregroundStyle(.white).background(AppColor.brandPrimary).clipShape(RoundedRectangle(cornerRadius: 10)) }
                    .jet_if(!highlighted) { $0.foregroundStyle(.primary).jet_border(Color.gray.opacity(0.35), cornerRadius: 10) }

                Text("jet_fillMaxWidth + jet_cardShadow + jet_border")
                    .font(.footnote)
                    .padding()
                    .jet_fillMaxWidth(alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .jet_border(Color.blue.opacity(0.25), cornerRadius: 10)
                    .jet_cardShadow()
            }
        }

        ExampleSection(title: "View extension catalog") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(JetExtensionExamples.viewSnippets, id: \.title) { s in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.title).font(.subheadline.weight(.semibold)).foregroundStyle(AppColor.brandPrimary)
                        Text(s.description).font(.caption).foregroundStyle(.secondary)
                        SnippetView(text: s.code)
                    }
                }
            }
        }

        ExampleSection(title: "UIImage extension catalog") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(JetExtensionExamples.imageSnippets, id: \.title) { s in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.title).font(.subheadline.weight(.semibold)).foregroundStyle(AppColor.brandPrimary)
                        Text(s.description).font(.caption).foregroundStyle(.secondary)
                        SnippetView(text: s.code)
                    }
                }
            }
        }
    }
}

// MARK: Features

private struct FeaturesExampleView: View {
    @State private var selectedFeature = "Onboarding"
    @State private var showPaywall = false

    private let features = ["Onboarding", "Settings", "Paywall"]

    var body: some View {
        ExampleSection(title: "Feature screens") {
            Picker("Feature", selection: $selectedFeature) {
                ForEach(features, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.segmented)

            switch selectedFeature {
            case "Onboarding":
                JetOnboardingView<EmptyView>(
                    pages: JetOnboardingExamples.examplePages,
                    configuration: .exampleDark,
                    onFinish: {}
                )
                .frame(height: 520)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            case "Settings":
                JetSettingsView(configuration: JetSettingsConfiguration.exampleDark())
                    .frame(height: 520)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

            default:
                VStack(alignment: .leading, spacing: 14) {
                    JetMembershipCardView(
                        configuration: .gradientCard(
                            title: "JetUI Pro",
                            subtitle: "Unlock all premium features",
                            onTap: { showPaywall = true }
                        )
                    )
                    Button("Open Trial Paywall") { showPaywall = true }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            JetPaywall(
                style: .timeline,
                content: .exampleTimeProofTrial,
                source: "features_example",
                onDismiss: { showPaywall = false }
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: Firebase

private struct FirebaseExampleView: View {
    @State private var lastLog = "Analytics disabled — all calls are no-ops."

    var body: some View {
        ExampleSection(title: "Analytics events") {
            VStack(alignment: .leading, spacing: 12) {
                Text(lastLog).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(JetFirebaseExamples.analyticsEvents, id: \.eventName) { e in
                        Button(e.eventName) {
                            AnalyticsManager.logEvent(e.eventName, parameters: e.parameters.mapValues { $0 as Any })
                            lastLog = "Fired: \(e.eventName)\n\(e.description)"
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                }
            }
        }

        ExampleSection(title: "User properties") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(JetFirebaseExamples.userProperties, id: \.name) { p in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(p.name).font(.caption.monospaced()).foregroundStyle(AppColor.brandPrimary)
                        Text("Example: \(p.exampleValue) · \(p.description)").font(.caption).foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }

        ExampleSection(title: "Storage paths") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(JetFirebaseExamples.storagePaths, id: \.path) { p in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(p.path).font(.caption.monospaced()).foregroundStyle(AppColor.brandPrimary).fixedSize(horizontal: false, vertical: true)
                        Text(p.description).font(.caption).foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }

        ExampleSection(title: "Storage snippet") {
            SnippetView(text:
"""
let url = try await JetStorageManager.shared.uploadImage(
    image, filename: "captures/photo.jpg"
)
"""
            )
        }
    }
}

// MARK: Models

private struct ModelsExampleView: View {
    @MainActor
    private var apps: [JetAppItem] { JetAppItem.companyApps }

    var body: some View {
        ExampleSection(title: "JetAppItem — company presets") {
            VStack(spacing: 10) {
                ForEach(apps) { item in
                    HStack(spacing: 12) {
                        Image(item.localIconName ?? "photo")
                            .resizable().scaledToFit()
                            .frame(width: 42, height: 42)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name).font(.subheadline.weight(.semibold))
                            Text(item.actionURL.absoluteString)
                                .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.tertiary).font(.caption)
                    }
                }
            }
        }

        ExampleSection(title: "Usage notes") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(JetModelsExamples.notes, id: \.title) { note in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(note.title).font(.subheadline.weight(.semibold))
                        Text(note.detail).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    }
                    Divider()
                }
            }
        }
    }
}

// MARK: Network

private struct NetworkExampleView: View {
    @State private var decodeResult = "Tap to decode"

    var body: some View {
        ExampleSection(title: "APIResponse decode") {
            VStack(alignment: .leading, spacing: 12) {
                Text(decodeResult).font(.subheadline).foregroundStyle(.secondary)

                Button("Decode sample JSON") { decodeResult = decodeSample() }
                    .buttonStyle(.borderedProminent)

                SnippetView(text: #"{"code":200,"message":"ok","data":{"name":"JetUI"}}"#)
            }
        }

        ExampleSection(title: "Auth session state") {
            VStack(alignment: .leading, spacing: 10) {
                Label(
                    AuthSession.shared.isLoggedIn ? "Token present" : "No access token",
                    systemImage: "key"
                )
                Label("Base URL: \(AuthSession.shared.baseURL.absoluteString)", systemImage: "link")
            }
        }

        ExampleSection(title: "Error scenarios") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(JetNetworkExamples.scenarios, id: \.statusCode) { s in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(s.statusCode)")
                            .font(.caption.weight(.bold).monospaced())
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 22)
                            .background(s.statusCode >= 500 ? Color.red : Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.name).font(.subheadline.weight(.semibold))
                            Text(s.description).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Divider()
                }
            }
        }

        ExampleSection(title: "Configuration snippet") {
            SnippetView(text:
"""
JetUI.configureAuth(MyAPIConfig())
JetUI.configureAccount(baseURL: apiURL) {
    AuthSession.shared.accessToken
}
let result: MyDTO? = try await NetworkCore.shared.api(
    AuthTarget.userInfo, MyDTO.self
)
"""
            )
        }
    }

    private func decodeSample() -> String {
        struct DTO: Decodable { let name: String }
        let data = Data(#"{"code":200,"message":"ok","data":{"name":"JetUI"}}"#.utf8)
        do {
            let r = try JSONDecoder().decode(APIResponse<DTO>.self, from: data)
            return "code \(r.code) · data.name = \(r.data?.name ?? "-")"
        } catch {
            return "Decode error: \(error.localizedDescription)"
        }
    }
}

// MARK: Resources

private struct ResourcesExampleView: View {
    private let assets = ["TimeProof_icon", "JetFax_icon", "JetScan_icon",
                          "Alarm_icon", "findMe_icon", "TimeStamp_icon"]

    var body: some View {
        ExampleSection(title: "Bundled app icons") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 74), spacing: 12)], spacing: 12) {
                ForEach(assets, id: \.self) { name in
                    VStack(spacing: 6) {
                        Image(name).resizable().scaledToFit()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text(name.replacingOccurrences(of: "_icon", with: ""))
                            .font(.caption2).lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }

        ExampleSection(title: "Localized subscription strings") {
            VStack(alignment: .leading, spacing: 8) {
                Label(SubL.Title.unlockPro,       systemImage: "lock.open")
                Label(SubL.Button.continue,       systemImage: "arrow.right.circle")
                Label(SubL.Legal.privacyPolicy,   systemImage: "hand.raised")
                Label(SubL.Benefit.noAds,         systemImage: "xmark.circle")
            }
        }
    }
}

// MARK: Theme

private struct ThemeExampleView: View {
    private let swatches: [(String, Color)] = [
        ("Brand",   AppColor.brandPrimary),
        ("Success", AppColor.statusSuccess),
        ("Warning", AppColor.statusWarning),
        ("Error",   AppColor.statusError),
        ("Gold",    AppColor.accentGold),
        ("Blue",    AppColor.accentBlue),
        ("Green",   AppColor.accentGreen),
        ("Purple",  AppColor.accentPurple),
    ]

    var body: some View {
        ExampleSection(title: "Color tokens") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                ForEach(swatches, id: \.0) { name, color in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 8).fill(color).frame(height: 44)
                        Text(name).font(.caption.weight(.semibold))
                    }
                }
            }
        }

        ExampleSection(title: "Typography scale") {
            VStack(alignment: .leading, spacing: 8) {
                Text("displayL — Hero").font(AppFont.displayL).lineLimit(1)
                Text("headingM — Section").font(AppFont.headingM)
                Text("bodyM — Body copy uses semantic spacing and radius tokens.")
                    .font(AppFont.bodyM).foregroundStyle(.secondary)
                Text("caption — Fine print").font(AppFont.caption).foregroundStyle(.tertiary)
            }
        }

        ExampleSection(title: "Layout helpers") {
            VStack(alignment: .leading, spacing: \.m) {
                HStack(spacing: \.m) {
                    Text("jetPadding")
                        .jetPadding(.horizontal, \.m)
                        .jetPadding(.vertical, \.s)
                        .jetBackground(AppColor.surfaceSecondary, radius: \.small)
                    JetIconButton(\.settings, color: AppColor.brandPrimary) {}
                    JetIconButton(\.close, color: AppColor.statusError) {}
                }
                Text("Custom ExampleTheme (purple brand):")
                    .font(.caption).foregroundStyle(.secondary)
                Text("ExampleTheme()")
                    .font(.caption.monospaced())
                    .padding(8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Shared UI Helpers
// ─────────────────────────────────────────────

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
                Text(title).font(.headline)
                if let subtitle {
                    Text(subtitle).font(.footnote).foregroundStyle(.secondary)
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

private struct FlowTagsView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(makeRows().enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in content(item) }
                }
            }
        }
    }

    private func makeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        for item in items {
            if rows[rows.count - 1].count >= 3 { rows.append([item]) }
            else { rows[rows.count - 1].append(item) }
        }
        return rows
    }
}
