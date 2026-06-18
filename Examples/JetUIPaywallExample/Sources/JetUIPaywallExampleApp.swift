//
//  JetUIPaywallExampleApp.swift
//  JetUIPaywallExample
//

import SwiftUI
import JetUI


private enum ExampleProducts {
    static let weekly = "jetui.example.weekly"
    static let yearly = "jetui.example.yearly"
    static let all = [weekly, yearly]
}

@main
@MainActor
struct JetUIPaywallExampleApp: App {
    init() {
        JetUI.configureAnalytics(enabled: false)
        JetUI.configureSubscription(
            JetSubscriptionConfig(
                productIds: ExampleProducts.all,
                proProductIds: Set(ExampleProducts.all),
                groupId: "jetui.example.pro",
                appIdentifier: "com.jetui.examples.paywall"
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            PaywallExampleHomeView()
        }
    }
}

private enum PaywallExampleScenario: String, CaseIterable, Identifiable {
    case trial
    case full

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trial: return "Trial Timeline"
        case .full: return "Full Paywall"
        }
    }

    var subtitle: String {
        switch self {
        case .trial:
            return "Timeline copy, benefits, links, and buttons from JetPaywallContent.exampleTimeProofTrial"
        case .full:
            return "List layout driven by JetPaywallContent.exampleTimeProofFull"
        }
    }

    var iconName: String {
        switch self {
        case .trial: return "calendar.badge.clock"
        case .full: return "list.bullet.rectangle.portrait"
        }
    }

    var style: JetPaywallStyle {
        switch self {
        case .trial: return .timeline
        case .full: return .list
        }
    }

    var content: JetPaywallContent {
        switch self {
        case .trial: return .exampleTimeProofTrial
        case .full: return .exampleTimeProofFull
        }
    }

    var source: String {
        "jetui_example_\(rawValue)"
    }
}

private struct PaywallExampleHomeView: View {
    @State private var selectedScenario: PaywallExampleScenario?
    @State private var lastEvent: String = "No purchase event yet"

    var body: some View {
        NavigationStack {
            List {
                Section("Paywall layouts") {
                    ForEach(PaywallExampleScenario.allCases) { scenario in
                        Button {
                            selectedScenario = scenario
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: scenario.iconName)
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scenario.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(scenario.subtitle)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
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
                    Text(lastEvent)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("JetUI Paywall")
            .fullScreenCover(item: $selectedScenario) { scenario in
                JetPaywall(
                    style: scenario.style,
                    content: scenario.content,
                    source: scenario.source,
                    onSuccess: {
                        lastEvent = "Success from \(scenario.source)"
                        selectedScenario = nil
                    },
                    onDismiss: {
                        lastEvent = "Dismissed from \(scenario.source)"
                        selectedScenario = nil
                    }
                )
                .ignoresSafeArea()
            }
        }
    }
}
