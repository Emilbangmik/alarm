//
//  ContentView.swift
//  Alarm
//
//  Created by Emil Bang Mikkelsen on 03/04/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AlarmStore.self) private var store
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            AlarmListView()
                .background(Theme.background)
            .navigationTitle("Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.amber)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AlarmEditView(mode: .add)
            }
            .fullScreenCover(item: Binding(
                get: { store.activeChallenge },
                set: { store.activeChallenge = $0 }
            )) { alarm in
                TypingChallengeView(alarm: alarm) {
                    store.completeChallenge()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environment(AlarmStore())
}
