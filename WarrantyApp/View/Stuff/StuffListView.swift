//
//  StuffListView.swift
//  Garantia
//
//  Created by Pedro Henrique on 25/12/21.
//

import SwiftUI

struct StuffListView: View {
    
    @ObservedObject
    var viewModel: StuffViewModel

    @State
    private var selection: String? = nil

    var body: some View {
        VStack {
            if viewModel.stuff.count == 0 {
                EmptyList(onAdd: onAddStuff)
            }else {
                List(viewModel.stuff) { product in
                    
                }
            }
            NavigationLink(destination: NewStuffView().environmentObject(viewModel), tag: "A", selection: $selection, label: { EmptyView() })
        }
        .navigationTitle(LocalizedStringKey("StuffListTitle"))
        .navigationBarItems(trailing: Button(action: onAddStuff, label: { Image(systemName: "plus") }))
    }

    private func onAddStuff() {
        selection = "A"
    }
}

fileprivate struct EmptyList: View {
    
    @Environment(\.colorScheme)
    private var colorScheme

    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack(alignment: .center) {
                Circle()
                    .fill()

                Image("empty_product_list")
                    .antialiased(true)
                    .resizable()
                    .padding(60)
                    .clipShape(Circle())
            }
            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .gray.opacity(0.3))
            .scaledToFit()
            
            Text(String(localized: "EmptyStuffList"))
                .onTapGesture(perform: onAdd)
        }
    }
    
}
