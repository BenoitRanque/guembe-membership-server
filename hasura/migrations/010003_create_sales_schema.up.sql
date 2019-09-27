CREATE SCHEMA sales;

CREATE TABLE sales.client (
  client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  address TEXT,
  phone TEXT,
  email TEXT
);

CREATE TABLE sales.product (
  product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  description TEXT
  price INTEGER,
);
CREATE TABLE sales.room (
  room_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  description TEXT
  price INTEGER,
  capacity
);
CREATE TABLE sales.voucher (
  voucher_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  preliminary BOOLEAN,
);
CREATE TABLE sales.voucher_product (
  voucher_id UUID NOT NULL
    REFERENCES sales.voucher (voucher_id)
    ON DELETE CASCADE,
  product_id UUID NOT NULL
    REFERENCES sales.product (product_id)
    ON DELETE RESTRICT,
  quantity INTEGER,
  price INTEGER,
  discount_flat INTEGER DEFAULT 0,
  discount_percent NUMERIC (4, 4) DEFAULT 0, -- discount will never be greater thab 0.9999
  CHECK ((discount_flat = 0 AND discount_percent != 0) OR (discount_flat != 0 AND discount_percent = 0)),
);
CREATE TABLE sales.voucher_room (
  voucher_id UUID NOT NULL
    REFERENCES sales.voucher (voucher_id)
    ON DELETE CASCADE,
  room_id UUID NOT NULL
    REFERENCES sales.product (product_id)
    ON DELETE RESTRICT,
  checkin DATE NOT NULL,
  checkout DATE NOT NULL,
  CHECK (checkout > checkin),
  adults INTEGER NOT NULL DEFAULT 0,
  minors INTEGER NOT NULL DEFAULT 0,
  CHECK (adults + minors > 0),
  price INTEGER NOT NULL,
  discount_flat INTEGER NOT NULL DEFAULT 0,
  discount_percent NUMERIC (4, 4) NOT NULL DEFAULT 0,
  CHECK ((discount_flat = 0 AND discount_percent != 0) OR (discount_flat != 0 AND discount_percent = 0)),
);
CREATE TABLE sales.voucher_use (
  voucher_use_id
  voucher_id
);