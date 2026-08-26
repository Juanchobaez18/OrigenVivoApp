# ===================================================
# OrigenVivo - Seed de Usuarios de Prueba en Supabase
# ===================================================
# INSTRUCCIONES:
# 1. Reemplaza SERVICE_ROLE_KEY con tu clave de servicio de Supabase
#    (Supabase Dashboard → Settings → API → service_role key)
# 2. Ejecuta este script con: .\seed_users.ps1
# ===================================================

$SUPABASE_URL  = "https://wbecrnnlxhblleuucahq.supabase.co"
$SERVICE_KEY   = "REEMPLAZA_CON_TU_SERVICE_ROLE_KEY"   # <-- Cambia esto

$headers = @{
    "apikey"        = $SERVICE_KEY
    "Authorization" = "Bearer $SERVICE_KEY"
    "Content-Type"  = "application/json"
}

# ---- Usuarios a crear ----
$usuarios = @(
    @{ email = "admin@origenvivo.com";     password = "Admin1234!";     rol = "admin";      nombre = "Administrador" }
    @{ email = "caja@origenvivo.com";      password = "Caja1234!";      rol = "caja";       nombre = "Cajero Origen" }
    @{ email = "produccion@origenvivo.com";password = "Prod1234!";      rol = "produccion"; nombre = "Taller Sublimacion" }
    @{ email = "cliente@origenvivo.com";   password = "Cliente1234!";   rol = "cliente";    nombre = "Cliente Demo" }
)

foreach ($u in $usuarios) {
    Write-Host "Creando usuario: $($u.email) ..."

    $body = @{
        email         = $u.email
        password      = $u.password
        email_confirm = $true
    } | ConvertTo-Json

    try {
        $resp = Invoke-RestMethod `
            -Uri "$SUPABASE_URL/auth/v1/admin/users" `
            -Method POST `
            -Headers $headers `
            -Body $body

        $userId = $resp.id
        Write-Host "  Auth OK -> user_id: $userId"

        $perfil = @{
            user_id = $userId
            nombre  = $u.nombre
            rol     = $u.rol
            correo  = $u.email
        } | ConvertTo-Json

        $perfHeaders = $headers.Clone()
        $perfHeaders["Prefer"] = "return=minimal"

        Invoke-RestMethod `
            -Uri "$SUPABASE_URL/rest/v1/perfiles" `
            -Method POST `
            -Headers $perfHeaders `
            -Body $perfil | Out-Null

        Write-Host "  Perfil OK -> rol: $($u.rol)"

    } catch {
        Write-Warning "  ERROR con $($u.email): $_"
    }
}

Write-Host ""
Write-Host "Credenciales de prueba:"
Write-Host "  admin@origenvivo.com      / Admin1234!"
Write-Host "  caja@origenvivo.com       / Caja1234!"
Write-Host "  produccion@origenvivo.com / Prod1234!"
Write-Host "  cliente@origenvivo.com    / Cliente1234!"
