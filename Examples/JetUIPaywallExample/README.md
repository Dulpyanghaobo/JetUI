# JetUI Paywall Example

This example app shows the intended product-side integration shape:

```swift
JetPaywall(
    style: .timeline,
    content: .exampleTimeProofTrial,
    source: "jetui_example_trial",
    onSuccess: { ... }
)
```

## Run

Generate the Xcode project:

```sh
xcodegen generate --spec Examples/JetUIPaywallExample/project.yml --project Examples/JetUIPaywallExample
```

Open:

```sh
open Examples/JetUIPaywallExample/JetUIPaywallExample.xcodeproj
```

Run the `JetUIPaywallExample` scheme on an iOS simulator.

## StoreKit Products

The app configures these example product IDs:

- `jetui.example.weekly`
- `jetui.example.yearly`

To see real price rows, create a StoreKit Configuration file in Xcode with those two auto-renewable subscriptions in the same group, then select it from `Scheme > Edit Scheme > Run > Options > StoreKit Configuration`.

Without a StoreKit configuration, the paywall still renders the content, layout, loading, and empty/error states, but StoreKit will not return local products.
