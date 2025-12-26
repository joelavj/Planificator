#!/bin/bash

# Script pour migrer les prints et loggers vers le nouveau système LoggingService
# Usage: bash migrate_logging.sh

echo "🔄 Migration du système de logging vers LoggingService..."

# Répertoire cible (lib)
TARGET_DIR="lib"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
PRINT_COUNT=0
LOGGER_COUNT=0

# 1. Ajouter l'import dans les fichiers sans import
echo -e "${YELLOW}1️⃣ Ajout des imports LoggingService...${NC}"
for file in $(find "$TARGET_DIR" -name "*.dart" -type f); do
  # Vérifier si le fichier contient print( ou logger mais pas l'import
  if (grep -q "print(" "$file" || grep -q "logger\." "$file") && ! grep -q "import.*logging_service" "$file"; then
    # Ajouter l'import après les autres imports
    sed -i "0,/^import/s/^import/import 'package:planificator\/services\/logging_service.dart';\nimport/" "$file"
    echo -e "${GREEN}✓${NC} Import ajouté à $file"
  fi
done

# 2. Migrer les prints simples
echo -e "${YELLOW}2️⃣ Migration des print()...${NC}"
for file in $(find "$TARGET_DIR" -name "*.dart" -type f | grep -v test); do
  if grep -q "print(" "$file"; then
    # Extraire le nom de la classe ou du fichier
    CLASS_NAME=$(grep -m1 "class\|void\|Future" "$file" | head -1 | sed 's/.*class \([^ {]*\).*/\1/' || echo "Unknown")
    
    # Remplacer print('message') par log.debug('message', source: 'ClassName')
    sed -i 's/print(\([^)]*\))/log.debug(\1, source: '"'"'$CLASS_NAME'"'"')/g' "$file"
    
    PRINT_COUNT=$((PRINT_COUNT + 1))
  fi
done

# 3. Migrer les logger.i
echo -e "${YELLOW}3️⃣ Migration des logger.i()...${NC}"
for file in $(find "$TARGET_DIR" -name "*.dart" -type f); do
  if grep -q "logger\.i(" "$file"; then
    sed -i 's/logger\.i(\([^)]*\))/log.info(\1, source: '"'"'${CLASS_NAME}'"'"')/g' "$file"
    LOGGER_COUNT=$((LOGGER_COUNT + 1))
  fi
done

# 4. Migrer les logger.w
for file in $(find "$TARGET_DIR" -name "*.dart" -type f); do
  if grep -q "logger\.w(" "$file"; then
    sed -i 's/logger\.w(\([^)]*\))/log.warning(\1, source: '"'"'${CLASS_NAME}'"'"')/g' "$file"
    LOGGER_COUNT=$((LOGGER_COUNT + 1))
  fi
done

# 5. Migrer les logger.e
for file in $(find "$TARGET_DIR" -name "*.dart" -type f); do
  if grep -q "logger\.e(" "$file"; then
    sed -i 's/logger\.e(\([^)]*\))/log.error(\1, source: '"'"'${CLASS_NAME}'"'"')/g' "$file"
    LOGGER_COUNT=$((LOGGER_COUNT + 1))
  fi
done

echo ""
echo -e "${GREEN}✅ Migration terminée!${NC}"
echo -e "  📝 ${GREEN}$PRINT_COUNT${NC} fichiers avec print() migrés"
echo -e "  📝 ${GREEN}$LOGGER_COUNT${NC} fichiers avec logger migrés"
echo ""
echo "📖 Consultez LOGGING_GUIDE.md pour les détails d'utilisation"
