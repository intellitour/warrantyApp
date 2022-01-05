//
//  Product.swift
//  WarrantyApp
//
//  Created by Pedro Henrique on 29/12/21.
//

import Foundation
import CoreData
import UIKit

class Product: NSManagedObject {
    
    var uiImage: UIImage {
        if let relativePath = self.photo,
           let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(relativePath),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data)
        {
            return image
        }
        return UIImage(systemName: "noImage")!
    }
    
    var remainingWarrantyDays: Int {
        if let warrantyEnds = self.warrantyStartDate?.adding(.month, value: Int(self.warrantyMonths)) {
            return warrantyEnds.daysSince(.now).int
        }
        
        return Int.min
    }
    
    enum NotificationScheme: Int16, CustomStringConvertible, CaseIterable, Identifiable {
        var id: String {
            return description
        }
        
        case month
        case threeDays
        case oneDay
        case other
        
        var description: String {
            switch self {
                case .month: return String(localized: "NotificationSchemeMonth")
                case .threeDays: return String(localized: "NotificationSchemeThreeDays")
                case .oneDay: return String(localized: "NotificationSchemeOneDay")
                case .other: return String(localized: "NotificationSchemeOther")
            }
        }
    }
    
    
    struct StateObject {
        var id: NSManagedObjectID? = nil
        var manufacturer: String = ""
        var name: String = ""
        var photo: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var purchaseDate: Date = .now
        var warrantyMonths: NSNumber = 12
        var warrantyStartDate: Date = .now
        var shouldNotify: Bool = false
        var notificationScheme: NotificationScheme = .month
        
        
        func createProduct(in context: NSManagedObjectContext) -> Product {
            let product = Product(context: context)
            
            product.name = name
            product.manufacturer = manufacturer
            product.photo = "\(photo.deletingLastPathComponent().lastPathComponent)/\(photo.lastPathComponent)"
            product.purchaseDate = purchaseDate
            product.warrantyStartDate = warrantyStartDate
            product.warrantyMonths = warrantyMonths.int16Value
            product.shouldNotify = shouldNotify
            product.notificationScheme = notificationScheme.rawValue
            
            return product
        }
        
    }
    
}
