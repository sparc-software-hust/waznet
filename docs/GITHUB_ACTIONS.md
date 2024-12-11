# Github Actions workflow for mobile app

## Giới thiệu
- Cấu hình thời gian tự động build và đẩy app lên testflight thông qua Github Actions
- Sử dụng command trong Pancake Work để trigger build testflight ngay lập tức

## Mô tả
- Sử dụng server Panchat để làm store để lưu thông tin **merged pull** phục vụ cho flow build
  - ví dụ mỗi lần merge sẽ lưu vào GenServer, đến thời gian build đã được cấu hình, kiểm tra điều kiện build, nếu đủ điều kiện, trigger API Github Actions để build và clear thông tin merged pull.
  - tương tự với dùng **command**, khi gọi command sẽ check GenServer, kiểm tra điều kiện build, gọi API.

## Các bước thực hiện
### Lấy các key cần thiết cho iOS Build
- Với các file, lưu vào **cùng 1 thư mục** để sau base64 cho dễ!
- **App Store Connect API**: User and Access -> Integrations -> Team Key -> Generate Key, lấy ra: **keyId**, **issuerId** và file **private key .p8** (đổi tên: `APPSTORE_KEY.p8`)
- **CertificateSigningRequest**: open Keychain Mac -> Certification Assistant -> Request a cert... -> email and Save to disk, sau đó upload cert này lên cert apple với role Apple Distribution (**Bước này bỏ qua nếu** đã có cert Apple Distribution)
- **Provisioning Profiles**: Profiles -> iOS App -> App Store Connect -> chọn App -> chọn tên là build_provision_profile -> download (file download đuôi là **.mobileprovision**)
- **Kiểm tra signing**: Mở Xcode chứa project -> ở tab signing chọn file provision vừa generate ở trên -> Thành công mới làm các bước tiếp theo!
  
### Paste các key vào Github Actions
- Lưu ý: để lưu cert vào secrets trên GHA, cần convert tất cả sang base64
- Bước 1: Gen .p12 cert: Xcode -> Settings -> Accounts -> Chọn đúng team -> Manage Certs -> chuột phải vào **Apple Distribution** -> export cert với tên `BUILD_CERTIFICATE.p12` (nhớ password p12)
- Bước 2: ExportOptions.plist: Xcode -> Product -> Archive -> Distribute App -> Custom -> App Store Connect -> Next chọn Export -> Next -> Choose profile -> Next -> Save folder -> Tìm file `ExportOptions.plist` -> paste vào folder iOS/
- Bước 3: Tạo các secrets cho GHA: Vào repo -> Settings -> Secrets and Variables -> Actions -> Repo secret
  Với các file sẽ convert sang **base64**: đảm bảo paste đủ key dưới đây vào GHA
  ```bash
    Dạng: KEY: value/command to get value
    Với những key cần dùng command để lấy, sẽ có (c) ở cuối, đảm bảo đã gom các keys vào cùng 1 folder

    BUILD_CERTIFICATE_BASE64: base64 -i BUILD_CERTIFICATE.p12 | pbcopy (c)
    P12_PASSWORD: Tự chọn
    BUILD_PROVISION_PROFILE_BASE64: base64 -i BUILD_PROVISION_PROFILE.p12 | pbcopy (c)
    KEYCHAIN_PASSWORD: Tự chọn
    APPSTORE_KEY_P8: base64 -i APPSTORE_KEY.p8 | pbcopy (c)
    APPSTORE_KEYID: Lấy keyId từ bước App Store Connect API
    APPSTORE_ISSUERID: Lấy issuerId từ bước App Store Connect API
    PAT: lấy github token của thành viên và paste vào
  ```
- Bước 4: Commit lên github và test flow với api (có thể bằng postman hoặc curl) (**NOTE**: chuyển quyền trong repo Settings -> Actions -> Workflow permissions thành **Read and write permissions**)

### Lấy các key cần thiết cho android Build
```bash
    Dạng: KEY: value/command to get value
    Với những key cần dùng command để lấy, sẽ có (c) ở cuối, đảm bảo đã gom các keys vào cùng 1 folder

    SIGNING_KEY: base64 -i upload-keystroke.jks | pbcopy (c)
    KEY_STORE_PASSWORD: lấy trong key.properties
    KEY_ALIAS: lấy trong key.properties
    KEY_PASSWORD: lấy trong key.properties
    GOOGLE_SERVICES_ACCOUNT_JSON: follow r0adkll/upload-google-play@v1, add mail service to play console
  ```

## Tham khảo
https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event

