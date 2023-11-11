//
//  Article.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/05.
//

import SwiftUI

struct Article: Codable {
    let comments_count: Int?
    let created_at: String?
    let likes_count: Int?
    let tags: [Tags]
    let title: String
    let url: String
    let user: User
    let page_views_count: Int?
}

struct ArticleList: Identifiable {
    let id = UUID()
    let commentsCount: Int
    let createdAt: String
    let likesCount: Int
    let tags: [Tags]
    let title: String
    let url: String
    let user: User
    let viewCount: Int
}
// title, urlはオプショナルでない
