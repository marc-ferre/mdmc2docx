#!/bin/bash

# Script de test pour mdmc2docx.pl
# Tests automatisés du convertisseur MC

set -e  # Arrêt en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Chemin vers le script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT_PATH="$PROJECT_DIR/bin/mdmc2docx.pl"
EXAMPLES_DIR="$PROJECT_DIR/examples"
CONFIG_DIR="$PROJECT_DIR/config"

echo -e "${BLUE}=== Tests du convertisseur MC md2docx ===${NC}"
echo "Répertoire du projet: $PROJECT_DIR"
echo

# Fonction pour afficher les résultats des tests
print_test_result() {
    local test_name="$1"
    local result="$2"
    
    if [[ $result -eq 0 ]]; then
        echo -e "${GREEN}✅ $test_name${NC}"
    else
        echo -e "${RED}❌ $test_name${NC}"
        return 1
    fi
}

# Vérification que le script existe
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo -e "${RED}❌ Erreur: Script $SCRIPT_PATH introuvable${NC}"
    exit 1
fi

# Rendre le script exécutable
chmod +x "$SCRIPT_PATH"

# Compteur de tests
test_count=0
passed_count=0

# Test 1: Aide
echo -e "${YELLOW}Test 1: Affichage de l'aide${NC}"
((test_count++))
if "$SCRIPT_PATH" --help > /dev/null 2>&1; then
    ((passed_count++))
    print_test_result "Aide"
else
    print_test_result "Aide" 1
fi
echo

# Test 2: Conversion basique avec fichier d'exemple
echo -e "${YELLOW}Test 2: Conversion basique${NC}"
((test_count++))
if [[ -f "$EXAMPLES_DIR/exemple_mc.md" ]]; then
    cd "$EXAMPLES_DIR"
    if "$SCRIPT_PATH" --verbose exemple_mc.md > /dev/null 2>&1 && [[ -f "exemple_mc.docx" ]]; then
        ((passed_count++))
        print_test_result "Conversion basique"
        echo "   📄 Fichier généré: $(ls -lh exemple_mc.docx | awk '{print $5}')"
    else
        print_test_result "Conversion basique" 1
    fi
else
    echo -e "${RED}⚠️ Fichier d'exemple introuvable${NC}"
fi
echo

# Test 3: Numérotation personnalisée
echo -e "${YELLOW}Test 3: Numérotation personnalisée (--fid 10)${NC}"
((test_count++))
if [[ -f "$EXAMPLES_DIR/exemple_mc.md" ]]; then
    cd "$EXAMPLES_DIR"
    if "$SCRIPT_PATH" --fid 10 --verbose exemple_mc.md > /dev/null 2>&1; then
        ((passed_count++))
        print_test_result "Numérotation personnalisée"
    else
        print_test_result "Numérotation personnalisée" 1
    fi
fi
echo

# Test 4: Conservation fichier temporaire
echo -e "${YELLOW}Test 4: Conservation du fichier temporaire${NC}"
((test_count++))
if [[ -f "$EXAMPLES_DIR/exemple_mc.md" ]]; then
    cd "$EXAMPLES_DIR"
    if "$SCRIPT_PATH" --keep --verbose exemple_mc.md > /dev/null 2>&1 && [[ -f "exemple_mc.md4docx" ]]; then
        ((passed_count++))
        print_test_result "Conservation fichier temporaire"
        echo "   📝 Aperçu du fichier temporaire:"
        head -10 "exemple_mc.md4docx" | sed 's/^/      /'
    else
        print_test_result "Conservation fichier temporaire" 1
    fi
fi
echo

# Test 5: Fichier de configuration
echo -e "${YELLOW}Test 5: Configuration personnalisée${NC}"
((test_count++))
if [[ -f "$CONFIG_DIR/default.json" && -f "$EXAMPLES_DIR/exemple_mc.md" ]]; then
    cd "$EXAMPLES_DIR"
    if "$SCRIPT_PATH" --config ../config/default.json --verbose exemple_mc.md > /dev/null 2>&1; then
        ((passed_count++))
        print_test_result "Configuration personnalisée"
    else
        print_test_result "Configuration personnalisée" 1
    fi
fi
echo

# Test 6: Gestion d'erreur (fichier inexistant)
echo -e "${YELLOW}Test 6: Gestion d'erreur (fichier inexistant)${NC}"
((test_count++))
cd "$EXAMPLES_DIR"
if ! "$SCRIPT_PATH" fichier_inexistant.md > /dev/null 2>&1; then
    ((passed_count++))
    print_test_result "Gestion d'erreur"
else
    print_test_result "Gestion d'erreur" 1
fi
echo

# Test 7: MC avec 5 propositions (sans completemulti_string)
echo -e "${YELLOW}Test 7: MC avec 5 propositions${NC}"
((test_count++))
if [[ -f "$EXAMPLES_DIR/exemple_mc_5prop.md" ]]; then
    cd "$EXAMPLES_DIR"
    if "$SCRIPT_PATH" --keep --verbose exemple_mc_5prop.md > /dev/null 2>&1 && [[ -f "exemple_mc_5prop.md4docx" ]]; then
        # Vérifier qu'il n'y a PAS de "Aucune des propositions" dans le fichier généré
        if ! grep -q "Aucune des propositions" exemple_mc_5prop.md4docx; then
            ((passed_count++))
            print_test_result "MC avec 5 propositions"
        else
            print_test_result "MC avec 5 propositions" 1
        fi
    else
        print_test_result "MC avec 5 propositions" 1
    fi
else
    echo -e "${RED}⚠️ Fichier exemple_mc_5prop.md introuvable${NC}"
fi
echo

# Test 8: Erreur avec nombre invalide de propositions
echo -e "${YELLOW}Test 8: Erreur avec 3 propositions${NC}"
((test_count++))
if [[ -f "$EXAMPLES_DIR/exemple_mc_invalide.md" ]]; then
    cd "$EXAMPLES_DIR"
    # Le script doit échouer avec un message d'erreur spécifique
    if "$SCRIPT_PATH" exemple_mc_invalide.md > /dev/null 2>&1; then
        print_test_result "Erreur avec 3 propositions" 1
    else
        # Vérifier que l'erreur mentionne bien le nombre de propositions
        error_output=$("$SCRIPT_PATH" exemple_mc_invalide.md 2>&1 || true)
        if echo "$error_output" | grep -q "Nombre de propositions invalide"; then
            ((passed_count++))
            print_test_result "Erreur avec 3 propositions"
        else
            print_test_result "Erreur avec 3 propositions" 1
        fi
    fi
else
    echo -e "${RED}⚠️ Fichier exemple_mc_invalide.md introuvable${NC}"
fi
echo

# Résumé des tests
echo -e "${BLUE}=== Résumé des tests ===${NC}"
echo -e "Tests exécutés: ${test_count}"
echo -e "Tests réussis:  ${GREEN}${passed_count}${NC}"
echo -e "Tests échoués:  ${RED}$((test_count - passed_count))${NC}"

if [[ $passed_count -eq $test_count ]]; then
    echo -e "\n${GREEN}🎉 Tous les tests sont passés avec succès !${NC}"
    exit_code=0
else
    echo -e "\n${YELLOW}⚠️ Certains tests ont échoué${NC}"
    exit_code=1
fi

# Nettoyage optionnel
echo
read -p "Supprimer les fichiers de test générés? (y/N): " cleanup
if [[ $cleanup == "y" || $cleanup == "Y" ]]; then
    cd "$EXAMPLES_DIR"
    rm -f exemple_mc.docx exemple_mc.md4docx
    echo -e "${GREEN}🧹 Fichiers de test supprimés${NC}"
fi

echo -e "\n${BLUE}Tests terminés${NC}"
exit $exit_code