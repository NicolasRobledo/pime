#!/bin/bash

# Script para desplegar stored procedures, functions y triggers
# Uso: ./deploy-procedures.sh [dev|test|prod]

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

log_info "Connecting to database: ${POSTGRES_HOST}:${POSTGRES_PORT:-5432}/${POSTGRES_DB}"

# Contador de objetos desplegados
SP_COUNT=0
FN_COUNT=0
TRG_COUNT=0

# Desplegar Functions
log_info "Deploying functions..."
if [ -d "functions" ]; then
    for fn_file in functions/*.sql; do
        if [ -f "$fn_file" ]; then
            fn_name=$(basename "$fn_file")
            log_info "Deploying function: $fn_name"

            if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB -f "$fn_file"; then
                log_info "Function $fn_name deployed successfully"
                ((FN_COUNT++))
            else
                log_error "Failed to deploy function: $fn_name"
                exit 1
            fi
        fi
    done
fi

# Desplegar Stored Procedures
log_info "Deploying stored procedures..."
if [ -d "stored_procedures" ]; then
    for module_dir in stored_procedures/*/; do
        if [ -d "$module_dir" ]; then
            module_name=$(basename "$module_dir")
            log_info "Processing module: $module_name"

            for sp_file in "$module_dir"*.sql; do
                if [ -f "$sp_file" ]; then
                    sp_name=$(basename "$sp_file")
                    log_info "Deploying stored procedure: $sp_name"

                    if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB -f "$sp_file"; then
                        log_info "Stored procedure $sp_name deployed successfully"
                        ((SP_COUNT++))
                    else
                        log_error "Failed to deploy stored procedure: $sp_name"
                        exit 1
                    fi
                fi
            done
        fi
    done
fi

# Desplegar Triggers
log_info "Deploying triggers..."
if [ -d "triggers" ]; then
    for trg_file in triggers/*.sql; do
        if [ -f "$trg_file" ]; then
            trg_name=$(basename "$trg_file")
            log_info "Deploying trigger: $trg_name"

            if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d $POSTGRES_DB -f "$trg_file"; then
                log_info "Trigger $trg_name deployed successfully"
                ((TRG_COUNT++))
            else
                log_error "Failed to deploy trigger: $trg_name"
                exit 1
            fi
        fi
    done
fi

# Resumen
log_info "========================================"
log_info "Deployment Summary:"
log_info "  Functions:         $FN_COUNT"
log_info "  Stored Procedures: $SP_COUNT"
log_info "  Triggers:          $TRG_COUNT"
log_info "========================================"
log_info "Deployment completed successfully"
