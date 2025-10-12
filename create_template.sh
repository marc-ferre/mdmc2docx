#!/bin/bash

# Script pour créer un template DOCX avec style de surlignage personnalisé

echo "🔧 Création du template DOCX avec style GoodAnswer..."

# Créer un fichier markdown de test
cat > /tmp/template_test.md << 'EOF'
# Template avec style personnalisé

## Exemples de formatage

Texte normal sans formatage.

[Texte avec style GoodAnswer - devrait être surligné]{custom-style="GoodAnswer"}

Autre texte normal.

### Test dans une liste

- Réponse normale
- [Bonne réponse]{custom-style="GoodAnswer"}  
- Autre réponse normale

EOF

# Générer le DOCX de base
echo "📄 Génération du fichier DOCX de base..."
pandoc /tmp/template_test.md -f markdown -t docx -o styles/reference_MC_Arial10_highlight.docx

echo "✅ Template créé : styles/reference_MC_Arial10_highlight.docx"
echo ""
echo "📝 Étapes suivantes :"
echo "1. Ouvrir styles/reference_MC_Arial10_highlight.docx dans Microsoft Word"
echo "2. Créer un nouveau style de caractère nommé 'GoodAnswer'"
echo "3. Définir ce style avec un surlignage jaune"
echo "4. Sauvegarder le fichier"
echo "5. Utiliser ce fichier comme référence dans le script"

# Nettoyer
rm /tmp/template_test.md