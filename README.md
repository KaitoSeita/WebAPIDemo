# WebAPIDemoApp
## 環境
Language：Swift
- Version：5.9
- Xcode：15.0
## 概要
QiitaのAPIを使用して指定したタグを含む記事をリストで一覧表示し、リストをタップするとURLを通じて記事を表示するアプリです。APIを通じてJSON形式のデータを取得したあと、デコードをして一覧表示させるだけの単純なアプリですが、UX向上をメインテーマとしています。無限スクロール、Pull-to-Refresh、非同期処理、エラーハンドリングを導入することで、ユーザーが違和感なく、低遅延で使用できることによるストレス軽減や、APIのリクエストのコスト低下などが期待されます。
## 開発の背景
[AuthenticationDemoApp](https://github.com/KaitoSeita/AuthenticationDemoApp)を制作後、かつて作っていたAPIを使用した通信アプリをリファクタリングすることでUXの向上であったり、アプリの完成度を高めることができるのではないかと思い、制作しました。以前制作していたものはSwift Concurrencyを使用した非同期処理や、無限スクロール、エラーハンドリング、extensionなどは当然なかったので、これまで得た知識のアウトプットという意味もあります。また、今回はアーキテクチャとしてMVVMを採用しました。[AuthenticationDemoApp](https://github.com/KaitoSeita/AuthenticationDemoApp)では、VIPERアーキテクチャを採用しましたが、ファイル数が膨大になってしまい、プロジェクト全体の見通しが悪くなってしまった印象があるので、シンプルにMVVM+API通信という形で構成しています。
## アーキテクチャ
### MVVM
#### アーキテクチャの概要

## 動作フロー図


## 具体的な動作とそのコードについて
