CREATE SCHEMA membership;

CREATE TABLE membership.type (
  type_id TEXT PRIMARY KEY,
  description TEXT
);

CREATE TABLE membership.contract (
  contract_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_number TEXT,
  client_id UUID NOT NULL
    REFERENCES sales.client (client_id)
    ON DELETE RESTRICT,
  sign_date DATE,
  start_date DATE,
  end_date DATE,
);
CREATE TABLE membership.card (
  card_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type_id TEXT NOT NULL
    REFERENCES membership.type (type_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  contract_id UUID NOT NULL
    REFERENCES membership.contract (contract_id)
    ON DELETE CASCADE,
  name TEXT NOT NULL,
  document TEXT NOT NULL,
  photo TEXT NOT NULL,
);
CREATE TABLE membership.use (
  use_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  card_id UUID NOT NULL
    REFERENCES membership.card (card_id)
    ON DELETE RESTRICT,
);