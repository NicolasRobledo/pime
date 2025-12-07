# PIME - Database Repository

Repositorio de base de datos PostgreSQL con integración continua automatizada.

## Cómo funciona el CI/CD para el DBA

### Flujo de trabajo

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  1. Escribir    │     │  2. Push a      │     │  3. GitHub      │
│  SQL en local   │ ──► │  GitHub         │ ──► │  Actions        │
│                 │     │                 │     │  despliega      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Dónde poner tus archivos SQL

| Tipo de cambio | Carpeta | Ejemplo |
|----------------|---------|---------|
| Crear/modificar tablas | `migrations/` | `001_create_users.sql` |
| Stored Procedures | `stored_procedures/<modulo>/` | `stored_procedures/users/sp_create_user.sql` |
| Functions | `functions/` | `fn_calculate_total.sql` |
| Triggers | `triggers/` | `trg_update_timestamp.sql` |
| Datos de prueba | `seeds/dev/` | `001_sample_users.sql` |

### Paso a paso: Agregar un nuevo Stored Procedure

1. **Crear el archivo SQL:**
```bash
nano stored_procedures/users/sp_get_user_by_id.sql
```

2. **Escribir el SP:**
```sql
CREATE OR REPLACE FUNCTION sp_get_user_by_id(p_user_id INT)
RETURNS TABLE(id INT, email VARCHAR, name VARCHAR)
AS $$
BEGIN
    RETURN QUERY SELECT u.id, u.email, u.name FROM users u WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;
```

3. **Subir a GitHub:**
```bash
git add stored_procedures/users/sp_get_user_by_id.sql
git commit -m "feat: add sp_get_user_by_id"
git push origin main
```

4. **Listo.** GitHub Actions aplica automáticamente el SP en el ambiente DEV.

### Paso a paso: Crear una nueva migración

1. **Crear el archivo con número secuencial:**
```bash
nano migrations/002_add_products_table.sql
```

2. **Escribir el DDL:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_name ON products(name);
```

3. **Subir a GitHub:**
```bash
git add migrations/002_add_products_table.sql
git commit -m "feat: add products table"
git push origin main
```

### Ambientes y triggers automáticos

| Cuando haces... | Se despliega en... | Automático? |
|-----------------|-------------------|-------------|
| `git push origin main` | DEV | Si |
| `git push origin test` | TEST | Si |
| `git tag v1.0.0 && git push --tags` | PROD | Requiere aprobación |

### Ver el estado del deployment

1. Ir a https://github.com/NicolasRobledo/pime/actions
2. Ver el workflow más reciente
3. Verde = OK, Rojo = Error (ver logs)

### Probar localmente antes de subir

```bash
# Levantar PostgreSQL local
docker-compose -f docker-compose.dev.yml up -d

# Aplicar todo
./scripts/deploy-all.sh dev

# O aplicar solo lo que modificaste
./scripts/apply-migrations.sh dev
./scripts/deploy-procedures.sh dev
```

### Estructura del repositorio

```
pime/
├── migrations/           # DDL: CREATE TABLE, ALTER TABLE, etc.
├── stored_procedures/    # Stored Procedures organizados por módulo
│   ├── users/
│   ├── products/
│   └── purchases/
├── functions/            # Functions reutilizables
├── triggers/             # Triggers
├── seeds/                # Datos de prueba
│   ├── dev/
│   └── test/
├── scripts/              # Scripts de deployment
└── .github/workflows/    # Configuración CI/CD
```

### Reglas importantes

1. **Nomenclatura de migraciones:** Usar números secuenciales `001_`, `002_`, etc.
2. **Stored Procedures:** Usar prefijo `sp_` y ubicar en la carpeta del módulo correspondiente
3. **No editar migraciones ya aplicadas:** Crear una nueva migración para cambios
4. **Probar localmente** antes de hacer push

### Configuración inicial (solo una vez)

Los secrets de conexión a las bases de datos están en GitHub:
- Settings > Secrets and variables > Actions

Variables necesarias por ambiente:
- `DEV_POSTGRES_HOST`, `DEV_POSTGRES_PORT`, `DEV_POSTGRES_DB`, `DEV_POSTGRES_USER`, `DEV_POSTGRES_PASSWORD`
- `TEST_POSTGRES_HOST`, `TEST_POSTGRES_PORT`, `TEST_POSTGRES_DB`, `TEST_POSTGRES_USER`, `TEST_POSTGRES_PASSWORD`
- `PROD_POSTGRES_HOST`, `PROD_POSTGRES_PORT`, `PROD_POSTGRES_DB`, `PROD_POSTGRES_USER`, `PROD_POSTGRES_PASSWORD`
