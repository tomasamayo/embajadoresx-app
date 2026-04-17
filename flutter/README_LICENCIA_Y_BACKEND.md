# Licenciamiento + Backend + API (Guía práctica)

Este documento explica una forma clara y segura de construir un sistema en la nube (backend + base de datos + API) que se conecte a una app (como esta Flutter) usando una **llave/licencia**.

La idea es que puedas:
- Tener tu propio sistema (base de datos + panel/admin) en tu servidor.
- Generar licencias para distintos clientes/instancias.
- Validar esas licencias desde la app.
- Controlar qué datos puede consumir cada cliente desde la API.

> Nota: Aquí hablo de “licencia” como un identificador seguro (tipo UUID) que habilita una instalación/cliente. No es DRM. El control real se hace en el backend.

---

## 1) Arquitectura recomendada

**Componentes**
- **Backend/API** (tu servidor): expone endpoints para login, productos, materiales, etc.
- **Base de datos**: guarda usuarios, licencias, permisos, productos, marketing media, etc.
- **Panel Admin** (opcional pero recomendado): para crear licencias y gestionar clientes.
- **App Flutter**: lee `base_url` + `license_key` desde `assets/config.json`, valida, y consume la API.

**Flujo general**
1. Admin crea una licencia para un cliente.
2. Se entrega al cliente:
   - `base_url` (dominio)
   - `license_key` (llave)
3. La app inicia y valida licencia con el backend.
4. Si es válida, permite login y consumo de endpoints.
5. Cada request del usuario usa token (`Authorization`) + (opcional) licencia para reforzar control.

---

## 2) Modelo de datos (tablas mínimas)

### Tabla `licenses`
Campos sugeridos:
- `id` (PK)
- `license_key` (UUID, único)
- `client_name` (texto)
- `status` (activo/inactivo/suspendido)
- `expires_at` (fecha, opcional)
- `allowed_domains` (lista o JSON, opcional)
- `max_users` / `max_devices` (opcional)
- `created_at`, `updated_at`

### Tabla `license_devices` (recomendado)
Sirve para limitar instalaciones por dispositivo.
- `id` (PK)
- `license_id` (FK)
- `device_id` (hash del dispositivo; en móvil puede ser un ID generado y guardado localmente)
- `platform` (android/ios/web)
- `created_at`, `last_seen_at`

### Tabla `users`
- `id`, `email`, `password_hash`, `status`, `created_at`, etc.
- `license_id` (FK) si cada usuario pertenece a un cliente/licencia

### Tablas de negocio (ejemplos)
- `products` (o tu tabla de productos real)
- `product_marketing_media` (como tu caso: `product_id`, `path`, `type`, `status`, etc.)

---

## 3) Cómo “crear” una licencia

### Opción A (rápida): crear licencia desde SQL
1. Genera un UUID (o clave segura aleatoria).
2. Inserta en `licenses`.

Ejemplo conceptual:
- `license_key = 9bebec0a-a12f-48c2-9f60-44fde30961e7`
- `status = active`

### Opción B (recomendada): panel/admin
Un panel donde puedas:
- Crear nueva licencia.
- Activar/desactivar/suspender.
- Definir fecha de expiración.
- Ver dispositivos conectados.
- Rotar la llave (revocar y emitir una nueva).

---

## 4) Endpoints mínimos del backend

### 4.1 Validación de licencia
`POST /user/license_validate`

Body:
- `license_key`

Response (ejemplo):
```json
{
  "status": true,
  "message": "License valid",
  "data": {
    "client_name": "Cliente X",
    "expires_at": "2026-12-31"
  }
}
```

Reglas recomendadas:
- Si `status` de licencia no es “active” → `status: false`
- Si expiró → `status: false`
- (Opcional) si `allowed_domains` no incluye el host → `status: false`

### 4.2 Registro/Handshake de dispositivo (opcional)
`POST /license/register_device`

Body:
- `license_key`
- `device_id`
- `platform`

Esto te permite limitar por número de dispositivos por licencia.

### 4.3 Login de usuario
`POST /user/login`

Body:
- email
- password
- (opcional) license_key

Response:
- `token` (JWT o token propio)

### 4.4 Endpoints de negocio
Ejemplos:
- `POST /User/my_affiliate_links` (requiere token)
- `GET /api/get_marketing_materials/{product_id}` (requiere token o licencia según tu política)

---

## 5) Seguridad (lo importante)

### No confíes solo en la app
La app se puede descompilar. La licencia NO debe ser tu única protección.

### Protege el backend
Recomendado:
- HTTPS obligatorio
- Tokens con expiración y refresh (si aplica)
- Rate limiting (anti abuso)
- Logs de intentos fallidos
- Bloqueo por IP si detectas ataques

### Licencia + token (lo más robusto)
Un patrón fuerte:
- Licencia valida que el “cliente/instancia” puede usar la plataforma.
- Token valida que el “usuario” tiene sesión y permisos.

---

## 6) Cómo lo usa la app Flutter (en este proyecto)

### Configuración
La app lee:
- `assets/config.json`

Con:
```json
{
  "base_url": "https://tu-dominio.com/",
  "license_key": "TU-LICENCIA"
}
```

En el código:
- Se carga en `AppConfig.load()`.
- La API usa esos valores para construir URLs.

### Validación
Existe un método para validar licencia:
- `ApiService.validateLicense()`

---

## 7) Si quieres tener “tu propio sistema” desde cero

Una ruta práctica (sin casarte con una tecnología):
1. Define BD (MySQL/PostgreSQL) con tablas: `licenses`, `users`, tus tablas de negocio.
2. Crea API (Laravel, Node/Nest, Django, .NET, etc.).
3. Implementa endpoints mínimos:
   - `license_validate`
   - `login`
   - endpoints de negocio
4. Implementa tokens (JWT recomendado).
5. Implementa panel admin para licencias (opcional pero ideal).
6. En la app:
   - apuntas `base_url` a ese servidor
   - pones `license_key` de ese cliente
   - consumes endpoints.

---

## 8) Reglas simples para que “no se rompa” la integración

- Mantén respuestas consistentes: siempre `status`/`message`/`data`.
- IDs coherentes: si un endpoint pide `product_id` numérico, asegúrate de enviar numérico en toda la cadena.
- Versiona la API si vas a crecer (ej: `/api/v1/...`).
- Documenta endpoints (Postman, Swagger/OpenAPI).

