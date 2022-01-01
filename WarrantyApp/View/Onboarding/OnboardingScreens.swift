//
//  OnboardingScreens.swift
//  Garantia (iOS)
//
//  Created by Pedro Henrique on 19/12/21.
//

import SwiftUI

struct OnboardingScreens {
    
    
    struct First: View {
        
        var body: some View {
            VStack(alignment: .center) {
                Text("Cadastre seus produtos")
                    .font(.title)
                
                    
                Image("onboarding_01")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Text("para controlar a garantia de cada um...")
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding()
            }
            .onboarding(background: Color("onboarding_01"))
        }
        
    }
    
    struct Second: View {
        
        var body: some View {
            VStack(alignment: .center) {
                Text("Informe as datas")
                    .font(.title)
                
                    
                Image("onboarding_02")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Text("de compra, de início da vigência da garantia e...")
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding()
            }
            .onboarding(background: Color("onboarding_02"))
        }
        
    }
    
    struct Third: View {
        
        @Environment(\.colorScheme)
        private var colorScheme
        
        @AppStorage("didShowOnboarding", store: UserDefaults.standard)
        private var didShowOnboarding: Bool?
        
        var body: some View {
            VStack(alignment: .center) {
                
                Spacer()
                
                Text("Seja Notificado")
                    .font(.title)
                
                    
                Image("onboarding_03")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Text("quando a garantia de um produto acabar.")
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding()
                Spacer()
                
                Button("Vamos começar!") {
                    didShowOnboarding = true
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("onboarding_03"))
                .foregroundColor(colorScheme == .light ? .white : .black)
                .padding(.bottom, 60)
                .environment(\.colorScheme, colorScheme == .dark ? .light : .dark)
            }
            .onboarding(background: Color("onboarding_03"))
        }
        
    }
    
}

fileprivate struct Onboarding: ViewModifier {
    
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 0,
                  maxHeight: .infinity,
                  alignment: .center
                )
            .background(content: {backgroundColor})
            .ignoresSafeArea()
    }
}

fileprivate extension View {
    
    func onboarding(background: Color) -> some View {
        modifier(Onboarding(backgroundColor: background))
    }
    
}
