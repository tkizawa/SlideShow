# SlideShow

SlideShow は、指定した画像フォルダ内の画像を一定間隔で全画面表示する WPF アプリです。

## できること

- 画像フォルダを選択してスライドショーを開始
- 切り替え間隔を秒単位で指定
- JPG、JPEG、PNG、BMP、GIF、WEBP に対応
- 前回の画像フォルダ、切り替え時間、設定ウィンドウ位置を保存

## 使い方

1. アプリを起動します。
2. 画像フォルダを選択します。
3. 切り替え間隔を秒で入力します。
4. 開始 を押すとスライドショーが始まります。
5. スライドショー中は Esc キーで終了します。

## 設定の保存先

設定は、実行ユーザーの LocalAppData 配下の次のファイルに保存されます。

- %LOCALAPPDATA%\SlideShow\settings.json

例:

- C:\Users\tomok\AppData\Local\SlideShow\settings.json

保存される内容:

- 画像フォルダパス
- 切り替え時間
- 設定ウィンドウの位置

## 開発環境での実行

前提:

- .NET SDK
- Windows

実行コマンド:

```powershell
dotnet run
```

## ビルド

```powershell
dotnet build
```

## インストーラ作成

Inno Setup 6 を使用します。

実行方法:

- installer/Build-Installer.cmd
- installer/Build-Installer.ps1

生成されるセットアップ:

- installer/output/SlideShow-1.0.0.0-Setup.exe

インストール先:

- C:\Users\tomok\AppData\Local\Programs\SlideShow

補足:

- スタートメニューにショートカットを作成します。
- インストーラの詳細は installer/README.md を参照してください。