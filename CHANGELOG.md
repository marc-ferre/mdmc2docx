# Changelog - MC Markdown vers DOCX

Toutes les modifications importantes de ce projet sont documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.1.1] - 2025-10-12

### ✨ Ajouté

- 🎯 **Gestion intelligente du nombre de propositions** :
  - **4 propositions** : Ajoute automatiquement l'option "Aucune des propositions ci-dessus n'est exacte"
  - **5 propositions** : Utilise seulement les 5 propositions (pas d'option "Aucune")
  - **< 4 ou > 5 propositions** : Génère une erreur avec message explicite et numéro de ligne
- ✅ **Nouveaux tests automatisés** (maintenant 8 tests au total) :
  - Test 7: Validation MC avec 5 propositions (vérification absence completemulti_string)
  - Test 8: Validation erreur avec nombre invalide de propositions
- 📖 **Documentation enrichie** :
  - Section dédiée "🔢 Gestion des propositions" dans le README
  - Exemples concrets avec code pour 4 et 5 propositions
  - Badges professionnels GitHub dans le README
- 📄 **Nouveaux fichiers exemples** :
  - `examples/exemple_mc_5prop.md` : 3 questions avec 5 propositions chacune
  - `examples/exemple_mc_invalide.md` : Exemple pour tester validation d'erreur

### 🔧 Modifié

- **Logique de validation** : Remplace validation fixe par validation flexible 4-5 propositions
- **Architecture du code** :
  - Nouvelle fonction `output_question_and_answers_no_completemulti()` pour questions à 5 propositions
  - Logique conditionnelle dans `process_end_answers()` selon le nombre de propositions
  - Messages d'erreur améliorés avec numéros de ligne précis
- **Configuration** : Mise à jour `config/default.json` avec note explicative sur la nouvelle logique

## [2.1.0] - 2025-10-12

### ✨ Première release publique

- 🎉 **Publication GitHub officielle** avec release v2.1.0
- 🔄 **CI/CD complet** : GitHub Actions, tests sur Ubuntu/macOS, Perl 5.20/5.30/5.32
- 📋 **Templates GitHub** : Issues (bugs/features), guide de contribution
- 📝 **Documentation professionnelle** : README complet, badges, exemples
- 📄 **Licence MIT** et fichiers de gouvernance open source

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
