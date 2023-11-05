# WebAPIDemoApp
## 環境
Language：Swift
- Version：5.9
- Xcode：15.0
## 概要
このアプリはQiitaの記事をリスト表示させるシンプルなアプリです。
細かい機能は今後のアップデートで追加していく予定ですが、主にMVVMのアーキテクチャの導入、Swift Concurrencyを使用した非同期でのWebAPI通信の実装などを目的として制作しています。
## アーキテクチャ
### MVVM
MVVMとは、`Model`、`View`、`ViewModel`から構成されるアーキテクチャです。
