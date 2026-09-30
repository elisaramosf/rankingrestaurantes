# Ranking Restaurantes

Aplicación web desarrollada con Ruby on Rails para el Trabajo Práctico N.º 1 de Programación IV (UTN FRLP).

Permite administrar restaurantes y categorías desde un back-office protegido y expone una API JSON para que un front-end público consulte los restaurantes, se registre e inicie sesión.

## Tipos de usuario

| Usuario | Qué hace | Cómo accede |
|---|---|---|
| Administrador | Gestiona categorías y restaurantes | Back-office en `/admin` (sesión con cookie) |
| Usuario final | Se registra, inicia sesión y consulta datos | API en `/api/v1` (token) |

Ambos son el mismo modelo (`User`), diferenciados por el campo `role` (`user`, `owner`, `admin`). Solo el rol `admin` puede entrar al back-office.

## Tecnologías

- Ruby 4.0.6 (ver `.ruby-version`) y Ruby on Rails 8.1
- Base de datos: PostgreSQL
- Autenticación del back-office: generador de autenticación integrado de Rails
- Autenticación de la API: token por sesión (`Authorization: Bearer <token>`)
- Active Storage (foto de cada restaurante) y Action Mailer (mail de bienvenida)
- Tests con Minitest, análisis de estilo con Rubocop y de seguridad con Brakeman

## Instalación y ejecución

1. Clonar el repositorio y entrar a la carpeta:

   ```
   git clone <URL_DEL_REPOSITORIO>
   cd rankingrestaurantes
   ```

2. Instalar las dependencias:

   ```
   bundle install
   ```

3. Preparar la base de datos (ver la sección siguiente).

4. Levantar el servidor:

   ```
   bin/rails server
   ```

5. Abrir `http://localhost:3000`. La raíz redirige al back-office.

## Base de datos

Crear la base, correr las migraciones y cargar los datos de ejemplo:

```
bin/rails db:create db:migrate db:seed
```

`db:seed` crea un usuario administrador, un usuario común, algunas categorías y restaurantes de ejemplo. Se puede ejecutar más de una vez sin duplicar datos.

## Acceso al back-office

- URL de ingreso: `http://localhost:3000/session/new`
- Panel: `http://localhost:3000/admin`

| Rol | Email | Contraseña |
|---|---|---|
| Administrador | `admin@example.com` | `admin1234` |
| Usuario común | `usuario@example.com` | `usuario1234` |

El usuario común puede iniciar sesión pero, al intentar entrar a `/admin`, es redirigido al login con un aviso de falta de permisos.

Desde el panel, el administrador puede crear, editar y eliminar **categorías** y **restaurantes** (incluida la foto del restaurante).

## API

Base: `/api/v1`. Todas las respuestas son JSON. Los endpoints protegidos requieren el header:

```
Authorization: Bearer <token>
```

| Método | Ruta | Token | Descripción |
|---|---|---|---|
| POST | `/api/v1/users` | No | Registra un usuario (`name`, `email`, `password`) y le envía un mail de bienvenida. Responde 201, o 422 con los errores. |
| POST | `/api/v1/login` | No | Recibe `email` y `password`. Responde 201 con el `token` y los datos del usuario, o 401 si las credenciales son inválidas. |
| DELETE | `/api/v1/logout` | Sí | Invalida el token actual. Responde 204. |
| GET | `/api/v1/restaurants` | No | Lista los restaurantes (`id`, `name`, `address`, `category`, `photo_url`). |
| GET | `/api/v1/restaurants/:id` | No | Devuelve un restaurante. Responde 404 si no existe. |
| GET | `/api/v1/profile` | Sí | Devuelve los datos del usuario autenticado. Responde 401 si falta o es inválido el token. |

Ejemplo de uso:

```
# Registrarse
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Ana","email":"ana@example.com","password":"clave12345"}'

# Iniciar sesión y obtener el token
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ana@example.com","password":"clave12345"}'

# Consultar el perfil con el token
curl http://localhost:3000/api/v1/profile \
  -H "Authorization: Bearer <TOKEN>"

# Listar restaurantes (público)
curl http://localhost:3000/api/v1/restaurants
```

Códigos de error usados: `401 Unauthorized` (token ausente o inválido), `404 Not Found` (recurso inexistente) y `422 Unprocessable Entity` (datos inválidos al registrarse).

## Modelo de datos

- **User**: `name`, `email` (único), `password_digest`, `role` (`user`, `owner` o `admin`). Tiene muchas reseñas, favoritos y sesiones.
- **Session**: pertenece a un usuario y guarda un `token` único, además de la IP y el navegador. Se usa tanto para la sesión del back-office como para el token de la API.
- **Category**: `name` (obligatorio y único). Tiene muchos restaurantes; no se puede eliminar si tiene restaurantes asociados.
- **Restaurant**: `name` (obligatorio), `address`, pertenece a una categoría y tiene una foto adjunta (Active Storage). Tiene muchas reseñas y favoritos, que se eliminan junto con él.
- **Review**: reseña de un usuario sobre un restaurante.
- **Favorite**: restaurante marcado como favorito por un usuario.

Relaciones principales: una categoría tiene muchos restaurantes; un usuario tiene muchas reseñas y favoritos; un restaurante tiene muchas reseñas y favoritos.

## Mails

El mail de bienvenida se envía al registrarse por la API. En desarrollo no se envía por internet: se guarda como archivo en `tmp/mails/`.

## Tests y calidad de código

```
bin/rails test      # tests automatizados
bin/rubocop         # estilo de código
bin/brakeman        # análisis de seguridad
```

Brakeman no reporta advertencias.

## Notas

- La gema `json` está fijada en una versión menor a 3.0 en el `Gemfile`, porque la versión 3.x es incompatible con Rails 8.1.3.1 (falla al leer cookies).
- El campo `role` no se acepta en el registro por la API, para que nadie pueda registrarse como administrador.