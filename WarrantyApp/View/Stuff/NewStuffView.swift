//
//  NewStuffView.swift
//  WarrantyApp
//
//  Created by Pedro Henrique on 27/12/21.
//
//

import Combine
import SwiftUI

struct NewStuffView: View {
    
    enum Focus {
        case manufacturer, name, photo, purchaseDate, warrantyMonths, warrantyStartDate
    }
    
    @EnvironmentObject
    var viewModel: StuffViewModel
    
    
    @State
    private var product = Product.StateObject()
    
    @FocusState
    private var focus: Focus?
    
    private let formatter = NumberFormatter()
    
    @State
    private var showImagePicker = false
    
    @State
    private var showImagePickerActionSheet = false
    
    @State
    private var selectedImage: SelectedImage? = nil
    
    @State
    private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        Form {
            ZStack(alignment: selectedImage != nil ? .bottomTrailing : .center) {
                
                if let selectedImage = self.selectedImage {
                    selectedImage.image
                        .antialiased(true)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                    
                    ZStack {
                        
                        Circle()
                            .background(.thickMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Image(systemName: "camera.fill")
                            .foregroundColor(.accentColor)
                        
                    }
                    .frame(width: 60, height: 60, alignment: .bottomTrailing)
                    .fixedSize()
                    
                }else {
                    Image("noImage")
                        .antialiased(true)
                        .resizable()
                        .clipShape(Circle())
                    
                    ZStack {
                        
                        Circle()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                        
                        Image(systemName: "camera.fill")
                            .scaleEffect(2)
                            .foregroundColor(.accentColor)
                        
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .fixedSize()
                }
            }
            .foregroundColor(.clear)
            .onTapGesture {
                showImagePickerActionSheet = true
            }
            
            Section(LocalizedStringKey("ProductData")) {
                TextField(LocalizedStringKey("ProductName"), text: $product.name)
                    .focused($focus, equals: .name)
                TextField("Fabricante", text: $product.manufacturer)
                    .focused($focus, equals: .manufacturer)
            }
            
            Section(LocalizedStringKey("WarrantyData")) {
                DatePicker(LocalizedStringKey("ProductManufacturer"),
                           selection: $product.purchaseDate,
                           in: PartialRangeThrough(.now),
                           displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .focused($focus, equals: .purchaseDate)
                
                DatePicker(LocalizedStringKey("WarrantyStartDate"),
                           selection: $product.warrantyStartDate,
                           in: PartialRangeThrough(.now),
                           displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .focused($focus, equals: .purchaseDate)
                
                HStack {
                    Text(String(localized: "WarrantyLengthInMonths"))
                    
                    Spacer()
                    
                    TextField(LocalizedStringKey("WarrantyLengthInMonths"),
                              value: $product.warrantyMonths,
                              formatter: NumberFormatter()
                    )
                    .focused($focus, equals: .warrantyMonths)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                }
                
                Toggle(LocalizedStringKey("ShouldNotify"), isOn: $product.shouldNotify)
            }
            
            Section {
                VStack(alignment: .center) {
                    Button("Salvar") {
                        viewModel.save(product)
                    }
                }
            }
        }
        .navigationTitle(product.name)
        .navigationBarItems(trailing: Button("\(Image(systemName: "checkmark"))") {
            print(product.purchaseDate)
        })
        .onAppear {
            formatter.numberStyle = .ordinal
            formatter.allowsFloats = false
            formatter.generatesDecimalNumbers = false
            formatter.minimum = 0
            formatter.maximum = NSNumber(value: Int16.max)
        }
        .confirmationDialog("Origem da imagem",
                            isPresented: $showImagePickerActionSheet,
                            titleVisibility: .visible
        ) {
            Button("Câmera") {
                imagePickerSourceType = .camera
                showImagePicker = true
            }
            
            Button("Biblioteca de Fotos") {
                imagePickerSourceType = .photoLibrary
                showImagePicker = true
            }
        }
        .popover(isPresented: $showImagePicker) {
            if imagePickerSourceType == .camera {
                ImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSourceType)
            }else {
                PHImagePicker(selectedImage: $selectedImage)
            }
        }
        .onChange(of: selectedImage, perform: { newValue in
            if let image = newValue?.uiImage,
               let url = viewModel.storePhoto(image)
            {
                product.photo = url
            }
        })
    }
}


struct NewStuffView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewStuffView()
        }
    }
}

