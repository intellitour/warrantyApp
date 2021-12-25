//
//  WarrantyAppApp.swift
//  WarrantyApp
//
//  Created by Pedro Henrique on 25/12/21.
//

import SwiftUI

@main
struct WarrantyAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
