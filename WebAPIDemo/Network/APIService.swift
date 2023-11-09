//
//  APIService.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/05.
//

import SwiftUI

protocol APIServiceProtocol {
    
    var session: URLSession { get }
    var decoder: JSONDecoder { get }
    
    func sendRequest<Request: APIRequestTypeProtocol>(request: Request) async throws -> Result<Request.Response, Error>
}

struct APIService: APIServiceProtocol {
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    let decoder: JSONDecoder = JSONDecoder()
    
}

extension APIService {
    
    func sendRequest<Request: APIRequestTypeProtocol>(request: Request) async -> Result<Request.Response, Error> {
        do {
            let result: (Data, URLResponse)? = try await session.data(for: request.buildURLRequest())

            guard result?.1 is HTTPURLResponse else {
                return .failure(APIError.noResponse)
            }

            guard let response = result?.1 as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                return .failure(APIError.invalidStatusCode)
            }
            
            if let data = result?.0 {
                
                let decodedData = try decoder.decode(Request.Response.self, from: data)
                
                return .success(decodedData)
            } else {
                return .failure(APIError.noData)
            }
            
        } catch {
            if error is DecodingError {
                
                return .failure(APIError.decodingError)
            } else if let error = error as NSError? {
                
                if error.code == NSURLErrorTimedOut {
                    
                    return .failure(APIError.networkTimeOut)
                } else {
                    
                    return .failure(APIError.unowned)
                }
            }
        }
    }
}

