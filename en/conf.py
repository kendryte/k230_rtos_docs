# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import sys, os
import datetime

proj_root = os.getenv('PROJ_ROOT') or '.'

sys.path.append(os.path.abspath(proj_root + '/exts'))

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = os.getenv('PROJECT') or 'CanMV K230'
copyright = str(datetime.datetime.now().year) + ' ' + (os.getenv('COPYRIGHT') or 'Canaan Inc')
# author = os.getenv('AUTHOR') or 'Canaan'
# release = '0.1'
root_doc = os.getenv('ROOT_DOC') or 'index'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx_copybutton',
    'myst_parser',
    'sphinx_multiversion',
    'sphinxcontrib.mermaid'
]
html_js_files = [
    'mermaid.min.js',
    'init_mermaid.js',
]
source_suffix = {
   '.rst': 'restructuredtext',  
    '.md': 'markdown',
}
html_title = 'CanMV K230 RTOS Only'
templates_path = [proj_root + '/_templates']
exclude_patterns = ['.github/*', '.gitlab/*', '**/--*']

language = 'en'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

myst_heading_anchors = 6
suppress_warnings = ["myst.header"]

html_copy_source = True
html_show_sourcelink = False

html_favicon = 'favicon.ico'

# html_show_sphinx = False

# html_theme = 'alabaster'
html_theme = "sphinx_book_theme"
html_static_path = [proj_root + '/_static']

# if want to add top nav for canann, enable this.
html_css_files = ['topbar.css', 'custom-theme.css']

locale_dirs = ['locale']

html_theme_options = {
    'collapse_navigation': True,
    "repository_url": "https://github.com/kendryte/k230_rtos_sdk_docs",
    'navigation_depth': 7,
    "use_repository_button": True,
    "primary_sidebar_end": ["versionsFlex.html"],
    "footer_start": ["FleftEn.html"],
	"footer_center": ["FooterEn.html"],
	"footer_end" : ["FrightEn.html"]
}
