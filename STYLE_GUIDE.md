# Guide de personnalisation du fichier de référence DOCX

## 🎯 Objectif
Le fichier `styles/reference_MC_Arial10.docx` définit l'apparence finale des documents convertis. Une fois personnalisé dans Word, tous les QCM utiliseront automatiquement ces styles.

## 🔧 Étapes de personnalisation

### 1. Ouvrir le fichier de référence
```bash
# Le fichier se trouve ici :
open styles/reference_MC_Arial10.docx
```

### 2. Modifier les styles dans Word

#### Style "Normal" (texte des réponses)
- **Police** : Arial 10pt
- **Interligne** : Simple (1.0)
- **Espacement** : 0pt avant/après
- **Alignement** : Justifié

#### Style "Heading 1" (numéros de questions)
- **Police** : Arial 12pt, Gras
- **Interligne** : Simple
- **Espacement** : 6pt avant, 3pt après
- **Alignement** : Gauche

#### Style "Heading 2" (énoncés de questions)  
- **Police** : Arial 10pt, Gras
- **Interligne** : Simple
- **Espacement** : 3pt avant/après
- **Alignement** : Gauche

#### Style "List Paragraph" (propositions A, B, C, D)
- **Police** : Arial 10pt
- **Interligne** : Simple
- **Retrait** : 0.6cm à gauche
- **Espacement** : 0pt avant/après

### 3. Paramètres de page recommandés

#### Marges
- **Haut/Bas** : 2.0 cm
- **Gauche/Droite** : 2.0 cm

#### Mise en page
- **Orientation** : Portrait
- **Taille** : A4
- **Colonnes** : 1

### 4. Sauvegarder
- **Format** : .docx (Word 2007+)
- **Nom** : Garder `reference_MC_Arial10.docx`

## ✅ Test du résultat

Après modification, tester avec :
```bash
./bin/mdmc2docx.pl --ref styles/reference_MC_Arial10.docx examples/exemple_mc.md
```

## 📝 Styles spéciaux pour QCM

### Mise en évidence des bonnes réponses
Si vous voulez que les bonnes réponses apparaissent différemment :

1. Créer un style "Réponse Correcte" :
   - **Police** : Arial 10pt, Gras
   - **Couleur** : Vert foncé (optionnel)
   - **Arrière-plan** : Jaune clair (optionnel)

2. Le script utilise déjà `> ` pour marquer les bonnes réponses

### Format recommandé final
```
1. Parmi les propositions suivantes, laquelle (lesquelles) est (sont) exacte(s) ?
Quelle est la capitale de la France ?

   A. > Paris                    [Style: Réponse Correcte]
   A. Lyon                       [Style: Normal]
   A. Marseille                  [Style: Normal] 
   A. Toulouse                   [Style: Normal]
   A. Aucune des propositions... [Style: Normal]
```

## 🔄 Modèles alternatifs

Vous pouvez créer plusieurs fichiers de référence :
- `reference_MC_Arial10.docx` : Standard universitaire
- `reference_MC_Times12.docx` : Format traditionnel
- `reference_MC_Exam.docx` : Format examens officiels

Usage :
```bash
./bin/mdmc2docx.pl --ref styles/reference_MC_Times12.docx examen.md
```