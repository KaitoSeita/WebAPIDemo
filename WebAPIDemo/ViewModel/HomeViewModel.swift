//
//  HomeViewModel.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/05.
//

import SwiftUI

protocol HomeViewModelProtocol: ObservableObject {
    func getArticleSortedByTags()
    func initializeArticle()
    func loadNext(id: UUID)
}

final class HomeViewModel: HomeViewModelProtocol {
    @Published var article: [ArticleList] = []
    @Published var errorMessage = ""
    @Published var currentPage = 1
    
    let apiService = APIService()
}

extension HomeViewModel {
    
    func getArticleSortedByTags() {
        Task { @MainActor in
            let request = ArticleSortedByTagsRequest(tag: "swiftui", page: String(currentPage))
            
            let result = await apiService.sendRequest(request: request)
            switch result {
            case .success(let data):
                for article in data {
                    self.article.append(
                        ArticleList(commentsCount: article.comments_count ?? 0,
                                    createdAt: dateFormatter(date: article.created_at!),
                                    likesCount: article.likes_count ?? 0,
                                    tags: article.tags,
                                    title: article.title,
                                    url: article.url,
                                    user: article.user,
                                    viewCount: article.page_views_count ?? 0)
                        )
                }
            case .failure(let error):
                print(error)
                setErrorMessage(error: error)
            }
            
        }
    }
    
    func initializeArticle() {
        Task { @MainActor in
            let request = ArticleSortedByTagsRequest(tag: "swiftui", page: "1")
            
            let result = await apiService.sendRequest(request: request)
            switch result {
            case .success(let data):
                article.removeAll()
                for article in data {
                    self.article.append(
                        ArticleList(commentsCount: article.comments_count ?? 0,
                                    createdAt: dateFormatter(date: article.created_at!),
                                    likesCount: article.likes_count ?? 0,
                                    tags: article.tags,
                                    title: article.title,
                                    url: article.url,
                                    user: article.user,
                                    viewCount: article.page_views_count ?? 0)
                        )
                }
            case .failure(let error):
                print(error)
                setErrorMessage(error: error)
            }
        }
    }
    
    func loadNext(id: UUID) {
        if article[article.endIndex - 5].id == id {
            currentPage += 1
            getArticleSortedByTags()
        }
    }
    
    private func dateFormatter(date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60) // UTC+9時間
        let formatDate = formatter.date(from: date)
        formatter.dateFormat = "yyyy年MM月dd日"
        
        return formatter.string(from: formatDate!)
    }
    
    private func setErrorMessage(error: Error) {
        if let error = error as? APIError {
            switch error {
            case .unowned:
                errorMessage = ""
            case .networkTimeOut:
                errorMessage = ""
            case .invalidStatusCode:
                errorMessage = ""
            case .noData:
                errorMessage = ""
            case .noResponse:
                errorMessage = ""
            case .decodingError:
                errorMessage = ""
            }
        }
    }
}
