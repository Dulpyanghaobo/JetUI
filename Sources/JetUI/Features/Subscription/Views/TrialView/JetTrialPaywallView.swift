//
//  JetTrialPaywallView.swift
//  JetUI
//

import SwiftUI
import StoreKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 试用版 Paywall 视图 - 展示免费试用流程和价格选项
public struct JetTrialPaywallView: View {

    @Environment(\.dismiss) private var dismiss

    private var externalViewModel: JetPaywallViewModel?
    @StateObject private var internalViewModel = JetPaywallViewModel()

    private var vm: JetPaywallViewModel {
        externalViewModel ?? internalViewModel
    }

    @State private var didLogView = false
    @State private var restoreTapPending = false
    @State private var autoSelectedLogged = false // 新增：追踪是否已执行自动选中
    @State private var isShimmering = false
    @State private var fallbackSelectedPlanID = "weekly"

    private let config: JetTrialPaywallConfig
    private let onSuccess: () -> Void
    private let onDismiss: (() -> Void)?

    public init(
        viewModel: JetPaywallViewModel? = nil,
        config: JetTrialPaywallConfig,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        self.externalViewModel = viewModel
        self.config = config
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }

    public init(
        viewModel: JetPaywallViewModel? = nil,
        content: JetPaywallContent,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        self.externalViewModel = viewModel
        self.config = JetTrialPaywallConfig(from: content)
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }

    private func selectTrialPlanByDefault() {
        guard !autoSelectedLogged else { return }
        guard let preferred = vm.plans.first(where: { $0.trialBadge != nil && !$0.isYearly })
                ?? vm.plans.first(where: { $0.trialBadge != nil })
                ?? vm.plans.first(where: { !$0.isYearly })
                ?? vm.plans.first else { return }

        if vm.selectedProductID == nil || vm.plans.first(where: { $0.id == vm.selectedProductID })?.isYearly == true {
            vm.selectedProductID = preferred.id
        }
        autoSelectedLogged = true
    }

    public var body: some View {
        GeometryReader { proxy in
            let bottomInset = max(proxy.safeAreaInsets.bottom, 14)
            let contentMaxWidth: CGFloat = 560
            let bottomReserve = bottomInset + 132

            ZStack(alignment: .top) {
                timelineBackground

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        header

                        Text(config.trialTitle)
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .padding(.top, 18)
                            .padding(.horizontal, 10)

                        topContent
                            .padding(.top, 18)

                        priceOptions
                            .padding(.top, 18)

                        if let recovery = vm.recoveryState {
                            recoveryStateView(recovery)
                                .padding(.top, 14)
                        }

                        Color.clear
                            .frame(height: bottomReserve)
                    }
                    .frame(maxWidth: contentMaxWidth)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                }

                VStack(spacing: 0) {
                    renewalHint
                        .frame(height: 24, alignment: .center)

                    continueButton

                    legalLinks
                        .padding(.top, 2)
                }
                .frame(maxWidth: contentMaxWidth)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, bottomInset)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0), .black.opacity(0.94), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            }
            .task { selectTrialPlanByDefault() }
            .onChange(of: vm.plans) { _, _ in selectTrialPlanByDefault() }
        }
        .background(.black)
        .onChange(of: vm.shouldDismissPaywall) { _, ok in
            if ok {
                logSuccessEvent()
                onSuccess()
                dismiss()
            }
        }
        .onAppear {
            if !didLogView {
                didLogView = true
                // AnalyticsManager.logPaywallView(variant: "trial")
            }
        }
    }
}
// MARK: - Subviews

private extension JetTrialPaywallView {

    var timelineBackground: some View {
        LinearGradient(
            colors: [
                config.backgroundColor.opacity(0.96),
                config.backgroundColor.opacity(0.35),
                .black,
                .black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var header: some View {
        HStack {
            Button(action: {
                AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: [
                    "action": "dismiss",
                    "source": "header_close"
                ])
                onDismiss?()
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .padding(10)
            }
            .contentShape(Rectangle())

            Spacer()

            Button(config.restoreButtonTitle) {
                AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: ["action": "restore_tap"])
                restoreTapPending = true
                Task { await vm.restore() }
            }
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .padding(10)
            .disabled(vm.restoreInProgress)
            .opacity(vm.restoreInProgress ? 0.6 : 1)
        }
        .foregroundColor(.white)
    }

    @ViewBuilder
    var topContent: some View {
        if !config.trialSteps.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(config.trialSteps.enumerated()), id: \.offset) { index, step in
                    TimelineStepRow(
                        iconName: step.iconName,
                        title: step.title,
                        message: step.message,
                        accentColor: config.accentColor,
                        isFirst: index == 0,
                        isLast: index == config.trialSteps.count - 1
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(config.benefits, id: \.self) { benefit in
                    BenefitRow(
                        iconName: benefit.iconName,
                        title: benefit.title
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var priceOptions: some View {
        VStack(spacing: 12) {
            if vm.plans.isEmpty {
                fallbackPriceOptions
            } else {
                ForEach(orderedPlans) { plan in
                    TrialPriceOptionRow(
                        title: displayTitle(for: plan),
                        message: priceMessage(for: plan),
                        price: plan.priceText,
                        isSelected: vm.selectedProductID == plan.id,
                        cornerTag: calculateSaveTag(for: plan),
                        accentColor: config.accentColor
                    ) {
                        AnalyticsManager.logEvent(JetPaywallEvent.optionSelect, parameters: [
                            "plan_id": plan.id,
                            "title": plan.title
                        ])
                        vm.selectedProductID = plan.id
                    }
                }
            }
        }
    }

    var orderedPlans: [JetPlanDisplay] {
        let weeklyPlans = vm.plans.filter { $0.isWeekly }
        let yearlyPlans = vm.plans.filter { $0.isYearly }
        let otherPlans = vm.plans.filter { !$0.isWeekly && !$0.isYearly }
        return weeklyPlans + yearlyPlans + otherPlans
    }

    var fallbackPriceOptions: some View {
        VStack(spacing: 12) {
            TrialPriceOptionRow(
                title: SubL.Period.everyWeek,
                message: SubL.Trial.threeDayTrialCancelAnytime,
                price: vm.isLoading ? SubL.Button.loading : "--",
                isSelected: fallbackSelectedPlanID == "weekly",
                cornerTag: nil,
                accentColor: config.accentColor
            ) {
                fallbackSelectedPlanID = "weekly"
            }

            TrialPriceOptionRow(
                title: SubL.Period.everyYear,
                message: config.autoRenewalTip,
                price: vm.isLoading ? SubL.Button.loading : "--",
                isSelected: fallbackSelectedPlanID == "yearly",
                cornerTag: nil,
                accentColor: config.accentColor
            ) {
                fallbackSelectedPlanID = "yearly"
            }

            if !vm.isLoading {
                HStack(spacing: 10) {
                    Button(SubL.Button.retry) {
                        Task { await vm.load() }
                    }
                    .font(.footnote.weight(.semibold))

                    Button(config.restoreButtonTitle) {
                        restoreTapPending = true
                        Task { await vm.restore() }
                    }
                    .font(.footnote.weight(.semibold))
                }
                .foregroundColor(.white.opacity(0.72))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)
            }
        }
    }

    func displayTitle(for plan: JetPlanDisplay) -> String {
        if plan.isWeekly { return SubL.Period.everyWeek }
        if plan.isYearly { return SubL.Period.everyYear }
        return plan.title
    }

    func priceMessage(for plan: JetPlanDisplay) -> String {
        if let trialBadge = plan.trialBadge, !trialBadge.isEmpty {
            return SubL.Trial.threeDayTrialCancelAnytime
        }
        if let yearlyWeeklyMessage = yearlyWeeklyEquivalentMessage(for: plan) {
            return yearlyWeeklyMessage
        }
        return plan.promoBadge ?? plan.sublineText ?? ""
    }

    func yearlyWeeklyEquivalentMessage(for plan: JetPlanDisplay) -> String? {
        guard plan.isYearly,
              plan.product.price > 0 else { return nil }

        let weeklyPrice = plan.product.price / Decimal(52)
        return "\(SubL.Price.perWeek(weeklyPrice.formatted(plan.product.priceFormatStyle))), \(SubL.Legal.cancelAnytime)"
    }

    func recoveryStateView(_ recovery: JetPaywallRecoveryState) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(recovery.title)
                .font(.headline)
                .foregroundColor(.white)

            Text(recovery.message)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button(recovery.retryTitle) {
                    Task { await vm.purchaseSelected() }
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(config.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(recovery.restoreTitle) {
                    restoreTapPending = true
                    Task { await vm.restore() }
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.14))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    @ViewBuilder
    var renewalHint: some View {
        if let hint = vm.nextRenewalHint {
            Text(hint)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        } else {
            Text(" ")
                .font(.caption)
                .foregroundColor(.clear)
        }
    }

    var continueButton: some View {
        let isBusy = vm.isLoading || vm.restoreInProgress || (vm.purchaseInProgress != nil)
        let sel = vm.plans.first(where: { $0.id == vm.selectedProductID })

        return Button {
            AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: [
                "action": "continue_tap",
                "plan_id": sel?.id ?? "none",
                "title": sel?.title ?? ""
            ])
            Task { await vm.purchaseSelected() }
        } label: {
            let title: String = {
                if vm.plans.isEmpty && vm.isLoading { return SubL.Button.loading }
                if isBusy { return config.processingTitle }
                if let badge = sel?.trialBadge, !badge.isEmpty {
                    return SubL.Trial.threeDayTrialTitle
                }
                return config.continueButtonTitle
            }()

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.88))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(config.accentColor)

                        if !isBusy && vm.selectedProductID != nil {
                            shimmerEffect
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
        }
        .disabled(isBusy || vm.selectedProductID == nil)
        .opacity(isBusy || vm.selectedProductID == nil ? 0.6 : 1)
    }

    var shimmerEffect: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.2),
                            .white.opacity(0.5),
                            .white.opacity(0.2),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .frame(width: 80, height: geo.size.height * 3)
                .offset(x: isShimmering ? geo.size.width + 100 : -100)
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear {
                    isShimmering = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                            isShimmering = true
                        }
                    }
                }
        }
        .mask(RoundedRectangle(cornerRadius: 30))
        .allowsHitTesting(false)
    }

    var legalLinks: some View {
        let selected = vm.plans.first(where: { $0.id == vm.selectedProductID })
        let isLifetime = selected?.product.type == .nonConsumable
        let tip = isLifetime ? config.lifetimeTip : config.autoRenewalTip

        return VStack(spacing: 4) {
            Text(tip)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            HStack(spacing: 6) {
                Link(destination: config.privacyPolicyURL) {
                    Text(config.privacyPolicyTitle)
                }
                Text("·").foregroundColor(.white.opacity(0.4))
                Link(destination: config.termsURL) {
                    Text(config.termsTitle)
                }
            }
            .font(.footnote)
            .foregroundColor(.white)
        }
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    // MARK: - Helper Methods

    func calculateSaveTag(for plan: JetPlanDisplay) -> String? {
        guard plan.isYearly else { return nil }

        if let percent = vm.calculateSavePercentage(for: plan), percent > 0 {
            return String(format: config.savePercentFormat, percent)
        }
        return nil
    }

    func logSuccessEvent() {
        let sel = vm.plans.first(where: { $0.id == vm.selectedProductID })
        let action = restoreTapPending ? "restore_success" : "purchase_success"
        AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: [
            "action": action,
            "plan_id": sel?.id ?? "none",
            "title": sel?.title ?? ""
        ])
        restoreTapPending = false
    }
}

// MARK: - Timeline Step Row

private struct TimelineStepRow: View {
    let iconName: String
    let title: String
    let message: String?
    let accentColor: Color
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            TimelineColumn(
                iconName: iconName,
                accentColor: accentColor,
                isFirst: isFirst,
                isLast: isLast
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if let message = message, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 14.5, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.58))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 82)
    }
}

private struct TimelineColumn: View {
    let iconName: String
    let accentColor: Color
    var isFirst: Bool
    var isLast: Bool

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 8)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer(minLength: 0)
                }

                Spacer().frame(height: 50)

                if !isLast {
                    Rectangle()
                        .fill(isFirst ? accentColor : .white.opacity(0.22))
                        .frame(width: 8)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer(minLength: 0)
                }
            }

            ZStack {
                Circle()
                    .fill(isFirst ? accentColor : Color.white.opacity(0.12))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(isFirst ? 0 : 0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(isFirst ? 0.18 : 0.25), radius: 8, y: 4)

                PaywallIconImage(
                    name: iconName,
                    size: 26,
                    foregroundColor: isFirst ? .black : .white
                )
            }
            .frame(width: 50, height: 50)
        }
        .frame(width: 56)
    }
}

private struct TrialPriceOptionRow: View {
    let title: String
    let message: String
    let price: String
    let isSelected: Bool
    let cornerTag: String?
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    if !message.isEmpty {
                        highlightedMessage
                            .font(.system(size: 14.5, weight: .medium, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer(minLength: 10)

                Text(price)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(minHeight: 72)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? accentColor.opacity(0.22) : Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2.5)
            )
            .overlay(alignment: .topTrailing) {
                if let cornerTag, !cornerTag.isEmpty {
                    Text(cornerTag.uppercased())
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(accentColor))
                        .offset(y: -13)
                        .padding(.trailing, 0)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }

    private var highlightedMessage: Text {
        guard let commaIndex = message.firstIndex(of: ",") else {
            return Text(message).foregroundColor(.white.opacity(0.62))
        }

        let firstPart = String(message[..<commaIndex])
        let secondPart = String(message[commaIndex...])
        return Text(firstPart).foregroundColor(accentColor)
            + Text(secondPart).foregroundColor(.white.opacity(0.62))
    }
}

// MARK: - Benefit Row

private struct BenefitRow: View {
    let iconName: String
    let title: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            PaywallIconImage(name: iconName, size: 40, foregroundColor: .white)

            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(.white)

            Spacer()
        }
        .frame(minHeight: 44)
    }
}

private struct PaywallIconImage: View {
    let name: String
    let size: CGFloat
    let foregroundColor: Color

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(foregroundColor)
    }

    private var image: Image {
#if canImport(UIKit)
        if UIImage(named: name) != nil {
            return Image(name)
        }
#elseif canImport(AppKit)
        if NSImage(named: NSImage.Name(name)) != nil {
            return Image(name)
        }
#endif
        return Image(systemName: name)
    }
}

// MARK: - Configuration

/// 试用 Paywall 配置
public struct JetTrialPaywallConfig {

    // MARK: - Colors

    public let backgroundColor: Color
    public let accentColor: Color

    // MARK: - Titles

    public let trialTitle: String
    public let lifetimeTitle: String
    public let restoreButtonTitle: String
    public let continueButtonTitle: String
    public let processingTitle: String

    // MARK: - Tips

    public let autoRenewalTip: String
    public let lifetimeTip: String
    public let savePercentFormat: String

    // MARK: - Legal

    public let privacyPolicyURL: URL
    public let privacyPolicyTitle: String
    public let termsURL: URL
    public let termsTitle: String

    // MARK: - Trial Steps

    public let trialSteps: [TrialStep]

    // MARK: - Benefits

    public let benefits: [Benefit]

    // MARK: - Types

    public struct TrialStep {
        public let iconName: String
        public let title: String
        public let message: String?

        public init(iconName: String, title: String, message: String? = nil) {
            self.iconName = iconName
            self.title = title
            self.message = message
        }
    }

    public struct Benefit: Hashable {
        public let iconName: String
        public let title: String

        public init(iconName: String, title: String) {
            self.iconName = iconName
            self.title = title
        }
    }

    // MARK: - Initializer

    public init(
        backgroundColor: Color = Color(red: 0.2, green: 0.1, blue: 0.3),
        accentColor: Color = .orange,
        trialTitle: String = SubL.Title.howTrialWorks,
        lifetimeTitle: String = SubL.Title.unlimitedAccess,
        restoreButtonTitle: String = SubL.Button.restore,
        continueButtonTitle: String = SubL.Button.continue,
        processingTitle: String = SubL.Button.processing,
        autoRenewalTip: String = SubL.Legal.autoRenewalTip,
        lifetimeTip: String = SubL.Legal.lifetimeTip,
        savePercentFormat: String = "Save %d%%",
        privacyPolicyURL: URL = URL(string: "https://example.com/privacy")!,
        privacyPolicyTitle: String = SubL.Legal.privacyPolicy,
        termsURL: URL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
        termsTitle: String = SubL.Legal.termsConditions,
        trialSteps: [TrialStep] = [],
        benefits: [Benefit] = []
    ) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.trialTitle = trialTitle
        self.lifetimeTitle = lifetimeTitle
        self.restoreButtonTitle = restoreButtonTitle
        self.continueButtonTitle = continueButtonTitle
        self.processingTitle = processingTitle
        self.autoRenewalTip = autoRenewalTip
        self.lifetimeTip = lifetimeTip
        self.savePercentFormat = savePercentFormat
        self.privacyPolicyURL = privacyPolicyURL
        self.privacyPolicyTitle = privacyPolicyTitle
        self.termsURL = termsURL
        self.termsTitle = termsTitle
        self.trialSteps = trialSteps
        self.benefits = benefits
    }

    // MARK: - Conversion from JetPaywallContent

    /// 从 JetPaywallContent 创建配置
    /// - Parameter content: 统一的内容容器
    /// - Returns: JetTrialPaywallConfig 实例
    public init(from content: JetPaywallContent) {
        self.backgroundColor = content.backgroundColor
        self.accentColor = content.accentColor
        self.trialTitle = content.brandTitle
        self.lifetimeTitle = content.brandTitle
        self.restoreButtonTitle = content.restoreText
        self.continueButtonTitle = content.continueText
        self.processingTitle = content.processingText
        self.autoRenewalTip = SubL.Legal.autoRenewalTip
        self.lifetimeTip = SubL.Legal.lifetimeTip
        self.savePercentFormat = "Save %d%%"
        self.privacyPolicyURL = content.privacyPolicyURL ?? URL(string: "https://example.com/privacy")!
        self.privacyPolicyTitle = content.privacyText
        self.termsURL = content.termsURL ?? URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
        self.termsTitle = content.termsText

        // 转换 Timeline Steps
        self.trialSteps = content.timelineSteps.map { step in
            TrialStep(iconName: step.icon, title: step.title, message: step.subtitle)
        }

        // 转换 Benefits
        self.benefits = content.complexBenefits.map { benefit in
            Benefit(iconName: benefit.icon, title: benefit.title)
        }
    }
}
