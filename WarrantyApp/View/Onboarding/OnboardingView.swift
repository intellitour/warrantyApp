//
//  OnboardingView.swift
//  Garantia (iOS)
//
//  Created by Pedro Henrique on 19/12/21.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        TabView {
            OnboardingScreens.First()
            OnboardingScreens.Second()
            OnboardingScreens.Third()
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea(.all, edges: .all)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
