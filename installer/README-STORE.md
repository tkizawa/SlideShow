# Microsoft Store 登録・公開ガイド (MSIX パッケージ)

このドキュメントでは、SlideShow アプリを Microsoft Store（Partner Center）に提出・公開する手順を説明します。

---

## 1. 事前準備 (Partner Center アカウント)

1. [Microsoft Partner Center](https://partner.microsoft.com/dashboard) にアクセスし、デベロッパーアカウントでログインします（初回未登録の場合はアカウント登録が必要です）。
2. ダッシュボードで **「新しいアプリを作成」** をクリックし、アプリ名 `SlideShow` を予約します。
3. 登録完了後、画面上の **「パッケージの識別情報」** を確認します：
   - **パッケージ / ID / Name**: 例 `12345TomokazuKizawa.SlideShow`
   - **発行者 / Publisher**: 例 `CN=XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
   - **発行者表示名 / PublisherDisplayName**: 例 `Tomokazu Kizawa`

---

## 2. マニフェストファイルの更新

リポジトリ直下の `Package.appxmanifest` を開き、Partner Center で発行された識別情報に合わせて書き換えます。

```xml
<Identity
  Name="<Partner CenterのPackage Name>"
  Publisher="<Partner CenterのPublisher ID (CN=...)"
  Version="1.0.0.2" />

<Properties>
  <DisplayName>SlideShow</DisplayName>
  <PublisherDisplayName><Partner Centerの発行者表示名></PublisherDisplayName>
  <Logo>assets\store\StoreLogo.png</Logo>
</Properties>
```

---

## 3. パッケージ（MSIX）のビルド手順

### 手順 A: スクリプトによるステージング構成

PowerShell で以下を実行します。

```powershell
installer/Build-MSIX-Layout.ps1
```

実行後、`output/msix_layout` フォルダに MSIX パッケージ化可能なすべてのファイルと `AppxManifest.xml` が配置されます。

### 手順 B: MSIX パッケージの生成

以下のいずれかの方法で `.msix` または `.msixupload` を生成します。

- **方法1 (推奨): MSIX Packaging Tool を使用する**
  1. Microsoft Store から **MSIX Packaging Tool**（無料）をインストールして起動します。
  2. 「アプリケーション パッケージ」を選択し、`output/msix_layout` フォルダを指定して作成します。
- **方法2: Visual Studio のパッケージ化プロジェクト**
  - Visual Studio で `SlideShow.sln` を開き、「アプリのパッケージ化」ウィザードから Partner Center と連携して直接 `.msixupload` を作成・出力できます。
- **方法3: makeappx.exe CLI**
  ```powershell
  makeappx pack /d "output/msix_layout" /p "output/SlideShow-1.0.0.2.msix"
  ```

---

## 4. Microsoft Store (Partner Center) での提出手順

1. **新規提出の作成**:
   - Partner Center のアプリ管理ページで「新規提出」を開始します。
2. **パッケージのアップロード**:
   - 生成した `.msix` または `.msixupload` ファイルをドラッグ＆ドロップします。
3. **ストアリスティング（情報・アセット）の設定**:
   - **説明文**: アプリの特徴（全画面スライドショー、間隔指定、マルチモニタ選択、保存機能など）
   - **スクリーンショット**: 1920x1080 などのアプリ実行中キャプチャ画像（1〜10枚）
   - **ストア用ロゴ**: `assets/store/` 配下のロゴ画像が自動的に適用されるか、アップロードします。
   - **プライバシーポリシー URL**:
     `https://github.com/tkizawa/SlideShow/blob/master/PRIVACY_POLICY.md` を入力します。
4. **年齢制限（IARC）回答**:
   - 簡単な質問事項に回答します（暴力や性的表現を含まないため「全年齢対象」となります）。
5. **価格および適用範囲**:
   - 無料 / 全地域を公開対象として選択。
6. **審査提出**:
   - 「ストアに提出」をクリックします。通常 24〜72 時間程度で自動チェックおよびレビューを経て Microsoft Store に正式公開されます。
