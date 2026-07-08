import XCTest
@testable import JetUI

@MainActor
final class JetDependencyContainerTests: XCTestCase {
    override func tearDown() async throws {
        JetDI.reset()
        try await super.tearDown()
    }

    func testAppScopeReusesRegisteredInstance() {
        JetDI.register(Box.self) { Box(value: UUID()) }

        let first: Box = JetDI.resolve()
        let second: Box = JetDI.resolve()

        XCTAssertTrue(first === second)
    }

    func testTransientScopeCreatesNewInstanceEveryResolve() {
        JetDI.register(Box.self, scope: .transient) { Box(value: UUID()) }

        let first: Box = JetDI.resolve()
        let second: Box = JetDI.resolve()

        XCTAssertFalse(first === second)
        XCTAssertNotEqual(first.value, second.value)
    }

    private final class Box {
        let value: UUID

        init(value: UUID) {
            self.value = value
        }
    }
}

final class JetDateProviderTests: XCTestCase {
    func testSystemDateProviderUsesInjectedCalendarForDayAndWeekCalculations() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let provider = JetSystemDateProvider(calendar: calendar)
        let start = Date(timeIntervalSince1970: 1_704_067_200) // 2024-01-01 00:00 UTC
        let sameDay = Date(timeIntervalSince1970: 1_704_153_599) // 2024-01-01 23:59:59 UTC
        let later = Date(timeIntervalSince1970: 1_704_758_400) // 2024-01-09 00:00 UTC

        XCTAssertTrue(provider.isSameDay(start, sameDay))
        XCTAssertEqual(provider.daysBetween(start, later), 8)
        XCTAssertEqual(provider.daysBetween(later, start), 8)
        XCTAssertEqual(provider.weeksBetween(start, later), 1)
    }
}

@MainActor
final class JetReviewPrompterTests: XCTestCase {
    private var store: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "JetReviewPrompterTests-\(UUID().uuidString)"
        store = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        store.removePersistentDomain(forName: suiteName)
        store = nil
        suiteName = nil
        super.tearDown()
    }

    func testRequestIfAllowedRecordsPromptAndBlocksDuringCooldown() {
        var requestCount = 0
        var now = Date(timeIntervalSince1970: 1_704_067_200)
        let prompter = JetReviewPrompter(
            store: store,
            clock: { now },
            requestReview: { requestCount += 1; return true }
        )

        XCTAssertTrue(prompter.requestIfAllowed(cooldownDays: 7))
        XCTAssertFalse(prompter.requestIfAllowed(cooldownDays: 7))

        now.addTimeInterval(8 * 24 * 60 * 60)
        XCTAssertTrue(prompter.requestIfAllowed(cooldownDays: 7))
        XCTAssertEqual(requestCount, 2)
    }

    func testActionCompletedTriggersAfterThresholdAndResetsActionCount() {
        var requestCount = 0
        let prompter = JetReviewPrompter(
            store: store,
            clock: { Date(timeIntervalSince1970: 1_704_067_200) },
            requestReview: { requestCount += 1; return true }
        )

        prompter.photoSaved()
        prompter.photoSaved()
        XCTAssertEqual(requestCount, 0)

        prompter.photoSaved()
        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(store.integer(forKey: JetReviewPrompter.photoSaveCountKey), 0)
    }
}

@MainActor
final class JetOrientationManagerTests: XCTestCase {
    func testLockOrientationUpdatesPublishedOrientation() {
        let manager = JetOrientationManager(initialOrientation: .portrait)

        manager.lockOrientation(.landscape)

        XCTAssertEqual(manager.lockedOrientation, .landscape)
    }
}
