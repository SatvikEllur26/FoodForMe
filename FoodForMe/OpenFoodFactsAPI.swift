// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import Foundation

class OpenFoodFactsAPI {
    
    // base URL for product search by keyword
    static let searchBaseURL = "https://world.openfoodfacts.org/cgi/search.pl"
    // base url for product search by barcode
    static let barcodeBaseURL = "https://world.openfoodfacts.org/api/v0/product"

    // only gets name and allergens from openfoodfacts
    struct Product {
        let name: String
        let allergens: [String]
    }

    // function for keyword search
    static func searchProducts(keywords: String, completion: @escaping (Result<[Product], Error>) -> Void) {
        let urlString = "\(searchBaseURL)?search_terms=\(keywords)&json=true"
        // makes sure url is correct
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // makes sure data is received
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            // parse the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let productsArray = json["products"] as? [[String: Any]] {
                    
                    let products: [Product] = productsArray.compactMap { productDict in
                        guard let name = productDict["product_name"] as? String else { return nil }
                        let allergens = productDict["allergens_tags"] as? [String] ?? []
                        return Product(name: name, allergens: allergens)
                    }
                    completion(.success(products))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // function for barcode search
    static func fetchProduct(by barcode: String, completion: @escaping (Result<Product, Error>) -> Void) {
        let urlString = "\(barcodeBaseURL)/\(barcode).json"
        // makes sure url is correct
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // makes sure data is received
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            // parse the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let productDict = json["product"] as? [String: Any],
                   let productName = productDict["product_name"] as? String {
                    
                    let allergens = productDict["allergens_tags"] as? [String] ?? []
                    let product = Product(name: productName, allergens: allergens)
                    completion(.success(product))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure or product not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
