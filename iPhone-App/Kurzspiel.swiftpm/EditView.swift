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
            ForEach(Face.allCases) { face in
                Text(summary(face))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func summary(_ face: Face) -> String {
        let values = Swing.allCases.map { swing -> String in
            club[keyPath: swing.keyPath(face)].map(Meters.text) ?? "–"
        }.joined(separator: " · ")
        return face == .open ? "offen: \(values)" : values
    }
}

/// Name und die drei Längen eines Schlägers.
struct ClubEditView: View {
    @Binding var club: Club
    // Eingaben als Text halten, damit "25," beim Tippen nicht verschwindet.
    @State private var texts: [Face: [String]]

    init(club: Binding<Club>) {
        _club = club
        var initial: [Face: [String]] = [:]
        for face in Face.allCases {
            initial[face] = Swing.allCases.map { swing in
                club.wrappedValue[keyPath: swing.keyPath(face)].map(Meters.text) ?? ""
            }
        }
        _texts = State(initialValue: initial)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("z. B. SW 56°", text: $club.name)
                    .autocorrectionDisabled()
            }
            ForEach(Face.allCases) { face in
                Section {
                    ForEach(Swing.allCases) { swing in
                        HStack(spacing: 12) {
                            ClockIcon(swing: swing)
                            Text("bis \(swing.label) Uhr")
                            Spacer()
                            TextField("–", text: binding(for: swing, face: face))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("m")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("\(face.title) – Längen in Metern")
                } footer: {
                    if face == .open {
                        Text("Feld leer lassen, wenn du die Länge noch nicht kennst.")
                    }
                }
            }
        }
        .navigationTitle(club.hasName ? club.name : "Neuer Schläger")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding(for swing: Swing, face: Face) -> Binding<String> {
        Binding(
            get: { texts[face]?[swing.rawValue] ?? "" },
            set: { newValue in
                texts[face, default: ["", "", ""]][swing.rawValue] = newValue
                club[keyPath: swing.keyPath(face)] = Meters.parse(newValue)
            }
        )
    }
}
