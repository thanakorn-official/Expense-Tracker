<div align="center">

<img src="assets/logo.png" alt="KeepTang Logo" width="120"/>

# 💰 เก็บตัง — KeepTang

**แอปบันทึกรายรับ-รายจ่ายส่วนบุคคล ที่ใช้งานง่าย ไม่ต้องสมัครบัญชี**

[![Version](https://img.shields.io/badge/version-1.3.0-blue?style=for-the-badge)]()
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-02569B?style=for-the-badge&logo=flutter)]()
[![Framework](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)]()
[![Database](https://img.shields.io/badge/Cloud%20Firestore-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)]()
[![License](https://img.shields.io/badge/license-Proprietary-grey?style=for-the-badge)]()

</div>

---

## 📌 เกี่ยวกับแอป

**KeepTang (เก็บตัง)** เป็นแอปจัดการการเงินส่วนบุคคล พัฒนาด้วย **Flutter** และเก็บข้อมูลบน **Firebase Cloud Firestore** แบบเรียลไทม์ ใช้งานได้ทันทีโดยไม่ต้องสมัครบัญชี — เปิดแอป ตั้งชื่อผู้ใช้ แล้วเริ่มจดเงินได้เลย

> 🆔 **ไม่มีระบบล็อกอิน ไม่มีการสมัครสมาชิก** — แต่ละเครื่องจะได้ **Guest ID แบบสุ่มที่ไม่ซ้ำกับใคร** โดยอัตโนมัติ ส่วนชื่อผู้ใช้เป็นเพียงชื่อแสดงผลที่เปลี่ยนได้อิสระ

---

## ✨ ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|---|---|
| 🆔 **Guest ID สุ่มไม่ซ้ำ** | แต่ละเครื่องได้ ID เฉพาะ (เช่น `G-mdef4k2x7q3z`) สร้างอัตโนมัติ ตรวจซ้ำกับฐานข้อมูลก่อนใช้เสมอ — คนละเครื่องคือคนละพื้นที่ข้อมูล แม้ตั้งชื่อผู้ใช้เหมือนกัน |
| ✏️ **ชื่อผู้ใช้เปลี่ยนได้อิสระ** | ชื่อผู้ใช้เป็นแค่ชื่อแสดงผล แก้ได้ทุกเมื่อในหน้าตั้งค่า โดยไม่กระทบข้อมูลเดิมแม้แต่รายการเดียว |
| 💸 **บันทึกรายรับ-รายจ่าย** | เพิ่ม แก้ไข ลบรายการ พร้อมระบบปัดเพื่อลบ (Swipe-to-Delete) และปุ่มเลิกทำ (Undo) |
| 📊 **กราฟวงกลม** | แสดงสัดส่วนค่าใช้จ่ายแยกตามหมวดหมู่ พร้อมไอคอนและเปอร์เซ็นต์ในตัว |
| 🗂 **จัดกลุ่มและกรอง** | จัดกลุ่มตามวัน/สัปดาห์/เดือน/ปี กรองตามประเภทรายการและช่องทางชำระเงิน เรียงใหม่-เก่า-มาก-น้อยได้ |
| 🎨 **หมวดหมู่และช่องทางชำระเงินแบบกำหนดเอง** | เพิ่ม/แก้ไข/ลบได้เอง พร้อมเลือกไอคอนและสีประจำรายการ |
| 🌐 **สองภาษา** | ไทย / อังกฤษ เปลี่ยนได้ทันทีทั่วทั้งแอป |
| 🌗 **ธีมสว่าง-มืด** | เลือก Light / Dark ได้ตามใจชอบ |

---

## 🛠 เทคโนโลยีที่ใช้

- **Flutter (Dart)** — โครงสร้าง UI และ state management แบบเรียบง่าย
- **Firebase Cloud Firestore** — ฐานข้อมูลเรียลไทม์ ซิงค์ข้อมูลทันที
- **FL Chart** — กราฟวงกลมสรุปสัดส่วนการเงิน
- **SharedPreferences** — เก็บ Guest ID, ชื่อผู้ใช้, ธีม, ภาษา และหมวดหมู่ที่กำหนดเอง
- **Material Design 3** — ดีไซน์ร่วมสมัย รองรับทั้งโหมดสว่างและมืด

---

## 🆔 ระบบตัวตนแบบ Guest

แอปตัดระบบล็อกอิน Facebook/Google ออกทั้งหมด แล้วใช้ระบบ Guest ที่ทำงานดังนี้

1. **เปิดแอปครั้งแรก** — ระบบสุ่ม Guest ID รูปแบบ `G-` + เวลา (base36) + ตัวอักษรสุ่ม 4 ตัว แล้วตรวจกับ Firestore ว่าไม่มีใครใช้ ID นี้ก่อน (ถ้าออฟไลน์จะใช้ค่าที่สุ่มได้ทันที เพราะโอกาสชนกันแทบเป็นศูนย์)
2. **ตั้งชื่อผู้ใช้** — ชื่อนี้เป็นแค่ชื่อแสดงผลเท่านั้น ไม่ได้ผูกกับพื้นที่ข้อมูล
3. **เปลี่ยนชื่อเมื่อไหร่ก็ได้** — ข้อมูลทั้งหมดยังอยู่กับ Guest ID เดิมของเครื่อง

### โครงสร้างข้อมูลบน Firestore

```text
guests/{guestId}                  ← ID สุ่มไม่ซ้ำ เช่น G-mdef4k2x7q3z
├── username: "สมชาย"            ← ชื่อแสดงผล (แก้ได้อิสระ)
├── createdAt: <serverTimestamp>
└── transactions/{docId}
    ├── title:        "ค่ากาแฟ"
    ├── amount:       55.0
    ├── date:         "2026-10-14T09:30:00.000"
    ├── isExpense:    1
    ├── category:     "อาหาร"
    ├── paymentMethod: "cash"
    └── updatedAt:    "2026-10-14T12:00:00.000"   (เฉพาะรายการที่แก้ไขแล้ว)
```

> 🔄 **อัปเกรดจากเวอร์ชันเก่าอัตโนมัติ** — เครื่องที่เคยใช้เวอร์ชันที่ใช้ "ชื่อผู้ใช้เป็น ID" จะถูกคัดลอกข้อมูลจากพื้นที่เดิม (`guests/{ชื่อผู้ใช้}`) มายัง ID สุ่มใหม่โดยอัตโนมัติเมื่อเปิดแอปครั้งแรก (คัดลอกเท่านั้น ไม่ลบข้อมูลเดิม)

---

## 📂 โครงสร้างโปรเจกต์

```text
KeepTang/
├── android/                 # การตั้งค่าระบบ Android (รวม google-services.json)
├── ios/                     # การตั้งค่าระบบ iOS
├── assets/                  # โลโก้และไฟล์ภาพ
├── lib/                     # ซอร์สโค้ดหลักของแอป
│   ├── main.dart            # จุดเริ่มต้น, ตั้งค่า Firebase, ธีม และภาษา
│   ├── firebase_options.dart
│   ├── models/
│   │   └── transaction_model.dart     # โครงสร้างข้อมูลรายรับ-รายจ่าย
│   ├── screens/
│   │   ├── splash_screen.dart         # หน้าเริ่ม — สุ่ม Guest ID แล้วเลือกเส้นทาง
│   │   ├── guest_setup_screen.dart    # หน้าตั้งชื่อผู้ใช้ครั้งแรก
│   │   ├── dashboard_screen.dart      # หน้าหลัก — สรุปยอด, กราฟ, รายการ, ตัวกรอง
│   │   └── settings_screen.dart       # ตั้งค่า — ชื่อผู้ใช้, หมวดหมู่, ธีม, ภาษา
│   ├── services/
│   │   └── guest_service.dart         # Guest ID สุ่มไม่ซ้ำ + ย้ายข้อมูลเก่าอัตโนมัติ
│   └── utils/
│       └── l10n.dart                  # คำแปลไทย/อังกฤษทั้งแอป
├── firestore.rules          # กติกาความปลอดภัยของ Firestore
├── pubspec.yaml             # รายการแพ็กเกจและทรัพยากร
└── README.md
```

---

## 🚀 เริ่มต้นใช้งาน

### สิ่งที่ต้องมี

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (ช่องทาง stable ล่าสุด)
- บัญชี [Firebase](https://console.firebase.google.com/) พร้อมสร้างโปรเจกต์และเปิดใช้ **Cloud Firestore**

### ติดตั้งและรัน

```bash
# 1. โคลนโปรเจกต์
git clone https://github.com/thanakorn-official/KeepTang.git
cd KeepTang

# 2. ติดตั้งแพ็กเกจ
flutter pub get

# 3. ตั้งค่า Firebase สำหรับโปรเจกต์ของคุณ (สร้าง firebase_options.dart)
dart pub global activate flutterfire_cli
flutterfire configure

# 4. รันแอป
flutter run
```

> 💡 repo นี้แนบไฟล์ config ของ Firebase โปรเจกต์เดิมมาด้วย (`android/app/google-services.json` และ `lib/firebase_options.dart`) ถ้าต้องการใช้ Firebase โปรเจกต์ของตัวเอง ให้รัน `flutterfire configure` ทับ แล้วไฟล์ config ทั้งหมดจะถูกสร้างใหม่ให้อัตโนมัติ

### ตั้งค่า Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### สร้างไฟล์ Release

```bash
flutter build apk --release        # Android APK
flutter build web                  # เว็บแอป
```

---

## 🗺 แนวทางพัฒนาต่อ

- [ ] ส่งออก/นำเข้าข้อมูล (CSV) เพื่อย้ายเครื่องหรือสำรองข้อมูล
- [ ] โหมดผู้พิทักษ์ — ลิงก์ Guest ID เข้ากับบัญชีเพื่อกู้คืนข้อมูลข้ามเครื่อง
- [ ] แจ้งเตือนบันทึกรายการรายวัน
- [ ] วิดเจ็ตหน้าจอหลักสำหรับเพิ่มรายการด่วน

---

<div align="center">

**KeepTang (เก็บตัง)** — เก็บทุกบาท ให้ครบทุกตัง 💰

Made with 💙 Flutter

</div>
