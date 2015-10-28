# Gruntを用いたJade/CoffeeScriptのコンパイル環境の雛形
HTMLのマークアップは慣れていない人にはきつく、またタグを閉じ忘れてもエラーがでないなどデバッグが難しい。
なので、JadeというHTMLを簡略化したマークアップ言語を用いてHTMLをマークアップできるようにする。
あわせて、JavaScriptもCoffeeScriptでマークアップ出来るようにする。
今回は、node.js環境ではよく使われているGruntというツールを用いて、これらの作業を自動化する。

参考URL: http://qiita.com/nowri/items/242bc8a5d94e85d33a1e

## node.jsをインストール
  https://nodejs.org/en/
  からインストーラを入手してインストール

## grunt-cliをインストール

```
$ npm install -g grunt-cli
```

## プロジェクトフォルダを作成、プロジェクトを初期化

```
$ mkdir jade-sample
$ cd jade-sample
$ npm init -y
```

## プロジェクトフォルダにgrunt / grunt-contrib-jade / grunt-contrib-coffee / grunt-contrib-watchをインストール

```
$ npm install grunt grunt-contrib-jade grunt-contrib-coffee grunt-contrib-watch
```

## Grantfile.jsを作成

```
module.exports = function(grunt) {

  'use strict';

  grunt.initConfig({
    watch : {
      deploy:{
        files:['**'],
        tasks:['deploy']
      }
    },
    coffee: {
      deploy:{
        files:[{
          expand:true,
          cwd:'coffee',
          src:[
            '*.coffee'
          ],
          dest:'deploy',
          ext:'.js'
        }]
      }
    },
    jade: {
      options:{
        data:jadeDataFunc(),
        pretty:true // コードを整形出力するか
      },
      deploy:{
        files:[{
          expand:true,
          cwd:'jade',
          src:[
            '*.jade'
          ],
          dest:'deploy',
          ext:'.html'
        }],
      }
    }
  });
  function jadeDataFunc() {
    return function(dest, srcAr) {
      var _ = grunt.util._,
        regDest = /\/([A-Za-z_0-9-]+?)\.html/,
        destName = dest.match(regDest)[1],
        data;
      try {
        data = grunt.file.readJSON("json/_common.json");
      } catch(e) {
        data = {};
      }
      return _.extend({
        page:destName
      }, data);
    };
  }

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jade');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.registerTask('deploy', ['jade', 'coffee']);

  grunt.loadTasks('tasks');

  grunt.registerTask('default', ['deploy', 'coffee']);
};
```

## デプロイの実行
以下でdeployフォルダにhtml、jsが生成されえる

```
$ grunt deploy
```

## 継続的実行
以下で、ファイルに変更が加えられるたびに自動変換される(デバッグに便利)

```
$ grunt deploy
```

## 課題
エラーがでた場合、ソースのどこかが特定できない。
Gruntの設定でjade / coffeeの何行目にあたるかをわかるようにできるという話もあるが、JavaScriptのままデバッグしたほうが効率がよいという説もある。