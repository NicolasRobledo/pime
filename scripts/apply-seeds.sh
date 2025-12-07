#!/bin/bash

# Script para aplicar datos de prueba (seeds)
# Uso: ./apply-seeds.sh [dev|test]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

ENVIRONMENT=${1:-dev}

# No permitir seeds en producción
if [ "$ENVIRONMENT" = "prod" ]; then
    log_error "Seeds are not allowed in production environment"
    exit 1
fi

log_info "Environment: $ENVIRONMENT"

# Cargar variables de entorno
if [ -f ".env.$ENVIRONMENT" ]; then
    export $(cat .env.$ENVIRONMENT | grep -v '^#' | xargs)
elif [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    log_error "No .env file found"
    exit 1
fi

# Verificar si existen seeds para este ambiente
SEED_DIR="seeds/$ENVIRONMENT"
if [ ! -d "$SEED_DIR" ]; then
    log_warning "No seed directory found for $ENVIRONMENT"
    exit 0
fi

log_info "Applying seeds from $SEED_DIR..."

# Aplicar cada archivo de seed
SEED_COUNT=0
for seed_file in "$SEED_DIR"/*.sql; do
    if [ -f "$seed_file" ]; then
        seed_name=$(basename "$seed_file")
        log_info "Applying seed: $seed_name"

        if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB -f "$seed_file"; then
            log_info "Seed $seed_name applied successfully"
            ((SEED_COUNT++))
        else
            log_error "Failed to apply seed: $seed_name"
            exit 1
        fi
    fi
done

if [ $SEED_COUNT -eq 0 ]; then
    log_info "No seed files found"
else
    log_info "Successfully applied $SEED_COUNT seed file(s)"
fi
