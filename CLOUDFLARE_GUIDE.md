# ☁️ คู่มือการ Deploy เว็บแอป "กินไรดี โรงอาหาร" ขึ้น Cloudflare Pages + Cloudflare D1 Database

คู่มือฉบับสมบูรณ์สำหรับการนำเว็บแอปพลิเคชันขึ้นสู่ระบบคลาวด์ระดับโลกของ **Cloudflare** พร้อมเชื่อมต่อฐานข้อมูลไร้เซิร์ฟเวอร์ความเร็วสูง **Cloudflare D1 (Serverless SQL Database)** ฟรี 100%

---

## 🏗️ สถาปัตยกรรมระบบ (Cloudflare Architecture)

```
┌──────────────────────────────────────────────────────────────────┐
│                   Cloudflare Edge Global Network                 │
├────────────────────────────────┬─────────────────────────────────┤
│  Frontend Assets (Pages CDN)   │   Serverless Edge Functions     │
│  - index.html                  │   - /api/canteen (ร้านค้า/เมนู)   │
│  - css/styles.css              │   - /api/profile (TDEE/เป้าหมาย) │
│  - js/*                        │   - /api/diary (ประวัติมื้ออาหาร)│
│  - manifest.json / PWA         │   - /api/init-db (สร้างตาราง)    │
└────────────────────────────────┴───────────────┬─────────────────┘
                                                 │ Binding: env.DB
                                                 ▼
                                 ┌─────────────────────────────────┐
                                 │   Cloudflare D1 SQL Database    │
                                 │   (siet-canteen-db)             │
                                 │   - canteen_info                │
                                 │   - stalls                      │
                                 │   - menus                       │
                                 │   - user_profile                │
                                 │   - diary_entries               │
                                 └─────────────────────────────────┘
```

---

## 🚀 วิธีที่ 1: Deploy ผ่านหน้าเว็บ Cloudflare Dashboard (ง่ายที่สุด ทำได้ใน 3 นาที ไม่ต้องติดตั้งโปรแกรม)

### ขั้นตอนที่ 1: สร้างฐานข้อมูล Cloudflare D1 Database
1. ล็อกอินเข้าสู่ [Cloudflare Dashboard](https://dash.cloudflare.com)
2. ที่เมนูด้านซ้าย เลือก **Storage & Databases** $\rightarrow$ **D1 SQL Database**
3. คลิกปุ่ม **Create Database**
   - **Database Name**: ตั้งชื่อว่า `siet-canteen-db`
   - คลิก **Create**
4. เมื่อสร้างเสร็จแล้ว คลิกเข้าไปที่ฐานข้อมูล `siet-canteen-db` $\rightarrow$ เลือกแท็บ **Console**
5. เปิดไฟล์ `schema.sql` ในโฟลเดอร์โปรเจกต์นี้ คัดลอกโค้ด SQL ทั้งหมดมาวางใน Console แล้วกดปุ่ม **Execute**
   *(ระบบจะสร้างตาราง `canteen_info`, `stalls`, `menus`, `user_profile`, `diary_entries` พร้อมลงข้อมูลร้านอาหารไทยตั้งต้นให้เรียบร้อยทันที)*

---

### ขั้นตอนที่ 2: Deploy เว็บแอปขึ้น Cloudflare Pages
1. ที่เมนูด้านซ้ายของ Cloudflare Dashboard เลือก **Compute (Workers & Pages)**
2. คลิกปุ่ม **Create application** $\rightarrow$ เลือกแท็บ **Pages**
3. เลือก **Upload assets** (หรือ Connect to Git หากเก็บโค้ดไว้บน GitHub/GitLab)
4. ตั้งชื่อโปรเจกต์: `siet-canteen`
5. อัปโหลดไฟล์:
   - นำไฟล์ **`siet-canteen-deploy.zip`** ที่สร้างไว้ในโฟลเดอร์นี้ ลากมาวางเพื่ออัปโหลดได้ทันที
   - หรือลากโฟลเดอร์โปรเจกต์ทั้งหมดขึ้นไป
6. คลิก **Deploy site** $\rightarrow$ รอประมาณ 10-15 วินาที ระบบจะแจ้งว่า Deploy เสร็จแล้ว

---

### ขั้นตอนที่ 3: ผูกฐานข้อมูล D1 เข้ากับ Cloudflare Pages (Binding)
1. ในหน้าโปรเจกต์ Pages `siet-canteen` คลิกไปที่แท็บ **Settings**
2. เลือกเมนูย่อย **Functions**
3. เลื่อนลงมาที่หัวข้อ **D1 Database Bindings** $\rightarrow$ คลิก **Add binding**
   - **Variable name**: พิมพ์คำว่า `DB` (ตัวพิมพ์ใหญ่ทั้งหมด)
   - **D1 database**: เลือกฐานข้อมูล `siet-canteen-db` ที่สร้างไว้ในขั้นตอนที่ 1
4. คลิกปุ่ม **Save**
5. กลับไปที่แท็บ **Deployments** $\rightarrow$ คลิกที่ปุ่มจุดสามจุด `...` ของ Deployment ล่าสุด $\rightarrow$ เลือก **Retry deployment** (เพื่อให้ฟังก์ชันเริ่มใช้งานฐานข้อมูลที่ผูกไว้)

🎉 **เสร็จสิ้น!** คุณจะได้ URL เว็บแอป เช่น:
`https://siet-canteen.pages.dev`
เมื่อเปิดเข้าไป แถบด้านบนจะแสดงสถานะสีเขียว: **`☁️ Cloudflare D1`** ข้อมูลร้านค้า เมนูอาหาร และสถิติแคลอรี่ของคุณจะถูกบันทึกลงสู่ระบบคลาวด์แบบเรียลไทม์!

---

## 💻 วิธีที่ 2: Deploy ผ่าน Wrangler CLI (สำหรับสาย Command Line)

หากเครื่องของคุณมี Node.js และต้องการ Deploy ผ่านคำสั่ง Terminal:

```bash
# 1. เข้าสู่ระบบ Cloudflare
npx wrangler login

# 2. สร้างฐานข้อมูล D1
npx wrangler d1 create siet-canteen-db
# (คัดลอก database_id ที่ได้ไปวางในไฟล์ wrangler.toml ตรง YOUR_CLOUDFLARE_D1_DATABASE_ID)

# 3. รัน Schema สร้างตารางข้อมูล
npx wrangler d1 execute siet-canteen-db --file=./schema.sql

# 4. สั่ง Deploy ขึ้น Cloudflare Pages
npx wrangler pages deploy . --project-name=siet-canteen
```

---

## 📡 รายละเอียด API Endpoints ที่สร้างไว้ใน `/functions/api/`

| Endpoint | Method | คำอธิบาย |
| :--- | :--- | :--- |
| `/api/canteen` | `GET` | ดึงรายชื่อร้านค้าและเมนูทั้งหมดจาก D1 |
| `/api/canteen` | `POST` | เพิ่ม/แก้ไข/ลบ ร้านค้า เมนู หรือชื่อโรงอาหาร |
| `/api/profile` | `GET` | ดึงข้อมูลส่วนตัว, ค่า TDEE และงบประมาณ |
| `/api/profile` | `POST` | บันทึกค่า TDEE และเป้าหมายสุขภาพลง D1 |
| `/api/diary` | `GET` | ดึงประวัติการกินอาหารของวันนี้ (`?date=YYYY-MM-DD`) |
| `/api/diary` | `POST` | บันทึกมื้ออาหารใหม่ลงฐานข้อมูล D1 |
| `/api/diary` | `DELETE` | ลบมื้ออาหารตาม ID หรือล้างประวัติประจำวัน |
| `/api/init-db` | `POST` | สั่งสร้างตารางและ Seed ข้อมูลให้อัตโนมัติผ่าน Edge |

---

## 🔄 ระบบ Dual-Mode (Online Cloud & Offline LocalStorage)
- **เมื่อเปิดบน Cloudflare Pages**: เว็บแอปจะติดต่อกับ `/api/...` เพื่อดึงและเซฟข้อมูลลง D1 Database ทันที ข้อมูลจะซิงค์ข้ามมือถือและคอมพิวเตอร์ของคุณ
- **เมื่อเปิดแบบออฟไลน์ / เปิดไฟล์ในเครื่อง (`file://`)**: แอปจะสลับไปใช้ `localStorage` โดยอัตโนมัติ ทำให้ยังคงสุ่มอาหารและคำนวณ TDEE ได้ตามปกติโดยไม่มี Error ใดๆ
