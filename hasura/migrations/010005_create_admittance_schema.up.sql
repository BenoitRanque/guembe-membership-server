CREATE SCHEMA admittance;

CREATE TABLE admittance.series (
  series_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
  updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER admittance_series_set_updated_at BEFORE UPDATE ON admittance.series FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE admittance.bracelet (
  bracelet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  series_id TEXT REFERENCES admittance.series (series_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT,
  serial BIGINT NOT NULL CHECK (serial > 0),
  UNIQUE (series_id, serial),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
  updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER admittance_bracelet_set_updated_at BEFORE UPDATE ON admittance.bracelet FOR EACH ROW EXECUTE FUNCTION set_updated_at();

INSERT INTO account.role (role_id, name, description) VALUES
  ('admittance_print', 'Imprimir Manillas', 'Permite crear & imprimir manillas'),
  ('admittance_view', 'Ver Manillas', 'Permite ver manillas');

-- CREATE TABLE admittance.checkpoint (
--   checkpoint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   checkpoint_name TEXT UNIQUE NOT NULL,
--   description TEXT
-- );

-- CREATE TABLE admittance.product (
--   product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   product_name TEXT UNIQUE NOT NULL,
--   description TEXT,
--   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
--   updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
-- );

-- CREATE TRIGGER admittance_product_set_updated_at BEFORE UPDATE ON admittance.product
--     FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- CREATE TABLE admittance.product_checkpoint (
--   product_id UUID NOT NULL REFERENCES admittance.product (product_id)
--     ON UPDATE CASCADE
--     ON DELETE CASCADE,
--   checkpoint_id UUID NOT NULL REFERENCES admittance.checkpoint (checkpoint_id)
--     ON UPDATE CASCADE
--     ON DELETE RESTRICT,
--   PRIMARY KEY (product_id, checkpoint_id)
-- );

-- CREATE TABLE admittance.assignation (
--   assignation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   bracelet_id UUID NOT NULL REFERENCES admittance.bracelet (bracelet_id)
--     ON UPDATE CASCADE
--     ON DELETE RESTRICT,
--   valid_from TIMESTAMP WITH TIME ZONE NOT NULL,
--   valid_to TIMESTAMP WITH TIME ZONE NOT NULL,
--   CHECK (valid_from < valid_to),
--   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
--   updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
-- );

-- CREATE TRIGGER admittance_assignation_set_updated_at BEFORE UPDATE ON admittance.assignation
--     FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- CREATE TABLE admittance.assignation_cancelation (
--   assignation_cancelation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   assignation_id UUID NOT NULL REFERENCES admittance.assignation (assignation_id)
--       ON UPDATE CASCADE
--       ON DELETE RESTRICT,
--   description TEXT,
--   owner_account_id UUID NOT NULL REFERENCES auth.account (account_id)
--     ON UPDATE CASCADE
--     ON DELETE RESTRICT,
--   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
--   updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
-- );

-- CREATE TABLE admittance.assignation_product (
--   assignation_id UUID NOT NULL REFERENCES admittance.assignation (assignation_id)
--     ON UPDATE CASCADE
--     ON DELETE CASCADE,
--   product_id UUID NOT NULL REFERENCES admittance.product (product_id)
--     ON UPDATE CASCADE
--     ON DELETE RESTRICT,
--   PRIMARY KEY (assignation_id, product_id)
-- );

-- CREATE TABLE admittance.activation (
--   activation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   bracelet_id UUID NOT NULL REFERENCES admittance.bracelet (bracelet_id)
--       ON UPDATE CASCADE
--       ON DELETE RESTRICT,
--   checkpoint_id UUID NOT NULL REFERENCES admittance.checkpoint (checkpoint_id)
--       ON UPDATE CASCADE
--       ON DELETE RESTRICT,
--   datetime TIMESTAMP WITH TIME ZONE NOT NULL,
--   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--   created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
--   updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
-- );

-- CREATE TRIGGER admittance_activation_set_updated_at BEFORE UPDATE ON admittance.activation FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- CREATE OR REPLACE FUNCTION admittance.activation_validation()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.datetime = NOW();
--     -- check if activations from other dates exist
--     IF EXISTS (
--         SELECT 1 FROM admittance.activation
--         WHERE bracelet_id = NEW.bracelet_id
--         AND NOT datetime <= CURRENT_DATE
--         AND NOT datetime >= (CURRENT_DATE + INTERVAL '1 day')
--     ) THEN
--         RAISE EXCEPTION 'This bracelet has already been activated on a diferent date';
--     END IF;
--     -- Join assignation to checkpoint using product
--     -- match bracelet and checkpoint
--     -- match valid_from and valid_to
--     -- check if assignation not cancelled
--     IF NOT EXISTS (
--         SELECT 1 FROM admittance.assignation
--             LEFT JOIN admittance.assignation_product
--             ON admittance.assignation_product.assignation_id = admittance.assignation.assignation_id
--             LEFT JOIN admittance.product_checkpoint
--             ON admittance.assignation_product.product_id = admittance.product_checkpoint.product_id
--         WHERE
--             admittance.assignation.bracelet_id = NEW.bracelet_id
--             AND admittance.product_checkpoint.checkpoint_id = NEW.checkpoint_id
--             AND admittance.assignation.valid_from <= NOW()
--             AND admittance.assignation.valid_to >= NOW()
--             AND NOT EXISTS (SELECT 1 FROM admittance.assignation_cancelation WHERE assignation_id = assignation.assignation_id)
--     ) THEN
--         RAISE EXCEPTION 'This bracelet is either invalid, expired or unassigned';
--     END IF;
--     RETURN NEW;
-- END;
-- $$ language 'plpgsql';
-- CREATE TRIGGER admittance_verify_activation_validation BEFORE INSERT ON admittance.activation
--     FOR EACH ROW EXECUTE FUNCTION admittance.activation_validation();
