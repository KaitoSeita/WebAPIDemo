# WebAPIDemoApp
## 環境
Language：Swift
- Version：5.9
- Xcode：15.0
## 概要
QiitaのAPIを使用して指定したタグを含む記事をリストで一覧表示し、リストをタップするとURLを通じて記事を表示するアプリです。APIを通じてJSON形式のデータを取得したあと、デコードをして一覧表示させるだけの単純なアプリですが、UX向上をメインテーマとしています。無限スクロール、Pull-to-Refresh、非同期処理、エラーハンドリングを導入することで、ユーザーが違和感なく、低遅延で使用できることによるストレス軽減や、APIのリクエストのコスト低下などが期待されます。    
QiitaにAPIの通信処理について詳しい内容を掲載しています。     
[【SwiftUI】API通信でデータを取得してみた](https://qiita.com/kaito-seita/items/dbddf34d56d4f325d48a)

![ezgif com-video-to-gif (4)](https://github.com/KaitoSeita/WebAPIDemoApp/assets/113151647/6c554da3-dc59-4f3c-a02c-023eb4d64553)
![ezgif com-video-to-gif (6)](https://github.com/KaitoSeita/WebAPIDemoApp/assets/113151647/50d7c370-5d5b-460c-99fa-a6404df0df1f)
![ezgif com-video-to-gif (7)](https://github.com/KaitoSeita/WebAPIDemoApp/assets/113151647/10d42744-6842-4646-8b81-39b42db9c11e)
## 開発の背景
[AuthenticationDemoApp](https://github.com/KaitoSeita/AuthenticationDemoApp)を制作後、かつて作っていたAPIを使用した通信アプリをリファクタリングすることでUXの向上であったり、アプリの完成度を高めることができるのではないかと思い、制作しました。以前制作していたものはSwift Concurrencyを使用した非同期処理や、無限スクロール、エラーハンドリング、extensionなどは当然なかったので、これまで得た知識のアウトプットという意味もあります。また、今回はアーキテクチャとしてMVVMを採用しました。[AuthenticationDemoApp](https://github.com/KaitoSeita/AuthenticationDemoApp)では、VIPERアーキテクチャを採用しましたが、ファイル数が膨大になってしまい、プロジェクト全体の見通しが悪くなってしまった印象があるので、シンプルにMVVM+API通信という形で構成しています。
## アーキテクチャ
### MVVM
#### アーキテクチャの概要
MVVMとは、`Model`、`View`、`ViewModel`の3つから構成されるアーキテクチャであり、`View`のイベント通知を`ViewModel`が取得して、それに応じた処理を行い、値を返します。`Model`は主にデータの構造などを定義します。今回はサーバを介した通信処理があるので、それは別で実装するようにしています。
##### View
`ViewModel`に対して画面表示時やタップ時にイベントを通知して、リスト表示、更新を行います。
```Swift
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
```
##### ViewModel
`View`から受け取ったイベント通知に対して更新処理を行います。無限スクロールや初期化、データの追加などが行えるようにしています。
```Swift
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
        ...
    }
    
    func initializeArticle() {
        ...
    }
    
    func loadNext(id: UUID) {
        ...
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
        ...
    }
}
```
##### Model
JSONに対応したデータ構造と、デコードしたデータに対応したデータ構造を定義しています。
```Swift
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
```
## 具体的な動作とそのコードについて
#### 無限スクロール
無限スクロールとは、記事を一度に大量に取得するものとは異なり、少しずつ取得してリストの下までいったら自動で次の記事を取得することで、データが存在する限りずっと下にスクロールできるというものです。一度の記事取得では量が少ないので、サーバーへの負荷が少なく、表示速度も速いというメリットがあります。一方で、リクエスト回数が増えてしまう可能性もあるので、条件にあった活用が必要です。    

![ezgif com-video-to-gif (3)](https://github.com/KaitoSeita/WebAPIDemoApp/assets/113151647/5ade559b-b913-4b37-8e61-5b03fd686a6a)    

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
基本的な定義の部分は次のような感じです。`URLSession`と`JSONDecoder`をそれぞれ定義しています。
```Swift
protocol APIServiceProtocol {
    
    var session: URLSession { get }
    var decoder: JSONDecoder { get }
    
    func sendRequest<Request: APIRequestTypeProtocol>(request: Request) async -> Result<Request.Response, Error>
}

struct APIService: APIServiceProtocol {
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    let decoder: JSONDecoder = JSONDecoder()
    
}
```
つづいて本体です。`URLSession`ではよく、`URLSession.dataTask`を用いることが多いですが、これは非同期処理に対応していないため、`async throws`で定義される`URLSession.data`を使用しています。エラーが変数として取り出すことができないので、do-catch文を使用してエラーハンドリングしています。
また、処理の成功、失敗は非同期な関数でよく使用される`Result`型で返却して、`ViewModel`側でswitchによる分岐をさせるようにしています。
```Swift
extension APIService {
    
    func sendRequest<Request: APIRequestTypeProtocol>(request: Request) async -> Result<Request.Response, Error> {
        do {
            let result = try? await session.data(for: request.buildURLRequest())
            // レスポンスが存在するかどうか
            guard result?.1 is HTTPURLResponse else {
                return .failure(APIError.noResponse)
            }
            // レスポンスのステータスコードを確認
            guard let response = result?.1 as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                return .failure(APIError.invalidStatusCode)
            }
            // データが存在すればデコードを開始
            if let data = result?.0 {
                
                let decodedData = try decoder.decode(Request.Response.self, from: data)
                
                return .success(decodedData)
            } else {
                return .failure(APIError.noData)
            }
        } catch {
            // デコーディングエラーを判定
            if error is DecodingError {
                
                return .failure(APIError.decodingError)
            } else if let error = error as NSError? {
                // 通常のエラーとタイムアウトを判定
                if error.code == NSURLErrorTimedOut {
                    
                    return .failure(APIError.networkTimeOut)
                } else {
                    
                    return .failure(APIError.unowned)
                }
            }
        }
    }
}
```
