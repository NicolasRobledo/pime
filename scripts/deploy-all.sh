#!/bin/bash

# Script para desplegar todo (migraciones + stored procedures)
# Uso: ./deploy-all.sh [dev|test|prod]

set -e

ENVIRONMENT=${1:-dev}

echo "=========================================="
echo "  PIME Database Deployment"
echo "  Environment: $ENVIRONMENT"
echo "=========================================="
echo ""

# Aplicar migraciones
echo "Step 1: Applying migrations..."
./scripts/apply-migrations.sh "$ENVIRONMENT"
echo ""

# Desplegar stored procedures
echo "Step 2: Deploying stored procedures, functions, and triggers..."
./scripts/deploy-procedures.sh "$ENVIRONMENT"
echo ""

# Aplicar seeds si es dev o test
if [ "$ENVIRONMENT" = "dev" ] || [ "$ENVIRONMENT" = "test" ]; then
    echo "Step 3: Applying seed data..."
    ./scripts/apply-seeds.sh "$ENVIRONMENT"
    echo ""
fi

echo "=========================================="
echo "  Deployment completed successfully!"
echo "=========================================="
