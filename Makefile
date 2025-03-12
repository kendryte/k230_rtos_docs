# Minimal Makefile for Sphinx documentation with multi-language and multi-version support

### Configurable Variables (override via command line or environment)
SPHINXOPTS          ?=
SPHINXBUILD         ?= sphinx-build
SPHINXMULTIVERSION  ?= sphinx-multiversion
WEB_DOCS_BUILDER_URL ?= https://ai.b-bug.org/~zhengshanshan/web-docs-builder

### Directory Structure
BUILDDIR            = _build
CONFDIR             = .
SOURCEDIR_EN        = en
SOURCEDIR_ZH        = zh

### Template and Static Files
WEB_FILES = \
	_static/init_mermaid.js \
	_static/mermaid.min.js \
	_static/topbar.css \
	_static/auto-nums.css \
	_static/custom-theme.css \
	_templates/versionsFlex.html \
	_templates/layout.html \
	_templates/Fleft.html \
	_templates/Footer.html \
	_templates/Fright.html \
	_templates/FleftEn.html \
	_templates/FooterEn.html \
	_templates/FrightEn.html

TEMPLATE_ZH = \
	_static/init_mermaid.js \
	_static/mermaid.min.js \
	_templates/versionsFlex.html \
	_templates/Fleft.html \
	_templates/Footer.html \
	_templates/Fright.html \
	_templates/layout.html \
	_static/topbar.css \
	_static/custom-theme.css \
    _static/auto-nums.css

TEMPLATE_EN = \
	_static/init_mermaid.js \
	_static/mermaid.min.js \
	_templates/versionsFlex.html \
	_templates/FleftEn.html \
	_templates/FooterEn.html \
	_templates/FrightEn.html \
	_templates/layout.html \
	_static/topbar.css \
	_static/custom-theme.css \
	_static/auto-nums.css

### Internal Variables
MKDIR_P = mkdir -p
WGET = wget -q

.PHONY: help html html-all html-en html-zh mhtml mhtml-en mhtml-zh clean clean-templates

# Default target - show help message
help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  html          Build single-version HTML for both languages"
	@echo "  html-en       Build English single-version HTML"
	@echo "  html-zh       Build Chinese single-version HTML"
	@echo "  mhtml         Build multi-version HTML for both languages"
	@echo "  mhtml-en      Build English multi-version HTML"
	@echo "  mhtml-zh      Build Chinese multi-version HTML"
	@echo "  clean         Remove build output"
	@echo "  clean-templates Remove downloaded templates and static files"

# Combined HTML build targets
html: html-en html-zh

html-en: $(TEMPLATE_EN)
	@SPHINX_LANGUAGE=en $(SPHINXBUILD) -b html "$(SOURCEDIR_EN)" "$(BUILDDIR)/html/en" -c "$(CONFDIR)"

html-zh: $(TEMPLATE_ZH)
	@SPHINX_LANGUAGE=zh_CN $(SPHINXBUILD) -b html "$(SOURCEDIR_ZH)" "$(BUILDDIR)/html/zh" -c "$(CONFDIR)"

# Multi-version HTML targets
mhtml: mhtml-en mhtml-zh

mhtml-en: $(TEMPLATE_EN)
	@SPHINX_LANGUAGE=en $(SPHINXMULTIVERSION) "$(SOURCEDIR_EN)" "$(BUILDDIR)/en" $(SPHINXOPTS) -c "$(CONFDIR)"

mhtml-zh: $(TEMPLATE_ZH)
	@SPHINX_LANGUAGE=zh_CN $(SPHINXMULTIVERSION) "$(SOURCEDIR_ZH)" "$(BUILDDIR)/zh" $(SPHINXOPTS) -c "$(CONFDIR)"

# File download infrastructure
_static _templates:
	@$(MKDIR_P) $@

$(WEB_FILES): | _static _templates
	@$(WGET) $(WEB_DOCS_BUILDER_URL)/$@ -O $@

# Cleanup targets
clean:
	@rm -rf "$(BUILDDIR)"

clean-templates:
	@rm -rf _static _templates

.DELETE_ON_ERROR:
.SILENT: _static _templates clean clean-templates
