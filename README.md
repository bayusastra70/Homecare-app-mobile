# 🏥 Ganesha Homecare

[![Flutter](https://img.shields.io/badge/Flutter-3.13.0-blue?logo=flutter)](https://flutter.dev/)
[![Laravel](https://img.shields.io/badge/Laravel-10-red?logo=laravel)](https://laravel.com/)
[![PHP](https://img.shields.io/badge/PHP-8.2-purple?logo=php)](https://www.php.net/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Ganesha Homecare** is a homecare service platform consisting of a **mobile app** and a **website**, designed to help elderly patients or post-hospitalization patients manage in-home care services.

- **Website** is used by admins to manage services, schedules, orders, and notifications.  
- **Mobile App** is used by patients to browse services, place orders, and receive real-time notifications.

---

## 🚀 Key Features

### Mobile App (Flutter)
- **Authentication & Security**: Login, Register, Token Refresh, Logout  
- **Profile & Address**: Edit user profile, manage address with dynamic dropdowns (Regency → District → Village), auto-prefill  
- **Services & Orders**: View service list, add to cart, checkout, confirm address  
- **Order Management**: View order list, status: Pending / Accepted / Paying, actions: Detail / Cancel  
- **Real-Time Notifications**: Receive push notifications when admins schedule services or update order status

> ⚠️ The admin website is only used for processing orders and scheduling visits; its source code is not included in this repository.


## Screenshots

### Home Page

<p align="center">
  <img src="./screenshots/homepage.png" width="500">
</p>

<br>

### Service

<p align="center">
  <img src="./screenshots/service.png" width="500">
</p>

<br>

### Cart

<p align="center">
  <img src="./screenshots/cart.png" width="500">
</p>

<br>

### Checkout Notifications

<p align="center">
  <img src="./screenshots/checkoutnotifikations.png" width="500">
</p>

<br>

### Payment

<p align="center">
  <img src="./screenshots/payment.png" width="500">
</p>

<br>

### History

<p align="center">
  <img src="./screenshots/history.png" width="500">
</p>



## 📖 References
- [Flutter Docs](https://flutter.dev/docs)  
- [Laravel Docs](https://laravel.com/docs)  
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)  
- [LocationIQ API](https://locationiq.com)

---

## 📜 License
MIT License © 2026
