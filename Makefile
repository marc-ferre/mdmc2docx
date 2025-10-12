# Makefile pour mdmc2docx.pl
# Simplifie les tâches courantes

.PHONY: help install test clean example run

# Configuration
SCRIPT_DIR = bin
SCRIPT_NAME = mdmc2docx.pl
SCRIPT_PATH = $(SCRIPT_DIR)/$(SCRIPT_NAME)
EXAMPLES_DIR = examples
TESTS_DIR = tests
CONFIG_DIR = config

help:
	@echo "MC md2docx - Commandes disponibles:"
	@echo ""
	@echo "  make install    - Installer et configurer l'environnement"
	@echo "  make test       - Lancer les tests automatisés"
	@echo "  make example    - Convertir l'exemple fourni"
	@echo "  make clean      - Nettoyer les fichiers temporaires"
	@echo "  make run FILE=<fichier.md> - Convertir un fichier spécifique"
	@echo ""
	@echo "Exemples d'usage:"
	@echo "  make example"
	@echo "  make run FILE=mon_mc.md"
	@echo "  make run FILE=mon_mc.md OPTS='--fid 10 --verbose'"

install:
	@echo "🔧 Installation et configuration..."
	@chmod +x $(SCRIPT_PATH)
	@chmod +x $(TESTS_DIR)/run_tests.sh
	@chmod +x install.sh
	@./install.sh

test:
	@echo "🧪 Lancement des tests..."
	@$(TESTS_DIR)/run_tests.sh

.PHONY: test-md-spacing
test-md-spacing:
	@echo "🧪 Vérification de l'espacement des questions (md spacing)..."
	@$(TESTS_DIR)/check_spacing.sh

example:
	@echo "📝 Conversion de l'exemple..."
	@if [ -f "$(EXAMPLES_DIR)/exemple_mc.md" ]; then \
		cd $(EXAMPLES_DIR) && ../$(SCRIPT_PATH) --verbose exemple_mc.md; \
		echo "✅ Fichier généré: $(EXAMPLES_DIR)/exemple_mc.docx"; \
	else \
		echo "❌ Fichier d'exemple introuvable"; \
	fi

run:
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Usage: make run FILE=<fichier.md> [OPTS='--verbose --fid 5']"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "❌ Fichier introuvable: $(FILE)"; \
		exit 1; \
	fi
	@echo "🔄 Conversion de $(FILE)..."
	@$(SCRIPT_PATH) $(OPTS) "$(FILE)"

clean:
	@echo "🧹 Nettoyage des fichiers temporaires..."
	@find . -name "*.md4docx" -delete
	@find . -name "*.docx" -path "./$(EXAMPLES_DIR)/*" -delete
	@echo "✅ Nettoyage terminé"

# Commandes de développement
dev-test:
	@echo "🔧 Test en mode développement..."
	@$(SCRIPT_PATH) --verbose --keep $(EXAMPLES_DIR)/exemple_mc.md

dev-clean:
	@echo "🧹 Nettoyage complet..."
	@find . -name "*.docx" -delete
	@find . -name "*.md4docx" -delete

info:
	@echo "📋 Informations sur le projet:"
	@echo "   Script principal: $(SCRIPT_PATH)"
	@echo "   Exemples: $(EXAMPLES_DIR)/"
	@echo "   Tests: $(TESTS_DIR)/"
	@echo "   Configuration: $(CONFIG_DIR)/"
	@echo ""
	@echo "📊 Statistiques:"
	@echo "   Exemples disponibles: $$(ls -1 $(EXAMPLES_DIR)/*.md 2>/dev/null | wc -l | tr -d ' ')"
	@echo "   Configurations: $$(ls -1 $(CONFIG_DIR)/*.json 2>/dev/null | wc -l | tr -d ' ')"
	@echo ""
	@echo "🔧 Prérequis:"
	@which perl >/dev/null && echo "   ✅ Perl: $$(perl --version | grep -o 'v[0-9.]*' | head -1)" || echo "   ❌ Perl non trouvé"
	@which pandoc >/dev/null && echo "   ✅ Pandoc: $$(pandoc --version | head -1 | awk '{print $$2}')" || echo "   ❌ Pandoc non trouvé"