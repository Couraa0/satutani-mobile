import 'package:supabase_flutter/supabase_flutter.dart';

/// Global accessor — gunakan `db` untuk query, `auth` untuk autentikasi.
SupabaseClient get db => Supabase.instance.client;
GoTrueClient get auth => Supabase.instance.client.auth;
