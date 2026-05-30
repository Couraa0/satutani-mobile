-- Fix: handle_new_user now reads 'role' from user metadata so that
-- email+password signUp correctly persists the chosen role without
-- needing a separate client-side UPDATE (which requires an active session).
--
-- Important: NULL::user_role returns NULL (no exception), so we must
-- guard with IF NOT NULL before casting — otherwise an insert with
-- role = NULL violates the NOT NULL constraint on profiles.role
-- and aborts auth.users insert ("Database error saving new user").

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  _role_text TEXT;
  _role user_role := 'consumer';
BEGIN
  _role_text := NEW.raw_user_meta_data->>'role';

  IF _role_text IS NOT NULL AND _role_text <> '' THEN
    BEGIN
      _role := _role_text::user_role;
    EXCEPTION WHEN OTHERS THEN
      _role := 'consumer';
    END;
  END IF;

  INSERT INTO public.profiles (id, name, avatar_url, role)
  VALUES (
    NEW.id,
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'full_name', ''), NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
    _role
  );
  RETURN NEW;
END;
$$;
