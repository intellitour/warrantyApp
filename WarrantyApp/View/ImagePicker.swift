//
//  ImagePicker.swift
//  WarrantyApp
//
//  Created by Pedro Henrique on 31/12/21.
//

import Foundation
import PhotosUI
import SwiftUI


struct SelectedImage {
    let uiImage: UIImage
    let image: Image
}

extension SelectedImage : Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uiImage.isEqual(rhs.uiImage) && lhs.image == rhs.image
    }
}

struct PHImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: SelectedImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PHImagePicker

        init(_ parent: PHImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        self.parent.selectedImage = SelectedImage(uiImage: image, image: Image(uiImage: image))
                    }
                }
            }
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @Binding
    var selectedImage: SelectedImage?
    
    var sourceType = UIImagePickerController.SourceType.photoLibrary
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.tintColor = .clear
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
      }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                  context: UIViewControllerRepresentableContext<ImagePicker>) { }

      func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let control: ImagePicker

        init(_ control: ImagePicker) {
          self.control = control
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
              self.control.selectedImage = SelectedImage(uiImage: image, image: Image(uiImage: image))
          }
          control.presentationMode.wrappedValue.dismiss()
        }
      }
}
