# 🏥 Ganesha Homecare

[![Flutter](https://img.shields.io/badge/Flutter-3.13.0-blue?logo=flutter)](https://flutter.dev/)
[![Laravel](https://img.shields.io/badge/Laravel-10-red?logo=laravel)](https://laravel.com/)
[![PHP](https://img.shields.io/badge/PHP-8.2-purple?logo=php)](https://www.php.net/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Ganesha Homecare** adalah platform layanan homecare yang terdiri dari **versi mobile** dan **website**, yang memudahkan pasien lansia atau pasca-rawat rumah sakit dalam mengatur layanan perawatan di rumah.  

- **Website** digunakan oleh admin untuk mengelola layanan, jadwal, pesanan, dan notifikasi.  
- **Mobile App** digunakan oleh pasien untuk melihat layanan, memesan, dan menerima notifikasi real-time.  

---

## 🚀 Fitur Utama

### Mobile App (Flutter)
- **Autentikasi & Keamanan**: Login, Register, Token Refresh, Logout  
- **Profil & Alamat**: Edit profil, alamat dengan dropdown dinamis (Kabupaten → Kecamatan → Desa), prefill otomatis  
- **Layanan & Pemesanan**: Lihat daftar layanan, tambah ke keranjang, checkout, konfirmasi alamat  
- **Manajemen Pesanan**: Lihat daftar pesanan, status: Pending / Accepted / Paying, aksi: Detail / Batalkan  
- **Notifikasi Real-Time**: Menerima push notification ketika admin website menjadwalkan layanan atau perubahan status pesanan  

### Website (Laravel)
- **Manajemen Layanan**: Tambah, edit, hapus layanan homecare  
- **Manajemen Pesanan & Jadwal**: Admin dapat membuat janji temu, menetapkan perawat, dan mengubah status pesanan  
- **Notifikasi ke Mobile**: Ketika admin menginput jadwal janji temu, pasien menerima notifikasi push di mobile app melalui FCM  
- **Dashboard Admin**: Monitoring pesanan, pengguna, dan laporan layanan  



