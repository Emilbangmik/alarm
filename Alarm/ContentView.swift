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
            ScrollView {
                AlarmListView()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            .background(Theme.background)
            .navigationTitle("Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
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
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environment(AlarmStore())
}
