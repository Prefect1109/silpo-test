//
//  Networking.swift
//  Silpo
//
//  Created by Prefect on 23.10.2021.
//

import Foundation
import Alamofire

class Networking {
    
    private init() { }
    
    static var shared = Networking()
    
    private let jsonDecoder = JSONDecoder()
    
    func fetchProduct(by barcode: String, completion: @escaping(Product?, String?) -> Void) {
        
        let url = URL(string: "http://23.88.123.99/product/\(barcode)")!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            
            // Data handling
            if let safeData = data {
                safeData.printJSON()
                let testData = self.parseFetchProductData(safeData)
                completion(testData, nil)
            }
            
            // Error handling
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
        }.resume()
    }
    
    func parseFetchProductData(_ data: Data) -> Product? {
        do {
            let decodedData = try JSONDecoder().decode(Product.self, from: data)
            return decodedData
        } catch {
            print("Error with decoding data-parseFetchProductData")
        }
        return nil
    }
    
    func fetchBlackListItems(completion: @escaping([BlackListItem]?, String?) -> Void) {
        
        let url = URL(string: "http://23.88.123.99/blacklist")!
        print(url)
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            
            // Data handling
            if let safeData = data {
                safeData.printJSON()
                let testData = self.parseFetchBlackListItems(safeData)
                completion(testData, nil)
            }
            
            // Error handling
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
        }.resume()
    }
    
    func parseFetchBlackListItems(_ data: Data) -> [BlackListItem]? {
        do {
            let decodedData = try JSONDecoder().decode([BlackListItem].self, from: data)
            return decodedData
        } catch {
            print("Error with decoding data-parseFetchBlackListItems")
        }
        return nil
    }
    
    func removeBlackListItem(by id: String, completion: @escaping(OK?, String?) -> Void) {
        
        let url = URL(string: "http://23.88.123.99/blacklist/\(id)/")!
        print(url)
        let request = try! URLRequest(url: url, method: .post)
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            
            // Data handling
            if let safeData = data {
                safeData.printJSON()
                let testData = self.parseOK(safeData)
                completion(testData, nil)
            }
            
            // Error handling
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
        }.resume()
    }
    
    func parseOK(_ data: Data) -> OK? {
        do {
            let decodedData = try JSONDecoder().decode(OK.self, from: data)
            return decodedData
        } catch {
            print("Error with decoding data")
        }
        return nil
    }
    
    func addBlackListItem(with name: String, completion: @escaping(OK?, String?) -> Void) {
        
        let url = URL(string: "http://23.88.123.99/blacklist/")!
        print(url)
        var request = try! URLRequest(url: url, method: .post)
        
        let json: [String: Any] = ["name": "\(name)"]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        jsonData.printJSON()
        request.httpMethod = "POST"

        let session = URLSession(configuration: .default)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request) { (data, response, error) in
            
            // Data handling
            if let safeData = data {
                safeData.printJSON()
                let testData = self.parseOK(safeData)
                completion(testData, nil)
            }
            
            // Error handling
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
        }.resume()
    }
}

// MARK: - Mocks
extension Networking {
    
    func productMock() -> Product {
        Product(barcode: "barcode",
               name: "Напій енергетичний Hell Nova безалкогольний газований з/б",
               mass: "250",
               image_url: "https://img.fozzyshop.com.ua/72362-large_default/napitok-energeticheskij-red-bull.jpg",
               price: "19",
               components: [ProductComponent(id: 1, is_healthy: true, name: "Fake", description: "SUKA", is_blacklisted: false),
                            ProductComponent(id: 2, is_healthy: false, name: "Fake2", description: "SUKA", is_blacklisted: false),
                            ProductComponent(id: 3, is_healthy: true, name: "Fake3", description: "SUKA", is_blacklisted: false),
                            ProductComponent(id: 1, is_healthy: false, name: "Fake4", description: "SUKA", is_blacklisted: true),
                           ProductComponent(id: 2, is_healthy: true, name: "Fake5", description: "SUKA", is_blacklisted: true),
                               ProductComponent(id: 3, is_healthy: true, name: "Fake6", description: "SUKA", is_blacklisted: true)],
                package: "String",
                utilize: "Vo",
               is_gmo: true,
               is_organic: true,
               is_vegetarian: true,
               is_vegan: true,
               healthy_components_percentage: "80",
               proteins: "12",
               fats: "123",
               carbohydrates: "1234")
    }
}

import Foundation

extension Data {
    func printJSON() {
        if let JSONString = String(data: self, encoding: String.Encoding.utf8) {
            print(JSONString)
        }
    }
}
