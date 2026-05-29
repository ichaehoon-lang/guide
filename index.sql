-- =====================================================
-- 1. tours 테이블 컬럼 추가
-- =====================================================
ALTER TABLE tours ADD COLUMN IF NOT EXISTS tour_code TEXT;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS flight_code TEXT;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS arrival_time TIME;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS captain_name TEXT;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS captain_contact TEXT;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS bus_capacity INT;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS total_days INT DEFAULT 1;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS current_day INT DEFAULT 1;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS scenic_confirmed BOOL DEFAULT false;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS everton_confirmed BOOL DEFAULT false;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS pax INT DEFAULT 0;

-- =====================================================
-- 2. 한식당 목록 테이블
-- =====================================================
CREATE TABLE IF NOT EXISTS restaurants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "인증된 사용자 조회"
  ON restaurants FOR SELECT
  USING (auth.role() = 'authenticated');
CREATE POLICY "인증된 사용자 입력"
  ON restaurants FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 기본 식당 데이터
INSERT INTO restaurants (name, address) VALUES
  ('시드니 한정식', 'Pitt St, Sydney'),
  ('강남 한식당', 'George St, Sydney'),
  ('코리아나', 'World Square, Sydney'),
  ('한강 식당', 'Haymarket, Sydney')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. 쇼핑업체 목록 테이블
-- =====================================================
CREATE TABLE IF NOT EXISTS shopping_companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE shopping_companies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "인증된 사용자 조회"
  ON shopping_companies FOR SELECT
  USING (auth.role() = 'authenticated');
CREATE POLICY "인증된 사용자 입력"
  ON shopping_companies FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 기본 쇼핑업체 데이터
INSERT INTO shopping_companies (name, category) VALUES
  ('UGG Australia', 'UGG'),
  ('BIO Health', 'BIO'),
  ('Wool & Cashmere', 'Wool'),
  ('Everton Health', 'BIO'),
  ('Sydney Opal', 'Opal')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. 일별 기록 테이블 (가이드 현장 입력)
-- =====================================================
CREATE TABLE IF NOT EXISTS daily_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tour_id UUID REFERENCES tours(id) ON DELETE CASCADE,
  guide_id UUID REFERENCES auth.users(id),
  day_number INT NOT NULL DEFAULT 1,
  meeting_completed BOOL DEFAULT false,
  meeting_completed_at TIMESTAMPTZ,
  restaurant_name TEXT,
  shopping_visits JSONB DEFAULT '[]',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE daily_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "가이드 본인 기록 입력"
  ON daily_records FOR INSERT
  WITH CHECK (auth.uid() = guide_id);
CREATE POLICY "가이드 본인 기록 조회"
  ON daily_records FOR SELECT
  USING (auth.uid() = guide_id);
CREATE POLICY "가이드 본인 기록 수정"
  ON daily_records FOR UPDATE
  USING (auth.uid() = guide_id);
