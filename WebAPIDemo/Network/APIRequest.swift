//
//  APIRequest.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/06.
//

import SwiftUI

protocol APIRequestTypeProtocol {
    associatedtype Response: Codable        // ArticleとUserで使い分けたいので準拠先で定義させるようにする
    
    var baseURL: URL? { get }
    var httpMethod: String { get }
    var relativePath: String { get }

    func buildURLRequest() -> URLRequest
}

struct ArticleSortedByTagsRequest: APIRequestTypeProtocol {
    typealias Response = [Article]
    
    let baseURL: URL? = URL(string: "https://qiita.com/api/v2/tags")!      // エンドポイントともいう
    let httpMethod: String = "GET"
    var relativePath: String = ""
    let page: String
    
    init(tag: String, page: String) {
        self.page = page
        relativePath += "/\(tag)/items"
    }
    
    func buildURLRequest() -> URLRequest {
        let url = baseURL!.appendingPathComponent(relativePath)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "page", value: page),
            URLQueryItem(name: "per_page", value: "15")
        ]
        
        var request = URLRequest(url: url)
        request.url = components?.url
        request.httpMethod = httpMethod
        request.timeoutInterval = 5
        
        return request
    }
}
