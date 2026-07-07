import Foundation

@MainActor
final class SquareupStore: ObservableObject {
    @Published private(set) var jars: [Jar] = []
    @Published var selectedJarID: UUID?

    static let freeJarLimit = 1

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("squareup_jars.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
        }
        load()
        if jars.isEmpty {
            seedDefault()
        }
        selectedJarID = jars.first?.id
    }

    private func seedDefault() {
        jars = [Jar(name: "Coffee Fund", goalAmount: 25)]
        save()
    }

    var selectedJar: Jar? {
        jars.first { $0.id == selectedJarID }
    }

    func canAddJar(isPro: Bool) -> Bool {
        isPro || jars.count < Self.freeJarLimit
    }

    @discardableResult
    func addJar(name: String, goalAmount: Double, isPro: Bool) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAddJar(isPro: isPro) else { return false }
        let jar = Jar(name: trimmed, goalAmount: max(1, goalAmount))
        jars.append(jar)
        if selectedJarID == nil { selectedJarID = jar.id }
        save()
        return true
    }

    func deleteJar(_ id: UUID) {
        jars.removeAll { $0.id == id }
        if selectedJarID == id { selectedJarID = jars.first?.id }
        save()
    }

    func renameJar(_ id: UUID, name: String, goalAmount: Double) {
        guard let idx = jars.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        jars[idx].name = trimmed
        jars[idx].goalAmount = max(1, goalAmount)
        save()
    }

    @discardableResult
    func addEntry(toJar jarID: UUID, label: String, purchaseAmount: Double) -> Bool {
        guard let idx = jars.firstIndex(where: { $0.id == jarID }) else { return false }
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, purchaseAmount > 0 else { return false }
        let entry = RoundUpEntry(purchaseLabel: trimmed, purchaseAmount: purchaseAmount, date: Date())
        jars[idx].entries.insert(entry, at: 0)
        save()
        return true
    }

    /// Quirky feature: "Shake the jar" — logs a randomized small round-up
    /// (25-99 cents) as a playful quick-add without typing a purchase amount,
    /// simulating literally tossing spare change into the jar.
    func shakeJarQuickAdd(jarID: UUID) {
        guard jars.contains(where: { $0.id == jarID }) else { return }
        let cents = Double(Int.random(in: 25...99)) / 100.0
        let idx = jars.firstIndex { $0.id == jarID }!
        let entry = RoundUpEntry(purchaseLabel: "Shake toss", purchaseAmount: 1 - cents, date: Date())
        jars[idx].entries.insert(entry, at: 0)
        save()
    }

    func deleteEntry(_ entryID: UUID, fromJar jarID: UUID) {
        guard let idx = jars.firstIndex(where: { $0.id == jarID }) else { return }
        jars[idx].entries.removeAll { $0.id == entryID }
        save()
    }

    func deleteAllData() {
        jars = []
        seedDefault()
        selectedJarID = jars.first?.id
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var jars: [Jar]
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            jars = decoded.jars
        }
    }

    private func save() {
        let snapshot = Snapshot(jars: jars)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
