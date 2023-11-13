# WebAPIDemoApp
## 環境
Language：Swift
- Version：5.9
- Xcode：15.0
## 概要
QiitaのAPIを使用して指定したタグを含む記事をリストで一覧表示し、リストをタップするとURLを通じて記事を表示するアプリです。APIを通じてJSON形式のデータを取得したあと、デコードをして一覧表示させるだけの単純なアプリですが、UX向上をメインテーマとしています。無限スクロール、Pull-to-Refresh、非同期処理、エラーハンドリングを導入することで、ユーザーが違和感なく、低遅延で使用できることによるストレス軽減や、APIのリクエストのコスト低下などが期待されます。    
QiitaにAPIの通信処理について詳しい内容を掲載しています。     
[【SwiftUI】API通信でデータを取得してみた](https://qiita.com/kaito-seita/items/dbddf34d56d4f325d48a)
## 開発の背景
[AuthenticationDemoApp](https://github.com/KaitoSeita/AuthenticationDemoApp)を制作後、かつて作っていたAPIを使用した通信アプリをリファクタリングすることでUXの向上であったり、アプリの完成度を高めることができるのではないかと思い、制作しました。以前制作していたものはSwift Concurrencyを使用した非同期処理や、無限スクロール、エラーハンドリング、extensionなどは当然なかったので、これまで得た知識のアウトプットという意味もあります。また、今回はアーキテクチャとしてMVVMを採用しました。[AuthenticationDemoApp](https://github.com/KaitoSeita/AuthenticationDemoApp)では、VIPERアーキテクチャを採用しましたが、ファイル数が膨大になってしまい、プロジェクト全体の見通しが悪くなってしまった印象があるので、シンプルにMVVM+API通信という形で構成しています。
## アーキテクチャ
### MVVM
#### アーキテクチャの概要

## 動作フロー図


## 具体的な動作とそのコードについて
#### APIRequest
まずはプロトコルからです。プロトコルにおいては必要な変数、`Response`を格納する型を定義します。`Response`をあえて`associatedtype`としていることについて説明します。今回はリクエスト内容が、タグを含む記事の一覧表示のみとなっていますが、現実的にはユーザー情報だけの取得であったり、タグではなく通常検索での取得といった複数のケースが考えられ、プロトコルだけは共通して使用したいため、`Response`の型をそれぞれで変更できるようにしています。
```Swift
protocol APIRequestTypeProtocol {
    associatedtype Response: Codable
    
    var baseURL: URL? { get }
    var httpMethod: String { get }
    var relativePath: String { get }

    func buildURLRequest() -> URLRequest
}
```
つづいてリクエストに関するコードです。`page`はリクエストの際に値を変えることで取得データが重複しないようになるので、インスタンス生成時に`page`を取得します。また、`relativePath`についてもタグを指定しないといけないので、変更が可能になるように同様にしてインスタンス生成時に取得できるようにしています。
`request.timeoutInterval`はタイムアウトの基準値を設定しています。
```Swift
struct ArticleSortedByTagsRequest: APIRequestTypeProtocol {
    typealias Response = [Article]
    
    let baseURL: URL? = URL(string: "https://qiita.com/api/v2/tags")!
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
```
#### APIService(クライアント)

#### 無限スクロール
無限スクロールとは、記事を一度に大量に取得するものとは異なり、少しずつ取得してリストの下までいったら自動で次の記事を取得することで、データが存在する限りずっと下にスクロールできるというものです。一度の記事取得では量が少ないので、サーバーへの負荷が少なく、表示速度も速いというメリットがあります。一方で、リクエスト回数が増えてしまう可能性もあるので、条件にあった活用が必要です。
コードについて説明していきます。`ViewModel`に`id`を引数に指定したメソッドを定義しました。記事データが入った配列に対してインデックスで`article.endIndex - 5`として指定しています。一番最後の記事から5つ前の記事であれば、`page`を加算して新しい記事を取得するという感じになっています。
```Swift
func loadNext(id: UUID) {
    if article[article.endIndex - 5].id == id {
        currentPage += 1
        getArticleSortedByTags()
    }
}
```
これは呼び出し元のコードです。リストの各行が表示される度に、データが最後から5つ前かどうかをチェックするようにしています。
```Swift
List(homeViewModel.article) { data in
    ...
    .onAppear {
        homeViewModel.loadNext(id: data.id)
    }
}
```
#### 非同期処理とエラーハンドリング



