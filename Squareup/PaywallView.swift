import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var purchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.mintDeep)
                        .padding(.top, 40)

                    Text("Squareup Pro")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.ink)

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow("infinity", "Unlimited jars")
                        featureRow("clock.arrow.circlepath", "Full round-up history")
                        featureRow("sparkles", "Support future updates")
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    Button {
                        purchasing = true
                        Task {
                            await purchases.purchase()
                            purchasing = false
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        HStack {
                            if purchasing {
                                ProgressView()
                            } else {
                                Text(purchases.product.map { "\($0.displayPrice)/month" } ?? "Unlock Pro")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.mintDeep)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(purchasing || purchases.product == nil)
                    .padding(.horizontal, 24)
                    .accessibilityIdentifier("paywallPurchaseButton")

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.mintDeep)
                .frame(width: 24)
            Text(text)
        }
    }
}

#Preview {
    PaywallView().environmentObject(PurchaseManager())
}
