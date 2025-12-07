# PIME - Database Repository

Base de datos PostgreSQL para el e-commerce de modelos 3D de figuras de anime.

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Arquitectura](#arquitectura)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Requisitos Previos](#requisitos-previos)
- [Instalación Local](#instalación-local)
- [Guía para Desarrolladores de Base de Datos](#guía-para-desarrolladores-de-base-de-datos)
- [CI/CD con GitHub Actions](#cicd-con-github-actions)
- [Ambientes](#ambientes)
- [Deployment](#deployment)
- [Documentación](#documentación)

---

## 🎯 Descripción

Este repositorio contiene:
- Scripts de migración DDL (estructura de la base de datos)
- Stored Procedures (interfaz entre backend y DB)
- Functions y Triggers
- Configuración de CI/CD automático
- Docker Compose para cada ambiente

**Filosofía:** El backend (Spring Boot) **SOLO** invoca Stored Procedures. Toda la lógica de datos está en la base de datos.

---

## 🏗️ Arquitectura

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   BACKEND   │  SOLO   │   STORED     │  ACCEDE │  TABLAS +   │
│   (Java)    │ ────→   │  PROCEDURES  │  ────→  │   DATOS     │
│             │  LLAMA  │   (SPs)      │         │             │
└─────────────┘         └──────────────┘         └─────────────┘
```

### Ventajas:
- ✅ Separación de responsabilidades
- ✅ Mayor seguridad (backend no hace queries directas)
- ✅ Performance optimizado
- ✅ Versionamiento completo de la lógica de datos

---

## 📁 Estructura del Proyecto

```
pime-db/
├── docs/                          # Documentación del proyecto
│   ├── analisis-requerimientos.md
│   ├── arquitectura-jwt-autenticacion.md
│   └── ...
├── migrations/                    # Scripts DDL (crear/modificar tablas)
│   ├── 001_create_initial_schema.sql
│   ├── 002_add_indexes.sql
│   └── ...
├── stored_procedures/             # Stored Procedures por módulo
│   ├── users/
│   │   ├── sp_create_user.sql
│   │   └── sp_get_user_by_email.sql
│   ├── products/
│   │   ├── sp_create_product.sql
│   │   └── sp_list_products.sql
│   └── purchases/
│       └── sp_create_purchase.sql
├── functions/                     # Funciones reutilizables
├── triggers/                      # Triggers
├── seeds/                         # Datos de prueba
│   ├── dev/
│   └── test/
├── scripts/                       # Scripts de deployment
│   ├── apply-migrations.sh
│   ├── deploy-procedures.sh
│   ├── deploy-all.sh
│   └── apply-seeds.sh
├── .github/workflows/             # GitHub Actions
│   ├── deploy-dev.yml
│   ├── deploy-test.yml
│   └── deploy-prod.yml
├── docker-compose.dev.yml         # PostgreSQL para desarrollo
├── docker-compose.test.yml        # PostgreSQL para testing
├── docker-compose.prod.yml        # PostgreSQL para producción
├── .env.example                   # Variables de entorno ejemplo
├── .gitignore
└── README.md
```

---

## 📦 Requisitos Previos

- Docker y Docker Compose
- Git
- PostgreSQL client (psql)
- Acceso SSH a la VPS (para producción)

---

## 🚀 Instalación Local

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/pime-db.git
cd pime-db
```

### 2. Configurar variables de entorno

```bash
cp .env.example .env.dev
```

Editar `.env.dev` con tus credenciales locales:

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=pime_dev
POSTGRES_USER=pime_user
POSTGRES_PASSWORD=dev_password
```

### 3. Levantar PostgreSQL con Docker

```bash
docker-compose -f docker-compose.dev.yml up -d
```

Esto levanta:
- PostgreSQL en el puerto 5432
- pgAdmin en http://localhost:5050 (usuario: admin@pime.local, password: admin)

### 4. Aplicar migraciones y stored procedures

```bash
# Todo de una vez
./scripts/deploy-all.sh dev

# O paso a paso
./scripts/apply-migrations.sh dev
./scripts/deploy-procedures.sh dev
./scripts/apply-seeds.sh dev
```

### 5. Verificar

```bash
docker exec -it pime-db-dev psql -U pime_user -d pime_dev -c "\dt"
```

---

## 👨‍💻 Guía para Desarrolladores de Base de Datos

### 📝 Crear una nueva migración

Las migraciones son scripts SQL que modifican la estructura de la base de datos.

**Nomenclatura:** `XXX_descripcion_del_cambio.sql`

Ejemplo:

```bash
# Crear archivo
nano migrations/001_create_initial_schema.sql
```

```sql
-- migrations/001_create_initial_schema.sql

-- Tabla de usuarios
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    google_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    picture_url TEXT,
    role VARCHAR(50) DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Tabla de productos
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    anime_name VARCHAR(255) NOT NULL,
    character_name VARCHAR(255) NOT NULL,
    optional_category VARCHAR(100),
    google_drive_file_id VARCHAR(255) NOT NULL,
    mercadolibre_id VARCHAR(100) UNIQUE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_anime ON products(anime_name);
CREATE INDEX idx_products_status ON products(status);
```

### 🔧 Crear un Stored Procedure

Los SPs son la **interfaz** entre el backend y la base de datos.

**Ubicación:** `stored_procedures/<modulo>/<nombre>.sql`

Ejemplo:

```bash
# Crear archivo
nano stored_procedures/users/sp_create_user.sql
```

```sql
-- stored_procedures/users/sp_create_user.sql

CREATE OR REPLACE FUNCTION sp_create_user(
    p_google_id VARCHAR(255),
    p_email VARCHAR(255),
    p_name VARCHAR(255),
    p_picture_url TEXT
)
RETURNS TABLE(
    user_id INT,
    created BOOLEAN,
    message TEXT
)
AS $$
DECLARE
    v_user_id INT;
    v_exists BOOLEAN;
BEGIN
    -- Verificar si el usuario ya existe
    SELECT EXISTS(
        SELECT 1 FROM users WHERE google_id = p_google_id
    ) INTO v_exists;

    IF v_exists THEN
        -- Usuario existe, actualizar
        UPDATE users
        SET last_login = CURRENT_TIMESTAMP,
            name = p_name,
            picture_url = p_picture_url
        WHERE google_id = p_google_id
        RETURNING id INTO v_user_id;

        RETURN QUERY SELECT v_user_id, FALSE, 'User updated'::TEXT;
    ELSE
        -- Usuario nuevo
        INSERT INTO users (google_id, email, name, picture_url, role, last_login)
        VALUES (p_google_id, p_email, p_name, p_picture_url, 'customer', CURRENT_TIMESTAMP)
        RETURNING id INTO v_user_id;

        RETURN QUERY SELECT v_user_id, TRUE, 'User created'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

### ✅ Probar localmente

```bash
# Aplicar migración
./scripts/apply-migrations.sh dev

# Desplegar stored procedure
./scripts/deploy-procedures.sh dev

# Probar el SP
docker exec -it pime-db-dev psql -U pime_user -d pime_dev -c "
SELECT * FROM sp_create_user(
    'google_123',
    'test@gmail.com',
    'Test User',
    'https://...'
);
"
```

### 📤 Subir cambios a GitHub

```bash
git add migrations/001_create_initial_schema.sql
git add stored_procedures/users/sp_create_user.sql
git commit -m "feat: add initial schema and user stored procedures"
git push origin main
```

**🎉 GitHub Actions automáticamente despliega los cambios a DEV!**

---

## 🤖 CI/CD con GitHub Actions

### Flujo automático:

| Acción | Ambiente | Trigger |
|--------|----------|---------|
| Push a `main` | **DEV** | Automático |
| Push a `test` | **TEST** | Automático |
| Tag `v*.*.*` | **PROD** | Automático + Aprobación manual |

### Configurar GitHub Secrets

Ve a tu repositorio → Settings → Secrets and variables → Actions

**Para DEV:**
- `DEV_POSTGRES_HOST` (ej: tu-vps-ip)
- `DEV_POSTGRES_PORT` (ej: 5432)
- `DEV_POSTGRES_DB` (ej: pime_dev)
- `DEV_POSTGRES_USER` (ej: pime_user)
- `DEV_POSTGRES_PASSWORD` (contraseña segura)

**Para TEST:**
- `TEST_POSTGRES_HOST`
- `TEST_POSTGRES_PORT`
- `TEST_POSTGRES_DB`
- `TEST_POSTGRES_USER`
- `TEST_POSTGRES_PASSWORD`

**Para PROD:**
- `PROD_POSTGRES_HOST`
- `PROD_POSTGRES_PORT`
- `PROD_POSTGRES_DB`
- `PROD_POSTGRES_USER`
- `PROD_POSTGRES_PASSWORD`

---

## 🌍 Ambientes

### Development (DEV)
- Base de datos para desarrollo diario
- Se destruye y recrea frecuentemente
- Contiene datos de prueba (seeds)
- Deployment automático con cada push a `main`

### Test (TEST)
- Base de datos para testing automatizado
- Datos consistentes y predecibles
- Deployment automático con cada push a `test`

### Production (PROD)
- Base de datos real con datos de usuarios
- **Requiere aprobación manual** en GitHub
- Se crea backup automático antes de cada deployment
- Deployment con tags: `git tag v1.0.0 && git push --tags`

---

## 🚀 Deployment

### Desarrollo local

```bash
./scripts/deploy-all.sh dev
```

### Deployment a DEV (VPS)

```bash
git add .
git commit -m "feat: add new stored procedure"
git push origin main
```

GitHub Actions despliega automáticamente.

### Deployment a TEST

```bash
git checkout test
git merge main
git push origin test
```

### Deployment a PROD

```bash
# 1. Crear tag
git tag v1.0.0

# 2. Push tag
git push --tags

# 3. Ir a GitHub → Actions
# 4. Aprobar el deployment manualmente
```

---

## 📚 Documentación

Toda la documentación del proyecto está en `docs/`:

- **analisis-requerimientos.md**: Análisis completo del sistema
- **arquitectura-jwt-autenticacion.md**: Arquitectura de autenticación
- **flujo-google-auth.md**: Flujo de autenticación con Google OAuth
- **mapeo-documentacion-apis.md**: Documentación de APIs externas

---

## 🛡️ Seguridad

- ✅ Nunca subas archivos `.env` al repositorio
- ✅ Usa contraseñas fuertes y únicas para cada ambiente
- ✅ Rotá las contraseñas regularmente
- ✅ El backend solo puede ejecutar SPs, no queries directas
- ✅ Los backups se crean automáticamente en producción

---

## 🤝 Contribución

### Workflow:

1. Crear rama para tu feature: `git checkout -b feature/nueva-tabla`
2. Crear migración/SP
3. Probar localmente
4. Commit y push
5. Crear Pull Request a `main`
6. Después de merge → deployment automático a DEV

---

## 📞 Contacto

- **Proyecto:** PIME - E-commerce de Modelos 3D
- **Repositorio Backend:** (próximamente)

---

## 📝 Licencia

[Definir licencia]

---

**Última actualización:** 2025-12-06
