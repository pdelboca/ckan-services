# Automate common development tasks here
PASTER := paster
DOCKER_COMPOSE := docker-compose
SHELL := bash
SUDO :=
CKAN := ckan
PYTEST := pytest
NOSETESTS := nosetests
PIP := pip
# Find GNU sed in path (on OS X gsed should be preferred)
SED := $(shell which gsed sed | head -n1)

# CKAN paths
CKAN_PATH := ../ckan
CKAN_CONFIG_FILE := ../ckan/ckan.ini
CKAN_TEST_CONFIG_FILE := ../ckan/test-core.ini
TEST_FOLDER := ../ckan/ckan/tests
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

## Install CKAN Requirements
install-requirements: | _check_virtualenv
	$(PIP) install -r $(CKAN_PATH)/requirement-setuptools.txt -r $(CKAN_PATH)/dev-requirements.txt -r $(CKAN_PATH)/requirements.txt

## Install CKAN
install-ckan: | _check_virtualenv
	$(PIP) install -e $(CKAN_PATH)
	$(CKAN) generate config $(CKAN_PATH)/ckan.ini

## Add admin user to the local instance
add-users: | _check_virtualenv
	$(CKAN) -c $(CKAN_CONFIG_FILE) user add admin password=12345678 email=admin@example.org
	$(CKAN) -c $(CKAN_CONFIG_FILE) sysadmin add admin
	$(CKAN) -c $(CKAN_CONFIG_FILE) user add ckan_admin password=test1234 email=ckan_admin@example.org
	$(CKAN) -c $(CKAN_CONFIG_FILE) sysadmin add ckan_admin
	$(CKAN) -c $(CKAN_CONFIG_FILE) user add test_user password=12345678 email=test_user@example.org
.PHONY: add-users

## Start the CKAN development server
start: | _check_virtualenv
	$(CKAN) -c $(CKAN_CONFIG_FILE) db init
	$(CKAN) -c $(CKAN_CONFIG_FILE) run
.PHONY: start

## Run the CKAN Core tests
test: | _check_virtualenv
	$(CKAN) -c $(CKAN_TEST_CONFIG_FILE) db init
	$(PYTEST) --ckan-ini=$(CKAN_TEST_CONFIG_FILE) -ra $(TEST_FOLDER)/$(TEST_PATH)
.PHONY: test

_check_virtualenv:
	@if [ -z "$(VIRTUAL_ENV)" ]; then \
	  echo "You are not in a virtual environment - activate your virtual environment first"; \
	  exit 1; \
	fi

################## DOCKER SERVICES ##################
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
	$(CKAN) -c $(CKAN_CONFIG_FILE) db init
.PHONY: docker-up

## Stop all Docker services
docker-down: .env
	$(DOCKER_COMPOSE) down
.PHONY: docker-down

## Remove all Docker services and remove the volumes
docker-remove:
	$(DOCKER_COMPOSE) down -v
.PHONY: docker-remove

## Build the docker-compose.yml file
docker-build:
	$(DOCKER_COMPOSE) build
.PHONY: docker-build

## Open an interactive terminal in the db container
docker-bash-db:
	$(DOCKER_COMPOSE) exec -it db /bin/bash
.PHONY: docker-bash-db

## Open an interactive terminal in the solr container
docker-bash-solr:
	$(DOCKER_COMPOSE) exec -it solr /bin/bash
.PHONY: docker-bash-solr

## Set up Datastore
setup-datastore: | _check_virtualenv
	$(CKAN) -c $(CKAN_CONFIG_FILE) datastore set-permissions \
	| $(DOCKER_COMPOSE) exec -T db psql --username "$(POSTGRES_USER)" --set ON_ERROR_STOP=1

# Help related variables and targets

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
TARGET_MAX_CHAR_NUM := 20

## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	  helpMessage = match(lastLine, /^## (.*)/); \
	  if (helpMessage) { \
	    helpCommand = substr($$1, 0, index($$1, ":")-1); \
	    helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
	    printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
	  } \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

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
	$(NOSETESTS) --ckan --reset-db --nologcapture -v --with-pylons=$(CKAN_TEST_CONFIG_FILE) $(TEST_FOLDER)/$(TEST_PATH) --with-id
.PHONY: tests-py2

failed-tests-py2:
	$(PASTER) --plugin=ckan db init -c $(CKAN_TEST_CONFIG_FILE)  && \
	$(NOSETESTS) --ckan --reset-db --nologcapture -v --with-pylons=$(CKAN_TEST_CONFIG_FILE) $(TEST_FOLDER)/$(TEST_PATH) --failed
.PHONY: failed-tests-py2
