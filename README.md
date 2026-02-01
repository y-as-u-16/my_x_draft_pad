# X Draft Pad

X（旧Twitter）への投稿テキストを下書き・管理するためのFlutterアプリです。文字数をリアルタイムで確認しながら推敲し、ワンタップでXに共有できます。

## 主な機能

- **下書きの作成・編集・削除** — SQLiteによるローカル保存。オフラインで動作します
- **リアルタイム文字数カウント** — 絵文字にも対応。上限超過時は赤色で警告表示
- **Xへの共有** — OS共有シートを利用してXの投稿画面にテキストを転送
- **設定** — 文字数上限の変更（デフォルト280）、ダーク/ライトテーマの切り替え
- **広告** — Google AdMob バナー広告

## スクリーンショット

| 下書き一覧 | 編集画面 | 設定画面 |
|:---:|:---:|:---:|
| タイムライン風リスト | X風テキスト入力 + 円形プログレスカウンター | テーマ切り替え・文字数上限設定 |

## 技術スタック

| カテゴリ | 技術 |
|---------|------|
| フレームワーク | Flutter (Dart) |
| アーキテクチャ | Clean Architecture + MVVM |
| 状態管理 | Provider |
| ルーティング | go_router |
| DI | get_it |
| DB | sqflite (SQLite) |
| 共有 | share_plus |
| 広告 | google_mobile_ads |
| 設定保存 | shared_preferences |
| 環境変数 | flutter_dotenv |

## セットアップ

### 前提条件

- Flutter SDK 3.9.2 以上

### インストール・起動

```bash
# 依存パッケージの取得
flutter pub get

# 開発実行
flutter run

# リリースビルド
flutter build apk      # Android
flutter build ios       # iOS
```

### 環境変数の設定（広告）

プロジェクトルートに `.env` ファイルを作成し、AdMobの広告ユニットIDを設定してください。未設定の場合はテスト広告が表示されます。

```
ADMOB_BANNER_AD_UNIT_ID=your_ad_unit_id
```

## ディレクトリ構成

```
lib/
├── main.dart                 # エントリポイント
├── ads/                      # 広告管理
├── core/
│   ├── constants/            # カラー、サイズ、DB定数、広告ID
│   ├── di/                   # 依存性注入（GetIt）
│   ├── router/               # GoRouterによるルーティング
│   └── utils/                # ユーティリティ
├── data/
│   ├── datasources/          # ローカルデータソース
│   ├── db/                   # SQLiteデータベース
│   ├── models/               # データモデル
│   └── repositories/         # リポジトリ実装
├── domain/
│   ├── entities/             # ドメインエンティティ
│   ├── repositories/         # リポジトリインターフェース
│   └── usecases/             # ユースケース
└── presentation/
    ├── screens/              # 画面（一覧・編集・設定）
    ├── viewmodels/           # ビューモデル
    └── widgets/              # 共通ウィジェット
```

## ライセンス

このプロジェクトのライセンスについては、リポジトリの管理者にお問い合わせください。
