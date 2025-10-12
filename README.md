# MC Markdown vers DOCX - Convertisseur optimisé

[![Tests](https://github.com/marc-ferre/mdmc2docx/workflows/Tests%20automatisés/badge.svg)](https://github.com/marc-ferre/mdmc2docx/actions)
[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://github.com/marc-ferre/mdmc2docx/releases/tag/v2.1.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Perl](https://img.shields.io/badge/perl-5.10+-yellow.svg)](https://www.perl.org/)
[![Pandoc](https://img.shields.io/badge/pandoc-1.12+-orange.svg)](https://pandoc.org/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)](README.md#prérequis)

Un outil en Perl pour convertir des fichiers MC (Questionnaires à Choix Multiples) au format Markdown modifié vers des documents Word DOCX via Pandoc.

## 🚀 Fonctionnalités

- ✅ **Conversion Markdown → DOCX** avec mise en forme automatique
- ✅ **Gestion intelligente des propositions** : 4 propositions (+ option "Aucune"), 5 propositions (sans option "Aucune")
- ✅ **Validation stricte** : Erreur si < 4 ou > 5 propositions par question
- ✅ **Gestion robuste des erreurs** avec numéros de ligne
- ✅ **Mode verbeux** pour le débogage
- ✅ **Configuration flexible** via fichiers JSON
- ✅ **Numérotation personnalisable** des questions
- ✅ **Style DOCX personnalisé** avec fichier de référence
- ✅ **Tests automatisés** inclus (8 tests complets)
- ✅ **Documentation complète** et exemples

## 📋 Prérequis

- **Perl** 5.10 ou supérieur
- **Pandoc** 1.12 ou supérieur
- **Modules Perl** :
  - `Pandoc` (obligatoire)
  - `JSON::PP` (optionnel, pour la configuration JSON)
  - `Getopt::Long`, `File::Basename` (généralement inclus)

## 🛠️ Installation

### Installation automatique

```bash
cd mdmc2docx
./install.sh
```

### Installation manuelle

```bash
# Vérifier Pandoc
pandoc --version

# Installer les modules Perl
cpan Pandoc JSON::PP

# Rendre le script exécutable
chmod +x bin/mdmc2docx.pl
```

## 🎯 Utilisation

### Usage basique

```bash
# Conversion simple
./bin/mdmc2docx.pl mon_qcm.md

# Avec mode verbeux
./bin/mdmc2docx.pl --verbose mon_qcm.md

# Numérotation personnalisée (commencer à 10)
./bin/mdmc2docx.pl --fid 10 mon_qcm.md
```

### Options avancées

```bash
# Conservation du fichier temporaire
./bin/mdmc2docx.pl --keep mon_qcm.md

# Configuration personnalisée
./bin/mdmc2docx.pl --config config/ma_config.json mon_qcm.md

# Fichier de référence DOCX personnalisé
./bin/mdmc2docx.pl --ref mon_style.docx mon_qcm.md

# Police et taille personnalisées
./bin/mdmc2docx.pl --font Arial --fontsize 10 mon_qcm.md

# Configuration Arial 10 prédéfinie
./bin/mdmc2docx.pl --config arial10.json mon_qcm.md

# Toutes les options combinées
./bin/mdmc2docx.pl --verbose --fid 5 --keep --font Times --fontsize 12 mon_qcm.md
```

### Aide complète

```bash
./bin/mdmc2docx.pl --help
```

## 📝 Format Markdown attendu

```markdown
# Titre du MC (optionnel)

## [question-id-1]
### Énoncé de la première question
+ Réponse correcte
- Réponse incorrecte
+ Autre réponse correcte
- Autre réponse incorrecte

## [question-id-2]
### Énoncé de la deuxième question
Contexte additionnel ou explications
+ Bonne réponse
- Mauvaise réponse
- Autre mauvaise réponse
- Encore une mauvaise réponse

```

### Règles importantes

1. **ID des questions** : Format `## [identifiant]`
2. **Énoncé** : Format `### Texte de la question`
3. **Réponses** : `+` pour correcte, `-` pour incorrecte
4. **Séparation** : Ligne vide entre chaque question

## 🔢 Gestion des propositions

Le convertisseur gère intelligemment le nombre de propositions par question :

### 4 propositions + option "Aucune"

```markdown
## [Q001]
### Question avec 4 choix ?
+ Bonne réponse
- Mauvaise réponse 1
- Mauvaise réponse 2  
- Mauvaise réponse 3
```

**Résultat :** Les 4 propositions + automatiquement "Aucune des propositions ci-dessus n'est exacte"

### 5 propositions (complet)

```markdown
## [Q002]
### Question avec 5 choix ?
+ Bonne réponse 1
+ Bonne réponse 2
- Mauvaise réponse 1
- Mauvaise réponse 2
- Mauvaise réponse 3
```

**Résultat :** Seulement les 5 propositions (pas d'option "Aucune")

### Validation stricte

- ✅ **4 propositions** : Valide (+ option "Aucune" ajoutée)
- ✅ **5 propositions** : Valide (aucune option ajoutée)  
- ❌ **< 4 ou > 5** : Erreur avec message explicite

## ⚙️ Configuration

### Fichier de configuration JSON

Créez un fichier JSON pour personnaliser le comportement :

```json
{
    "prequestion_string": "**Choisissez la ou les bonnes réponses :**",
    "completemulti_string": "Aucune proposition n'est correcte",
    "a_bullet": "   • ",
    "ref_path": "/chemin/vers/mon-style.docx",
    "expected_answers": 4
}
```

### Configuration par défaut

- **Texte de pré-question** : "Parmi les propositions suivantes, laquelle (lesquelles) est (sont) exacte(s) ?"
- **Option finale** : "Aucune des propositions ci-dessus n'est exacte."
- **Puce réponses** : "   A.  "
- **Nombre de réponses** : 4 par question

## 🔤 Gestion des polices

### Méthodes pour définir la police

**1. Via les options de ligne de commande (recommandé pour tests)**

```bash
# Arial 10pt
./bin/mdmc2docx.pl --font Arial --fontsize 10 mon_qcm.md

# Times New Roman 12pt  
./bin/mdmc2docx.pl --font "Times New Roman" --fontsize 12 mon_qcm.md

# Calibri 11pt
./bin/mdmc2docx.pl --font Calibri --fontsize 11 mon_qcm.md
```

**2. Via un fichier de référence DOCX (recommandé pour production)**

```bash
# Utilise le style défini dans le fichier DOCX
./bin/mdmc2docx.pl --ref styles/reference_MC_Arial10.docx mon_qcm.md

# Configuration Arial 10 prédéfinie
./bin/mdmc2docx.pl --config arial10.json mon_qcm.md
```

**3. Via configuration JSON**

```json
{
    "font_settings": {
        "main_font": "Arial",
        "font_size": 10,
        "use_font_variables": true
    },
    "ref_path": "styles/reference_MC_Arial10.docx"
}
```

### Polices recommandées pour l'enseignement

- **Arial 10-11pt** : Excellent pour la lisibilité, standard universitaire
- **Calibri 11pt** : Police Microsoft moderne, très lisible
- **Times New Roman 11-12pt** : Standard académique traditionnel
- **Verdana 10pt** : Très lisible à l'écran et à l'impression

### Priorité des paramètres

1. Fichier de référence DOCX (`--ref`) - **Priorité HAUTE**
2. Options ligne de commande (`--font`, `--fontsize`)
3. Configuration JSON (`font_settings`)
4. Style par défaut Pandoc - **Priorité BASSE**

## 🧪 Tests

### Lancer les tests automatisés

```bash
./tests/run_tests.sh
```

### Tests inclus

- ✅ Affichage de l'aide
- ✅ Conversion basique
- ✅ Numérotation personnalisée
- ✅ Conservation fichier temporaire
- ✅ Configuration JSON
- ✅ Gestion d'erreurs

## 📁 Structure du projet

```
mdmc2docx/
├── bin/
│   └── mdmc2docx.pl      # Script principal
├── config/
│   └── default.json        # Configuration par défaut
├── examples/
│   └── exemple_mc.md      # Exemple de fichier MC
├── tests/
│   └── run_tests.sh        # Tests automatisés
├── install.sh              # Script d'installation
└── README.md               # Cette documentation
```

## 📊 Exemple de sortie

### Fichier d'entrée (`exemple.md`)

```markdown
## [evolution]
### Selon la théorie de l'évolution :
+ Les espèces évoluent au fil du temps
- Toutes les espèces sont immuables
+ L'adaptation est un processus continu
- L'évolution s'arrête après création
```

### Fichier de sortie (format DOCX)

```
1. Parmi les propositions suivantes, laquelle (lesquelles) est (sont) exacte(s) ?
Selon la théorie de l'évolution :

   A.  > Les espèces évoluent au fil du temps
   A.  Toutes les espèces sont immuables  
   A.  > L'adaptation est un processus continu
   A.  L'évolution s'arrête après création
   A.  Aucune des propositions ci-dessus n'est exacte.
```

## 🔧 Dépannage

### Erreurs courantes

**"pandoc executable not found"**

```bash
# Installer Pandoc
brew install pandoc  # macOS
# ou télécharger depuis https://pandoc.org
```

**"Module Pandoc not found"**

```bash
cpan Pandoc
```

**"4 réponses attendues, X trouvées"**

- Vérifier que chaque question a exactement 4 réponses
- S'assurer que les réponses commencent par `+` ou `-`

**"Fichier de référence introuvable"**

- Vérifier le chemin dans la configuration
- Le script fonctionne sans fichier de référence (style par défaut)

### Mode débogage

```bash
# Mode verbeux pour voir les détails
./bin/mdmc2docx.pl --verbose --keep mon_qcm.md

# Examiner le fichier temporaire généré
cat mon_qcm.md4docx
```

## 📈 Statistiques d'exécution

Le mode verbeux affiche :

- Nombre de questions traitées
- Nombre de réponses analysées  
- Avertissements éventuels
- Fichiers générés et leurs tailles

## 🤝 Contribution

1. **Tests** : Lancez `./tests/run_tests.sh` avant modification
2. **Documentation** : Mettez à jour ce README pour les nouvelles fonctionnalités
3. **Exemples** : Ajoutez des exemples dans `examples/`
4. **Configuration** : Documentez les nouvelles options de configuration

## 📄 Licence

© Marc FERRE - Université d'Angers - Tous droits réservés

## 🔗 Liens utiles

- [Documentation Pandoc](https://pandoc.org/MANUAL.html)
- [Format Markdown](https://www.markdownguide.org/)
- [Modules Perl CPAN](https://metacpan.org/)

---

*Dernière mise à jour : Octobre 2025*
