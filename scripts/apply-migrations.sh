#!/bin/bash

# Script para aplicar migraciones de base de datos
# Uso: ./apply-migrations.sh [dev|test|prod]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar argumentos
ENVIRONMENT=${1:-dev}
log_info "Environment: $ENVIRONMENT"

# Cargar variables de entorno
if [ -f ".env.$ENVIRONMENT" ]; then
    log_info "Loading .env.$ENVIRONMENT"
    export $(cat .env.$ENVIRONMENT | grep -v '^#' | xargs)
elif [ -f ".env" ]; then
    log_info "Loading .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    log_error "No .env file found"
    exit 1
fi

# Verificar variables requeridas
if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    log_error "Missing required environment variables"
    exit 1
fi

# Construir connection string
DB_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT:-5432}/${POSTGRES_DB}"

log_info "Connecting to database: ${POSTGRES_HOST}:${POSTGRES_PORT:-5432}/${POSTGRES_DB}"

# Crear tabla de tracking de migraciones si no existe
log_info "Creating schema_migrations table if not exists..."
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB <<EOF
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);
EOF

# Obtener migraciones ya aplicadas
APPLIED_MIGRATIONS=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT version FROM schema_migrations ORDER BY version;")

# Aplicar migraciones pendientes
MIGRATION_COUNT=0
for migration_file in migrations/*.sql; do
    if [ -f "$migration_file" ]; then
        migration_name=$(basename "$migration_file" .sql)

        # Verificar si ya fue aplicada
        if echo "$APPLIED_MIGRATIONS" | grep -q "$migration_name"; then
            log_info "Migration $migration_name already applied, skipping..."
        else
            log_info "Applying migration: $migration_name"

            # Aplicar migración
            if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB -f "$migration_file"; then
                # Registrar migración exitosa
                PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB <<EOF
INSERT INTO schema_migrations (version, description)
VALUES ('$migration_name', 'Applied migration from $migration_file');
EOF
                log_info "Migration $migration_name applied successfully"
                ((MIGRATION_COUNT++))
            else
                log_error "Failed to apply migration: $migration_name"
                exit 1
            fi
        fi
    fi
done

if [ $MIGRATION_COUNT -eq 0 ]; then
    log_info "No new migrations to apply"
else
    log_info "Successfully applied $MIGRATION_COUNT migration(s)"
fi

log_info "Migration process completed"
