#!/bin/bash

# Script d'installation et de configuration pour mdmc2docx.pl
# Vérifie les prérequis et configure l'environnement

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}=== Installation MC md2docx ===${NC}"
echo "Répertoire: $SCRIPT_DIR"
echo

# Fonction de vérification
check_command() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $name trouvé: $(command -v "$cmd")${NC}"
        return 0
    else
        echo -e "${RED}❌ $name non trouvé${NC}"
        return 1
    fi
}

# Vérification de Perl
echo -e "${YELLOW}Vérification de Perl...${NC}"
if check_command "perl" "Perl"; then
    perl_version=$(perl -v | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    echo "   Version: $perl_version"
else
    echo -e "${RED}Perl est requis. Installez-le avec Homebrew: brew install perl${NC}"
    exit 1
fi

# Vérification de Pandoc
echo
echo -e "${YELLOW}Vérification de Pandoc...${NC}"
if check_command "pandoc" "Pandoc"; then
    pandoc_version=$(pandoc --version | head -1 | awk '{print $2}')
    echo "   Version: $pandoc_version"
    
    # Vérification de la version minimale
    required_version="1.12"
    if [[ $(echo -e "$pandoc_version\n$required_version" | sort -V | head -1) == "$required_version" ]]; then
        echo -e "${GREEN}   ✅ Version suffisante (>= $required_version)${NC}"
    else
        echo -e "${YELLOW}   ⚠️ Version potentiellement ancienne${NC}"
    fi
else
    echo -e "${RED}Pandoc est requis. Installez-le:${NC}"
    echo "   - macOS: brew install pandoc"
    echo "   - Site officiel: https://pandoc.org/installing.html"
    exit 1
fi

# Vérification des modules Perl
echo
echo -e "${YELLOW}Vérification des modules Perl...${NC}"

check_perl_module() {
    local module="$1"
    local optional="$2"
    
    if perl -e "use $module; print '$module OK\n'" 2>/dev/null; then
        echo -e "${GREEN}✅ $module${NC}"
        return 0
    else
        if [[ "$optional" == "optional" ]]; then
            echo -e "${YELLOW}⚠️ $module (optionnel)${NC}"
            return 0
        else
            echo -e "${RED}❌ $module${NC}"
            return 1
        fi
    fi
}

modules_ok=true

if ! check_perl_module "Pandoc"; then
    echo -e "${RED}   Module Pandoc manquant. Installez avec: cpan Pandoc${NC}"
    modules_ok=false
fi

if ! check_perl_module "Getopt::Long"; then
    echo -e "${RED}   Module Getopt::Long manquant (normalement inclus)${NC}"
    modules_ok=false
fi

if ! check_perl_module "File::Basename"; then
    echo -e "${RED}   Module File::Basename manquant (normalement inclus)${NC}"
    modules_ok=false
fi

check_perl_module "JSON::PP" "optional"

if ! $modules_ok; then
    echo
    echo -e "${RED}Modules Perl manquants. Installez-les avec:${NC}"
    echo "   cpan Pandoc JSON::PP"
    exit 1
fi

# Configuration des permissions
echo
echo -e "${YELLOW}Configuration des permissions...${NC}"
chmod +x "$SCRIPT_DIR/bin/mdmc2docx.pl"
chmod +x "$SCRIPT_DIR/tests/run_tests.sh"
echo -e "${GREEN}✅ Permissions configurées${NC}"

# Création du lien symbolique optionnel
echo
echo -e "${YELLOW}Configuration du PATH (optionnel)...${NC}"
read -r -p "Créer un lien symbolique dans /usr/local/bin? (y/N): " create_link

if [[ $create_link == "y" || $create_link == "Y" ]]; then
    if sudo ln -sf "$SCRIPT_DIR/bin/mdmc2docx.pl" /usr/local/bin/mdmc2docx 2>/dev/null; then
        echo -e "${GREEN}✅ Lien créé: /usr/local/bin/mdmc2docx${NC}"
        echo "   Vous pouvez maintenant utiliser 'mdmc2docx' depuis n'importe où"
    else
        echo -e "${YELLOW}⚠️ Impossible de créer le lien (permissions?)${NC}"
    fi
fi

# Tests rapides
echo
echo -e "${YELLOW}Tests rapides...${NC}"
if "$SCRIPT_DIR/bin/mdmc2docx.pl" --help >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Script fonctionnel${NC}"
else
    echo -e "${RED}❌ Problème avec le script${NC}"
    exit 1
fi

# Récapitulatif
echo
echo -e "${GREEN}=== Installation terminée ===${NC}"
echo
echo "📁 Répertoire du projet: $SCRIPT_DIR"
echo "🔧 Script principal: $SCRIPT_DIR/bin/mdmc2docx.pl"
echo "📖 Exemples: $SCRIPT_DIR/examples/"
echo "⚙️ Configuration: $SCRIPT_DIR/config/"
echo "🧪 Tests: $SCRIPT_DIR/tests/run_tests.sh"
echo
echo -e "${BLUE}Prochaines étapes:${NC}"
echo "1. Testez avec: cd $SCRIPT_DIR && ./tests/run_tests.sh"
echo "2. Utilisez avec: ./bin/mdmc2docx.pl --help"
echo "3. Consultez les exemples dans examples/"
echo

echo -e "${GREEN}🎉 Installation réussie !${NC}"