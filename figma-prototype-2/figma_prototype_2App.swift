//
//  figma_prototype_2App.swift
//  figma-prototype-2
//
//  Created by Christo Polydorou on 11/17/23.
//

import SwiftUI

@main
struct figma_prototype_2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
