# サニックスアイズ
サニックスアイズの利用にはnode.js / npm が必要です。
## node / npm をインストール
https://nodejs.org/en/

からインストールできます。
いまはnode.jsにnpmもセットになっているため、node.jsをインストールすればnpmも使えるようになります。

## プロジェクトをクローン後、nodeの依存ライブラリをインストール

```
$ git clone https://sanix-pv.backlog.jp/git/EYE_HOME/sanix-eyes.git
$ cd sanix-eyes
$ npm install
```
npm installとすることで、package.jsonに含まれる依存ファイルが自動的に取得できます。

## htmlの生成

```
$ grunt deploy
```
で、deployフォルダにhtmlが出来ます。ブラウザから開くことでデバッグも可能です。

## 本番環境(S3)にデプロイする

gruntで自動的にデプロイするようにしてあるつもりなのですが、うまく動きません。
aws-cliでコピーしてください。

```
$ aws s3 cp deploy s3://sanix-data-analysis/ --recursive
```

## s3auth.jsonファイルの設定

プロジェクトフォルダ(Gruntfile.jsのあるフォルダ)にs3auth.jsonというファイルを作成してください。

```
{
	"key": "<AWS ACCESS KEY ID>",
	"secret": "<AWS SECRET KEY ID>"
}
```
ソースにキー情報を直書きするのはセキュリティ上推奨されていませんので上記のようにしています。