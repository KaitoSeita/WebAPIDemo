//
//  Article.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/05.
//

struct Article: Codable, Hashable {
    let comments_count: Int?
    let created_at: String?
    let likes_count: Int?
    let title: String?
    let url: String?
    let page_views_count: Int?
}
