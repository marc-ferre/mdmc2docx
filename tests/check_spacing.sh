#!/usr/bin/env bash
set -euo pipefail

# Test: Vérifie qu'une ligne vide sépare chaque question dans le fichier .md4docx
# Usage: tests/check_spacing.sh [input_md]

# Déterminer le répertoire du projet (parent du répertoire du script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

INPUT=${1:-examples/exemple_mc.md}
BASE=$(basename "$INPUT" .md)
MD4DOCX="examples/${BASE}.md4docx"

# Nettoyage possible d'anciens fichiers
rm -f "$MD4DOCX"

# Exécuter la conversion en gardant le fichier intermédiaire
./bin/mdmc2docx.pl --keep "$INPUT"

if [[ ! -f "$MD4DOCX" ]]; then
  echo "Fichier intermédiaire $MD4DOCX introuvable" >&2
  exit 2
fi

# Vérifier la présence d'une ligne vide entre chaque question
# On considère une question commençant par '**<num>.' (ex: **1.)
question_lines=()
while IFS= read -r num; do
  question_lines+=("$num")
done < <(grep -nE "^\*\*\s*[0-9]+\." "$MD4DOCX" | cut -d: -f1)

if [[ ${#question_lines[@]} -eq 0 ]]; then
  echo "Aucune question détectée dans $MD4DOCX" >&2
  exit 2
fi

# Pour chaque paire consécutive de positions, vérifier qu'il y a au moins
# une ligne vide entre la fin de la première question et le début de la suivante.
# Nous cherchons la première ligne vide après la position de la question courante

failures=0
for ((i=0; i<${#question_lines[@]}-1; i++)); do
  start=${question_lines[i]}
  next=${question_lines[i+1]}
  # Extraire le bloc entre start et next
  block=$(sed -n "${start},$((next-1))p" "$MD4DOCX")
  # Vérifier s'il existe une ligne vide dans ce bloc
  if ! echo "$block" | grep -q "^\s*$"; then
    echo "Erreur: pas de ligne vide entre question $((i+1)) (ligne $start) et question $((i+2)) (ligne $next)" >&2
    echo "Contexte:" >&2
    echo "$block" >&2
    failures=$((failures+1))
  fi
done

if [[ $failures -ne 0 ]]; then
  echo "Test échoué: $failures problème(s) détecté(s)" >&2
  exit 1
fi

# Si tout va bien
echo "Test OK: chaque question est séparée par au moins une ligne vide." 
exit 0
