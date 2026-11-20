# Cara pakai

## 1. Ganti app-nya dengan app lo
Semua kode SwiftUI ada di `Demo/`. Ganti isi `ContentView.swift` — project file
(`.xcodeproj`) TIDAK perlu di-commit, XcodeGen bikin ulang otomatis di runner.

Tambah file baru? Taruh di `Demo/`, otomatis ke-include.

## 2. Push -> build otomatis
```
git add -A && git commit -m "feat: ui baru" && git push
```
Buka tab **Actions** -> run terbaru -> job `build`.
Selesai ~7 menit. Di bagian bawah run ada artifact **build-output**:
- `screenshot.png` — screenshot app dari iPhone 16 simulator (bukti UI jalan)
- `Demo-unsigned.ipa` — app siap-sideload

Ambil via CLI:
```
gh run download -D artifacts   # artifact run terakhir
```

## 3. Install ke iPhone (unsigned)
Butuh PC + Apple ID gratis:
1. Install **Sideloadly** (Windows/Mac) atau **AltStore**
2. Colok iPhone, drag `Demo-unsigned.ipa` ke Sideloadly, masukkan Apple ID
3. App hidup **7 hari**, lalu resign ulang dengan cara sama

Kalau punya **Apple Developer $99/tahun**: upload ke TestFlight, berlaku 90 hari,
dan app bisa dipakai tanpa colok PC.

## 4. Batasan unsigned
- Nggak bisa: push notification, iCloud, Sign in with Apple, App Groups
- Bisa: UI, network, local storage, kamera, lokasi

## Biaya
Repo ini **public** -> standard GitHub-hosted runner (termasuk macOS) **gratis**,
nggak makan kuota. Private repo: macOS $0.062/menit dari kuota $12/bulan.
