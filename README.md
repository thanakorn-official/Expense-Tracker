<div align="center">

# 💰 EXPENSE TRACKER
### แอปพลิเคชันบันทึกและบริหารจัดการรายรับ-รายจ่ายส่วนบุคคล

[![Status](https://img.shields.io/badge/STATUS-COMPLETED-success?style=for-the-badge)]()
[![Platform](https://img.shields.io/badge/PLATFORM-ANDROID%20%2F%20WEB-blue?style=for-the-badge)]()
[![Framework](https://img.shields.io/badge/FRAMEWORK-FLUTTER-informational?style=for-the-badge)]()
[![Database](https://img.shields.io/badge/DATABASE-FIREBASE-orange?style=for-the-badge)]()

</div>

---

## 📌 ภาพรวมโปรเจกต์ (Project Overview)

**Expense Tracker** เป็นแอปพลิเคชันมือถือและเว็บสำหรับบันทึกและบริหารจัดการรายรับ-รายจ่ายส่วนบุคคล พัฒนาด้วย **Flutter** และเชื่อมต่อฐานข้อมูลแบบเรียลไทม์ด้วย **Firebase (Cloud Firestore)** เพื่อให้ข้อมูลซิงค์ตรงกันทุกอุปกรณ์อย่างไร้รอยต่อ ตัวแอปถูกออกแบบให้มี UI ที่สะอาดตา รองรับ **Dark Mode** อัตโนมัติตามระบบ พร้อมระบบจัดการหมวดหมู่และช่องทางชำระเงินแบบกำหนดเอง กราฟวงกลมสรุปสัดส่วนการเงิน ระบบเพิ่ม-ลบ-แก้ไขข้อมูล และระบบบันทึกประวัติการแก้ไขล่าสุดอย่างเป็นระบบ 🚀

---

## 🛠 เทคโนโลยีที่ใช้ (Tech Stack)

* **Core Framework:** Flutter (Dart) 💙
* **Cloud Database:** Firebase Cloud Firestore (Real-time Sync) 🔥
* **Data Visualization:** FL Chart (Circular / Pie Chart) 📊
* **Local Storage:** SharedPreferences (Custom Categories & Payment Methods) 💾
* **UI & Localization:** Intl & Material Design 3 with Multi-language Support (TH/EN) 🌐
* **Version Control:** Git & GitHub 🐙

---

## ✨ ฟีเจอร์หลัก (Key Features)

* **Transaction Management:** บันทึก แก้ไข และลบรายการ (ระบบ Swipe-to-Delete พร้อมปุ่ม Undo)
* **Time-based Grouping & Scoping:** จัดกลุ่มและกรองข้อมูลตามช่วงเวลา (รายวัน, รายสัปดาห์, รายเดือน, รายปี)
* **Advanced Filtering:** กรองข้อมูลตามประเภท (รายรับ/รายจ่าย) และช่องทางการชำระเงิน
* **Custom Categories & Payment Methods:** เพิ่มหมวดหมู่และช่องทางชำระเงินใหม่ได้เองพร้อมบันทึกค่า
* **Financial Analytics:** กราฟวงกลม (Pie Chart) แสดงสัดส่วนค่าใช้จ่ายตามหมวดหมู่แบบเรียลไทม์
* **Localization:** รองรับการเปลี่ยนภาษา (ไทย / อังกฤษ) ทั่วทั้งแอป
* **Theme Support:** รองรับโหมดสว่างและโหมดมืด (Light / Dark Theme) ตามระบบ

---

## 📂 โครงสร้างโปรเจกต์ (Project Structure)

```text
Expense_Tracker/
├── android/            # การตั้งค่าระบบ Android และ App Icon
├── ios/                # การตั้งค่าระบบ iOS
├── assets/             # จัดเก็บไฟล์ภาพและโลโก้
├── lib/                # ซอร์สโค้ดหลักของแอปพลิเคชัน
│   ├── models/         # โครงสร้างข้อมูล (transaction_model.dart)
│   ├── screens/        # หน้าจอการใช้งาน (dashboard_screen.dart, settings_screen.dart)
│   ├── utils/          # ระบบจัดการภาษาและโลแคล (l10n.dart)
│   └── main.dart       # จุดเริ่มต้นและระบบธีมหลักของแอปพลิเคชัน
├── pubspec.yaml        # รายการแพ็กเกจและตั้งค่า Asset
└── README.md           # รายละเอียดโปรเจกต์
