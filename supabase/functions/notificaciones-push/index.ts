import { createClient } from 'jsr:@supabase/supabase-js@2';
import { cert, getApps, initializeApp } from 'npm:firebase-admin/app';
import { getMessaging } from 'npm:firebase-admin/messaging';

type EventoPush =
  | 'post_created'
  | 'adoption_interest'
  | 'rescue_support_interest';

type Body = {
  event: EventoPush;
  post_id: string;
};

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const firebaseServiceAccount =
  Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ??
  (Deno.env.get('FIREBASE_SERVICE_ACCOUNT_BASE64')
    ? atob(Deno.env.get('FIREBASE_SERVICE_ACCOUNT_BASE64')!)
    : '');

function inicializarFirebase(): string | null {
  if (getApps().length) return null;
  if (!firebaseServiceAccount.trim()) {
    return 'Falta configurar FIREBASE_SERVICE_ACCOUNT en Supabase secrets';
  }
  try {
    initializeApp({
      credential: cert(JSON.parse(firebaseServiceAccount)),
    });
    return null;
  } catch (error) {
    return `FIREBASE_SERVICE_ACCOUNT invalido: ${error}`;
  }
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const jwt = authHeader.replace('Bearer ', '');
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
  if (userError || !userData.user) {
    return Response.json({ error: 'No autenticado' }, { status: 401 });
  }

  const body = await req.json() as Body;
  if (!body.event || !body.post_id) {
    return Response.json({ error: 'Payload incompleto' }, { status: 400 });
  }

  const firebaseError = inicializarFirebase();
  if (firebaseError) {
    return Response.json({ error: firebaseError }, { status: 500 });
  }

  const { data: post, error: postError } = await supabase
    .from('posts')
    .select('id,title,type,author_id')
    .eq('id', body.post_id)
    .single();

  if (postError || !post) {
    return Response.json({ error: 'Publicacion no encontrada' }, { status: 404 });
  }

  const actorId = userData.user.id;
  let recipientIds: string[] = [];
  let title = 'PetFindr';
  let message = '';

  if (body.event === 'post_created') {
    const { data: admins } = await supabase
      .from('profiles')
      .select('id')
      .eq('is_admin', true);
    recipientIds = (admins ?? []).map((admin) => admin.id);
    title = 'Nueva publicacion pendiente';
    message = post.title ?? 'Hay una publicacion pendiente de aprobar.';
  }

  if (body.event === 'adoption_interest') {
    if (post.type !== 'adoption') {
      return Response.json({ error: 'La publicacion no es de adopcion' }, { status: 400 });
    }
    if (post.author_id === actorId) {
      return Response.json({ ok: true, skipped: 'Autor propio' });
    }
    recipientIds = [post.author_id];
    title = 'Nuevo interesado en adoptar';
    message = `Alguien quiere adoptar: ${post.title}`;
  }

  if (body.event === 'rescue_support_interest') {
    if (post.type !== 'rescued') {
      return Response.json({ error: 'La publicacion no es de rescate' }, { status: 400 });
    }
    if (post.author_id === actorId) {
      return Response.json({ ok: true, skipped: 'Autor propio' });
    }
    recipientIds = [post.author_id];
    title = 'Nuevo apoyo para rescate';
    message = `Alguien quiere apoyar: ${post.title}`;
  }

  recipientIds = [...new Set(recipientIds)].filter((id) => id !== actorId);
  if (!recipientIds.length) {
    return Response.json({
      ok: true,
      sent: 0,
      reason: 'no_recipients',
      detail: 'No se encontraron destinatarios distintos al usuario que ejecuto la accion',
    });
  }

  const { data: tokens } = await supabase
    .from('fcm_tokens')
    .select('token')
    .in('user_id', recipientIds);

  const fcmTokens = [...new Set((tokens ?? []).map((item) => item.token))];
  if (!fcmTokens.length) {
    return Response.json({
      ok: true,
      sent: 0,
      reason: 'no_fcm_tokens',
      detail: 'El duenio existe, pero no tiene token FCM registrado en fcm_tokens',
      recipient_ids: recipientIds,
    });
  }

  const response = await getMessaging().sendEachForMulticast({
    tokens: fcmTokens,
    notification: {
      title,
      body: message,
    },
    data: {
      event: body.event,
      post_id: body.post_id,
    },
  });

  return Response.json({
    ok: true,
    sent: response.successCount,
    failed: response.failureCount,
    token_count: fcmTokens.length,
  });
});
