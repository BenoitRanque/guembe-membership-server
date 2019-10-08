CREATE SCHEMA account;

CREATE TABLE account.user (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL DEFAULT '',
    name TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER account_user_set_updated_at BEFORE UPDATE ON account.user FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE FUNCTION account.hash_password()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.password IS NOT NULL AND (OLD IS NULL OR OLD.password != NEW.password) THEN
        NEW.password = crypt(NEW.password, gen_salt('bf'));
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER account_user_hash_password BEFORE INSERT OR UPDATE ON account.user FOR EACH ROW EXECUTE FUNCTION account.hash_password();

CREATE TABLE account.role (
    role_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE account.user_role (
    user_id UUID REFERENCES account.user(user_id)
        ON DELETE CASCADE,
    role_id TEXT REFERENCES account.role(role_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER account_user_role_set_updated_at BEFORE UPDATE ON account.user_role FOR EACH ROW EXECUTE FUNCTION set_updated_at();
