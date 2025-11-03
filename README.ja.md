# autoland

AIエージェントを使ってGitHub PRを自動修正・マージするCLI

## 機能

- OpenなPRの自動検出と処理
- GitHub checksの完了待機
- AIエージェントを使ったレビューコメントの自動修正
- 修正内容の自動コミット・プッシュ
- マージ可否の自動判定とマージ実行

## インストール

```bash
pipx install autoland
```

pipxについては <https://pipx.pypa.io/latest/installation/> を参考にしてください。

## 前提条件

以下のツールがセットアップ済みであること：

- `gh` (GitHub CLI)
- `codex` コマンド（AIコーディングツール）
- Gitリポジトリでの実行

## 使用方法

対象リポジトリのディレクトリで実行：

```bash
autoland
```

## 動作フロー

1. **PR検出**: 最も古いOpenなPRを選択し、対応ブランチにcheckout
2. **Checks待機**: GitHub checksの完了を待機
3. **自動修正**: AIエージェントがレビューコメントを解析し、必要な修正を実行
4. **変更プッシュ**: 修正をコミットし、処理レポートをコメント投稿
5. **再チェック**: 新しいコメントの確認と再修正
6. **マージ実行**: 問題がなければ自動マージ

```mermaid
flowchart TD
  Start(["開始"]) --> Use[["使用方法<br>対象リポジトリで実行: <code>autoland</code>"]]

  subgraph CLI["CLIツールが行う処理"]
    direction TB
    C0{"OpenなPRは存在するか"}
    C1["最も古いOpen PRを選び<br>対応ブランチに checkout"]
    C2["github checksが終わるまで待機"]
    C3["修正エージェントを起動し<br>PRコンテキストを渡す"]
    C6["エージェントが生成したレポートを<br>PRにコメント投稿"]
    C4{"エージェントがcommitを加えた？"}
    C5["push"]
    C8["PRをマージ"]
  end

  subgraph AG["コーディングエージェント"]
    direction TB
    A1["コンテキストを解析"]
    A2{"問題はあるか"}
    A3["必要な修正を実施してcommit"]
    A4_fix["結果レポート（修正内容の詳細）を出力"]
    A4_ok["結果レポート（問題なし）を出力"]
    A_OUT["レポート"]
  end

  Use --> C0
  C0 -- はい --> C1 --> C2
  C0 -- いいえ --> End(["終了"])

  C2 --> C3 --> A1 --> A2
  A2 -- はい --> A3 --> A4_fix --> A_OUT
  A2 -- いいえ --> A4_ok --> A_OUT

  A_OUT --> C6

  C6 --> C4
  C4 -- いいえ（マージ可能） --> C8 --> End
  C4 -- はい（pushするものがある） --> C5 --> C2
```

## 設計方針

- CLIは認証情報を管理せず、既存ツールを活用
- 複雑な判定はAIに委譲し、機械的な判定のみCLI側で実装
- 長時間実行のためタイムスタンプ付きログ出力
