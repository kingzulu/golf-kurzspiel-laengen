import SwiftUI

/// Schläger hinzufügen, sortieren, löschen und zum Bearbeiten öffnen.
struct EditView: View {
    @EnvironmentObject private var store: ClubStore
    @Environment(\.dismiss) private var dismiss
    @State private var path: [Club.ID] = []
    @State private var editMode: EditMode = .inactive
    @State private var confirmReset = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    ForEach(store.clubs) { club in
                        NavigationLink(value: club.id) {
                            ClubSummary(club: club)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                store.delete(club.id)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                    .onMove { store.clubs.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        path.append(store.addClub())
                    } label: {
                        Label("Schläger hinzufügen", systemImage: "plus.circle.fill")
                    }
                } footer: {
                    Text("Tippe auf einen Schläger, um Name und Längen einzutragen. Nach links wischen zum Löschen.")
                }

                Section {
                    Button("Alles zurücksetzen", role: .destructive) {
                        confirmReset = true
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(editMode.isEditing ? "Sortieren beenden" : "Sortieren") {
                        withAnimation {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .navigationDestination(for: Club.ID.self) { id in
                if let index = store.clubs.firstIndex(where: { $0.id == id }) {
                    ClubEditView(club: $store.clubs[index])
                }
            }
            .alert("Alles zurücksetzen?", isPresented: $confirmReset) {
                Button("Zurücksetzen", role: .destructive) { store.reset() }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Alle Schläger und Längen werden gelöscht. Danach stehen wieder LW, SW, GW, PW und 9er ohne Werte in der Liste.")
            }
        }
    }
}

private struct ClubSummary: View {
    let club: Club

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(club.hasName ? club.name : "Ohne Namen")
                .font(.headline)
                .foregroundStyle(club.hasName ? Color.primary : Color.secondary)
            Text(Swing.allCases.map { swing -> String in
                let value = club[keyPath: swing.keyPath].map(Meters.text) ?? "–"
                return "\(swing.label): \(value)"
            }.joined(separator: "  ·  "))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// Name und die drei Längen eines Schlägers.
struct ClubEditView: View {
    @Binding var club: Club
    // Eingaben als Text halten, damit "25," beim Tippen nicht verschwindet.
    @State private var texts: [String]

    init(club: Binding<Club>) {
        _club = club
        _texts = State(initialValue: Swing.allCases.map { swing in
            club.wrappedValue[keyPath: swing.keyPath].map(Meters.text) ?? ""
        })
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("z. B. SW 56°", text: $club.name)
                    .autocorrectionDisabled()
            }
            Section {
                ForEach(Swing.allCases) { swing in
                    HStack(spacing: 12) {
                        ClockIcon(swing: swing)
                        Text("bis \(swing.label) Uhr")
                        Spacer()
                        TextField("–", text: binding(for: swing))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("m")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Längen in Metern")
            } footer: {
                Text("Feld leer lassen, wenn du die Länge noch nicht kennst.")
            }
        }
        .navigationTitle(club.hasName ? club.name : "Neuer Schläger")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding(for swing: Swing) -> Binding<String> {
        Binding(
            get: { texts[swing.rawValue] },
            set: { newValue in
                texts[swing.rawValue] = newValue
                club[keyPath: swing.keyPath] = Meters.parse(newValue)
            }
        )
    }
}
