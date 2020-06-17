# Automate common development tasks here
PASTER := paster
DOCKER_COMPOSE := docker-compose
SHELL := bash
SUDO :=
CKAN := ckan
PYTEST := pytest
NOSETESTS = nosetests
# Find GNU sed in path (on OS X gsed should be preferred)
SED := $(shell which gsed sed | head -n1)

# Config files path
CKAN_CONFIG_FILE := ../ckan/development.ini
CKAN_TEST_CONFIG_FILE := ../ckan/test-core.ini
TEST_FOLDER := ../ckan/ckan/tests/
TEST_PATH :=

# These are used in creating .env
CKAN_SITE_URL := http://localhost:5000
POSTGRES_USER := ckan_default
POSTGRES_PASSWORD := pass
CKAN_DB := ckan_default
CKAN_TEST_DB := ckan_test
CKAN_SOLR_PASSWORD := ckan
DATASTORE_DB_NAME := datastore_default
DATASTORE_TEST_DB_NAME := datastore_test
DATASTORE_DB_RO_USER := datastore_default
DATASTORE_DB_RO_PASSWORD := pass

.env:
	@___POSTGRES_USER=$(POSTGRES_USER) \
	___POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
	___CKAN_DB=$(CKAN_DB) \
	___CKAN_TEST_DB=$(CKAN_TEST_DB) \
	___CKAN_SOLR_PASSWORD=$(CKAN_SOLR_PASSWORD) \
	___DATASTORE_DB_NAME=$(DATASTORE_DB_NAME) \
	___DATASTORE_TEST_DB_NAME=$(DATASTORE_TEST_DB_NAME) \
	___DATASTORE_DB_USER=$(POSTGRES_USER) \
	___DATASTORE_DB_RO_USER=$(DATASTORE_DB_RO_USER) \
	___DATASTORE_DB_RO_PASSWORD=$(DATASTORE_DB_RO_PASSWORD) \
	env | grep ^___ | $(SED) 's/^___//' > .env
	@cat .env

## Start all Docker services
docker-up: .env
	$(DOCKER_COMPOSE) up -d
	@until $(DOCKER_COMPOSE) exec db pg_isready -U $(POSTGRES_USER); do sleep 1; done
	@sleep 2
	@echo " \
    	CREATE ROLE $(DATASTORE_DB_RO_USER) NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '$(DATASTORE_DB_RO_PASSWORD)'; \
    	CREATE DATABASE $(DATASTORE_DB_NAME) OWNER $(POSTGRES_USER) ENCODING 'utf-8'; \
    	CREATE DATABASE $(DATASTORE_TEST_DB_NAME) OWNER $(POSTGRES_USER) ENCODING 'utf-8'; \
    	CREATE DATABASE $(CKAN_TEST_DB) OWNER $(POSTGRES_USER) ENCODING 'utf-8'; \
    	GRANT ALL PRIVILEGES ON DATABASE $(DATASTORE_DB_NAME) TO $(POSTGRES_USER);  \
    	GRANT ALL PRIVILEGES ON DATABASE $(DATASTORE_TEST_DB_NAME) TO $(POSTGRES_USER);  \
    	GRANT ALL PRIVILEGES ON DATABASE $(CKAN_TEST_DB) TO $(POSTGRES_USER);  \
    " | $(DOCKER_COMPOSE) exec -T db psql --username "$(POSTGRES_USER)"
.PHONY: docker-up

## Stop all Docker services
docker-down: .env
	$(DOCKER_COMPOSE) down
.PHONY: docker-down

docker-remove:
	$(DOCKER_COMPOSE) down -v
.PHONY: docker-remove

docker-build:
	$(DOCKER_COMPOSE) build
.PHONY: docker-build

docker-bash-db:
	$(DOCKER_COMPOSE) exec -it db /bin/bash
.PHONY: docker-bash-db

docker-bash-solr:
	$(DOCKER_COMPOSE) exec -it solr /bin/bash
.PHONY: docker-bash-solr

add-users: | _check_virtualenv
	$(CKAN) -c $(CKAN_CONFIG_FILE) user add admin password=12345678 email=admin@example.org
.PHONY: add-users

start: | _check_virtualenv
	$(CKAN) -c $(CKAN_CONFIG_FILE) db init
	$(CKAN) -c $(CKAN_CONFIG_FILE) run
.PHONY: start

test: | _check_virtualenv
	$(CKAN) -c $(CKAN_TEST_CONFIG_FILE) db init
	$(PYTEST) --ckan-ini=$(CKAN_TEST_CONFIG_FILE) -ra $(TEST_FOLDER)$(TEST_PATH)
.PHONY: test

_check_virtualenv:
	@if [ -z "$(VIRTUAL_ENV)" ]; then \
	  echo "You are not in a virtual environment - activate your virtual environment first"; \
	  exit 1; \
	fi

#############################################
# TO BE REMOVED WHEN DEPRECATING Python 2

start-py2: | _check_virtualenv
	$(PASTER) --plugin=ckan db init -c $(CKAN_CONFIG_FILE)
	$(PASTER) --plugin=ckan serve --reload $(CKAN_CONFIG_FILE)
.PHONY: start-py2

add-users-py2: | _check_virtualenv
	$(PASTER) --plugin=ckan user add admin password=12345678 email=admin@example.org -c $(CKAN_CONFIG_FILE)
.PHONY: add-users-py2

tests-py2:
	$(PASTER) --plugin=ckan db init -c $(CKAN_TEST_CONFIG_FILE)  && \
	$(NOSETESTS) --ckan --reset-db --nologcapture -v --with-pylons=$(CKAN_TEST_CONFIG_FILE) $(TEST_FOLDER)$(TEST_PATH) --with-id
.PHONY: tests-py2

failed-tests-py2:
	$(PASTER) --plugin=ckan db init -c $(CKAN_TEST_CONFIG_FILE)  && \
	$(NOSETESTS) --ckan --reset-db --nologcapture -v --with-pylons=$(CKAN_TEST_CONFIG_FILE) $(TEST_FOLDER)$(TEST_PATH) --failed
.PHONY: failed-tests-py2
