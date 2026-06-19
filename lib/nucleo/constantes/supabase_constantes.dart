// Contiene credenciales y banderas de integracion con Supabase.
const urlSupabase = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://yoraosrnnlqenpjtefre.supabase.co',
);
const llaveAnonimaSupabase = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_psmF742Hds9eFPniSBwCRg_9VHfqh2N',
);
const llaveGoogleMaps = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'TU_GOOGLE_MAPS_API_KEY',
);

// Para usar datos mock ejecuta con --dart-define=USAR_MOCK=true.
const usarMock = bool.fromEnvironment('USAR_MOCK', defaultValue: false);

const credencialesSupabaseConfiguradas = urlSupabase != 'TU_SUPABASE_URL' &&
    llaveAnonimaSupabase != 'TU_SUPABASE_ANON_KEY';
