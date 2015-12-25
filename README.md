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
$ gulp deploy
```

でs3へのデプロイが完了します。