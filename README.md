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
$ gulp default
```

でビルド・s3へのデプロイが完了します。

ビルドだけ

```
$ gulp build
```

s3へのデプロイ(アップロード)だけ

```
$ gulp upload
```

## ページの追加方法

json/_common.jsonを修正することでメニューが追加できます。
対応するページはsrc/以下にjadeで記述してください。
スクリプトは、jade内に直書きしてもいいですが、分離してCoffeeScriptで記述したほうが可読性が上がります。