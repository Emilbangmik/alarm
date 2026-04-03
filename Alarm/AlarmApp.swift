//
//  AlarmApp.swift
//  Alarm
//
//  Created by Emil Bang Mikkelsen on 03/04/2026.
//

import SwiftUI

@main
struct AlarmApp: App {
    @State private var store = AlarmStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .task {
                    _ = await store.requestAuthorization()
                }
        }
    }
}
