//
//  NetworkService.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import Foundation

func getRequest<T: Decodable>(fromAmount: Double, fromCurrency: String, toCurrency: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
    
    guard let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(fromAmount)-\(fromCurrency)/\(toCurrency)/latest") else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        DispatchQueue.main.async {
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            guard error == nil else {
                completion(.failure(.unidentified))
                return
            }
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.jsonSerilizationError))
            }
        }
    }.resume()
}

