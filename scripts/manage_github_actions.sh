#!/bin/bash

# Script pour désactiver/réactiver temporairement les GitHub Actions

REPO="marc-ferre/mdmc2docx"
TOKEN="YOUR_GITHUB_TOKEN_HERE"

if [ "$TOKEN" == "YOUR_GITHUB_TOKEN_HERE" ]; then
    echo "❌ Veuillez configurer votre token GitHub"
    exit 1
fi

case "$1" in
    "disable")
        echo "🔕 Désactivation des GitHub Actions..."
        curl -X PUT -H "Authorization: token $TOKEN" \
          "https://api.github.com/repos/$REPO/actions/permissions" \
          -d '{"enabled": false}'
        echo "✅ Actions désactivées"
        ;;
    "enable")
        echo "🔔 Réactivation des GitHub Actions..."
        curl -X PUT -H "Authorization: token $TOKEN" \
          "https://api.github.com/repos/$REPO/actions/permissions" \
          -d '{"enabled": true}'
        echo "✅ Actions réactivées"
        ;;
    *)
        echo "Usage: $0 [disable|enable]"
        echo "  disable  - Désactive les GitHub Actions"
        echo "  enable   - Réactive les GitHub Actions"
        ;;
esac