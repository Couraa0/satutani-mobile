-- Fix: orders insert failed with FK violation orders_consumer_id_fkey because
-- an authenticated auth.users row had no matching public.profiles row
-- (e.g. created during a window where handle_new_user did not run/insert).
-- consumer_id / farmer_id on orders reference profiles.id, so checkout 500'd.
--
-- 1) Backfill a profile for every auth.users row that is missing one.
-- 2) Harden handle_new_user: SET search_path + schema-qualified enum so the
--    SECURITY DEFINER trigger resolves types/tables regardless of caller path.

-- 1) Backfill -----------------------------------------------------------------
INSERT INTO public.profiles (id, name, avatar_url, role)
SELECT
  u.id,
  COALESCE(NULLIF(u.raw_user_meta_data->>'full_name', ''), u.email, ''),
  COALESCE(u.raw_user_meta_data->>'avatar_url', ''),
  CASE
    WHEN u.raw_user_meta_data->>'role' IN ('farmer', 'consumer')
      THEN (u.raw_user_meta_data->>'role')::public.user_role
    ELSE 'consumer'::public.user_role
  END
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- 2) Harden trigger function --------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  _role_text TEXT;
  _role public.user_role := 'consumer';
BEGIN
  _role_text := NEW.raw_user_meta_data->>'role';

  IF _role_text IS NOT NULL AND _role_text <> '' THEN
    BEGIN
      _role := _role_text::public.user_role;
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
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

ALTER FUNCTION public.handle_new_user() OWNER TO postgres;
