CREATE TABLE membership.print (
  print_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  card_id UUID NOT NULL REFERENCES membership.card (card_id),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
  updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);