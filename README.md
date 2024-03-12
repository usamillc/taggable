# Taggable

Taggable は[森羅プロジェクト](http://shinra-project.info)での固有表現抽出アノテーションデータ作成のために開発された Web アプリケーションです。日本語Mediawikiのページに拡張固有表現をアノテーションする目的で開発されましたが、汎用的な日本語テキストのタグ付け Web アプリケーションとして利用可能です。

Taggable でできること:
* 複数人でのマニュアルアノテーション
* Web 上の日本語テキストを取り込み
* Plan text と HTML の両方の offset 対応
* アノテーションラベルの独自定義
* 複数人でのアノテーション結果を比較検討

## 動作環境

Taggable は Ruby 2.6、Rails 5 にて開発・運用されました。それ以外のバージョンでの動作は保証しません。

## Setup

1. この repository を clone

    $ git clone https://github.com/usamillc/taggable.git

2. bundle install

clone したディレクトリ内でコマンドを実行:

    $ cd taggable
    $ bundle install

3. `bundle exec rails db:setup` で DB を準備する
4. `bundle exec rails s` で Rails サーバーを起動する

## 運用

運用時は docker image を作成し、k8s などのコンテナ実行環境にて運用することを推奨します。repository 内の `Dockerfile` を利用することで必要な docker image を作成できます。

docker image の作成:

    $ docker build .

## License

[MITライセンス](https://github.com/usamillc/taggable?tab=MIT-1-ov-file)にて公開しています。
