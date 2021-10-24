//
//  Product.swift
//  Silpo
//
//  Created by Prefect on 23.10.2021.
//

import Foundation

struct Product: Codable {
    
    let barcode: String
    let name: String
    let mass: String

    let image_url: String
    let price: String

    let components: [ProductComponent]?
    let package: String
    let utilize: String

    let is_gmo: Bool
    let is_organic: Bool

    let is_vegetarian: Bool
    let is_vegan: Bool
    let healthy_components_percentage: String

    let proteins: String
    let fats: String
    let carbohydrates: String

}

struct ProductComponent: Codable {
    let id: Int
    let is_healthy: Bool
    let name: String
    let description: String
    let is_blacklisted: Bool
}
