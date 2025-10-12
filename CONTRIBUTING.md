# Guide de Contribution

Merci de votre intérêt pour contribuer à mdmc2docx !

## 🚀 Comment contribuer

### 🐛 Signaler un bug

1. Vérifiez que le bug n'a pas déjà été signalé dans les [Issues](../../issues)
2. Créez une nouvelle issue avec le template "Bug report"
3. Incluez :
   - Version de mdmc2docx (`cat VERSION`)
   - Version de Pandoc (`pandoc --version`)
   - Système d'exploitation
   - Fichier MC d'exemple qui pose problème (si possible)
   - Message d'erreur complet

### ✨ Proposer une fonctionnalité

1. Créez une issue avec le template "Feature request"
2. Décrivez clairement le besoin et l'usage prévu
3. Proposez une implémentation si possible

### 🔧 Proposer du code

1. **Fork** le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/ma-fonctionnalite`)
3. Effectuez vos modifications
4. **Testez** vos changements :

   ```bash
   make test
   make example
   ```

5. Committez vos modifications (`git commit -am 'Ajout de ma fonctionnalité'`)
6. Poussez vers votre branche (`git push origin feature/ma-fonctionnalite`)
7. Créez une **Pull Request**

## 📋 Standards de code

### Style Perl

- Utilisez `strict` et `warnings`
- Indentation : 4 espaces
- Commentaires en français pour ce projet
- Documentation POD pour les fonctions principales

### Tests

- Tous les tests doivent passer : `make test`
- Ajoutez des tests pour les nouvelles fonctionnalités
- Testez sur différents types de fichiers MC

### Documentation

- Mettez à jour le README.md si nécessaire
- Ajoutez une entrée dans CHANGELOG.md
- Documentez les nouvelles options dans l'aide (`--help`)

## 🧪 Tests

```bash
# Tests automatisés
make test

# Test sur un fichier spécifique
make run FILE=mon_test.md OPTS="--verbose"

# Nettoyage
make clean
```

## 📝 Structure du projet

```
mdmc2docx/
├── bin/mdmc2docx.pl        # Script principal
├── config/default.json    # Configuration par défaut  
├── examples/exemple_mc.md  # Exemple de fichier MC
├── tests/run_tests.sh      # Suite de tests
├── Makefile               # Commandes de développement
└── README.md              # Documentation principale
```

## 🤝 Code de conduite

- Soyez respectueux et constructif
- Utilisez un langage inclusif
- Concentrez-vous sur la résolution des problèmes
- Aidez les nouveaux contributeurs

## 📞 Contact

Pour toute question, n'hésitez pas à :

- Ouvrir une issue sur GitHub
- Contacter Marc FERRE (Université d'Angers)

Merci pour votre contribution ! 🙏
