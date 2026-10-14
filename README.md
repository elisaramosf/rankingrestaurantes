
# Ranking Restaurantes

Aplicación web desarrollada con Ruby on Rails para el Trabajo Práctico N.º 1 de Programación IV (UTN FRLP).

Permite administrar restaurantes y categorías desde un back-office protegido y expone una API REST en formato JSON para que los usuarios puedan registrarse, iniciar sesión, consultar restaurantes, publicar reseñas con puntuaciones de 1 a 5 estrellas y guardar restaurantes como favoritos.

## Tipos de usuario

| Usuario | Qué hace | Cómo accede |
|---|---|---|
| Administrador | Gestiona categorías y restaurantes | Back-office en `/admin` (sesión con cookie) |
| Usuario final | Se registra, inicia sesión, consulta restaurantes, publica reseñas y guarda favoritos | API en `/api/v1` (token) |

Ambos tipos de usuario están representados por el mismo modelo (`User`), diferenciados por el campo `role` (`user`, `owner`, `admin`).

Solo el rol `admin` puede acceder al back-office.

## Tecnologías

- Ruby 4.0.6 (ver `.ruby-version`) y Ruby on Rails 8.1.
- Base de datos: PostgreSQL.
- Autenticación del back-office: sistema integrado de Rails.
- Autenticación de la API: token por sesión (`Authorization: Bearer <token>`).
- Active Storage: fotografías de los restaurantes.
- Action Mailer: correo de bienvenida al registrarse.
- Tests automatizados con Minitest.
- Análisis de calidad de código con RuboCop.
- Análisis de seguridad con Brakeman.
- Control de versiones con Git y GitHub.

## Instalación y ejecución

### 1. Clonar el repositorio

```bash
git clone https://github.com/elisaramosf/rankingrestaurantes.git
cd rankingrestaurantes
```

### 2. Instalar las dependencias

```bash
bundle install
```

Es necesario contar con Ruby y PostgreSQL instalados.

### 3. Preparar la base de datos

```bash
bin/rails db:create db:migrate db:seed
```

### 4. Iniciar el servidor

```bash
bin/rails server
```

### 5. Abrir la aplicación

Ingresar desde el navegador a:

http://localhost:3000

La ruta principal redirige al panel de administración.

## Base de datos

La aplicación utiliza PostgreSQL como sistema de gestión de base de datos.

Para crear la base, ejecutar las migraciones y cargar datos de ejemplo:

```bash
bin/rails db:create db:migrate db:seed
```

El archivo `db/seeds.rb` permite cargar:

- Un usuario administrador.
- Un usuario común.
- Categorías de restaurantes.
- Restaurantes de ejemplo.

Los datos de ejemplo pueden utilizarse para probar las funcionalidades.

## Acceso al back-office

URL de inicio de sesión:

http://localhost:3000/session/new

Panel de administración:

http://localhost:3000/admin

### Usuarios de prueba

| Rol | Email | Contraseña |
|---|---|---|
| Administrador | `admin@example.com` | `admin1234` |
| Usuario común | `usuario@example.com` | `usuario1234` |

Estas credenciales corresponden al entorno de desarrollo y no deben utilizarse en producción.

El usuario común puede iniciar sesión, pero no tiene permisos para acceder a las funcionalidades administrativas.

### Funcionalidades del administrador

Desde el back-office, el administrador puede:

- Listar categorías.
- Crear, editar y eliminar categorías.
- Listar restaurantes.
- Crear nuevos restaurantes.
- Editar restaurantes existentes.
- Eliminar restaurantes.
- Adjuntar fotografías mediante Active Storage.

El acceso está protegido mediante autenticación y autorización.

## API REST

La aplicación expone una API JSON organizada bajo el namespace:

`/api/v1`

La API está separada de los controladores del back-office.

### Autenticación

Los endpoints protegidos requieren un token de sesión.

El token se obtiene mediante:

`POST /api/v1/login`

Y debe enviarse en las solicitudes posteriores utilizando el encabezado:

```text
Authorization: Bearer <token>
```

### Endpoints de usuarios y sesiones

| Método | Ruta | Token | Descripción |
|---|---|---|---|
| POST | `/api/v1/users` | No | Registrar un usuario |
| POST | `/api/v1/login` | No | Iniciar sesión y obtener un token |
| DELETE | `/api/v1/logout` | Sí | Cerrar sesión e invalidar el token |
| GET | `/api/v1/profile` | Sí | Consultar el perfil del usuario autenticado |

El registro recibe `name`, `email` y `password`.

El campo `role` no puede establecerse mediante el registro público, evitando que un usuario pueda registrarse como administrador.

### Endpoints de restaurantes

| Método | Ruta | Token | Descripción |
|---|---|---|---|
| GET | `/api/v1/restaurants` | No | Listar restaurantes |
| GET | `/api/v1/restaurants/:id` | No | Consultar un restaurante específico |

Las respuestas incluyen información del restaurante, su categoría y la URL de la fotografía cuando está disponible.

## Reviews (Reseñas)

La API permite que los usuarios publiquen reseñas sobre los restaurantes.

Cada reseña contiene:

- Usuario que realizó la reseña.
- Restaurante al que pertenece.
- Puntuación (`rating`) entre 1 y 5.
- Comentario (`comment`).
- Fecha de creación.

Los usuarios solamente pueden editar y eliminar sus propias reseñas.

### Endpoints de Reviews

| Método | Endpoint | Token | Descripción |
|---|---|---|---|
| GET | `/api/v1/restaurants/:restaurant_id/reviews` | No | Listar reseñas de un restaurante |
| POST | `/api/v1/restaurants/:restaurant_id/reviews` | Sí | Crear una reseña |
| PATCH | `/api/v1/reviews/:id` | Sí | Editar una reseña propia |
| DELETE | `/api/v1/reviews/:id` | Sí | Eliminar una reseña propia |

### Ejemplo: crear una reseña

**Método:** POST

**URL:**

```text
http://localhost:3000/api/v1/restaurants/1/reviews
```

**Headers:**

```text
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**

```json
{
  "review": {
    "rating": 5,
    "comment": "Excelente comida y muy buena atención"
  }
}
```

Si la reseña se crea correctamente, la API responde con el código HTTP `201 Created`.

### Validaciones

- La puntuación debe estar entre 1 y 5.
- El comentario es obligatorio.
- Se requiere autenticación para publicar.
- Solo el autor puede editar o eliminar su reseña.

## Favorites (Favoritos)

Los usuarios autenticados pueden guardar restaurantes en su lista personal de favoritos.

Cada favorito relaciona un usuario con un restaurante.

El sistema impide guardar dos veces el mismo restaurante para un mismo usuario mediante una validación del modelo y un índice único en PostgreSQL.

### Endpoints de Favorites

| Método | Endpoint | Token | Descripción |
|---|---|---|---|
| GET | `/api/v1/favorites` | Sí | Listar los restaurantes favoritos del usuario |
| POST | `/api/v1/favorites` | Sí | Agregar un restaurante a favoritos |
| DELETE | `/api/v1/favorites/:restaurant_id` | Sí | Eliminar un restaurante de favoritos |

### Ejemplo: agregar un favorito

**Método:** POST

**URL:**

```text
http://localhost:3000/api/v1/favorites
```

**Headers:**

```text
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**

```json
{
  "restaurant_id": 1
}
```

Si la operación se realiza correctamente, la API responde con `201 Created`.

### Ejemplo: consultar favoritos

**Método:** GET

```text
http://localhost:3000/api/v1/favorites
```

La respuesta devuelve los restaurantes guardados por el usuario autenticado.

### Ejemplo: eliminar un favorito

**Método:** DELETE

```text
http://localhost:3000/api/v1/favorites/1
```

El número `1` representa el ID del restaurante.

Si se elimina correctamente, la API responde con `204 No Content`.

## Modelo de datos

La aplicación utiliza los siguientes modelos principales:

### User

Representa a los usuarios del sistema.

Atributos principales:

- `name`
- `email`
- `password_digest`
- `role`

Relaciones:

- Tiene muchas sesiones.
- Tiene muchas reseñas.
- Tiene muchos favoritos.

### Session

Representa las sesiones de autenticación.

- Pertenece a un usuario.
- Almacena un token de sesión.
- Permite autenticar solicitudes de la API.

### Category

Representa las categorías de restaurantes.

- Tiene un nombre obligatorio y único.
- Tiene muchos restaurantes.
- No puede eliminarse si tiene restaurantes asociados.

### Restaurant

Representa un restaurante.

- Tiene nombre y dirección.
- Pertenece a una categoría.
- Tiene una fotografía mediante Active Storage.
- Tiene muchas reseñas.
- Tiene muchos favoritos.

### Review

Representa una reseña publicada por un usuario.

- Pertenece a un usuario.
- Pertenece a un restaurante.
- Contiene una puntuación y un comentario.
- Valida que la puntuación esté entre 1 y 5.

### Favorite

Representa un restaurante guardado como favorito.

- Pertenece a un usuario.
- Pertenece a un restaurante.
- No permite duplicar la relación entre un mismo usuario y restaurante.

## Active Storage

Se utiliza Active Storage para asociar fotografías a los restaurantes.

El administrador puede adjuntar imágenes al crear o editar un restaurante desde el back-office.

## Action Mailer

Al registrarse mediante la API, el usuario recibe un correo de bienvenida.

En el entorno de desarrollo, los correos se almacenan en:

`tmp/mails/`

Esto permite comprobar el funcionamiento sin necesidad de utilizar un servicio de correo externo.

## Testing automatizado

Se utiliza Minitest para ejecutar pruebas automatizadas.

Las pruebas incluyen:

- Validaciones de modelos.
- Operaciones de la API.
- Autenticación de usuarios.
- Gestión de restaurantes.
- Creación, consulta, edición y eliminación de reseñas.
- Creación, consulta y eliminación de favoritos.
- Prevención de favoritos duplicados.
- Restricciones de autenticación.

Para ejecutar los tests:

```bash
bin/rails test
```

Resultado de la última ejecución:

```text
37 runs, 78 assertions, 0 failures, 0 errors, 0 skips
```

Además, los endpoints fueron probados manualmente mediante Postman.

## Calidad de código

El proyecto utiliza RuboCop para comprobar el estilo y la calidad del código Ruby.

Ejecutar:

```bash
bin/rubocop
```

Resultado de la última verificación:

```text
73 files inspected, no offenses detected
```

## Seguridad

Se utiliza Brakeman para realizar un análisis estático de seguridad de la aplicación Ruby on Rails.

Ejecutar:

```bash
bin/brakeman --no-pager
```

Resultado de la última verificación:

```text
Errors: 0
Security Warnings: 0
```

El proyecto incorpora autenticación para los endpoints protegidos y restricciones de acceso según el tipo de usuario.

## Códigos de respuesta HTTP

La API utiliza los siguientes códigos de respuesta:

| Código | Significado |
|---|---|
| 200 OK | Consulta o modificación exitosa |
| 201 Created | Recurso creado correctamente |
| 204 No Content | Recurso eliminado correctamente |
| 401 Unauthorized | Falta autenticación o el token es inválido |
| 404 Not Found | El recurso solicitado no existe o no es accesible |
| 422 Unprocessable Entity | Los datos enviados no cumplen las validaciones |

## Notas técnicas

- La gema `json` está fijada en una versión menor a 3.0 en el `Gemfile` por una incompatibilidad observada con Rails 8.1.3.1.
- Los usuarios no pueden asignarse el rol de administrador durante el registro público.
- La autenticación del back-office y la autenticación de la API se encuentran separadas.
- Se utiliza un índice único para mantener la consistencia de los favoritos en PostgreSQL.

## Próxima etapa

Este proyecto corresponde al Trabajo Práctico N.º 1 de Programación IV, enfocado en el desarrollo del backend.

La interfaz pública para usuarios finales se desarrollará en el Trabajo Práctico N.º 2, consumiendo los endpoints de esta API.

Esto permitirá implementar visualmente funcionalidades como consultar restaurantes, publicar reseñas con estrellas y administrar favoritos.
