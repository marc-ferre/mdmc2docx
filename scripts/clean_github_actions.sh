#!/bin/bash

# Script pour nettoyer les GitHub Actions échouées
# Nécessite un token GitHub avec les permissions repo et actions

REPO="marc-ferre/mdmc2docx"
TOKEN="YOUR_GITHUB_TOKEN_HERE"

echo "🧹 Nettoyage des GitHub Actions pour $REPO"

if [ "$TOKEN" == "YOUR_GITHUB_TOKEN_HERE" ]; then
    echo "❌ Veuillez configurer votre token GitHub dans le script"
    echo "1. Allez sur https://github.com/settings/tokens"
    echo "2. Créez un token avec les scopes 'repo' et 'actions'"
    echo "3. Remplacez YOUR_GITHUB_TOKEN_HERE par votre token"
    exit 1
fi

# Obtenir tous les runs de workflow
echo "📋 Récupération des workflows runs..."
RUNS=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs?per_page=100" | \
  jq -r '.workflow_runs[] | select(.conclusion == "failure" or .conclusion == "cancelled") | .id')

if [ -z "$RUNS" ]; then
    echo "✅ Aucun run échoué à supprimer"
    exit 0
fi

echo "🔍 Runs échoués trouvés:"
echo "$RUNS"

read -p "Voulez-vous supprimer ces runs ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️ Suppression en cours..."
    
    for run_id in $RUNS; do
        echo "  Suppression du run $run_id..."
        curl -s -X DELETE -H "Authorization: token $TOKEN" \
          "https://api.github.com/repos/$REPO/actions/runs/$run_id" > /dev/null
        
        if [ $? -eq 0 ]; then
            echo "    ✅ Run $run_id supprimé"
        else
            echo "    ❌ Erreur lors de la suppression du run $run_id"
        fi
        
        # Pause pour éviter le rate limiting
        sleep 1
    done
    
    echo "🎉 Nettoyage terminé !"
else
    echo "❌ Suppression annulée"
fi