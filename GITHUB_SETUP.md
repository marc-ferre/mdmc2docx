# Instructions pour publier mdmc2docx sur GitHub

## 🚀 Étapes pour créer le dépôt GitHub

### 1. Créer le dépôt sur GitHub.com

1. Allez sur [github.com](https://github.com) et connectez-vous
2. Cliquez sur le bouton **"New repository"** (ou le + en haut à droite → "New repository")
3. Remplissez les informations :
   - **Repository name:** `mdmc2docx`
   - **Description:** `Convertisseur MC (Multiple Choice) Markdown vers DOCX avec Pandoc`
   - **Visibility:** Public (recommandé) ou Private selon vos préférences
   - **❌ NE PAS** cocher "Add a README file" (nous en avons déjà un)
   - **❌ NE PAS** cocher "Add .gitignore" (nous en avons déjà un)
   - **❌ NE PAS** cocher "Choose a license" (nous avons déjà LICENSE)
4. Cliquez sur **"Create repository"**

### 2. Connecter votre dépôt local à GitHub

Après avoir créé le dépôt sur GitHub, exécutez ces commandes dans votre terminal :

```bash
# Aller dans le dossier du projet
cd /Users/marcferre/Documents/Enseignement/Outils/mdmc2docx

# Ajouter l'origine GitHub (remplacez YOUR_USERNAME par votre nom d'utilisateur GitHub)
git remote add origin https://github.com/YOUR_USERNAME/mdmc2docx.git

# Pousser le code vers GitHub
git branch -M main
git push -u origin main
```

### 3. Vérification

Une fois les commandes exécutées, votre projet sera visible sur :
`https://github.com/YOUR_USERNAME/mdmc2docx`

## 📋 Fonctionnalités GitHub recommandées

### Issues Templates

Créez des templates d'issues pour faciliter les contributions :

- Bug reports
- Feature requests  
- Questions

### GitHub Actions (CI/CD)

Ajoutez des tests automatiques sur chaque commit :

- Tests automatisés avec différentes versions de Perl
- Vérification de la syntaxe
- Tests sur différents OS (Ubuntu, macOS)

### Releases

Créez des releases avec tags pour chaque version :

```bash
git tag -a v2.1.0 -m "Release v2.1.0 - Renommage QCM → MC"
git push origin v2.1.0
```

## 🔧 Commandes Git utiles pour la suite

```bash
# Voir l'état du dépôt
git status

# Ajouter des modifications
git add .
git commit -m "Description des modifications"
git push

# Créer une nouvelle branche
git checkout -b nouvelle-fonctionnalite

# Voir l'historique
git log --oneline

# Voir les dépôts distants
git remote -v
```

## 📚 Ressources utiles

- [Documentation Git](https://git-scm.com/doc)
- [Guide GitHub](https://guides.github.com/)
- [Markdown Guide](https://www.markdownguide.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Prochaines étapes après publication :**

1. Ajouter des badges dans le README (version, license, etc.)
2. Configurer GitHub Actions pour les tests automatiques
3. Créer la première release v2.1.0
4. Inviter des collaborateurs si nécessaire
