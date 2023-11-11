//
//  HomeView.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/05.
//

import SwiftUI

struct HomeView: View {
    @StateObject var homeViewModel = HomeViewModel()
    
    @State private var page = 1
    
    var body: some View {
        NavigationStack {
            List(homeViewModel.article) { data in
                ListItemView(title: data.title,
                             user: data.user,
                             likesCount: data.likesCount,
                             createdDate: data.createdAt,
                             viewCount: data.viewCount,
                             tags: data.tags,
                             url: data.url
                )
                .onAppear {
                    homeViewModel.loadNext(id: data.id)
                }
            }
            .listStyle(.plain)
            .refreshable {
                homeViewModel.initializeArticle()
            }
            .onAppear {
                if homeViewModel.article.isEmpty {
                    homeViewModel.initializeArticle()
                }
            }
        }
    }
}

private struct ListItemView: View {
    let title: String?
    let user: User
    let likesCount: Int?
    let createdDate: String?
    let viewCount: Int?
    let tags: [Tags]
    let url: String
    
    var body: some View {
        NavigationLink(destination: WebView(url: URL(string: url)!)) {
            VStack(spacing: 10) {
                HStack {
                    AsyncImage(url: URL(string: user.profile_image_url!)) { image in
                        image
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 40, height:40)
                    } placeholder: {
                        Circle()
                            .foregroundColor(.gray)
                            .frame(width: 40, height:40)
                    }
                    Spacer()
                        .frame(width: 10)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("@\(user.id!)")
                                .font(.system(size: 12, design: .rounded))
                            Text(user.name != "" ? "(\(user.name!))" : "")
                                .font(.system(size: 12, design: .rounded))
                        }
                        Text(createdDate!)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    Spacer()
                }
                Text(title ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 20))
                    .bold()
                    .lineLimit(2)
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag.name)
                            .font(.system(size: 10))
                            .padding(.all, 5)
                            .background(.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    Spacer()
                }
                HStack(spacing: 10) {
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: 12, height: 12)
                    Text("\(likesCount ?? 0)")
                        .font(.system(size: 12))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 150)
        }
    }
}

#Preview {
    HomeView()
}
