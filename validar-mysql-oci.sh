#!/bin/bash

# ==========================================
# Validación de MySQL gestionado en OCI
# ==========================================
# Author: Rafael Vida
# Context: OCI + MySQL Architecture Validation
# ==========================================

# ==========================
# Configuración
# ==========================
COMPARTMENT_OCID="ocid1.compartment.oc1..xxxx"
MYSQL_DB_NAME="mysql-oci-prod"

echo "Validando MySQL gestionado en Oracle Cloud Infrastructure"
echo "----------------------------------------------------------"

# ==========================
# Obtener MySQL DB System
# ==========================
MYSQL_INFO=$(oci mysql db-system list \
  --compartment-id "$COMPARTMENT_OCID" \
  --query "data[?\"display-name\"=='$MYSQL_DB_NAME'] | [0]")

if [ -z "$MYSQL_INFO" ] || [ "$MYSQL_INFO" == "null" ]; then
  echo "❌ MySQL DB System no encontrado"
  exit 1
fi

ESTADO=$(echo "$MYSQL_INFO" | jq -r '.lifecycle-state')
CPU=$(echo "$MYSQL_INFO" | jq -r '.shape-name')
HA=$(echo "$MYSQL_INFO" | jq -r '.is-highly-available')
BACKUP_RETENTION=$(echo "$MYSQL_INFO" | jq -r '.backup-policy.retention-in-days')
ENDPOINT=$(echo "$MYSQL_INFO" | jq -r '.ip-address')

echo "MySQL DB System encontrado"
echo "Estado                 : $ESTADO"
echo "Shape / CPU            : $CPU"
echo "Alta disponibilidad    : $HA"
echo "Retención de backup    : $BACKUP_RETENTION días"
echo "Endpoint               : $ENDPOINT"

# ==========================
# Validaciones
# ==========================
if [ "$ESTADO" != "ACTIVE" ]; then
  echo "MySQL DB System no está operativo"
  exit 1
fi

if [ "$HA" != "true" ]; then
  echo "Alta disponibilidad NO habilitada"
else
  echo "Alta disponibilidad habilitada"
fi

if [ "$BACKUP_RETENTION" -lt 7 ]; then
  echo "Retención de backups inferior a 7 días"
else
  echo "Política de backups configurada correctamente"
fi

echo "Validación completada: MySQL gestionado correctamente en OCI"
``