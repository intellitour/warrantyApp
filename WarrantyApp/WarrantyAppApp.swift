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
    
    @AppStorage("didShowOnboarding", store: UserDefaults.standard)
    private var didShowOnboarding: Bool?
    
    var body: some Scene {
        WindowGroup {
            if didShowOnboarding ?? false {
                NavigationView {
                    StuffListView(viewModel: StuffViewModel(persistenceController: persistenceController))
                }
            }else {
                OnboardingView()
            }
        }
    }
}
