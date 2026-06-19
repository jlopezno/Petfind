-- Migracion PetFindr v2: nueva logica de publicaciones.
-- Ejecutar despues de supabase_schema.sql.
-- Objetivo:
-- - Reemplazar tipos antiguos: found/sponsor -> rescued.
-- - Agregar aprobacion de administrador.
-- - Permitir datos de mascota directamente en posts.
-- - Mantener donaciones como accion de publicaciones rescued.
-- - Agregar centro de notificaciones en app.

begin;

create extension if not exists postgis;
create extension if not exists pgcrypto;

-- 1. Administradores externos
-- Se mantiene user_role como owner/shelter y se agrega bandera admin para el panel externo.
alter table public.profiles
add column if not exists is_admin boolean not null default false;

-- Las policies que usan posts.type/status deben eliminarse antes de cambiar enums.
drop policy if exists "Publicaciones activas visibles" on public.posts;
drop policy if exists "Autores gestionan publicaciones" on public.posts;
drop policy if exists "Publicaciones visibles por estado y autor" on public.posts;
drop policy if exists "Usuarios crean publicaciones pendientes" on public.posts;
drop policy if exists "Autores actualizan publicaciones no aprobadas o cerradas" on public.posts;
drop policy if exists "Administradores moderan publicaciones" on public.posts;

-- 2. Migracion segura de enums de publicaciones
-- PostgreSQL no permite quitar valores de un enum facilmente. Por eso se crea un enum v2,
-- se transforma la columna y luego se renombra al nombre original.
do $$
begin
  if not exists (select 1 from pg_type where typname = 'post_type_v2') then
    create type public.post_type_v2 as enum ('lost', 'rescued', 'adoption');
  end if;
end $$;

alter table public.posts
alter column type drop default;

alter table public.posts
alter column type type public.post_type_v2
using (
  case type::text
    when 'lost' then 'lost'
    when 'found' then 'rescued'
    when 'sponsor' then 'rescued'
    when 'rescued' then 'rescued'
    when 'adoption' then 'adoption'
    else 'rescued'
  end
)::public.post_type_v2;

do $$
begin
  drop type if exists public.post_type_legacy;
  if exists (select 1 from pg_type where typname = 'post_type') then
    alter type public.post_type rename to post_type_legacy;
  end if;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  if exists (select 1 from pg_type where typname = 'post_type_v2') then
    alter type public.post_type_v2 rename to post_type;
  end if;
exception
  when duplicate_object then null;
end $$;

-- 3. Estados nuevos: todo post empieza pendiente de aprobacion.
do $$
begin
  if not exists (select 1 from pg_type where typname = 'post_status_v2') then
    create type public.post_status_v2 as enum (
      'pending_approval',
      'active',
      'observed',
      'rejected',
      'resolved',
      'closed',
      'deleted'
    );
  end if;
end $$;

alter table public.posts
alter column status drop default;

alter table public.posts
alter column status type public.post_status_v2
using (
  case status::text
    when 'active' then 'active'
    when 'resolved' then 'resolved'
    when 'closed' then 'closed'
    when 'deleted' then 'deleted'
    when 'pending_approval' then 'pending_approval'
    when 'observed' then 'observed'
    when 'rejected' then 'rejected'
    else 'pending_approval'
  end
)::public.post_status_v2;

do $$
begin
  drop type if exists public.post_status_legacy;
  if exists (select 1 from pg_type where typname = 'post_status') then
    alter type public.post_status rename to post_status_legacy;
  end if;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  if exists (select 1 from pg_type where typname = 'post_status_v2') then
    alter type public.post_status_v2 rename to post_status;
  end if;
exception
  when duplicate_object then null;
end $$;

alter table public.posts
alter column status set default 'pending_approval'::public.post_status;

-- 4. Datos de mascota dentro de la publicacion.
-- pet_id queda opcional para vincular una mascota registrada, pero el post puede vivir solo.
alter table public.posts
add column if not exists pet_name text,
add column if not exists pet_species public.pet_species,
add column if not exists pet_breed text,
add column if not exists pet_color_features text,
add column if not exists pet_size public.pet_size,
add column if not exists pet_gender char(1) check (pet_gender is null or pet_gender in ('M', 'F')),
add column if not exists pet_age_text text,
add column if not exists pet_description text,
add column if not exists contact_phone text;

-- 5. Campos especificos para rescatado.
alter table public.posts
add column if not exists severity text check (severity is null or severity in ('mild', 'moderate', 'urgent')),
add column if not exists sponsor_goal numeric(10, 2) check (sponsor_goal is null or sponsor_goal >= 0);

-- 6. Campos especificos para adopcion.
alter table public.posts
add column if not exists adoption_requirements text;

-- 7. Moderacion por administrador.
alter table public.posts
add column if not exists admin_note text,
add column if not exists reviewed_at timestamptz,
add column if not exists reviewed_by uuid references public.profiles(id) on delete set null;

create index if not exists idx_posts_status_type_created
on public.posts(status, type, created_at desc);

create index if not exists idx_posts_author_status
on public.posts(author_id, status, created_at desc);

-- 8. Reglas criticas por tipo.
-- Validaciones suaves: permiten datos incompletos en migraciones antiguas, pero protegen datos nuevos.
create or replace function public.validate_post_business_rules()
returns trigger
language plpgsql
as $$
begin
  if new.type = 'rescued' then
    if new.severity is null then
      raise exception 'Las publicaciones rescatadas requieren gravedad del caso';
    end if;
  end if;

  if new.type = 'adoption' then
    if new.pet_name is null or length(trim(new.pet_name)) = 0 then
      raise exception 'Las publicaciones de adopcion requieren nombre de mascota';
    end if;
  end if;

  if new.status in ('observed', 'rejected') and (new.admin_note is null or length(trim(new.admin_note)) = 0) then
    raise exception 'Las publicaciones observadas o rechazadas requieren nota del administrador';
  end if;

  return new;
end;
$$;

drop trigger if exists posts_validate_business_rules on public.posts;
create trigger posts_validate_business_rules
before insert or update on public.posts
for each row execute function public.validate_post_business_rules();

-- 9. Funciones de moderacion para panel externo.
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
  set
    status = 'active',
    admin_note = null,
    reviewed_at = now(),
    reviewed_by = auth.uid()
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
  set
    status = 'observed',
    admin_note = note,
    reviewed_at = now(),
    reviewed_by = auth.uid()
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
  set
    status = 'rejected',
    admin_note = note,
    reviewed_at = now(),
    reviewed_by = auth.uid()
  where id = post_id;
end;
$$;

-- 10. Cierre manual por autor.
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

-- 11. Avistamientos: solo perdido y activo.
create or replace function public.validate_sighting_business_rules()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1
    from public.posts p
    where p.id = new.post_id
      and p.type = 'lost'
      and p.status = 'active'
  ) then
    raise exception 'Solo se pueden reportar avistamientos en publicaciones perdidas activas';
  end if;

  return new;
end;
$$;

drop trigger if exists sightings_validate_business_rules on public.sightings;
create trigger sightings_validate_business_rules
before insert or update on public.sightings
for each row execute function public.validate_sighting_business_rules();

-- 12. Donaciones: solo rescatado y activo.
alter table public.sponsorships
drop constraint if exists sponsorships_amount_check;

alter table public.sponsorships
add constraint sponsorships_amount_min_check check (amount >= 1);

create or replace function public.validate_sponsorship_business_rules()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1
    from public.posts p
    where p.id = new.post_id
      and p.type = 'rescued'
      and p.status = 'active'
  ) then
    raise exception 'Solo se puede apoyar publicaciones rescatadas activas';
  end if;

  return new;
end;
$$;

drop trigger if exists sponsorships_validate_business_rules on public.sponsorships;
create trigger sponsorships_validate_business_rules
before insert or update on public.sponsorships
for each row execute function public.validate_sponsorship_business_rules();

create or replace view public.sponsorship_totals as
select
  post_id,
  coalesce(sum(amount) filter (where payment_status = 'completed'), 0)::numeric(10, 2) as total_completed,
  count(distinct sponsor_id) filter (where payment_status = 'completed') as sponsor_count,
  count(*) filter (where payment_status = 'completed') as payment_count
from public.sponsorships
group by post_id;

-- 13. Solicitudes de adopcion: cualquier autor puede recibir solicitudes.
-- shelter_id queda como author_id del post por compatibilidad con la tabla existente.
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

-- 14. Notificaciones en app.
do $$
begin
  if not exists (select 1 from pg_type where typname = 'notification_type') then
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
  end if;
end $$;

create table if not exists public.notifications (
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

create index if not exists idx_notifications_recipient_created
on public.notifications(recipient_id, created_at desc);

alter table public.notifications enable row level security;

drop policy if exists "Usuarios ven sus notificaciones" on public.notifications;
create policy "Usuarios ven sus notificaciones" on public.notifications
for select to authenticated using (auth.uid() = recipient_id);

drop policy if exists "Usuarios actualizan sus notificaciones" on public.notifications;
create policy "Usuarios actualizan sus notificaciones" on public.notifications
for update to authenticated using (auth.uid() = recipient_id) with check (auth.uid() = recipient_id);

-- 15. Reporte "encontre al duenio" para rescatado.
create table if not exists public.owner_found_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  message text,
  contact_phone text,
  created_at timestamptz not null default now()
);

create index if not exists idx_owner_found_reports_post_created
on public.owner_found_reports(post_id, created_at desc);

alter table public.owner_found_reports enable row level security;

drop policy if exists "Reportes de duenio visibles para autor y reportante" on public.owner_found_reports;
create policy "Reportes de duenio visibles para autor y reportante" on public.owner_found_reports
for select to authenticated
using (
  auth.uid() = reporter_id
  or exists (
    select 1 from public.posts p
    where p.id = post_id and p.author_id = auth.uid()
  )
);

drop policy if exists "Usuarios reportan duenio en rescatados activos" on public.owner_found_reports;
create policy "Usuarios reportan duenio en rescatados activos" on public.owner_found_reports
for insert to authenticated
with check (
  auth.uid() = reporter_id
  and exists (
    select 1 from public.posts p
    where p.id = post_id
      and p.type = 'rescued'
      and p.status = 'active'
      and p.author_id <> auth.uid()
  )
);

-- 16. RPC de mapa/feed: solo publicaciones activas.
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

-- 17. Politicas RLS actualizadas.
drop policy if exists "Publicaciones activas visibles" on public.posts;
drop policy if exists "Autores gestionan publicaciones" on public.posts;
drop policy if exists "Publicaciones visibles por estado y autor" on public.posts;
drop policy if exists "Usuarios crean publicaciones pendientes" on public.posts;
drop policy if exists "Autores actualizan publicaciones no aprobadas o cerradas" on public.posts;
drop policy if exists "Administradores moderan publicaciones" on public.posts;

create policy "Publicaciones visibles por estado y autor" on public.posts
for select to authenticated
using (
  status = 'active'
  or author_id = auth.uid()
  or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true)
);

create policy "Usuarios crean publicaciones pendientes" on public.posts
for insert to authenticated
with check (
  author_id = auth.uid()
  and status = 'pending_approval'
);

create policy "Autores actualizan publicaciones no aprobadas o cerradas" on public.posts
for update to authenticated
using (
  author_id = auth.uid()
  and status in ('pending_approval', 'observed', 'active')
)
with check (
  author_id = auth.uid()
  and status in ('pending_approval', 'observed', 'resolved', 'closed', 'deleted')
);

create policy "Administradores moderan publicaciones" on public.posts
for update to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true))
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

drop policy if exists "Avistamientos visibles" on public.sightings;
drop policy if exists "Usuarios reportan avistamientos" on public.sightings;
drop policy if exists "Avistamientos visibles en posts activos o propios" on public.sightings;
drop policy if exists "Usuarios reportan avistamientos en perdidos activos" on public.sightings;

create policy "Avistamientos visibles en posts activos o propios" on public.sightings
for select to authenticated
using (
  exists (
    select 1 from public.posts p
    where p.id = post_id
      and (p.status = 'active' or p.author_id = auth.uid())
  )
);

create policy "Usuarios reportan avistamientos en perdidos activos" on public.sightings
for insert to authenticated
with check (
  auth.uid() = reporter_id
  and exists (
    select 1 from public.posts p
    where p.id = post_id
      and p.type = 'lost'
      and p.status = 'active'
      and p.author_id <> auth.uid()
  )
);

drop policy if exists "Patrocinios propios visibles" on public.sponsorships;
drop policy if exists "Usuarios crean patrocinios" on public.sponsorships;
drop policy if exists "Patrocinios visibles para autor y donante" on public.sponsorships;
drop policy if exists "Usuarios crean patrocinios pendientes en rescatados activos" on public.sponsorships;

create policy "Patrocinios visibles para autor y donante" on public.sponsorships
for select to authenticated
using (
  auth.uid() = sponsor_id
  or exists (
    select 1 from public.posts p
    where p.id = post_id and p.author_id = auth.uid()
  )
);

create policy "Usuarios crean patrocinios pendientes en rescatados activos" on public.sponsorships
for insert to authenticated
with check (
  auth.uid() = sponsor_id
  and payment_status = 'pending'
  and amount >= 1
  and exists (
    select 1 from public.posts p
    where p.id = post_id
      and p.type = 'rescued'
      and p.status = 'active'
      and p.author_id <> auth.uid()
  )
);

commit;
