import SwiftUI

enum SquareupSheetMode: Identifiable {
    case addEntry(UUID)
    case addJar
    case editJar(Jar)
    case paywall

    var id: String {
        switch self {
        case .addEntry(let jarID): return "addEntry_\(jarID.uuidString)"
        case .addJar: return "addJar"
        case .editJar(let jar): return "editJar_\(jar.id.uuidString)"
        case .paywall: return "paywall"
        }
    }
}

struct EntryAddSheet: View {
    let onSave: (String, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var label: String = ""
    @State private var amountText: String = ""

    var computedRoundUp: Double? {
        guard let amount = Double(amountText), amount > 0 else { return nil }
        let entry = RoundUpEntry(purchaseLabel: "preview", purchaseAmount: amount, date: Date())
        return entry.roundUpAmount
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Purchase") {
                    TextField("What did you buy?", text: $label)
                        .accessibilityIdentifier("entryLabelField")

                    TextField("Amount (e.g. 4.35)", text: $amountText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("entryAmountField")
                }
                Section("Spare Change") {
                    if let roundUp = computedRoundUp {
                        Text("Rounds up to jar: $\(String(format: "%.2f", roundUp))")
                            .foregroundStyle(Theme.mintDeep)
                    } else {
                        Text("Enter an amount to see your round-up")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Log a Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(amountText) {
                            onSave(label, amount)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("entrySaveButton")
                    .disabled(label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(amountText) == nil)
                }
            }
        }
        .dismissKeyboardOnTap()
    }
}

struct JarEditSheet: View {
    let mode: SquareupSheetMode
    let onSave: (String, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var goalText: String

    init(mode: SquareupSheetMode, onSave: @escaping (String, Double) -> Void) {
        self.mode = mode
        self.onSave = onSave
        if case .editJar(let jar) = mode {
            _name = State(initialValue: jar.name)
            _goalText = State(initialValue: String(format: "%.0f", jar.goalAmount))
        } else {
            _name = State(initialValue: "")
            _goalText = State(initialValue: "25")
        }
    }

    private var title: String {
        if case .editJar = mode { return "Edit Jar" }
        return "New Jar"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Jar") {
                    TextField("Jar name (e.g. Coffee Fund)", text: $name)
                        .accessibilityIdentifier("jarNameField")
                    TextField("Goal amount", text: $goalText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("jarGoalField")
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, Double(goalText) ?? 25)
                        dismiss()
                    }
                    .accessibilityIdentifier("jarSaveButton")
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .dismissKeyboardOnTap()
    }
}
