# Changelog - MC Markdown vers DOCX

Toutes les modifications importantes de ce projet sont documentées dans ce fichier.

## [2.0.0] - 2025-10-12

### ✨ Nouvelles fonctionnalités

- **Restructuration complète** du projet en dossier organisé
- **Makefile** pour simplifier les commandes courantes
- **Script d'installation** automatisé avec vérification des prérequis
- **Tests automatisés** complets avec rapports colorés
- **Configuration JSON** flexible et extensible
- **Gestion d'erreurs robuste** avec contexte et numéros de ligne
- **Mode verbeux** avec logging horodaté
- **Documentation complète** avec exemples d'usage

### 🔧 Améliorations

- **Validation étendue** des fichiers d'entrée et permissions
- **Support UTF-8** explicite pour les caractères français
- **Architecture modulaire** avec fonctions séparées
- **Statistiques de traitement** détaillées
- **Chemins relatifs** pour une meilleure portabilité

### 📁 Structure du projet

```
mdmc2docx/
├── bin/mdmc2docx.pl      # Script principal optimisé
├── config/default.json     # Configuration par défaut
├── examples/exemple_qcm.md # Exemple fonctionnel
├── tests/run_tests.sh      # Suite de tests automatisés
├── install.sh              # Script d'installation
├── Makefile               # Commandes simplifiées
└── README.md              # Documentation complète
```

### 🧪 Tests

- ✅ 6 tests automatisés couvrant tous les cas d'usage
- ✅ Validation sur fichier réel de 28 questions (UE1 Examen 2)
- ✅ Gestion d'erreurs testée et validée

### 🎯 Compatibilité

- ✅ Pandoc 3.8 (testé)
- ✅ Perl v5.10+
- ✅ macOS (testé)
- ✅ Fichiers de référence DOCX personnalisés

## [1.0.0] - Version originale

### Fonctionnalités de base

- Conversion MC Markdown vers DOCX
- Support des réponses correctes/incorrectes (+/-)
- Numérotation des questions
- Formatage avec Pandoc

---

**Format des versions :** [MAJOR.MINOR.PATCH]

- **MAJOR** : Changements incompatibles
- **MINOR** : Nouvelles fonctionnalités compatibles  
- **PATCH** : Corrections de bugs
