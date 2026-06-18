# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

JetUI is a reusable iOS SwiftUI component library (Swift Package) extracted from the TimeProof app. It targets iOS 17+ and is consumed by host apps as a local Swift package dependency.

## Commands

**Build / test the package (terminal):**
```sh
swift build
swift test
# Run a single test class:
swift test --filter JetPaywallExampleContentTests
```

**Regenerate an example Xcode project (required after editing `project.yml`):**
```sh
xcodegen generate --spec Examples/JetUIPaywallExample/project.yml --project Examples/JetUIPaywallExample
xcodegen generate --spec Examples/JetUIModuleExamples/project.yml --project Examples/JetUIModuleExamples
```

**Open an example app:**
```sh
open Examples/JetUIPaywallExample/JetUIPaywallExample.xcodeproj
open Examples/JetUIModuleExamples/JetUIModuleExamples.xcodeproj
```

> After opening a regenerated project, Xcode may show "An inconsistency was found … will be automatically corrected." — click OK, it is harmless.

## Architecture

### Layer overview

```
Host App (TimeProof, PetPal, …)
    └─ JetUI (Swift Package)
          ├─ Theme/          – Protocol-based theme injection (JetThemeConfig)
          ├─ Core/           – Logger, Cache, CircuitBreaker, MemoryMonitor, Utilities
          ├─ Components/     – Stateless SwiftUI building blocks (Toast, Alert, Glass, …)
          ├─ Network/        – Moya-backed NetworkCore, Auth, Account services
          ├─ Auth/           – AuthManager (token lifecycle)
          ├─ Firebase/       – Analytics + Storage wrappers
          ├─ Features/
          │     ├─ Subscription/  – StoreKit 2 full-stack (config → service → VM → views)
          │     ├─ Settings/      – Configurable settings page
          │     └─ Onboarding/    – Paginated onboarding view
          ├─ Models/         – Shared value types (JetAppItem)
          └─ Extensions/     – UIImage+Jet, View+Jet
```

### Theme system

Host apps inject a `JetThemeConfig` implementation at startup; internal code accesses it via `JetUI.theme`. The protocol hierarchy is:

```
JetThemeConfig
  ├─ colors:  JetColorPalette   (brandPrimary, backgroundPrimary, textPrimary, …)
  ├─ fonts:   JetTypography     (displayXXL … footnote)
  └─ layout:  JetLayoutConfig
                ├─ spacing: JetSpacing  (xs/s/m/l/xl/xxl)
                ├─ radius:  JetRadius   (small/medium/large/pill)
                └─ icons:   JetIcons
```

`DefaultTheme` is used when no custom theme is provided. `AppColor` and `AppFont` are convenience accessors that delegate to `JetUI.theme`.

### Subscription module

The public entry point is `JetPaywall` (`Features/Subscription/Views/JetPaywall.swift`). It dispatches to either `JetPaywallView` (`.list` style) or `JetTrialPaywallView` (`.timeline` style) based on a `JetPaywallStyle` enum.

Content is separated from style via `JetPaywallContent`. Example presets live in `JetPaywallContent+Presets` (used by both tests and example apps).

The subscription stack:
- `JetSubscriptionConfig` — product IDs, group ID, app identifier
- `JetStoreService` — StoreKit 2 fetch/purchase, calls backend `bindSubscription` internally
- `JetSubscriptionManager` — observable `isPro` state, wraps `JetTransactionObserver`
- `JetPaywallViewModel` — drives both paywall views; host app configures it via `JetUI.configureSubscription(_:)`

### Network layer

`NetworkCore` wraps Moya. Callers use `NetworkCore.shared.api(_:_:)`. Auth tokens are managed by `AuthSession` and injected via `NetworkCore.shared.authSession`. `AccountService` handles subscription backend binding.

### Naming convention

All public types are prefixed with `Jet` (e.g., `JetToastView`, `JetStoreService`). File names match type names.

## Example Apps

| App | Purpose |
|---|---|
| `JetUIPaywallExample` | Integration test for the paywall flow; needs a StoreKit Configuration file for real price rows |
| `JetUIModuleExamples` | Module catalog — one screen per top-level Sources/JetUI folder; Auth/Network/Firebase screens avoid real network calls |

## App Startup Configuration

```swift
// Typical host-app init()
JetUI.configureTheme(MyAppTheme())
JetUI.configureLogger(subsystem: Bundle.main.bundleIdentifier!)
JetUI.configureAnalytics(enabled: true)
JetUI.configureAuth(MyAPIConfig())
JetUI.configureAccount(baseURL: apiURL, tokenProvider: { AuthManager.shared.token })
JetUI.configureSubscription(
    JetSubscriptionConfig(
        productIds: [...],
        proProductIds: [...],
        groupId: "...",
        appIdentifier: "..."
    )
)
```
