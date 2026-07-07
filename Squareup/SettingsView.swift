import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: SquareupStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("squareup_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("squareup_shake_sound_enabled") private var shakeSoundEnabled: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var sheetMode: SquareupSheetMode?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if purchases.isPro {
                        HStack {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(Theme.mintDeep)
                            Text("Squareup Pro active")
                        }
                    } else {
                        Button {
                            sheetMode = .paywall
                        } label: {
                            HStack {
                                Image(systemName: "star.fill").foregroundStyle(Theme.copper)
                                Text("Unlock Squareup Pro")
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("settingsUnlockProButton")
                    }
                }

                Section("Jars") {
                    Text("\(store.jars.count) jar\(store.jars.count == 1 ? "" : "s") \(purchases.isPro ? "" : "(free: \(SquareupStore.freeJarLimit))")")
                        .foregroundStyle(.secondary)
                }

                Section("Preferences") {
                    Toggle(isOn: $hapticsEnabled) {
                        Label("Haptics", systemImage: "hand.tap.fill")
                    }
                    .tint(Theme.mintDeep)

                    Toggle(isOn: $shakeSoundEnabled) {
                        Label("Shake sound effect", systemImage: "speaker.wave.2.fill")
                    }
                    .tint(Theme.mintDeep)
                    .accessibilityIdentifier("shakeSoundToggle")

                    Button {
                        Task { await purchases.restore() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                }

                Section("About") {
                    Link(destination: URL(string: "https://shimondeitel.github.io/squareup-site/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    Link(destination: URL(string: "https://shimondeitel.github.io/squareup-site/terms.html")!) {
                        Label("Terms of Use", systemImage: "doc.text.fill")
                    }
                    Link(destination: URL(string: "mailto:s0533495227@gmail.com")!) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash.fill")
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Settings")
            .sheet(item: $sheetMode) { mode in
                if case .paywall = mode {
                    PaywallView().environmentObject(purchases)
                }
            }
            .alert("Delete All Data?", isPresented: $showingDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
            } message: {
                Text("This permanently removes every jar and entry. This cannot be undone.")
            }
        }
        .dismissKeyboardOnTap()
    }
}

#Preview {
    SettingsView()
        .environmentObject(SquareupStore())
        .environmentObject(PurchaseManager())
}
