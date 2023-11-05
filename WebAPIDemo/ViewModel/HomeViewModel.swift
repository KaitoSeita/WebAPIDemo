//
//  HomeViewModel.swift
//  WebAPIDemo
//
//  Created by kaito-seita on 2023/11/05.
//

// データ通信はGatewayとしてファイルを完全に分離させた方がいい

import SwiftUI

// プロトコル定義(メソッド定義)
protocol HomeViewModelProtocol: ObservableObject {
    
}

// ViewModel本体
final class HomeViewModel: HomeViewModelProtocol {
    @Published var isssf = ""
    
}

// メソッドの追加
extension HomeViewModel {
    
}
