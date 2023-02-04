//
//  NetworkError.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case invalidData
    case unidentified
    case jsonSerilizationError
}
