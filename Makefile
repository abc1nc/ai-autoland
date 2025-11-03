.PHONY: lint lint-errors format check pot po mo

SRC_DIR = src/autoland
LOCALES_DIR = $(SRC_DIR)/locales
GETTEXT_DOMAIN = autoland

lint:
	git ls-files -- "*.py" | xargs poetry run pylint

lint-errors:
	git ls-files -- "*.py" | xargs poetry run pylint --errors-only --load-plugins=""

# Install editorconfig-checker: https://github.com/editorconfig-checker/editorconfig-checker/
format:
	git ls-files -- "*.py" | xargs poetry run autopep8 --in-place
	editorconfig-checker

check:
	git ls-files -- "*.py" | xargs poetry run python -m py_compile
	poetry check

pot:
	poetry run pybabel extract --no-location --sort-output -o $(LOCALES_DIR)/$(GETTEXT_DOMAIN).pot $(SRC_DIR)

po: pot
	poetry run pybabel update --no-wrap --ignore-obsolete -i $(LOCALES_DIR)/$(GETTEXT_DOMAIN).pot -d $(LOCALES_DIR) -D $(GETTEXT_DOMAIN)

mo:
	poetry run pybabel compile -d $(LOCALES_DIR) -D $(GETTEXT_DOMAIN)
