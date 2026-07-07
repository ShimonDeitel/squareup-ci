import SwiftUI

/// Main screen: a literal glass jar that visually fills with copper "coins"
/// as round-up entries accumulate toward the jar's goal. The quirky/fun
/// gimmick is the "Shake the Jar" quick-toss button — a satisfying tactile
/// motion (rotation + haptic) that logs a randomized small round-up without
/// any typing, plus the jar visibly jiggles when tapped.
struct JarView: View {
    @EnvironmentObject private var store: SquareupStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var sheetMode: SquareupSheetMode?
    @State private var jarWiggle = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        jarPicker

                        if let jar = store.selectedJar {
                            jarVisual(jar)
                                .padding(.top, 8)

                            Text("$\(String(format: "%.2f", jar.total))")
                                .font(Theme.numberFont)
                                .foregroundStyle(Theme.mintDeep)

                            Text("of $\(String(format: "%.0f", jar.goalAmount)) goal")
                                .font(Theme.bodyFont)
                                .foregroundStyle(.secondary)

                            if jar.isFull {
                                Text("Jar is full! Time to cash it in.")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Theme.copper)
                            }

                            HStack(spacing: 16) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                                        jarWiggle.toggle()
                                    }
                                    store.shakeJarQuickAdd(jarID: jar.id)
                                } label: {
                                    Label("Shake the Jar", systemImage: "shuffle")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Theme.copper)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("shakeJarButton")
                            }
                            .padding(.horizontal)

                            Button {
                                sheetMode = .addEntry(jar.id)
                            } label: {
                                Label("Log a Purchase", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.mintDeep)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("logPurchaseButton")
                            .padding(.horizontal)

                            entryList(jar)
                        } else {
                            emptyState
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Squareup")
            .dismissKeyboardOnTap()
            .sheet(item: $sheetMode) { mode in
                switch mode {
                case .paywall:
                    PaywallView().environmentObject(purchases)
                case .addEntry(let jarID):
                    EntryAddSheet { label, amount in
                        store.addEntry(toJar: jarID, label: label, purchaseAmount: amount)
                    }
                case .addJar, .editJar:
                    JarEditSheet(mode: mode) { name, goal in
                        switch mode {
                        case .addJar:
                            store.addJar(name: name, goalAmount: goal, isPro: purchases.isPro)
                        case .editJar(let jar):
                            store.renameJar(jar.id, name: name, goalAmount: goal)
                        default: break
                        }
                    }
                }
            }
        }
    }

    private var jarPicker: some View {
        HStack {
            Menu {
                ForEach(store.jars) { jar in
                    Button(jar.name) { store.selectedJarID = jar.id }
                }
            } label: {
                HStack {
                    Text(store.selectedJar?.name ?? "No Jar")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Theme.ink)
                }
            }
            .accessibilityIdentifier("jarPickerMenu")

            Spacer()

            Button {
                if store.canAddJar(isPro: purchases.isPro) {
                    sheetMode = .addJar
                } else {
                    sheetMode = .paywall
                }
            } label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(Theme.mintDeep)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("addJarButton")
        }
        .padding(.horizontal)
    }

    private func jarVisual(_ jar: Jar) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 28)
                .stroke(Theme.mintDeep, lineWidth: 4)
                .background(RoundedRectangle(cornerRadius: 28).fill(Theme.jarGlass))
                .frame(width: 180, height: 220)

            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.copper.opacity(0.85))
                .frame(width: 164, height: max(8, 204 * jar.fillFraction))
                .padding(.bottom, 8)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .frame(width: 180, height: 220)
        .rotationEffect(.degrees(jarWiggle ? -4 : 4))
        .animation(.spring(response: 0.3, dampingFraction: 0.3), value: jarWiggle)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("jarVisual")
    }

    private func entryList(_ jar: Jar) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !jar.entries.isEmpty {
                Text("Recent Round-Ups")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal)

                ForEach(jar.entries) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.purchaseLabel).foregroundStyle(Theme.ink)
                            Text(entry.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("+$\(String(format: "%.2f", entry.roundUpAmount))")
                            .foregroundStyle(Theme.copper)
                            .font(.subheadline.bold())
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.deleteEntry(entry.id, fromJar: jar.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.mintDeep)
            Text("No jar yet. Create one to start rounding up.")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }
}

#Preview {
    JarView()
        .environmentObject(SquareupStore())
        .environmentObject(PurchaseManager())
}
