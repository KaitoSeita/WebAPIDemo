//
//  APIError.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/07.
//

enum APIError: Error {
    case unowned
    case networkTimeOut
    case invalidStatusCode
    case noData
    case noResponse
    case decodingError
}

