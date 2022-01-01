//
//  StuffViewModel.swift
//  WarrantyApp
//
//  Created by Pedro Henrique on 25/12/21.
//

import Foundation
import Combine
import SwiftUI
import SwifterSwift
import UniformTypeIdentifiers.UTType

class StuffViewModel: ObservableObject {
    
    let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    @Published
    var stuff = [Product]()
    
    @Published
    var loading = false
    
    @Published
    var error: Error?
    
    
    func save(_ product: Product.StateObject) {
        do {
            loading = true
            let context = persistenceController.container.viewContext
            product.createProduct(in: context)
            try context.save()
            loading = false
        }catch (let error) {
            self.error = error
            debugPrint(error)
        }
    }
    
    func storePhoto(_ photo: UIImage) -> URL? {
        let isHorizontal = photo.size.width > photo.size.height
        var scaledWidth = CGFloat(0)
        if isHorizontal {
            scaledWidth = 1920
        }else {
            scaledWidth = 1080
        }
        
        if let scaled = photo.scaled(toWidth: scaledWidth),
           let compressed = scaled.jpegData(compressionQuality: 0.8),
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            
            let photoDir = documentsDirectory
                .appendingPathComponent("stuffPhotos", isDirectory: true)
            
            if !FileManager.default.fileExists(atPath: photoDir.path) {
                do {
                    try FileManager.default.createDirectory(at: photoDir, withIntermediateDirectories: true, attributes: nil)
                }catch {
                    debugPrint(error)
                    return nil
                }
            }
            
            let photoPath = photoDir
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")
            
            let created = FileManager.default.createFile(atPath: photoPath.path,
                                           contents: compressed,
                                           attributes: nil)
            if created {
                debugPrint("Saved photo at: \(photoPath)")
                return photoPath
            }
        }
        return nil
    }
    
    
}
