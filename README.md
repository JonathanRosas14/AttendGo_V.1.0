# AttendGo - Documentacion del Proyecto

> Sistema de control de asistencia estudiantil con verificacion QR, biometria y deteccion de suplantacion.

---

## Tabla de Contenidos

1. [Vision General](#1-vision-general)
2. [Stack Tecnologico](#2-stack-tecnologico)
3. [Arquitectura](#3-arquitectura)
4. [Estructura del Proyecto](#4-estructura-del-proyecto)
5. [Capa de Dominio - Entidades y DTOs](#5-capa-de-dominio---entidades-y-dtos)
6. [Configuracion del Entorno](#6-configuracion-del-entorno)
7. [Docker](#7-docker)
8. [Base de Datos](#8-base-de-datos)
9. [API Endpoints](#9-api-endpoints)
10. [Flujo de Autenticacion](#10-flujo-de-autenticacion)
11. [Roles y Permisos](#11-roles-y-permisos)
12. [Sistema de Asistencia](#12-sistema-de-asistencia)
13. [Git Flow y Contribucion](#13-git-flow-y-contribucion)
14. [Scripts Disponibles](#14-scripts-disponibles)
15. [Problemas Conocidos y Soluciones](#15-problemas-conocidos-y-soluciones)

---

## 1. Vision General

AttendGo es una plataforma web para el control de asistencia en instituciones educativas. Permite a los profesores abrir sesiones de asistencia y a los estudiantes marcar su asistencia mediante:

- **QR dinamico** (metodo basico)
- **QR + Biometria** (verificacion de huella digital)
- **Manual** (registro directo por el profesor)

El sistema detecta automaticamente posibles suplantaciones verificando:

- Geolocalizacion del estudiante
- Direccion MAC del dispositivo
- Verificacion biometrica

### Roles del Sistema

| Rol | Descripcion |
|-----|-------------|
| `admin_general` | Super administrador. Gestiona todas las instituciones y usuarios globales. |
| `admin_education_entity` | Administrador de una institucion educativa específica. Gestiona profesores, estudiantes y clases de su entidad. |
| `professor` | Profesor que crea sesiones de asistencia y gestiona sus clases. |
| `student` | Estudiante que marca asistencia y consulta su historial. |

---

## 2. Stack Tecnologico

| Capa | Tecnologia | Version |
|------|-----------|---------|
| Runtime | Node.js | 20 (Alpine) |
| Lenguaje | TypeScript | ^7.0.2 |
| Framework HTTP | Fastify | ^5.12.3 |
| Base de Datos | PostgreSQL | 16 (Alpine) |
| Driver PostgreSQL | pg (node-postgres) | ^8.23.0 |
| Cache/Sesiones | Redis | 7 (Alpine) |
| Cliente Redis | ioredis | ^6.0.0 |
| JWT | @fastify/jwt | ^10.2.2 |
| Hash de passwords | bcryptjs | ^3.0.3 |
| Validacion | Zod | ^4.6.2 |
| Logging | Pino + pino-pretty | ^10.3.1 / ^13.1.3 |
| Seguridad HTTP | @fastify/helmet | ^13.1.1 |
| CORS | @fastify/cors | ^11.3.0 |
| Rate Limiting | @fastify/rate-limit | ^11.2.0 |
| Cookies | @fastify/cookie | ^11.1.2 |
| Exportacion Excel | exceljs | ^4.4.0 |
| Testing | Vitest | ^5.0.0 |
| Linting | ESLint | ^10.10.0 |
| Formateo | Prettier | ^3.9.6 |
| Package Manager | pnpm | (workspace) |
| Sistema Modulos | ESM (`"type": "module"`) | -- |

---

## 3. Arquitectura

El proyecto sigue una **Arquitectura Limpia / Hexagonal** con separacion clara de capas:

```
src/
├── app.ts                    # Punto de entrada / bootstrap
├── applications/             # CAPA DE CASOS DE USO
│   ├── admin-entidad/        # Casos de uso del admin de institucion
│   ├── admin-general/        # Casos de uso del super admin
│   ├── auth/                 # Casos de uso de autenticacion
│   ├── professor/            # Casos de uso del profesor
│   └── student/              # Casos de uso del estudiante
├── domains/                  # CAPA DE ENTIDADES DE DOMINIO
│   ├── auth/                 # Enums y value objects de autenticacion
│   │   ├── auth.enums.ts     # Role, DayWeek, AssistanceMethod, AttendanceStatus
│   │   └── auth.value-objects.ts # Validaciones de password y email
│   ├── user/                 # Entidad User (compartida por todos los roles)
│   │   └── user.entity.ts    # User, CreateUserDTO, UserResponse
│   ├── institution/          # Entidad EducationEntity (instituciones)
│   │   └── institution.entity.ts
│   ├── admin-general/        # Entidad AdminGeneral (super admin)
│   │   └── admin-general.entity.ts
│   ├── admin-entidad/        # Entidad AdminEducationEntity (admin de institucion)
│   │   └── admin-entidad.entity.ts
│   ├── professor/            # Entidad Professor
│   │   └── professor.entity.ts
│   ├── class/                # Entidad Class (clases programadas)
│   │   └── class.entity.ts
│   ├── student/              # Entidades Student y StudentClass
│   │   ├── student.entity.ts
│   │   └── student-class.entity.ts
│   ├── biometric/            # Entidad StudentBiometric (huellas digitales)
│   │   └── biometric.entity.ts
│   ├── attendance/           # Entidades Assistance y AttendanceDetail
│   │   ├── attendance.entity.ts
│   │   └── attendance-detail.entity.ts
│   ├── session/              # Entidad Session (multi-dispositivo)
│   │   └── session.entity.ts
│   ├── token-recovery/       # Entidad TokenRecovery (recuperacion de password)
│   │   └── token-recovery.entity.ts
│   ├── terms/                # Entidad TermsAndConditions
│   │   └── terms.entity.ts
│   └── error/                # Entidad ErrorLog (log de errores)
│       └── error-log.entity.ts
├── infrastructure/           # CAPA DE INFRAESTRUCTURA / ADAPTADORES
│   ├── auth/                 # Adaptadores JWT
│   ├── config/               # Configuracion de entorno
│   ├── database/             # Conexiones a BD
│   ├── email/                # Servicio de email
│   └── redis/                # Cliente Redis
├── interfaces/               # CAPA DE INTERFAZ / PRESENTACION
│   ├── http/
│   │   ├── handlers/         # Controladores HTTP
│   │   ├── middleware/       # Middleware (auth, validacion)
│   │   └── routes/          # Definicion de rutas
│   └── websocket/           # WebSocket (tiempo real)
└── shared/                   # UTILIDADES COMPARTIDAS
    ├── errors/               # Manejo de errores
    ├── logger/               # Logger Pino
    └── utils/                # Funciones utilitarias
```

### Flujo de Datos

```
HTTP Request
    │
    ▼
[interfaces/http/routes] ──► [interfaces/http/handlers]
    │
    ▼
[applications/] ──► Casos de uso / logica de negocio
    │
    ▼
[domains/] ──► Entidades y reglas de negocio
    │
    ▼
[infrastructure/] ──► Adaptadores (DB, Redis, JWT, Email)
    │
    ▼
PostgreSQL / Redis / Externo
```

---

## 4. Estructura del Proyecto

```
AttendGo/
├── .env                          # Variables de entorno (NO se sube a git)
├── .env.example                  # Plantilla de variables de entorno
├── .gitignore                    # Archivos ignorados por git
├── docker-compose.yml            # Orquestacion Docker
├── GUIA_CODIGO.txt               # Guia detallada del codigo para junior devs
├── docs/                         # Documentacion
│   └── README.md                 # Este archivo
└── backend/
    ├── .dockerignore
    ├── .env.example
    ├── .gitignore
    ├── Dockerfile                # Imagen de desarrollo
    ├── Dockerfile.prod           # Imagen de produccion (multi-stage)
    ├── package.json
    ├── pnpm-lock.yaml
    ├── pnpm-workspace.yaml
    ├── tsconfig.json
    ├── migrations/               # Migraciones SQL
    │   ├── 001_initial.sql       # Schema completo (15 tablas)
    │   └── 002_indexes.sql       # Indices de rendimiento (43 indices)
    ├── seeds/                    # Datos de prueba (pendiente)
    ├── tests/                    # Tests (pendiente)
    └── src/
        ├── app.ts
        ├── applications/
        ├── domains/              # Entidades de dominio (interfaces y DTOs)
        │   ├── auth/             # Enums + value objects
        │   ├── user/             # User entity
        │   ├── institution/      # EducationEntity
        │   ├── admin-general/    # AdminGeneral
        │   ├── admin-entidad/    # AdminEducationEntity
        │   ├── professor/        # Professor
        │   ├── class/            # Class
        │   ├── student/          # Student + StudentClass
        │   ├── biometric/        # StudentBiometric
        │   ├── attendance/       # Assistance + AttendanceDetail
        │   ├── session/          # Session
        │   ├── token-recovery/   # TokenRecovery
        │   ├── terms/            # TermsAndConditions
        │   └── error/            # ErrorLog
        ├── infrastructure/
        ├── interfaces/
        └── shared/
```

---

## 5. Capa de Dominio - Entidades y DTOs

La capa de dominio (`backend/src/domains/`) contiene las interfaces que representan las tablas de la base de datos y los objetos que viajan entre capas.

### Conceptos Clave

| Concepto | Descripcion | Ejemplo |
|----------|-------------|---------|
| **Entidad** | Representacion de un objeto del negocio | `User`, `Student`, `Class` |
| **DTO** | Data Transfer Object, se envia entre capas | `CreateUserDTO`, `UpdateClassDTO` |
| **Value Object** | Valor con reglas de validacion | `validatePasswordStrength()` |
| **Filters** | Parametros de busqueda/filtro | `ClassFilters`, `StudentFilters` |

### Archivos de Dominio

| Archivo | Contenido |
|---------|-----------|
| `auth/auth.enums.ts` | 4 enums: Role, DayWeek, AssistanceMethod, AttendanceStatus |
| `auth/auth.value-objects.ts` | Validaciones de password y email |
| `user/user.entity.ts` | User, CreateUserDTO, UserResponse |
| `institution/institution.entity.ts` | EducationEntity, DTOs, Filters |
| `admin-general/admin-general.entity.ts` | AdminGeneral, CreateAdminGeneralDTO |
| `admin-entidad/admin-entidad.entity.ts` | AdminEducationEntity, DTOs |
| `professor/professor.entity.ts` | Professor, DTOs, Filters |
| `class/class.entity.ts` | Class (usa DayWeek enum), DTOs, Filters |
| `student/student.entity.ts` | Student, DTOs, Filters |
| `student/student-class.entity.ts` | StudentClass, EnrollStudentDTO |
| `biometric/biometric.entity.ts` | StudentBiometric (huellas digitales) |
| `attendance/attendance.entity.ts` | Assistance (sesion de asistencia) |
| `attendance/attendance-detail.entity.ts` | AttendanceDetail, RegisterQR/Manual DTOs |
| `session/session.entity.ts` | Session (multi-dispositivo) |
| `token-recovery/token-recovery.entity.ts` | TokenRecovery (recuperacion de password) |
| `terms/terms.entity.ts` | TermsAndConditions |
| `error/error-log.entity.ts` | ErrorLog (log de errores) |

### Patron de DTOs

Cada entidad sigue el mismo patron de 3-4 interfaces:

```typescript
// 1. Entidad completa (lo que hay en la BD)
export interface Student {
    id: string;
    userId: string;
    educationEntityId: string;
    // ... todos los campos
    createdAt: Date;
    updatedAt: Date;
}

// 2. DTO de creacion (lo que envia el usuario al crear)
export interface CreateStudentDTO {
    userId: string;
    educationEntityId: string;
    // ... solo campos obligatorios
}

// 3. DTO de actualizacion (todos opcionales)
export interface UpdateStudentDTO {
    name?: string;
    phone?: string;
    // ... solo campos editables
}

// 4. Filtros de busqueda (para listados)
export interface StudentFilters {
    educationEntityId?: string;
    search?: string;
}
```

---

## 6. Configuracion del Entorno

### Variables de Entorno

Copia `.env.example` a `.env` y configura los valores:

```bash
cp .env.example .env
```

| Variable | Ejemplo | Descripcion |
|----------|---------|-------------|
| `PORT` | `5000` | Puerto del servidor HTTP |
| `NODE_ENV` | `development` | Entorno: `development` o `production` |
| `DB_HOST` | `localhost` | Host de PostgreSQL |
| `DB_PORT` | `5432` | Puerto de PostgreSQL |
| `DB_USER` | `attendgo` | Usuario de PostgreSQL |
| `DB_PASSWORD` | `secreto123` | Password de PostgreSQL (**requerido**) |
| `DB_NAME` | `attendgo` | Nombre de la base de datos |
| `REDIS_HOST` | `localhost` | Host de Redis |
| `REDIS_PORT` | `6379` | Puerto de Redis |
| `REDIS_PASSWORD` | (vacio) | Password de Redis (opcional) |
| `JWT_SECRET` | `clave_secreta` | Secreto para firmar JWT (**requerido**) |
| `JWT_EXPIRES_IN` | `30m` | Tiempo de expiracion del JWT |
| `CORS_ORIGIN` | `http://localhost:3000` | Origenes permitidos (separados por coma) |

### Generar Secrets Automaticamente

```bash
# Generar JWT_SECRET y DB_PASSWORD
JWT_SECRET=$(openssl rand -base64 32)
DB_PASSWORD=$(openssl rand -base64 24)
```

---

## 7. Docker

### Iniciar en Desarrollo

```bash
# Desde la raiz del proyecto
docker compose up -d --build
```

Esto levanta 3 servicios:

| Servicio | Imagen | Puerto | Descripcion |
|----------|--------|--------|-------------|
| `attendgo-db` | postgres:16-alpine | 5432 | Base de datos PostgreSQL |
| `attendgo-redis` | redis:7-alpine | 6379 | Cache y sesiones |
| `attendgo-backend` | (build local) | 5000 | API Fastify con hot-reload |

### Verificar Estado

```bash
docker compose ps
docker compose logs backend
```

### Detener

```bash
docker compose down
```

### Detener y Eliminar Volumes

```bash
docker compose down -v
```

### Produccion

```bash
# Usar el Dockerfile de produccion
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

El `Dockerfile.prod` usa multi-stage build:
1. **Builder**: instala dependencias y compila TypeScript
2. **Runner**: solo copia `dist/` y `node_modules/` (imagen minimal)

---

## 8. Base de Datos

### Tablas

El schema completo esta en `backend/migrations/001_initial.sql`:

#### Users
Tabla central de usuarios. Todos los roles comparten esta tabla.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| email | VARCHAR(255) UNIQUE | Correo electronico |
| password | VARCHAR(255) | Password hasheado con bcrypt |
| role | VARCHAR(255) | Rol: admin_general, admin_education_entity, professor, student |
| token_version | INTEGER | Version del token para revocacion JWT |
| is_active | BOOLEAN | Si la cuenta esta activa |
| must_change_password | BOOLEAN | Si debe cambiar password en el proximo login |
| terms_and_conditions_accepted | BOOLEAN | Si acepto terminos y condiciones |
| created_at | TIMESTAMP | Fecha de creacion |
| updated_at | TIMESTAMP | Fecha de ultima actualizacion |

#### Education_entities
Instituciones educativas (escuelas, universidades).

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| name | VARCHAR(255) | Nombre de la institucion |
| country | VARCHAR(255) | Pais |
| city | VARCHAR(255) | Ciudad |
| address | VARCHAR(255) | Direccion |
| phone | VARCHAR(255) | Telefono |
| email | VARCHAR(255) UNIQUE | Correo de la institucion |
| is_active | BOOLEAN | Si esta activa |

#### Admin_general
Perfil de super administrador.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID FK->Users | Referencia al usuario |
| name | VARCHAR(255) | Nombre completo |
| phone | VARCHAR(255) | Telefono |

#### admin_education_entity
Administrador de una institucion especifica.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID FK->Users | Referencia al usuario |
| education_entity_id | UUID FK->Education_entities | Institucion que administra |
| name | VARCHAR(255) | Nombre completo |
| phone | VARCHAR(255) | Telefono |

#### Professors
Perfil de profesor.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID FK->Users | Referencia al usuario |
| education_entity_id | UUID FK->Education_entities | Institucion |
| name | VARCHAR(255) | Nombre completo |
| phone | VARCHAR(255) | Telefono |
| educational_department | VARCHAR(255) | Departamento academico |
| is_active | BOOLEAN | Si esta activo |

#### Classes
Clases programadas (un slot semanal recurrente).

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| education_entity_id | UUID FK | Institucion |
| professor_id | UUID FK | Profesor asignado |
| class_code | VARCHAR(100) | Codigo de la clase |
| name | VARCHAR(100) | Nombre de la clase |
| class_day | VARCHAR(20) | Dia de la semana (Monday-Sunday) |
| start_time | TIME | Hora de inicio |
| end_time | TIME | Hora de fin |
| classroom | VARCHAR(50) | Aula |
| is_active | BOOLEAN | Si esta activa |

#### Students
Perfil de estudiante.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID FK->Users | Referencia al usuario |
| education_entity_id | UUID FK | Institucion |
| educational_program | VARCHAR(100) | Programa academico |
| identification_number | VARCHAR(100) UNIQUE | Numero de identificacion |
| name | VARCHAR(255) | Nombre completo |
| phone | VARCHAR(255) | Telefono |
| is_active | BOOLEAN | Si esta activo |

#### Students_Classes
Relacion many-to-many estudiante-clase (inscripcion).

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| students_id | UUID FK | Estudiante |
| class_id | UUID FK | Clase |
| added_at | TIMESTAMP | Fecha de inscripcion |

#### student_biometrics
Plantillas de huellas digitales para verificacion biométrica.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| students_id | UUID FK | Estudiante |
| template_data | BYTEA | Datos de la plantilla biometrica |
| device_info | VARCHAR(200) | Informacion del dispositivo |
| registered_at | TIMESTAMP | Fecha de registro |

#### Assistance
Sesion de asistencia abierta por un profesor.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| class_id | UUID FK | Clase |
| professor_id | UUID FK | Profesor que abre la sesion |
| date_assistance | DATE | Fecha de la sesion |
| start_time | TIME | Hora de inicio |
| end_time | TIME | Hora de cierre |
| method | VARCHAR(100) | Metodo: QR, QR_BIOMETRIC, MANUAL |

#### Attendance_details
Registro individual de asistencia de cada estudiante.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| assistance_id | UUID FK | Sesion de asistencia |
| students_id | UUID FK | Estudiante |
| state_attendance | VARCHAR(100) | Estado: attended, no_attended, no_attended_excuse |
| mac_address | VARCHAR(100) | Direccion MAC del dispositivo |
| geolocation_lat | DECIMAL(10,8) | Latitud |
| geolocation_lng | DECIMAL(11,8) | Longitud |
| biometric_verified | BOOLEAN | Si paso verificacion biometrica |
| possible_impersonation | BOOLEAN | Posible suplantacion detectada |
| impersonation_reason | VARCHAR(200) | Razon de la suplantacion |
| observations | TEXT | Observaciones |

#### Tokens_recovery
Tokens de recuperacion de password (codigo de 6 digitos).

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID FK | Usuario |
| code | VARCHAR(6) | Codigo de 6 digitos |
| expires_at | TIMESTAMP | Fecha de expiracion |
| used | BOOLEAN | Si ya fue utilizado |

#### Terms_and_conditions
Registro de aceptacion de terminos y condiciones.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID UNIQUE FK | Usuario |
| version | VARCHAR(100) | Version de los terminos |
| accepted | BOOLEAN | Si fue aceptado |

#### Sessions
Sesiones activas (multi-dispositivo).

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID FK | Usuario |
| token_hash | VARCHAR(255) | Hash del token JWT |
| ip_address | VARCHAR(45) | IP del cliente |
| user_agent | TEXT | User-Agent del navegador |
| expires_at | TIMESTAMP | Fecha de expiracion |

#### Error_logs
Log de errores de la aplicacion.

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| id | UUID PK | Identificador unico |
| user_id | UUID FK (nullable) | Usuario (si aplica) |
| action | VARCHAR(100) | Accion que fallo |
| error_message | TEXT | Mensaje de error |
| ip_address | VARCHAR(45) | IP del cliente |
| user_agent | TEXT | User-Agent |

### Indices

Los indices de rendimiento estan en `backend/migrations/002_indexes.sql` (43 indices). Cubren todas las columnas de FK, busquedas frecuentes y filtros comunes.

### Ejecutar Migraciones

```bash
# Desde la raiz del proyecto
docker compose exec postgres psql -U attendgo -d attendgo -f /dev/stdin < backend/migrations/001_initial.sql
docker compose exec postgres psql -U attendgo -d attendgo -f /dev/stdin < backend/migrations/002_indexes.sql
```

### Verificar Tablas

```bash
docker compose exec postgres psql -U attendgo -d attendgo -c "\dt"
```

---

## 9. API Endpoints

### Endpoints Implementados

| Metodo | Ruta | Descripcion | Auth |
|--------|------|-------------|------|
| GET | `/health` | Health check del servidor | No |

### Endpoints Planificados

#### Auth
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| POST | `/auth/register` | Registro de usuario |
| POST | `/auth/login` | Login |
| POST | `/auth/logout` | Logout |
| POST | `/auth/refresh` | Refrescar token |
| POST | `/auth/forgot-password` | Solicitar recuperacion |
| POST | `/auth/reset-password` | Restablecer password |

#### Admin General
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/admin-general/institutions` | Listar instituciones |
| POST | `/admin-general/institutions` | Crear institucion |
| GET | `/admin-general/users` | Listar usuarios |
| POST | `/admin-general/users` | Crear usuario |

#### Admin Institucion
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/admin-entidad/professors` | Listar profesores |
| POST | `/admin-entidad/professors` | Crear profesor |
| GET | `/admin-entidad/students` | Listar estudiantes |
| POST | `/admin-entidad/students` | Crear estudiante |
| GET | `/admin-entidad/classes` | Listar clases |
| POST | `/admin-entidad/classes` | Crear clase |

#### Professor
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/professor/classes` | Mis clases |
| POST | `/professor/attendance/open` | Abrir sesion de asistencia |
| POST | `/professor/attendance/close` | Cerrar sesion |
| GET | `/professor/attendance/:id` | Ver detalles de sesion |
| POST | `/professor/qr/generate` | Generar QR para asistencia |

#### Student
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/student/classes` | Mis clases inscritas |
| POST | `/student/attendance/scan` | Escanear QR para asistencia |
| GET | `/student/attendance/history` | Historial de asistencia |

---

## 10. Flujo de Autenticacion

### Registro

```
1. Usuario envia email, password, role
2. Se hashea el password con bcrypt (10 rounds)
3. Se crea el registro en Users
4. Se crea el perfil segun el rol (Admin_general, Professors, Students)
5. Se genera token JWT con user_id, role, token_version
6. Se retorna el token
```

### Login

```
1. Usuario envia email y password
2. Se busca el usuario por email
3. Se verifica el password con bcrypt.compare()
4. Se verifica que is_active === true
5. Se genera token JWT con user_id, role, token_version
6. Se crea registro en Sessions (token_hash, ip, user_agent)
7. Se retorna el token
```

### Revocacion de Token

El campo `token_version` en Users permite revocar tokens:
- Cuando el usuario cambia su password, se incrementa `token_version`
- El JWT incluye `token_version` al momento de firmarlo
- Al validar, se compara la version del token con la version actual en la BD
- Si no coinciden, el token es invalido

---

## 11. Roles y Permisos

### admin_general
- Gestiona todas las instituciones educativas
- Crea/edita/elimina usuarios de cualquier rol
- Ve reportes globales del sistema
- Gestiona terminos y condiciones

### admin_education_entity
- Gestiona solo su institucion
- Crea/edita/elimina profesores de su entidad
- Crea/edita/elimina estudiantes de su entidad
- Gestiona clases de su entidad
- Ve reportes de su institucion

### professor
- Ve sus clases asignadas
- Abre/cierra sesiones de asistencia
- Genera QR para asistencia
- Ve asistencia de sus clases
- Registra asistencia manual

### student
- Ve sus clases inscritas
- Marca asistencia escaneando QR
- Consulta historial de asistencia
- Registra datos biometricos

---

## 12. Sistema de Asistencia

### Metodos de Asistencia

| Metodo | Descripcion | Verificacion |
|--------|-------------|--------------|
| `QR` | Codigo QR dinamico | Solo escaneo |
| `QR_BIOMETRIC` | QR + huella digital | Escaneo + biometria |
| `MANUAL` | Registro manual por profesor | Sin verificacion |

### Flujo de Asistencia QR

```
1. Profesor abre sesion de asistencia (POST /professor/attendance/open)
   - Se crea registro en Assistance con method='QR'
   - Se genera un UUID unico como "semilla" del QR

2. Backend genera QR dinamico con:
   - assistance_id
   - UUID unico (cambia cada 30 segundos)
   - Timestamp de expiracion

3. Estudiante escanea el QR (POST /student/attendance/scan)
   - El backend valida:
     a. Que la sesion este abierta
     b. Que el QR no haya expirado
     c. Que el UUID sea valido (no replay)
     d. Geolocalizacion dentro del radio permitido
     e. Direccion MAC registrada

4. Se crea registro en Attendance_details con:
   - state_attendance = 'attended'
   - geolocation_lat/lng
   - mac_address
   - possible_impersonation = false
```

### Deteccion de Suplantacion

El sistema marca `possible_impersonation = true` si:

| Condicion | Razon |
|-----------|-------|
| Geolocalizacion fuera del radio | "Ubicacion fuera del campus" |
| MAC address no registrada | "Dispositivo no reconocido" |
| Biometria no verificada (en QR_BIOMETRIC) | "Huella no coincidente" |
| Multiples intentos desde diferente IP | "Multiples dispositivos detectados" |

---

## 13. Git Flow y Contribucion

### Ramas

| Rama | Proposito | Proteccion |
|------|-----------|------------|
| `main` | Produccion, codigo estable | PR requerido, minimo 1 review |
| `develop` | Integracion, codigo en desarrollo | PR requerido |
| `feature/*` | Nuevas funcionalidades | Se mergea a develop |
| `fix/*` | Correccion de bugs | Se mergea a develop |
| `release/*` | Preparacion de release | Se mergea a main y develop |
| `hotfix/*` | Fix urgente en produccion | Se mergea a main y develop |

### Flujo de Trabajo

```bash
# 1. Actualizar develop
git checkout develop
git pull origin develop

# 2. Crear feature
git checkout -b feature/nombre-feature

# 3. Trabajar y hacer commits
git add .
git commit -m "feat: descripcion del cambio"

# 4. Push y crear PR
git push -u origin feature/nombre-feature
# Crear PR en GitHub: feature/nombre-feature -> develop

# 5. Despues del merge, eliminar feature
git checkout develop
git pull origin develop
git branch -d feature/nombre-feature
```

### Convenciones de Commits

```
feat:     Nueva funcionalidad
fix:      Correccion de bug
docs:     Documentacion
style:    Formato (no afecta logica)
refactor: Refactorizacion (no agrega feature ni fix)
test:     Tests
chore:    Configuracion, dependencias, scripts
```

### Reglas de Seguridad (GitHub)

- `main` tiene branch protection activado
- Todos los cambios pasan por PR + review
- `pnpm-lock.yaml` SIEMPRE se sube a git (reproducibilidad)
- `.env` NUNCA se sube a git (contiene secretos)

---

## 14. Scripts Disponibles

### package.json

| Script | Comando | Descripcion |
|--------|---------|-------------|
| `dev` | `tsx watch src/app.ts` | Servidor con hot-reload |
| `build` | `tsc` | Compilar TypeScript a `dist/` |
| `start` | `node dist/app.js` | Ejecutar build de produccion |
| `test` | `vitest` | Tests en modo watch |
| `test:run` | `vitest run` | Ejecutar tests una vez |
| `lint` | `eslint src/` | Verificar codigo con ESLint |
| `format` | `prettier --write src/` | Formatear codigo |

### Docker

| Comando | Descripcion |
|---------|-------------|
| `docker compose up -d --build` | Levantar todo |
| `docker compose down` | Detener servicios |
| `docker compose down -v` | Detener y eliminar volumes |
| `docker compose ps` | Ver estado |
| `docker compose logs backend` | Ver logs del backend |
| `docker compose exec backend sh` | Shell dentro del contenedor |

---

## 15. Problemas Conocidos y Soluciones

### Error: `ERR_PNPM_IGNORED_BUILDS` en Docker

**Causa:** pnpm v10+ bloquea scripts de build por defecto. `esbuild` necesita un script postinstall.

**Solucion:** En el Dockerfile, cambiar la linea de install:
```dockerfile
RUN pnpm approve-builds esbuild && pnpm install
```

### Error: `logger options only accepts a configuration object` (Fastify 5)

**Causa:** Fastify 5 ya no acepta una instancia de `pino` directamente en `logger`. Solo acepta un objeto de configuracion.

**Solucion:** Pasar configuracion inline:
```typescript
const app = Fastify({
  logger: {
    level: config.NODE_ENV === 'production' ? 'info' : 'debug',
    transport: config.NODE_ENV !== 'production' ? { target: 'pino-pretty' } : undefined,
  },
});
```
Usar `app.log.info()` / `app.log.error()` en lugar de `logger.info()` / `logger.error()`.

### Error: `This expression is not constructable` (ioredis v6)

**Causa:** En ioredis v6, la exportacion default ya no es la clase `Redis`. Ahora es un namespace.

**Solucion:** Cambiar el import:
```typescript
// ❌ Antes
import Redis from 'ioredis';

// ✅ Ahora
import { Redis } from 'ioredis';
```

### Error: `DB_PASSWORD is required` en Docker Compose

**Causa:** El `.env` tiene `DB_PASSWORD=` (vacio), pero `docker-compose.yml` usa `${DB_PASSWORD:?DB_PASSWORD is required}`.

**Solucion:** Asignar un valor real en `.env`:
```bash
DB_PASSWORD=$(openssl rand -base64 24)
```

### pnpm-lock.yaml no se sube a git

**Causa:** Estaba en `.gitignore`.

**Solucion:** Eliminar `pnpm-lock.yaml` de `.gitignore`. El lock file DEBE subirse para garantizar instalaciones reproducibles y prevenir supply chain attacks.

---

## Notas para Desarrolladores

### Antes de empezar

1. Asegurate de tener Docker y Docker Compose instalados
2. Copia `.env.example` a `.env` y configura los valores
3. Ejecuta `docker compose up -d --build`
4. Ejecuta las migraciones SQL
5. Verifica con `curl http://localhost:5000/health`

### Convenciones de Codigo

- **TypeScript strict mode** esta habilitado
- Usar **ESM imports** con extensiones `.js` (NodeNext module resolution)
- Separar logica por **capas** (applications, domains, infrastructure, interfaces)
- Los **handlers HTTP** van en `interfaces/http/handlers/`
- Los **casos de uso** van en `applications/`
- Las **entidades de dominio** van en `domains/`
- Los **adaptadores de infraestructura** van en `infrastructure/`

### Dependencias Importantes

- **No instalar `@types/ioredis`** - ioredis v6 ya incluye tipos
- **No instalar `@types/pino`** - pino ya incluye tipos
- Usar **pnpm** como package manager (no npm ni yarn)
- El proyecto usa **ESM** (`"type": "module"`), no CommonJS
