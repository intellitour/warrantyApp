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
import StoreKit

class StuffViewModel: ObservableObject {

    @ObservedObject
    private var iapManager = IAPManager.shared
    
    let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        iapManager.getProducts(withHandler: iapProductsHandler(result:))
    }
    
    @Published
    var stuff = [Product]()
    
    @Published
    var productState = Product.StateObject()
    
    @Published
    var loading = false
    
    @Published
    var error: Error?

    @Published
    var notificationAuthorized = true

    @Published
    var hasRequestNotificationAuthorization = false

    private func iapProductsHandler(result: Result<[SKProduct], IAPManager.IAPManagerError>) {
        print(result);
    }


    func requestNotificationAuthorization() {
        hasRequestNotificationAuthorization = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] authorized, error in
            DispatchQueue.main.async { [weak self] in
                self?.notificationAuthorized = authorized
                if !authorized {
                    self?.productState.shouldNotify = false
                }
            }
        }
    }

    func save() {
        do {
            loading = true
            let context = persistenceController.container.viewContext
            let persistent = productState.createProduct(in: context)
            try context.save()
            productState.id = persistent.objectID
            loading = false
            Task {
                await scheduleNotifications(for: persistent)
            }
        }catch (let error) {
            self.error = error
            debugPrint(error)
        }
    }
    
    private func scheduleNotifications(for product: Product) async {
        var timeInterval: TimeInterval? = nil
        var daysRemaining: Int? = nil
        switch Product.NotificationScheme(rawValue: product.notificationScheme) {
            case .month:
                timeInterval = product.warrantyStartDate?.adding(.month, value: Int(product.warrantyMonths - 1)).timeIntervalSinceNow
                daysRemaining = 30
            case .threeDays:
                timeInterval = product.warrantyStartDate?.adding(.month, value: Int(product.warrantyMonths)).adding(.day, value: -3).timeIntervalSinceNow
                daysRemaining = 3
            case .oneDay:
                timeInterval = product.warrantyStartDate?.adding(.month, value: Int(product.warrantyMonths)).adding(.day, value: -1).timeIntervalSinceNow
                daysRemaining = 1
            case .none: break
        }

        if let timeInterval = timeInterval, let daysRemaining = daysRemaining {
            let content = UNMutableNotificationContent()
            content.title = product.name!
            content.subtitle = "Warranty Status"
            content.body = "Warranty for \(product.name!) has \(daysRemaining) days remaining"
            content.sound = .defaultCritical

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

            let request = UNNotificationRequest(identifier: product.objectID.description,
                                                content: content,
                                                trigger: trigger)

            try? await UNUserNotificationCenter.current().add(request)
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
