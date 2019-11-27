CREATE SCHEMA membership;

CREATE TABLE membership.type (
  type_id TEXT PRIMARY KEY,
  description TEXT
);

INSERT INTO membership.type (type_id, description) VALUES
  ('INDIVIDUAL', 'Membresia Individual'),
  ('DUO', 'Membresia Doble'),
  ('FAMILY', 'Membresia Familiar'),
  ('CHILD', 'Membresia Infantil');

CREATE TABLE membership.contract (
  contract_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_number TEXT,
  client_id UUID NOT NULL
    REFERENCES sales.client (client_id)
    ON DELETE RESTRICT,
  sign_date DATE,
  start_date DATE,
  end_date DATE,
  business_name TEXT,
  tax_identification_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
  updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER membership_contract_set_updated_at BEFORE UPDATE ON membership.contract FOR EACH ROW EXECUTE FUNCTION set_updated_at();
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
  image TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
  updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER membership_card_set_updated_at BEFORE UPDATE ON membership.card FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE membership.use (
  use_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  card_id UUID NOT NULL
    REFERENCES membership.card (card_id)
    ON DELETE RESTRICT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
  updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER membership_use_set_updated_at BEFORE UPDATE ON membership.use FOR EACH ROW EXECUTE FUNCTION set_updated_at();