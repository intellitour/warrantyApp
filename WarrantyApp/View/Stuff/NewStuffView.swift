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
    
    @FocusState
    private var focus: Focus?
    
    private let formatter = NumberFormatter()
    
    @State
    private var showImagePicker = false
    
    @State
    private var showImagePickerActionSheet = false

    @State
    private var showUnauthorizedNotificationAlert = false
    
    @State
    private var selectedImage: SelectedImage? = nil
    
    @State
    private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Environment(\.dismiss)
    private var dismiss
    
    @ViewBuilder
    var body: some View {
        
        if viewModel.loading {
            ProgressView()
        }else {
            if let _ = viewModel.productState.id {
                Group {
                    ProgressView()
                }.onAppear {
                    viewModel.productState = Product.StateObject()
                    dismiss()
                }
            }else {
                renderForm()
            }
        }
        
    }
     
    
    private func renderForm() -> some View {
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
                TextField(LocalizedStringKey("ProductName"), text: $viewModel.productState.name)
                    .focused($focus, equals: .name)
                TextField("Fabricante", text: $viewModel.productState.manufacturer)
                    .focused($focus, equals: .manufacturer)
            }
            
            Section(LocalizedStringKey("WarrantyData")) {
                DatePicker(LocalizedStringKey("PurchaseDate"),
                           selection: $viewModel.productState.purchaseDate,
                           in: PartialRangeThrough(.now),
                           displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .focused($focus, equals: .purchaseDate)
                
                DatePicker(LocalizedStringKey("WarrantyStartDate"),
                           selection: $viewModel.productState.warrantyStartDate,
                           in: PartialRangeThrough(.now),
                           displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .focused($focus, equals: .purchaseDate)
                
                HStack {
                    Text(String(localized: "WarrantyLengthInMonths"))
                    
                    Spacer()
                    
                    TextField(LocalizedStringKey("WarrantyLengthInMonths"),
                              value: $viewModel.productState.warrantyMonths,
                              formatter: NumberFormatter()
                    )
                    .focused($focus, equals: .warrantyMonths)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                }
                
                Toggle(LocalizedStringKey("ShouldNotify"), isOn: $viewModel.productState.shouldNotify)
                    .onChange(of: viewModel.productState.shouldNotify) { newValue in
                        if newValue {
                            viewModel.requestNotificationAuthorization()
                        }
                    }
                    .onChange(of: viewModel.notificationAuthorized, perform: { newValue in
                        if !newValue && viewModel.hasRequestNotificationAuthorization {
                            viewModel.productState.shouldNotify = false
                            showUnauthorizedNotificationAlert = true
                        }
                    })
                    .alert(LocalizedStringKey("NotificationsDisabledAlertTitle"), isPresented: $showUnauthorizedNotificationAlert) {
                        HStack {
                            Button(LocalizedStringKey("Cancel"), role: .cancel) {

                            }
                            Button(LocalizedStringKey("NotificationsDisabledAlertGoToSettingsButton")) {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        }
                    } message: {
                        Text(String(localized: "NotificationsDisabledAlertMessage"))
                    }

                
                if viewModel.productState.shouldNotify {
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey("NotificationScheme"))
                        
                        Picker(LocalizedStringKey("NotificationScheme"), selection: $viewModel.productState.notificationScheme) {
                            ForEach(Product.NotificationScheme.allCases) { scheme in
                                Button(scheme.description) {
                                    
                                }
                                .tag(scheme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
//                    if viewModel.productState.notificationScheme == .other {
//
//                    }
                    
                }
            }
            
            Section {
                VStack(alignment: .center) {
                    Button(LocalizedStringKey("Save")) {
                        viewModel.save()
                    }
                }
            }
        }
        .navigationTitle(viewModel.productState.name)
        .navigationBarItems(trailing: Button("\(Image(systemName: "checkmark"))") {
            viewModel.save()
        })
        .onAppear {
            formatter.numberStyle = .ordinal
            formatter.allowsFloats = false
            formatter.generatesDecimalNumbers = false
            formatter.minimum = 0
            formatter.maximum = NSNumber(value: Int16.max)
        }
        .confirmationDialog(LocalizedStringKey("ImageSourceConfirmTitle"),
                            isPresented: $showImagePickerActionSheet,
                            titleVisibility: .visible
        ) {
            Button(LocalizedStringKey("CameraImageSource")) {
                imagePickerSourceType = .camera
                showImagePicker = true
            }
            
            Button(LocalizedStringKey("LibraryImageSource")) {
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
                viewModel.productState.photo = url
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

