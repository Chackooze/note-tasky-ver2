# NoteTasky

Aplikasi mobile untuk mengelola catatan dan tugas dengan sistem autentikasi Firebase dan penyimpanan cloud.

## Nama
**NoteTasky Version 2** - Aplikasi produktivitas untuk mencatat dan mengelola tugas harian

## Judul Project
**NoteTasky Ver2** - Note & Task Management App

## Deskripsi Fungsionalitas Aplikasi

NoteTasky adalah aplikasi Flutter yang memungkinkan pengguna untuk:

### 🔐 **Sistem Autentikasi**
- **Login** dengan email dan password
- **Registrasi** akun baru dengan nama, email, dan password
- **Autentikasi otomatis** dengan Firebase Auth
- **Multi-user support** dengan isolasi data per pengguna

### 📝 **Manajemen Catatan (Notes)**
- **Membuat catatan baru** dengan judul, konten, dan kategori
- **Melihat daftar catatan** milik pengguna yang sedang login
- **Mengedit catatan** yang sudah ada
- **Menghapus catatan** dengan konfirmasi
- **Kategorisasi catatan**: Personal, Work, Study, Ideas, Recipes, Travel, Other
- **Tampilan ringkas** dengan preview konten (3 baris maksimal)

### ✅ **Manajemen Tugas (Tasks)**
- **Membuat tugas baru** dengan judul, deskripsi, dan kategori
- **Melihat daftar tugas** dengan status completed/incomplete
- **Mengedit tugas** yang sudah ada
- **Menghapus tugas** dengan konfirmasi
- **Menandai tugas selesai** dengan checkbox
- **Kategorisasi tugas**: Personal, Work, Study, Health, Shopping, Other
- **Visual feedback** dengan strikethrough untuk tugas yang selesai

## Teknologi yang Digunakan

### **Frontend Framework**
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language

### **Backend & Database**
- **Firebase Core** - Platform backend Google
- **Firebase Authentication** - Sistem autentikasi pengguna
- **Cloud Firestore** - NoSQL database untuk penyimpanan data
- **Firebase Options** - Konfigurasi platform-specific

### **State Management**
- **StreamBuilder** - Real-time data streaming dari Firestore
- **StatefulWidget** - Local state management untuk UI interaktif

### **UI Components**
- **Material Design** - Design system Android
- **Custom Widgets**: CustomTextField, CustomButton
- **Responsive Layout** dengan Scaffold dan AppBar

## Cara Menjalankan Aplikasi

### **Prerequisites**
1. Install Flutter SDK
2. Setup Firebase project dan konfigurasi
3. Download file `firebase_options.dart` dari Firebase Console

### **Langkah Instalasi**
```bash
# Clone repository
git clone [repository-url]

# Masuk ke direktori project
cd note_tasky_ver2

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### **Konfigurasi Firebase**
1. Buat project Firebase baru
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore
4. Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
5. Letakkan file konfigurasi di direktori yang sesuai

## Screenshot UI dan Tampilan

### **Login Screen**
- Form login dengan email dan password
- Link navigasi ke halaman registrasi
- Loading indicator saat proses autentikasi
- Error handling dengan SnackBar

### **Signup Screen**
- Form registrasi dengan nama, email, dan password
- Validasi input (password minimal 6 karakter)
- Link navigasi ke halaman login

### **Home Screen**
- Dashboard utama aplikasi
- Navigasi ke fitur Notes dan Tasks

### **Add Note Screen**
- Form input judul catatan
- Text area untuk konten catatan (expandable)
- Dropdown pemilihan kategori
- Tombol simpan dengan loading state

### **View Note Screen**
- Daftar catatan dalam bentuk cards
- Preview konten dengan ellipsis overflow
- Tombol edit dan delete per catatan
- FloatingActionButton untuk tambah catatan baru

### **Add Task Screen**
- Form input judul tugas
- Text area untuk deskripsi tugas
- Dropdown pemilihan kategori
- Tombol simpan dengan loading state

### **View Task Screen**
- Daftar tugas dalam ListTile format
- Checkbox untuk menandai completion status
- Strikethrough text untuk tugas selesai
- Tombol edit dan delete per tugas
- FloatingActionButton untuk tambah tugas baru

## Struktur Database

### **Collection: notes**
```
{
  id: string,
  title: string,
  content: string,
  category: string,
  createdAt: timestamp,
  userId: string
}
```

### **Collection: tasks**
```
{
  id: string,
  title: string,
  description: string,
  category: string,
  isCompleted: boolean,
  createdAt: timestamp,
  userId: string
}
```

### **Collection: users**
```
{
  uid: string,
  email: string,
  displayName: string,
  createdAt: timestamp
}
```

## Fitur Keamanan
- **User Authentication** dengan Firebase Auth
- **Data Isolation** - setiap user hanya bisa mengakses data miliknya
- **Real-time Security Rules** di Firestore
- **Input Validation** untuk mencegah data kosong
- **Error Handling** yang comprehensive

---
