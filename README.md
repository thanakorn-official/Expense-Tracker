<div align="center">

# 💰 EXPENSE TRACKER

<p>
  <img src="https://img.shields.io/badge/STATUS-COMPLETED-brightgreen?style=flat-square" alt="Status Completed">
  <img src="https://img.shields.io/badge/PLATFORM-ANDROID%20%2F%20WEB-blue?style=flat-square" alt="Platform Android Web">
  <img src="https://img.shields.io/badge/FRAMEWORK-FLUTTER-blueviolet?style=flat-square" alt="Framework Flutter">
  <img src="https://img.shields.io/badge/DATABASE-FIREBASE-orange?style=flat-square" alt="Database Firebase">
</p>

</div>

---

### 📝 รายละเอียดโปรเจกต์ (Project Overview)

**Expense Tracker** เป็นแอปพลิเคชันมือถือและเว็บแอปสำหรับบันทึกและบริหารจัดการรายรับ-รายจ่ายส่วนตัว พัฒนาขึ้นด้วย Flutter และเชื่อมต่อฐานข้อมูลแบบเรียลไทม์ด้วย Firebase (Cloud Firestore) เพื่อให้ข้อมูลซิงก์ตรงกันทุกอุปกรณ์อย่างไร้รอยต่อ ตัวแอปถูกออกแบบมาให้มี UI ที่สะอาดตา รองรับ Dark Mode อัตโนมัติตามระบบ พร้อมระบบจัดหมวดหมู่พร้อมไอคอน กราฟวงกลมสรุปสัดส่วนการเงิน ระบบเพิ่ม-ลบ-แก้ไขข้อมูล และบันทึกประวัติการแก้ไขล่าสุดอย่างเป็นระบบ 🚀

---

### 🛠️ เทคโนโลยีที่ใช้ (Tech Stack)

* **Core Framework:** Flutter (Dart) 💙
* **Cloud Database:** Firebase Cloud Firestore (Real-time Sync) 🔥
* **Data Visualization:** FL Chart (Circular / Pie Chart) 📊
* **UI & Date Formatting:** Intl & Material Design 3 🎨
* **App Branding:** Flutter Launcher Icons & Flutter Native Splash 🖼️
* **Version Control:** Git & GitHub 🐙

---

# Expense Tracker

แอปพลิเคชันบันทึกรายรับ-รายจ่าย พัฒนาด้วย Flutter และเชื่อมต่อฐานข้อมูล Firebase Firestore

## ฟีเจอร์หลัก
- บันทึก แก้ไข และลบรายการรายรับ-รายจ่ายแบบเรียลไทม์
- จัดกลุ่มรายการย้อนหลัง (รายวัน, รายเดือน, รายปี)
- กรองและเรียงลำดับข้อมูล
- กราฟแสดงสัดส่วนการใช้จ่าย (Pie Chart)
- รองรับการเปลี่ยนภาษา (ไทย / อังกฤษ)
- รองรับการเปลี่ยนธีม (System / Light / Dark)

---

## 📂 โครงสร้างไฟล์ในโปรเจกต์ (Project Structure)

```text
🧾Expense_Tracker/
├── 📱android/            # การตั้งค่าระบบ Android และ App Icon
├── 📱ios/                # การตั้งค่าระบบ iOS
├── 🖼️assets/             # จัดเก็บไฟล์รูปภาพและโลโก้ (logo.png)
├── 🏠lib/                # ซอร์สโค้ดหลักของแอปพลิเคชัน
│   ├── ✨models/         # โครงสร้างข้อมูล (transaction_model.dart)
│   ├── ✨screens/        # หน้าจอการใช้งาน (dashboard_screen.dart)
│   └── ✨main.dart       # จุดเริ่มต้นแอปและเชื่อมต่อ Firebase
├── 📄pubspec.yaml        # รายการแพ็กเกจและตั้งค่า Asset/Splash
└── 📄README.md           # รายละเอียดโปรเจกต์
```