import SwiftUI

/// Die Tabelle zum Ablesen auf dem Platz.
struct ContentView: View {
    @EnvironmentObject private var store: ClubStore
    @State private var showEditor = false

    private var visibleClubs: [Club] {
        store.clubs.filter(\.hasName)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HeaderRow()
                    if visibleClubs.isEmpty {
                        Divider()
                        Text("Noch keine Schläger. Tippe oben auf „Bearbeiten“.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(24)
                    } else {
                        ForEach(visibleClubs) { club in
                            Divider()
                            ClubRow(club: club, face: .square)
                            Divider().padding(.leading, 14)
                            ClubRow(club: club, face: .open)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal)
                .padding(.top, 8)

                Text("Längen in Metern. Uhrzeit = wie weit du ausholst (linker Arm als Uhrzeiger).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Kurzspiel-Längen")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Bearbeiten") { showEditor = true }
                }
            }
            .sheet(isPresented: $showEditor) {
                EditView()
                    .environmentObject(store)
            }
        }
    }
}

private struct HeaderRow: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Schläger")
                .frame(width: 96, alignment: .leading)
            ForEach(Swing.allCases) { swing in
                VStack(spacing: 4) {
                    ClockIcon(swing: swing)
                    Text(swing.label)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.accentColor.opacity(0.12))
    }
}

private struct ClubRow: View {
    let club: Club
    let face: Face

    var body: some View {
        HStack(spacing: 0) {
            nameLabel
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(width: 96, alignment: .leading)
            ForEach(Swing.allCases) { swing in
                valueText(club[keyPath: swing.keyPath(face)])
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, face == .square ? 16 : 12)
        .background(face == .open ? Color.accentColor.opacity(0.05) : Color.clear)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var nameLabel: some View {
        switch face {
        case .square:
            Text(club.name)
                .font(.title3.weight(.semibold))
        case .open:
            VStack(alignment: .leading, spacing: 0) {
                Text(club.name)
                    .font(.subheadline.weight(.semibold))
                Text("offen")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
    }

    private func valueText(_ value: Double?) -> Text {
        guard let value else {
            return Text("–").font(.title2).foregroundColor(.secondary)
        }
        return Text(Meters.text(value)).font(.title.weight(.bold)).monospacedDigit()
            + Text(" m").font(.subheadline).foregroundColor(.secondary)
    }
}
