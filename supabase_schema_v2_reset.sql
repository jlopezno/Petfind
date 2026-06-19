-- PetFindr schema v2 reset.
-- ADVERTENCIA: este script borra las tablas, funciones, tipos y policies de PetFindr en public.
-- No borra usuarios de auth.users ni archivos ya subidos a Storage.
-- Ejecutar en Supabase SQL Editor cuando no haya datos importantes.

begin;

create extension if not exists postgis;
create extension if not exists pgcrypto;

-- 1. Limpiar objetos anteriores de PetFindr.
drop view if exists public.sponsorship_totals;

drop trigger if exists on_auth_user_created on auth.users;
drop trigger if exists profiles_set_updated_at on public.profiles;
drop trigger if exists pets_set_updated_at on public.pets;
drop trigger if exists posts_set_updated_at on public.posts;
drop trigger if exists adoptions_set_updated_at on public.adoptions;
drop trigger if exists sponsorships_set_updated_at on public.sponsorships;
drop trigger if exists ratings_refresh_totals on public.ratings;
drop trigger if exists posts_validate_business_rules on public.posts;
drop trigger if exists sightings_validate_business_rules on public.sightings;
drop trigger if exists sponsorships_validate_business_rules on public.sponsorships;

drop table if exists public.owner_found_reports cascade;
drop table if exists public.notifications cascade;
drop table if exists public.ratings cascade;
drop table if exists public.sightings cascade;
drop table if exists public.sponsorships cascade;
drop table if exists public.adoptions cascade;
drop table if exists public.lost_reports cascade;
drop table if exists public.vaccines cascade;
drop table if exists public.posts cascade;
drop table if exists public.pets cascade;
drop table if exists public.profiles cascade;

drop function if exists public.set_updated_at() cascade;
drop function if exists public.handle_new_user() cascade;
drop function if exists public.recalculate_profile_rating(uuid) cascade;
drop function if exists public.refresh_rating_totals() cascade;
drop function if exists public.posts_near_location(float, float, int, text) cascade;
drop function if exists public.validate_post_business_rules() cascade;
drop function if exists public.validate_sighting_business_rules() cascade;
drop function if exists public.validate_sponsorship_business_rules() cascade;
drop function if exists public.approve_post(uuid) cascade;
drop function if exists public.observe_post(uuid, text) cascade;
drop function if exists public.reject_post(uuid, text) cascade;
drop function if exists public.resolve_own_post(uuid) cascade;
drop function if exists public.close_own_post(uuid) cascade;
drop function if exists public.create_adoption_request(uuid, text) cascade;

drop type if exists public.notification_type cascade;
drop type if exists public.rating_target cascade;
drop type if exists public.payment_status cascade;
drop type if exists public.adoption_status cascade;
drop type if exists public.post_status cascade;
drop type if exists public.post_status_legacy cascade;
drop type if exists public.post_status_v2 cascade;
drop type if exists public.post_type cascade;
drop type if exists public.post_type_legacy cascade;
drop type if exists public.post_type_v2 cascade;
drop type if exists public.pet_size cascade;
drop type if exists public.pet_species cascade;
drop type if exists public.user_role cascade;

-- 2. Tipos.
create type public.user_role as enum ('owner', 'shelter');
create type public.pet_species as enum ('dog', 'cat', 'bird', 'rabbit', 'other');
create type public.pet_size as enum ('small', 'medium', 'large');
create type public.post_type as enum ('lost', 'rescued', 'adoption');
create type public.post_status as enum (
  'pending_approval',
  'active',
  'observed',
  'rejected',
  'resolved',
  'closed',
  'deleted'
);
create type public.adoption_status as enum ('pending', 'approved', 'rejected', 'completed');
create type public.payment_status as enum ('pending', 'completed', 'failed', 'refunded');
create type public.rating_target as enum ('publisher', 'shelter', 'reporter', 'adopter');
create type public.notification_type as enum (
  'post_approved',
  'post_rejected',
  'post_observed',
  'new_sighting',
  'new_sponsorship',
  'new_adoption_request',
  'adoption_approved',
  'adoption_rejected',
  'owner_found_report'
);

-- 3. Tablas.
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.user_role not null default 'owner',
  full_name text not null default '',
  email text,
  phone text,
  avatar_url text,
  city text,
  shelter_name text,
  shelter_ruc text,
  shelter_bio text,
  verified boolean not null default false,
  is_admin boolean not null default false,
  location geometry(point, 4326),
  rating_score int not null default 0,
  rating_count int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  species public.pet_species not null,
  breed text,
  color text,
  size public.pet_size,
  birth_date date,
  gender char(1) not null check (gender in ('M', 'F')),
  description text,
  photos text[] not null default '{}',
  main_photo text,
  microchip_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.vaccines (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  name text not null,
  administered_at date not null,
  next_due_at date,
  veterinarian text,
  clinic text,
  notes text,
  certificate_url text,
  created_at timestamptz not null default now()
);

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid references public.pets(id) on delete set null,
  type public.post_type not null,
  status public.post_status not null default 'pending_approval',
  title text not null,
  body text,
  photos text[] not null default '{}',
  location geometry(point, 4326),
  address_hint text,

  -- Datos de mascota embebidos en la publicacion.
  pet_name text,
  pet_species public.pet_species,
  pet_breed text,
  pet_color_features text,
  pet_size public.pet_size,
  pet_gender char(1) check (pet_gender is null or pet_gender in ('M', 'F')),
  pet_age_text text,
  pet_description text,
  contact_phone text,

  -- Tipo rescued.
  severity text check (severity is null or severity in ('mild', 'moderate', 'urgent')),
  sponsor_goal numeric(10, 2) check (sponsor_goal is null or sponsor_goal >= 0),

  -- Tipo adoption.
  adoption_requirements text,

  -- Moderacion.
  admin_note text,
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id) on delete set null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.lost_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null unique references public.posts(id) on delete cascade,
  last_seen_at timestamptz not null,
  last_seen_loc geometry(point, 4326),
  last_seen_addr text,
  circumstances text,
  reward numeric(10, 2),
  contact_phone text,
  resolved boolean not null default false,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.adoptions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  applicant_id uuid not null references public.profiles(id) on delete cascade,
  shelter_id uuid not null references public.profiles(id) on delete cascade,
  status public.adoption_status not null default 'pending',
  message text,
  rejection_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (post_id, applicant_id)
);

create table public.sponsorships (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  sponsor_id uuid not null references public.profiles(id) on delete cascade,
  amount numeric(10, 2) not null check (amount >= 1),
  currency char(3) not null default 'PEN',
  payment_status public.payment_status not null default 'pending',
  payment_provider text,
  provider_tx_id text,
  provider_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sightings (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  seen_at timestamptz not null,
  location geometry(point, 4326) not null,
  address_hint text,
  photo_url text,
  notes text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.ratings (
  id uuid primary key default gen_random_uuid(),
  reviewer_id uuid not null references public.profiles(id) on delete cascade,
  target_id uuid not null references public.profiles(id) on delete cascade,
  target_type public.rating_target not null,
  value smallint not null check (value in (1, -1)),
  comment text,
  context_id uuid,
  created_at timestamptz not null default now(),
  check (reviewer_id <> target_id),
  unique (reviewer_id, target_id, target_type, context_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  type public.notification_type not null,
  title text not null,
  body text not null,
  context_id uuid,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.owner_found_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  message text,
  contact_phone text,
  created_at timestamptz not null default now()
);

-- 4. Indices.
create index idx_profiles_location on public.profiles using gist(location);
create index idx_pets_owner_id on public.pets(owner_id);
create index idx_posts_location on public.posts using gist(location);
create index idx_posts_status_type_created on public.posts(status, type, created_at desc);
create index idx_posts_author_status on public.posts(author_id, status, created_at desc);
create index idx_sightings_post_id on public.sightings(post_id);
create index idx_sponsorships_post_status on public.sponsorships(post_id, payment_status);
create index idx_ratings_target_id on public.ratings(target_id);
create index idx_notifications_recipient_created on public.notifications(recipient_id, created_at desc);
create index idx_owner_found_reports_post_created on public.owner_found_reports(post_id, created_at desc);

-- 5. Funciones y triggers.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

create trigger pets_set_updated_at before update on public.pets
for each row execute function public.set_updated_at();

create trigger posts_set_updated_at before update on public.posts
for each row execute function public.set_updated_at();

create trigger adoptions_set_updated_at before update on public.adoptions
for each row execute function public.set_updated_at();

create trigger sponsorships_set_updated_at before update on public.sponsorships
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    email,
    role,
    full_name,
    shelter_name,
    shelter_ruc
  )
  values (
    new.id,
    new.email,
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'owner'),
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    nullif(new.raw_user_meta_data ->> 'shelter_name', ''),
    nullif(new.raw_user_meta_data ->> 'shelter_ruc', '')
  )
  on conflict (id) do update set
    email = excluded.email,
    role = excluded.role,
    full_name = excluded.full_name,
    shelter_name = excluded.shelter_name,
    shelter_ruc = excluded.shelter_ruc,
    updated_at = now();

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.validate_post_business_rules()
returns trigger
language plpgsql
as $$
begin
  if new.status is null then
    new.status = 'pending_approval';
  end if;

  if tg_op = 'INSERT' and new.status <> 'pending_approval' then
    raise exception 'Toda publicacion nueva debe iniciar pendiente de aprobacion';
  end if;

  if new.type = 'rescued' and new.severity is null then
    raise exception 'Las publicaciones rescatadas requieren gravedad del caso';
  end if;

  if new.type = 'adoption' and (new.pet_name is null or length(trim(new.pet_name)) = 0) then
    raise exception 'Las publicaciones de adopcion requieren nombre de mascota';
  end if;

  if new.status in ('observed', 'rejected') and (new.admin_note is null or length(trim(new.admin_note)) = 0) then
    raise exception 'Las publicaciones observadas o rechazadas requieren nota del administrador';
  end if;

  return new;
end;
$$;

create trigger posts_validate_business_rules
before insert or update on public.posts
for each row execute function public.validate_post_business_rules();

create or replace function public.validate_sighting_business_rules()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1 from public.posts p
    where p.id = new.post_id
      and p.type = 'lost'
      and p.status = 'active'
  ) then
    raise exception 'Solo se pueden reportar avistamientos en publicaciones perdidas activas';
  end if;

  return new;
end;
$$;

create trigger sightings_validate_business_rules
before insert or update on public.sightings
for each row execute function public.validate_sighting_business_rules();

create or replace function public.validate_sponsorship_business_rules()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1 from public.posts p
    where p.id = new.post_id
      and p.type = 'rescued'
      and p.status = 'active'
  ) then
    raise exception 'Solo se puede apoyar publicaciones rescatadas activas';
  end if;

  return new;
end;
$$;

create trigger sponsorships_validate_business_rules
before insert or update on public.sponsorships
for each row execute function public.validate_sponsorship_business_rules();

create or replace function public.recalculate_profile_rating(profile_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set
    rating_score = coalesce((select sum(value)::int from public.ratings where target_id = profile_id), 0),
    rating_count = coalesce((select count(*)::int from public.ratings where target_id = profile_id), 0)
  where id = profile_id;
end;
$$;

create or replace function public.refresh_rating_totals()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.recalculate_profile_rating(old.target_id);
    return old;
  end if;

  perform public.recalculate_profile_rating(new.target_id);
  if tg_op = 'UPDATE' and old.target_id <> new.target_id then
    perform public.recalculate_profile_rating(old.target_id);
  end if;
  return new;
end;
$$;

create trigger ratings_refresh_totals
after insert or update or delete on public.ratings
for each row execute function public.refresh_rating_totals();

-- 6. RPC de administracion y usuario.
create or replace function public.approve_post(post_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from public.profiles where id = auth.uid() and is_admin = true) then
    raise exception 'Solo un administrador puede aprobar publicaciones';
  end if;

  update public.posts
  set status = 'active', admin_note = null, reviewed_at = now(), reviewed_by = auth.uid()
  where id = post_id;
end;
$$;

create or replace function public.observe_post(post_id uuid, note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from public.profiles where id = auth.uid() and is_admin = true) then
    raise exception 'Solo un administrador puede observar publicaciones';
  end if;

  update public.posts
  set status = 'observed', admin_note = note, reviewed_at = now(), reviewed_by = auth.uid()
  where id = post_id;
end;
$$;

create or replace function public.reject_post(post_id uuid, note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from public.profiles where id = auth.uid() and is_admin = true) then
    raise exception 'Solo un administrador puede rechazar publicaciones';
  end if;

  update public.posts
  set status = 'rejected', admin_note = note, reviewed_at = now(), reviewed_by = auth.uid()
  where id = post_id;
end;
$$;

create or replace function public.resolve_own_post(post_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.posts
  set status = 'resolved'
  where id = post_id
    and author_id = auth.uid()
    and status = 'active';
end;
$$;

create or replace function public.close_own_post(post_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.posts
  set status = 'closed'
  where id = post_id
    and author_id = auth.uid()
    and status in ('pending_approval', 'active', 'observed');
end;
$$;

create or replace function public.create_adoption_request(post_id uuid, message text default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  author uuid;
  request_id uuid;
begin
  select p.author_id
  into author
  from public.posts p
  where p.id = post_id
    and p.type = 'adoption'
    and p.status = 'active';

  if author is null then
    raise exception 'Solo se puede solicitar adopcion en publicaciones activas de adopcion';
  end if;

  if author = auth.uid() then
    raise exception 'El autor no puede solicitar adoptar su propia publicacion';
  end if;

  insert into public.adoptions(post_id, applicant_id, shelter_id, message)
  values (post_id, auth.uid(), author, message)
  returning id into request_id;

  return request_id;
end;
$$;

create or replace function public.posts_near_location(
  lon float,
  lat float,
  radius_m int,
  filter_type text default null
)
returns table (
  id uuid,
  author_id uuid,
  pet_id uuid,
  type public.post_type,
  status public.post_status,
  title text,
  body text,
  photos text[],
  address_hint text,
  pet_name text,
  pet_species public.pet_species,
  pet_breed text,
  pet_color_features text,
  pet_size public.pet_size,
  pet_gender char(1),
  pet_age_text text,
  pet_description text,
  contact_phone text,
  severity text,
  sponsor_goal numeric(10, 2),
  adoption_requirements text,
  admin_note text,
  reviewed_at timestamptz,
  reviewed_by uuid,
  created_at timestamptz,
  updated_at timestamptz,
  lat float,
  lon float,
  distance_m float
)
language sql
stable
as $$
  select
    p.id,
    p.author_id,
    p.pet_id,
    p.type,
    p.status,
    p.title,
    p.body,
    p.photos,
    p.address_hint,
    p.pet_name,
    p.pet_species,
    p.pet_breed,
    p.pet_color_features,
    p.pet_size,
    p.pet_gender,
    p.pet_age_text,
    p.pet_description,
    p.contact_phone,
    p.severity,
    p.sponsor_goal,
    p.adoption_requirements,
    p.admin_note,
    p.reviewed_at,
    p.reviewed_by,
    p.created_at,
    p.updated_at,
    st_y(p.location)::float as lat,
    st_x(p.location)::float as lon,
    st_distance(
      p.location::geography,
      st_setsrid(st_makepoint(posts_near_location.lon, posts_near_location.lat), 4326)::geography
    )::float as distance_m
  from public.posts p
  where p.status = 'active'
    and p.location is not null
    and (filter_type is null or p.type::text = filter_type)
    and st_dwithin(
      p.location::geography,
      st_setsrid(st_makepoint(posts_near_location.lon, posts_near_location.lat), 4326)::geography,
      radius_m
    )
  order by distance_m asc, p.created_at desc;
$$;

create view public.sponsorship_totals as
select
  post_id,
  coalesce(sum(amount) filter (where payment_status = 'completed'), 0)::numeric(10, 2) as total_completed,
  count(distinct sponsor_id) filter (where payment_status = 'completed') as sponsor_count,
  count(*) filter (where payment_status = 'completed') as payment_count
from public.sponsorships
group by post_id;

-- 7. RLS.
alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.vaccines enable row level security;
alter table public.posts enable row level security;
alter table public.lost_reports enable row level security;
alter table public.adoptions enable row level security;
alter table public.sponsorships enable row level security;
alter table public.sightings enable row level security;
alter table public.ratings enable row level security;
alter table public.notifications enable row level security;
alter table public.owner_found_reports enable row level security;

create policy "Perfiles visibles para usuarios autenticados" on public.profiles
for select to authenticated using (true);

create policy "Usuarios actualizan su perfil" on public.profiles
for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "Mascotas visibles para autenticados" on public.pets
for select to authenticated using (true);

create policy "Duenios gestionan sus mascotas" on public.pets
for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "Vacunas visibles para autenticados" on public.vaccines
for select to authenticated using (true);

create policy "Duenios gestionan vacunas" on public.vaccines
for all to authenticated
using (exists (select 1 from public.pets p where p.id = pet_id and p.owner_id = auth.uid()))
with check (exists (select 1 from public.pets p where p.id = pet_id and p.owner_id = auth.uid()));

create policy "Publicaciones visibles por estado y autor" on public.posts
for select to authenticated
using (
  status = 'active'
  or author_id = auth.uid()
  or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true)
);

create policy "Usuarios crean publicaciones pendientes" on public.posts
for insert to authenticated
with check (author_id = auth.uid() and status = 'pending_approval');

create policy "Autores actualizan publicaciones no aprobadas o cerradas" on public.posts
for update to authenticated
using (author_id = auth.uid() and status in ('pending_approval', 'observed', 'active'))
with check (author_id = auth.uid() and status in ('pending_approval', 'observed', 'resolved', 'closed', 'deleted'));

create policy "Administradores moderan publicaciones" on public.posts
for update to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true))
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

create policy "Reportes de perdida visibles" on public.lost_reports
for select to authenticated using (true);

create policy "Autores gestionan reportes de perdida" on public.lost_reports
for all to authenticated
using (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid()))
with check (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid()));

create policy "Adopciones relacionadas visibles" on public.adoptions
for select to authenticated using (auth.uid() in (applicant_id, shelter_id));

create policy "Usuarios solicitan adopcion" on public.adoptions
for insert to authenticated with check (auth.uid() = applicant_id);

create policy "Autores gestionan adopciones" on public.adoptions
for update to authenticated using (auth.uid() = shelter_id) with check (auth.uid() = shelter_id);

create policy "Patrocinios visibles para autor y donante" on public.sponsorships
for select to authenticated
using (
  auth.uid() = sponsor_id
  or exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid())
);

create policy "Usuarios crean patrocinios pendientes en rescatados activos" on public.sponsorships
for insert to authenticated
with check (
  auth.uid() = sponsor_id
  and payment_status = 'pending'
  and amount >= 1
  and exists (
    select 1 from public.posts p
    where p.id = post_id and p.type = 'rescued' and p.status = 'active' and p.author_id <> auth.uid()
  )
);

create policy "Avistamientos visibles en posts activos o propios" on public.sightings
for select to authenticated
using (
  exists (
    select 1 from public.posts p
    where p.id = post_id and (p.status = 'active' or p.author_id = auth.uid())
  )
);

create policy "Usuarios reportan avistamientos en perdidos activos" on public.sightings
for insert to authenticated
with check (
  auth.uid() = reporter_id
  and exists (
    select 1 from public.posts p
    where p.id = post_id and p.type = 'lost' and p.status = 'active' and p.author_id <> auth.uid()
  )
);

create policy "Calificaciones visibles" on public.ratings
for select to authenticated using (true);

create policy "Usuarios califican a otros" on public.ratings
for insert to authenticated with check (auth.uid() = reviewer_id and reviewer_id <> target_id);

create policy "Usuarios ven sus notificaciones" on public.notifications
for select to authenticated using (auth.uid() = recipient_id);

create policy "Usuarios actualizan sus notificaciones" on public.notifications
for update to authenticated using (auth.uid() = recipient_id) with check (auth.uid() = recipient_id);

create policy "Reportes de duenio visibles para autor y reportante" on public.owner_found_reports
for select to authenticated
using (
  auth.uid() = reporter_id
  or exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid())
);

create policy "Usuarios reportan duenio en rescatados activos" on public.owner_found_reports
for insert to authenticated
with check (
  auth.uid() = reporter_id
  and exists (
    select 1 from public.posts p
    where p.id = post_id and p.type = 'rescued' and p.status = 'active' and p.author_id <> auth.uid()
  )
);

-- 8. Storage.
insert into storage.buckets (id, name, public)
values
  ('fotos-mascotas', 'fotos-mascotas', true),
  ('fotos-publicaciones', 'fotos-publicaciones', true),
  ('fotos-avistamientos', 'fotos-avistamientos', true),
  ('avatares', 'avatares', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists "Fotos publicas visibles" on storage.objects;
create policy "Fotos publicas visibles" on storage.objects
for select to public using (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);

drop policy if exists "Usuarios autenticados suben fotos" on storage.objects;
create policy "Usuarios autenticados suben fotos" on storage.objects
for insert to authenticated with check (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);

drop policy if exists "Usuarios autenticados actualizan fotos" on storage.objects;
create policy "Usuarios autenticados actualizan fotos" on storage.objects
for update to authenticated using (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
) with check (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);

drop policy if exists "Usuarios autenticados eliminan fotos" on storage.objects;
create policy "Usuarios autenticados eliminan fotos" on storage.objects
for delete to authenticated using (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);

commit;
