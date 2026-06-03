class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jitlmgzlwicqpbvvudmv.supabase.co',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_GTvM_M3eKti0dMRp0Vu-IA_f_2Nd-vJ',
  );
}
