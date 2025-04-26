.DEFAULT_GOAL := lint

# Папки проекта
docker_name := auth_service
package_dir := app
tests_dir := tests
scripts_dir := scripts
code_dirs := $(package_dir) $(tests_dir)
reports_dir := reports

# =================================================================================================
# Environment
# =================================================================================================

.PHONY: clean
clean:
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -rf `find . -name .pytest_cache`
	rm -rf *.egg-info
	rm -f report.html
	rm -f .coverage
	rm -rf {build,dist,site,.cache,.mypy_cache,.ruff_cache,reports}

.PHONY: install
install:
	poetry install
	pre-commit install

# =================================================================================================
# Code Quality
# =================================================================================================

.PHONY: lint
lint:
	black --check --diff $(code_dirs)
	isort --check-only $(code_dirs)
	ruff check $(code_dirs)

.PHONY: type-check
type-check:
	mypy $(package_dir)

.PHONY: format
format:
	black $(code_dirs)
	isort $(code_dirs)

.PHONY: check
check: lint type-check test

.PHONY: ci-check
ci-check: check

# =================================================================================================
# Tests
# =================================================================================================

.PHONY: test
test:
	pytest $(tests_dir)

.PHONY: test-coverage
test-coverage:
	pytest --cov=$(package_dir) --cov-report=html $(tests_dir)

.PHONY: test-coverage-view
test-coverage-view:
	python -c "import webbrowser; webbrowser.open('file://$(shell pwd)/htmlcov/index.html')"

# =================================================================================================
# Dev
# =================================================================================================

.PHONY: dev
dev:
	poetry run uvicorn app.main:app --reload

# =================================================================================================
# Docker
# =================================================================================================

.PHONY: up
up:
	docker-compose -p $(project_name) up -d

.PHONY: down
down:
	docker-compose -p $(project_name) down

.PHONY: docker-clean
docker-clean:
	docker-compose -p $(project_name) down --volumes --remove-orphans
