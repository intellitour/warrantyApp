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
    
    struct StateObject {
        var manufacturer: String = ""
        var name: String = ""
        var photo: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var purchaseDate: Date = .now
        var warrantyMonths: NSNumber = 12
        var warrantyStartDate: Date = .now
        var shouldNotify: Bool = true
        
        func createProduct(in context: NSManagedObjectContext) {
            let product = Product(context: context)
            
            product.name = name
            product.manufacturer = manufacturer
            product.photo = photo
            product.purchaseDate = purchaseDate
            product.warrantyStartDate = warrantyStartDate
            product.warrantyMonths = warrantyMonths.int16Value
            product.shouldNotify = shouldNotify
        }
        
    }
    
}
