import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
const GAGAL = "Nama atau kata sandi salah.";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Metode tidak didukung." }, 405);
  try {
    const { nama, password } = await req.json();
    if (typeof nama !== "string" || typeof password !== "string" || !nama.trim() || !password) {
      return json({ error: "Isi nama dan kata sandi." }, 400);
    }
    const url = Deno.env.get("SUPABASE_URL")!;
    const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: email } = await admin.rpc("email_by_nama", { p_nama: nama });
    if (!email) return json({ error: GAGAL }, 401);
    const anon = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!);
    const { data, error } = await anon.auth.signInWithPassword({ email, password });
    if (error || !data.session) return json({ error: GAGAL }, 401);
    return json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token });
  } catch (_e) {
    return json({ error: "Terjadi kesalahan. Coba lagi." }, 500);
  }
});
