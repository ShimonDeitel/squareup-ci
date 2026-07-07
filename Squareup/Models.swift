import Foundation

/// A single round-up entry: user bought something for a non-round amount and
/// logs the "spare change" difference up to the next whole dollar (manual —
/// no bank linkage, per the app's no-backend design constraint).
struct RoundUpEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var purchaseLabel: String
    var purchaseAmount: Double
    var date: Date

    /// The round-up amount: difference to the next whole dollar.
    var roundUpAmount: Double {
        let ceilDollar = purchaseAmount.rounded(.up)
        let diff = ceilDollar - purchaseAmount
        // If already a whole dollar, round up a full extra dollar (still "spare change").
        return diff < 0.005 ? 1.0 : diff
    }
}

/// A named jar; users can keep more than one goal jar (Pro unlocks >1).
struct Jar: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var goalAmount: Double
    var entries: [RoundUpEntry] = []

    var total: Double {
        entries.reduce(0) { $0 + $1.roundUpAmount }
    }

    var fillFraction: Double {
        guard goalAmount > 0 else { return 0 }
        return min(1.0, total / goalAmount)
    }

    var isFull: Bool {
        goalAmount > 0 && total >= goalAmount
    }
}
