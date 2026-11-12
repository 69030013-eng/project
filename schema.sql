-- ====================================================================
-- Cloudflare D1 Database Schema for SIET Smart Canteen App
-- ====================================================================

-- 1. Canteen Info Table
CREATE TABLE IF NOT EXISTS canteen_info (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  name TEXT NOT NULL DEFAULT 'โรงอาหารกลาง (Main Canteen)',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Stalls Table
CREATE TABLE IF NOT EXISTS stalls (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT DEFAULT '🍲',
  color TEXT DEFAULT '#3B82F6',
  sort_order INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Menus Table
CREATE TABLE IF NOT EXISTS menus (
  id TEXT PRIMARY KEY,
  stall_id TEXT NOT NULL,
  name TEXT NOT NULL,
  price INTEGER NOT NULL DEFAULT 40,
  calories INTEGER NOT NULL DEFAULT 400,
  category TEXT DEFAULT 'จานเดียว',
  tags TEXT DEFAULT '[]', -- JSON string array
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (stall_id) REFERENCES stalls(id) ON DELETE CASCADE
);

-- 4. User Health Profile & TDEE Table
CREATE TABLE IF NOT EXISTS user_profile (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  gender TEXT DEFAULT 'male',
  age INTEGER DEFAULT 22,
  weight REAL DEFAULT 68,
  height REAL DEFAULT 172,
  activity_level REAL DEFAULT 1.375,
  goal TEXT DEFAULT 'deficit',
  tdee INTEGER DEFAULT 2150,
  bmr INTEGER DEFAULT 1620,
  target_calories INTEGER DEFAULT 1650,
  daily_budget INTEGER DEFAULT 150,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5. Daily Food Diary Entries Table
CREATE TABLE IF NOT EXISTS diary_entries (
  id TEXT PRIMARY KEY,
  date TEXT NOT NULL, -- YYYY-MM-DD
  time TEXT NOT NULL, -- HH:MM
  timestamp INTEGER NOT NULL,
  meal_type TEXT NOT NULL, -- breakfast, lunch, dinner, snack
  stall_name TEXT,
  menu_name TEXT NOT NULL,
  calories INTEGER NOT NULL,
  price INTEGER NOT NULL,
  modifiers TEXT DEFAULT '[]', -- JSON array
  is_ai_recognized INTEGER DEFAULT 0,
  image_url TEXT,
  nutrition TEXT, -- JSON object
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indices for performance
CREATE INDEX IF NOT EXISTS idx_menus_stall_id ON menus(stall_id);
CREATE INDEX IF NOT EXISTS idx_diary_date ON diary_entries(date);

-- ====================================================================
-- Initial Seed Data (Default Thai Canteen Presets)
-- ====================================================================

INSERT OR IGNORE INTO canteen_info (id, name) VALUES (1, 'โรงอาหารกลาง (Main Canteen)');

INSERT OR IGNORE INTO user_profile (id, gender, age, weight, height, activity_level, goal, tdee, bmr, target_calories, daily_budget)
VALUES (1, 'male', 22, 68, 172, 1.375, 'deficit', 2150, 1620, 1650, 150);

-- Insert Default Stalls
INSERT OR IGNORE INTO stalls (id, name, icon, color, sort_order) VALUES
('stall-1', 'ร้านป้าศรี ข้าวราดแกง & ตามสั่ง', '🍲', '#F97316', 1),
('stall-2', 'ร้านเจ๊หมวย ก๋วยเตี๋ยวปลา & ต้มยำ', '🍜', '#3B82F6', 2),
('stall-3', 'ร้านลุงหนุ่ม ข้าวมันไก่ & ข้าวหมูแดง', '🍗', '#EAB308', 3),
('stall-4', 'ร้านเจ๊แต๋ว อาหารตามสั่ง & สุกี้', '🍳', '#10B981', 4),
('stall-5', 'ร้านกรีนไลฟ์ สลัดผลไม้ & น้ำสมุนไพร', '🥗', '#06B6D4', 5);

-- Insert Menus for Stall 1
INSERT OR IGNORE INTO menus (id, stall_id, name, price, calories, category, tags) VALUES
('m-1-1', 'stall-1', 'ข้าวราดแกงส้มชะอมกุ้ง', 40, 320, 'ต้ม/แกง', '["โปรตีน","ไขมันต่ำ"]'),
('m-1-2', 'stall-1', 'ข้าวราดผัดกะเพราหมูสับ', 40, 550, 'ตามสั่ง', '["ยอดนิยม","รสจัด"]'),
('m-1-3', 'stall-1', 'ข้าวราดพะแนงหมู', 40, 490, 'แกงกะทิ', '["แกง"]'),
('m-1-4', 'stall-1', 'ข้าวราดไข่พะโล้หมู', 40, 430, 'ต้ม', '["โปรตีน"]'),
('m-1-5', 'stall-1', 'ข้าวราดต้มจืดเต้าหู้หมูสับ', 35, 230, 'ต้ม/แกง', '["คลีน","ไขมันต่ำ"]'),
('m-1-6', 'stall-1', 'ข้าวผัดกะเพราอกไก่ (น้ำมันน้อย)', 45, 360, 'ตามสั่ง', '["คลีน","โปรตีนสูง"]'),
('m-1-7', 'stall-1', 'ข้าวราดผัดผักรวมมิตรหมูชิ้น', 35, 310, 'ผัด', '["ผักเยอะ","ใยอาหาร"]');

-- Insert Menus for Stall 2
INSERT OR IGNORE INTO menus (id, stall_id, name, price, calories, category, tags) VALUES
('m-2-1', 'stall-2', 'เส้นหมี่น้ำใสลูกชิ้นปลา', 45, 280, 'ก๋วยเตี๋ยว', '["ไขมันต่ำ","คลีน"]'),
('m-2-2', 'stall-2', 'บะหมี่ต้มยำหมูสับ', 50, 430, 'ก๋วยเตี๋ยว', '["รสจัด","ยอดนิยม"]'),
('m-2-3', 'stall-2', 'เกาเหลาเลือดหมูใบตำลึง + ข้าวเปล่า', 45, 310, 'ต้ม', '["โปรตีนสูง","ผักเยอะ"]'),
('m-2-4', 'stall-2', 'เส้นเล็กแห้งต้มยำหมู', 50, 470, 'ก๋วยเตี๋ยว', '["แห้ง"]'),
('m-2-5', 'stall-2', 'วุ้นเส้นน้ำใสไก่ฉีก', 40, 240, 'ก๋วยเตี๋ยว', '["แคลอรี่ต่ำ","คลีน"]'),
('m-2-6', 'stall-2', 'ก๋วยเตี๋ยวเส้นใหญ่น้ำตกเนื้อ', 50, 460, 'ก๋วยเตี๋ยว', '["เข้มข้น"]');

-- Insert Menus for Stall 3
INSERT OR IGNORE INTO menus (id, stall_id, name, price, calories, category, tags) VALUES
('m-3-1', 'stall-3', 'ข้าวมันไก่ต้ม (ไม่เอาหนัง)', 45, 440, 'จานเดียว', '["โปรตีนสูง","ยอดนิยม"]'),
('m-3-2', 'stall-3', 'ข้าวมันไก่ทอด', 50, 650, 'จานเดียว', '["ของทอด","แคลอรี่สูง"]'),
('m-3-3', 'stall-3', 'ข้าวหน้าไก่ต้ม (ข้าวสวยธรรมดา)', 40, 340, 'จานเดียว', '["คลีน","ไขมันต่ำ"]'),
('m-3-4', 'stall-3', 'ข้าวหมูแดงล้วน (ไม่เอากรอบ)', 45, 430, 'จานเดียว', '["โปรตีน"]'),
('m-3-5', 'stall-3', 'ข้าวหมูกรอบล้วน', 50, 680, 'จานเดียว', '["ของทอด","ไขมันสูง"]');

-- Insert Menus for Stall 4
INSERT OR IGNORE INTO menus (id, stall_id, name, price, calories, category, tags) VALUES
('m-4-1', 'stall-4', 'สุกี้น้ำรวมมิตร (ไม่ใส่น้ำมัน)', 50, 270, 'สุกี้/ต้ม', '["คลีน","ผักเยอะ","ลดน้ำหนัก"]'),
('m-4-2', 'stall-4', 'สุกี้แห้งไก่', 50, 390, 'สุกี้/ผัด', '["ผักเยอะ"]'),
('m-4-3', 'stall-4', 'ผัดซีอิ๊วหมูนุ่มเส้นใหญ่', 50, 570, 'ผัด', '["เส้น","ยอดนิยม"]'),
('m-4-4', 'stall-4', 'ข้าวผัดไข่ใส่ไก่', 45, 490, 'ข้าวผัด', '["จานเดียว"]'),
('m-4-5', 'stall-4', 'ราดหน้าหมูนุ่มเส้นหมี่ขาว', 50, 410, 'เส้น', '["ผักคะน้า"]');

-- Insert Menus for Stall 5
INSERT OR IGNORE INTO menus (id, stall_id, name, price, calories, category, tags) VALUES
('m-5-1', 'stall-5', 'สลัดอกไก่ฉีกไข่ต้ม น้ำสลัดงาญี่ปุ่น', 50, 250, 'สลัด', '["คลีน","โปรตีนสูง","ไฟเบอร์"]'),
('m-5-2', 'stall-5', 'ผลไม้รวมจานสด (แตงโม+ฝรั่ง+สับปะรด)', 25, 90, 'ผลไม้', '["วิตามิน","หวานธรรมชาติ"]'),
('m-5-3', 'stall-5', 'น้ำเต้าหู้หวานน้อยทรงเครื่อง', 15, 120, 'เครื่องดื่ม', '["โปรตีนพืช"]'),
('m-5-4', 'stall-5', 'ชาเขียวมะลิแท้ ไม่ใส่น้ำตาล (0 kcal)', 20, 5, 'เครื่องดื่ม', '["0แคลอรี่","คีโต"]'),
('m-5-5', 'stall-5', 'แซนด์วิชไข่ต้มอกไก่ ขนมปังโฮลวีท', 30, 210, 'ของว่าง', '["โฮลวีท","พกพาสะดวก"]');
