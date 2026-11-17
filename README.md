# e-Santri

Platform pembelajaran santri Pondok Pesantren Sunanulhuda.

- **Frontend:** satu halaman statis (`index.html`) dengan media di folder `assets/`.
- **Database & login:** Supabase (tabel `profiles`, Supabase Auth, Edge Function `login`).
- **Hosting:** Vercel (situs statis, tanpa build).

## Login
- Daftar: nama, email, instansi, kata sandi.
- Masuk: nama dan kata sandi (Edge Function `login` mencari email dari nama, lalu masuk lewat Supabase Auth).
- Peran `developer` hanya bisa diubah langsung di database oleh pemilik proyek.

## Struktur
```
index.html
assets/                         foto & video
supabase/schema.sql             skema database
supabase/functions/login/       Edge Function login berdasarkan nama
```

Kunci yang ada di `index.html` adalah *publishable key* Supabase yang memang aman dipublikasikan; keamanan data dijaga oleh Row Level Security.
