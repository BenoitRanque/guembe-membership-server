DO $$
DECLARE
    admin_user_id UUID := gen_random_uuid();
BEGIN

INSERT INTO account.user (user_id, username, password, created_by_user_id, updated_by_user_id) VALUES
  (admin_user_id,  'admin', 'admin', admin_user_id, admin_user_id);

INSERT INTO account.role (role_id, name, description) VALUES
  ('administrator', 'Administrador', 'Usuario Administrador');

INSERT INTO account.user_role (role_id, user_id, created_by_user_id, updated_by_user_id) VALUES
  ('administrator', admin_user_id, admin_user_id, admin_user_id);

END $$;