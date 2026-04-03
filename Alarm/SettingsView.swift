import SwiftUI

struct SettingsView: View {
    @State private var showingPuzzleTest = false

    var body: some View {
        List {
            // MARK: - About
            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    HStack {
                        Label {
                            Text("About")
                                .foregroundStyle(Theme.textPrimary)
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(Theme.amber)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary.opacity(0.5))
                    }
                }
                .listRowBackground(Theme.surface)
            } header: {
                Text("General")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.amber.opacity(0.7))
                    .tracking(1.5)
            }

            // MARK: - Developer
            Section {
                Button {
                    showingPuzzleTest = true
                } label: {
                    HStack {
                        Label {
                            Text("Test Puzzle")
                                .foregroundStyle(Theme.textPrimary)
                        } icon: {
                            Image(systemName: "keyboard")
                                .foregroundStyle(Theme.amber)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary.opacity(0.5))
                    }
                }
                .listRowBackground(Theme.surface)
            } header: {
                Text("Developer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.amber.opacity(0.7))
                    .tracking(1.5)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .fullScreenCover(isPresented: $showingPuzzleTest) {
            TypingChallengeView(
                alarm: Alarm(hour: 7, minute: 0, label: "Test Alarm"),
                onComplete: { showingPuzzleTest = false },
                playSound: false
            )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .preferredColorScheme(.dark)
}
