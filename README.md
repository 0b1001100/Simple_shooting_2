# Simple_shooting_2(Alpha0)
## 概要
シンプルなシューティングゲームのアルファ版です。
まだある程度が書きかけなので、今のところゲーム性はありません。<br>
また、今のところデバッグするためのコードをそのまま上げているので、改造したくなった場合は
Simple_shooting_2.pdeの中のStage()辺りを書き換えてください。<br><br>
もし良ければ、衝突判定などで苦戦しているので、
そのコードを書いてPull requestまたはアドバイスしてくれると助かります。<br>
補足:タイルなどは
[Shooting_Maps.pde](https://github.com/0b1001100/Simple_shooting_2/blob/master/Shooting_Maps.pde)
で管理しています。<br><br>
このプロジェクト内のクラスなどの仕様書→
[wiki](https://github.com/0b1001100/Simple_shooting_2/wiki)
## 利用する際の注意点
ソースコードは現状[Processing4.0b2](https://processing.org/)において動作を確認しているので、
実行にはprocessing4.0以上のバージョンを推奨します。
## 動作環境
### 最低環境
CPU:intel core i5 5世代以降<br>
GPU:OpenGL3.0以降対応<br>
メモリ:256MB<br>
ストレージ:10MB<br>
OS:windows7以降64bit
### 推奨環境
CPU:intel core i5 8世代以降<br>
GPU:OpenGL3.0以降対応<br>
メモリ:512MB<br>
ストレージ:10MB<br>
OS:windows10以降64bit
### 動作確認環境
CPU:intel core i7 11700<br>
GPU:intel UHD graphics 750<br>
OS:windows10 64bit

## Todo
### 短期間
- メニューのシステムの追加
- 描画を画面の領域内に限定
### 長期間
- 敵を動かす
- マップの作成
- セーブ機能
- UI·処理の改善
