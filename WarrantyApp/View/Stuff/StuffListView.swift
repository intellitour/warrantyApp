//
//  StuffListView.swift
//  Garantia
//
//  Created by Pedro Henrique on 25/12/21.
//

import SwiftUI
import PureSwiftUI

struct StuffListView: View {
    
    @ObservedObject
    var viewModel: StuffViewModel

    @State
    private var selection: String? = nil
    
    @FetchRequest(
        entity: Product.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Product.purchaseDate, ascending: false),
            NSSortDescriptor(keyPath: \Product.warrantyStartDate, ascending: false),
            NSSortDescriptor(keyPath: \Product.name, ascending: true),
            NSSortDescriptor(keyPath: \Product.manufacturer, ascending: true)
        ],
        predicate: nil,
        animation: Animation.interactiveSpring()
    )
    private var products: FetchedResults<Product>

    var body: some View {
        VStack {
            if products.count == 0 {
                EmptyList(onAdd: onAddStuff)
            }else {
                List(products) { product in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(uiImage: product.uiImage)
                                .antialiased(true)
                                .resizedToFill(CGSize(width: 70, height: 70))
                                .clipCircle()
                                .strokeCircle(.accentColor, lineWidth: 4)
                            
                            VStack(alignment: .leading) {
                                
                                HeadlineText(product.name ?? "")
                                SubheadlineText(product.manufacturer ?? "")
                            }
                            .padding()
                        }
                        BodyText("\(String(localized: "WarrantyDaysRemaining")) \(product.remainingWarrantyDays)")
                    }
                    
                    
                    
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
