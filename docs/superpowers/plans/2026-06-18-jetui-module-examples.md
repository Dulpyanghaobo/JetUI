# JetUI Module Examples Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an iOS example catalog that lets JetUI modules be opened and tested from one place.

**Architecture:** Add a lightweight, public module example registry in JetUI so tests and example apps share the same module list. Add an independent XcodeGen iOS example app under `Examples/JetUIModuleExamples` that imports JetUI and renders one sample page per top-level module.

**Tech Stack:** Swift 5.9, SwiftUI, XCTest, Swift Package Manager, XcodeGen.

---

### Task 1: Module Registry

**Files:**
- Create: `Sources/JetUI/Examples/JetUIModuleExampleCatalog.swift`
- Test: `Tests/JetUITests/JetUIModuleExampleCatalogTests.swift`

- [ ] Write a failing XCTest that asserts the catalog contains Auth, Components, Core, Extensions, Features, Firebase, Models, Network, Resources, and Theme.
- [ ] Run `GIT_CONFIG_GLOBAL=/dev/null swift test --filter JetUIModuleExampleCatalogTests` and verify the new symbol is missing or package resolution blocks before implementation.
- [ ] Implement `JetUIModuleExampleCatalog` with stable module IDs, titles, descriptions, and example names.
- [ ] Re-run the test or the strongest available local verification.

### Task 2: Module Example App

**Files:**
- Create: `Examples/JetUIModuleExamples/project.yml`
- Create: `Examples/JetUIModuleExamples/Sources/JetUIModuleExamplesApp.swift`
- Create: `Examples/JetUIModuleExamples/README.md`

- [ ] Create an iOS app target that depends on the local JetUI package.
- [ ] Build a `NavigationStack` list from `JetUIModuleExampleCatalog.modules`.
- [ ] Add module-specific SwiftUI sample sections for Components, Core, Extensions, Features, Models, Resources, and Theme.
- [ ] Add safe configuration/code sample sections for Auth, Network, and Firebase without making real external calls.
- [ ] Generate the Xcode project with `xcodegen generate --spec Examples/JetUIModuleExamples/project.yml --project Examples/JetUIModuleExamples`.
- [ ] Run parse/project checks and document any full-build blocker.
