-- Activa unicamente las 20 publicaciones creadas por supabase_seed_20_adopciones.sql.
update public.posts
set
  status = 'active',
  reviewed_at = now(),
  admin_note = null
where type = 'adoption'
  and status = 'pending_approval'
  and title in (
    'Mamba busca una familia',
    'Bruno necesita un hogar',
    'Luna quiere conocerte',
    'Toby espera una segunda oportunidad',
    'Nala busca casa',
    'Max necesita familia',
    'Milo busca un hogar tranquilo',
    'Kira quiere ser parte de tu familia',
    'Simba esta listo para adoptar',
    'Canela busca compania',
    'Rocky quiere volver a confiar',
    'Mia busca una familia amorosa',
    'Duke necesita paseos y carino',
    'Pelusa quiere una casa',
    'Zeus busca un hogar activo',
    'Olivia espera conocerte',
    'Thor necesita una oportunidad',
    'Cleo busca una familia paciente',
    'Rex quiere jugar contigo',
    'Lola necesita un hogar definitivo'
  );
