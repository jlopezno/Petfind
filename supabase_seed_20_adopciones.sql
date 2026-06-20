-- Datos de prueba: 20 publicaciones pendientes de aprobacion de adopcion.
-- Ejecutar en el SQL Editor despues de tener al menos un usuario registrado.

do $$
begin
  if not exists (select 1 from public.profiles) then
    raise exception 'Debes crear al menos un usuario antes de insertar publicaciones.';
  end if;
end;
$$;

with autor as (
  select id from public.profiles order by created_at asc limit 1
),
datos (
  titulo,
  cuerpo,
  pet_name,
  pet_species,
  pet_breed,
  pet_color_features,
  pet_size,
  pet_gender,
  pet_age_text,
  pet_description,
  contact_phone,
  address_hint,
  adoption_requirements,
  creado_hace_dias
) as (
  values
    ('Mamba busca una familia', 'Mamba es carinosa y espera un hogar responsable.', 'Mamba', 'dog', 'Mestizo', 'Negro con pecho blanco', 'medium', 'F', '2 anos', 'Sociable y esterilizada.', '987654321', 'Chimbote, Ancash', 'Entrevista previa y compromiso de esterilizacion.', 1),
    ('Bruno necesita un hogar', 'Bruno disfruta los paseos y se lleva bien con adultos.', 'Bruno', 'dog', 'Labrador mestizo', 'Cafe claro', 'large', 'M', '3 anos', 'Activo, noble y vacunado.', '986543210', 'Nuevo Chimbote, Ancash', 'Casa con espacio y familia responsable.', 2),
    ('Luna quiere conocerte', 'Luna es una gata tranquila que busca una familia paciente.', 'Luna', 'cat', 'Comun europeo', 'Blanco y gris', 'small', 'F', '1 ano', 'Usa arenero y esta esterilizada.', '985432109', 'Trujillo, La Libertad', 'Adopcion responsable y hogar seguro.', 3),
    ('Toby espera una segunda oportunidad', 'Toby fue rescatado y esta listo para un nuevo comienzo.', 'Toby', 'dog', 'Beagle mestizo', 'Tricolor', 'medium', 'M', '4 anos', 'Amigable con personas y otros perros.', '984321098', 'Lima, Lima', 'Formulario de adopcion y visita domiciliaria.', 4),
    ('Nala busca casa', 'Nala es curiosa, juguetona y muy companera.', 'Nala', 'cat', 'Siames mestizo', 'Crema y marron', 'small', 'F', '8 meses', 'Desparasitada y con controles veterinarios.', '983210987', 'Piura, Piura', 'Ventanas protegidas y compromiso de cuidado.', 5),
    ('Max necesita familia', 'Max tiene mucha energia y aprende rapido.', 'Max', 'dog', 'Pastor mestizo', 'Negro y canela', 'large', 'M', '1 ano', 'Ideal para una familia activa.', '982109876', 'Arequipa, Arequipa', 'Espacio adecuado y paseos diarios.', 6),
    ('Milo busca un hogar tranquilo', 'Milo es un gato dulce que ama las siestas.', 'Milo', 'cat', 'Comun europeo', 'Naranja', 'small', 'M', '2 anos', 'Esterilizado y sano.', '981098765', 'Cusco, Cusco', 'Hogar sin acceso a la calle.', 7),
    ('Kira quiere ser parte de tu familia', 'Kira es protectora y muy leal.', 'Kira', 'dog', 'Husky mestizo', 'Gris y blanco', 'large', 'F', '3 anos', 'Requiere paseos y actividad diaria.', '980987654', 'Huancayo, Junin', 'Experiencia con perros medianos o grandes.', 8),
    ('Simba esta listo para adoptar', 'Simba es un pequeno explorador lleno de carino.', 'Simba', 'cat', 'Comun europeo', 'Atigrado', 'small', 'M', '6 meses', 'Vacunado y acostumbrado al arenero.', '979876543', 'Chiclayo, Lambayeque', 'Compromiso de vacunacion anual.', 9),
    ('Canela busca compania', 'Canela es tranquila y disfruta los mimos.', 'Canela', 'dog', 'Cocker mestizo', 'Canela', 'medium', 'F', '5 anos', 'Ideal para un hogar calmado.', '978765432', 'Ica, Ica', 'Familia responsable y seguimiento inicial.', 10),
    ('Rocky quiere volver a confiar', 'Rocky necesita tiempo para adaptarse, pero es muy noble.', 'Rocky', 'dog', 'Pitbull mestizo', 'Blanco y negro', 'large', 'M', '2 anos', 'Rescatado y rehabilitado.', '977654321', 'Callao, Callao', 'Adoptante con experiencia y ambiente seguro.', 11),
    ('Mia busca una familia amorosa', 'Mia es una gata independiente y muy limpia.', 'Mia', 'cat', 'Angora mestizo', 'Blanco', 'small', 'F', '3 anos', 'Esterilizada y con vacunas al dia.', '976543210', 'Lima, Lima', 'Hogar responsable con ventanas seguras.', 12),
    ('Duke necesita paseos y carino', 'Duke es obediente y disfruta estar acompanado.', 'Duke', 'dog', 'Boxer mestizo', 'Marron y blanco', 'large', 'M', '4 anos', 'Sabe comandos basicos.', '975432109', 'Huaraz, Ancash', 'Disponibilidad para paseos diarios.', 13),
    ('Pelusa quiere una casa', 'Pelusa es una companera pequena y afectuosa.', 'Pelusa', 'cat', 'Comun europeo', 'Negro', 'small', 'F', '1 ano', 'Sociable y esterilizada.', '974321098', 'Cajamarca, Cajamarca', 'Adopcion con compromiso de cuidado.', 14),
    ('Zeus busca un hogar activo', 'Zeus tiene energia y mucho amor para dar.', 'Zeus', 'dog', 'Golden retriever mestizo', 'Dorado', 'large', 'M', '2 anos', 'Jugueton y amigable.', '973210987', 'Tacna, Tacna', 'Familia activa con espacio suficiente.', 15),
    ('Olivia espera conocerte', 'Olivia es serena y se adapta con facilidad.', 'Olivia', 'cat', 'Persa mestizo', 'Gris', 'small', 'F', '2 anos', 'Tranquila y habituada a vivir en departamento.', '972109876', 'Lima, Lima', 'Hogar interior y seguimiento responsable.', 16),
    ('Thor necesita una oportunidad', 'Thor es un perro noble que fue rescatado.', 'Thor', 'dog', 'Rottweiler mestizo', 'Negro y canela', 'large', 'M', '3 anos', 'Cariñoso con quienes conoce.', '971098765', 'Puno, Puno', 'Experiencia previa con perros grandes.', 17),
    ('Cleo busca una familia paciente', 'Cleo es timida al inicio, luego muy carinosa.', 'Cleo', 'cat', 'Comun europeo', 'Blanco y negro', 'small', 'F', '10 meses', 'Esterilizada y desparasitada.', '970987654', 'Ayacucho, Ayacucho', 'Hogar tranquilo y responsable.', 18),
    ('Rex quiere jugar contigo', 'Rex es joven, sociable y aprende muy rapido.', 'Rex', 'dog', 'Criollo', 'Marron', 'medium', 'M', '1 ano', 'Vacunado y con mucha energia.', '969876543', 'Huanuco, Huanuco', 'Paseos diarios y compromiso a largo plazo.', 19),
    ('Lola necesita un hogar definitivo', 'Lola es dulce y se lleva bien con ninos.', 'Lola', 'dog', 'Poodle mestizo', 'Blanco', 'small', 'F', '4 anos', 'Companera ideal para una familia.', '968765432', 'Chimbote, Ancash', 'Entrevista y adopcion responsable.', 20)
)
insert into public.posts (
  author_id,
  type,
  status,
  title,
  body,
  pet_name,
  pet_species,
  pet_breed,
  pet_color_features,
  pet_size,
  pet_gender,
  pet_age_text,
  pet_description,
  contact_phone,
  address_hint,
  adoption_requirements,
  created_at,
  updated_at
)
select
  autor.id,
  'adoption'::public.post_type,
  'pending_approval'::public.post_status,
  datos.titulo,
  datos.cuerpo,
  datos.pet_name,
  datos.pet_species::public.pet_species,
  datos.pet_breed,
  datos.pet_color_features,
  datos.pet_size::public.pet_size,
  datos.pet_gender,
  datos.pet_age_text,
  datos.pet_description,
  datos.contact_phone,
  datos.address_hint,
  datos.adoption_requirements,
  now() - make_interval(days => datos.creado_hace_dias),
  now() - make_interval(days => datos.creado_hace_dias)
from autor
cross join datos;
