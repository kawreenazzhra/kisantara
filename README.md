# Kisantara

Kisantara adalah sebuah aplikasi mobile yang dibangun menggunakan framework **Flutter**. Aplikasi ini berfokus pada eksplorasi cerita, menyediakan pengalaman pengguna yang modern dan responsif dengan fitur penjelajahan konten, cerita pengguna, dan profil.
<img width="738" height="1600" alt="image" src="https://github.com/user-attachments/assets/d2921ff0-55d2-47ed-a331-cea15940636a" />
<img width="738" height="1600" alt="image" src="https://github.com/user-attachments/assets/d6c11036-3b35-4b59-8410-a31972b9ae13" />
<img width="738" height="1600" alt="image" src="https://github.com/user-attachments/assets/10dd8717-3c15-439b-983a-c9fd1cf03e0c" />
<img width="738" height="1600" alt="image" src="https://github.com/user-attachments/assets/5895124c-0ce7-47bd-b1fe-94d2f84b8de0" />


## 🌟 Fitur Utama
- **Autentikasi Aman**: Login dan manajemen pengguna yang didukung oleh **Firebase Authentication**.
- **Jelajah & Cerita Saya**: Eksplorasi dan manajemen cerita secara dinamis menggunakan **Cloud Firestore**.
- **Desain Modern**: Antarmuka bersih yang menggunakan **Material 3** dipadukan dengan tipografi **Plus Jakarta Sans** (Google Fonts).
- **Multibahasa**: Mendukung terjemahan teks secara dinamis menggunakan paket `translator`.
- **Manajemen Media**: Mendukung pemilihan dan pengunggahan gambar menggunakan `image_picker`.
- **Penyimpanan Lokal**: Menyimpan preferensi dan status pengguna (seperti pilihan bahasa) dengan `shared_preferences`.

## 🛠️ Teknologi yang Digunakan
- **Frontend**: [Flutter](https://flutter.dev/) (Dart)
- **Backend/BaaS**: Firebase (Firebase Core, Auth, Cloud Firestore)
- **Networking**: Dio
- **UI/UX**: Google Fonts, Cupertino Icons

## 🚀 Persiapan & Instalasi

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.11.0 atau lebih baru)
- Android Studio / VS Code dengan plugin Flutter
- Perangkat Android/iOS atau Emulator/Simulator

### Langkah-langkah
1. **Clone repositori ini** ke mesin lokal Anda.
   ```bash
   git clone https://github.com/kawreenazzhra/kisantara.git
   ```
2. **Masuk ke direktori project**:
   ```bash
   cd kisantara
   ```
3. **Unduh semua dependensi**:
   ```bash
   flutter pub get
   ```
4. **Jalankan aplikasi**:
   Sambungkan perangkat Anda atau jalankan emulator, lalu eksekusi:
   ```bash
   flutter run
   ```

## 📦 Membangun Rilis (Build APK)
Jika Anda ingin menghasilkan file `.apk` untuk dibagikan atau diinstal di perangkat Android, Anda bisa menjalankan perintah berikut:

```bash
flutter build apk
```
Setelah proses selesai, file APK siap pakai dapat ditemukan di dalam direktori:
`build/app/outputs/flutter-apk/app-release.apk`

---
*Dibuat untuk project Tugas Besar Aplikasi Perangkat Bergerak (APB).*
