//
//  ExchangeWorker.swift
//  Currency Converter
//
//  Created by Alex on 5.02.23.
//

import Foundation

struct ExchangeWorker {
    
    struct Body {
        let amount: Double
        let inputCurrency: String
        let outputCurrency: String
    }
    
    struct Output: Decodable {
        let amount: String
        let currency: String
    }
    
    let numberOfFreeConversions: Int = 5
    let commissionAmount: Double = 0.007
    
    var run: (Body, @escaping (Result<Output, NetworkError>) -> Void) -> Void
}

extension ExchangeWorker {
    
    static var currency: Self {
        Self { input, completion in
            guard let exchangeAPI = Bundle.main.object(forInfoDictionaryKey: "ExchangeAPI") else { return }
            let stringUrl = "\(exchangeAPI)\(input.amount)-\(input.inputCurrency)/\(input.outputCurrency)/latest"
            
            guard let url = URL(string: stringUrl) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        return completion(.failure(.invalidResponse))
                    }
                    
                    guard error == nil else {
                        return completion(.failure(.unidentified))
                    }
                    
                    guard let data = data else {
                        return completion(.failure(.invalidData))
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(Output.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(.jsonSerilizationError))
                    }
                }
            }.resume()
        }
    }
}
