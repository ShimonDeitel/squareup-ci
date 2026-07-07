import XCTest
@testable import Squareup

final class SquareupTests: XCTestCase {
    func testRoundUpForNonWholeAmount() {
        let entry = RoundUpEntry(purchaseLabel: "Coffee", purchaseAmount: 4.35, date: Date())
        XCTAssertEqual(entry.roundUpAmount, 0.65, accuracy: 0.001)
    }

    func testRoundUpForWholeDollarAmountAddsFullDollar() {
        let entry = RoundUpEntry(purchaseLabel: "Snack", purchaseAmount: 5.00, date: Date())
        XCTAssertEqual(entry.roundUpAmount, 1.0, accuracy: 0.001)
    }

    func testJarTotalSumsRoundUps() {
        var jar = Jar(name: "Test", goalAmount: 10)
        jar.entries = [
            RoundUpEntry(purchaseLabel: "A", purchaseAmount: 1.25, date: Date()),
            RoundUpEntry(purchaseLabel: "B", purchaseAmount: 2.50, date: Date())
        ]
        XCTAssertEqual(jar.total, 1.25, accuracy: 0.001)
    }

    func testJarFillFractionClampsToOne() {
        var jar = Jar(name: "Test", goalAmount: 1)
        jar.entries = [RoundUpEntry(purchaseLabel: "A", purchaseAmount: 5.00, date: Date())]
        XCTAssertEqual(jar.fillFraction, 1.0, accuracy: 0.001)
        XCTAssertTrue(jar.isFull)
    }

    @MainActor
    func testStoreAddJarRespectsFreeLimit() {
        let store = SquareupStore()
        for jar in store.jars { store.deleteJar(jar.id) }
        XCTAssertTrue(store.addJar(name: "Jar A", goalAmount: 10, isPro: false))
        XCTAssertFalse(store.addJar(name: "Jar B", goalAmount: 10, isPro: false))
        XCTAssertTrue(store.addJar(name: "Jar B", goalAmount: 10, isPro: true))
    }

    @MainActor
    func testAddEntryUpdatesJarTotal() {
        let store = SquareupStore()
        for jar in store.jars { store.deleteJar(jar.id) }
        store.addJar(name: "Jar A", goalAmount: 10, isPro: false)
        let jarID = store.jars[0].id
        store.addEntry(toJar: jarID, label: "Coffee", purchaseAmount: 3.50)
        XCTAssertEqual(store.jars[0].total, 0.50, accuracy: 0.001)
    }

    @MainActor
    func testShakeJarAddsRandomizedEntry() {
        let store = SquareupStore()
        for jar in store.jars { store.deleteJar(jar.id) }
        store.addJar(name: "Jar A", goalAmount: 10, isPro: false)
        let jarID = store.jars[0].id
        store.shakeJarQuickAdd(jarID: jarID)
        XCTAssertEqual(store.jars[0].entries.count, 1)
        XCTAssertGreaterThan(store.jars[0].total, 0)
        XCTAssertLessThanOrEqual(store.jars[0].total, 0.99)
    }

    @MainActor
    func testDeleteEntryRemovesFromJar() {
        let store = SquareupStore()
        for jar in store.jars { store.deleteJar(jar.id) }
        store.addJar(name: "Jar A", goalAmount: 10, isPro: false)
        let jarID = store.jars[0].id
        store.addEntry(toJar: jarID, label: "Coffee", purchaseAmount: 3.50)
        let entryID = store.jars[0].entries[0].id
        store.deleteEntry(entryID, fromJar: jarID)
        XCTAssertTrue(store.jars[0].entries.isEmpty)
    }
}
