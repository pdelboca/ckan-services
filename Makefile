# Automate common development tasks here
CKAN_CONFIG_FILE := # Complete with local path like ~/Repos/ckan/development.ini
CKAN_TEST_CONFIG_FILE := # Complete with local path like ~/Repos/ckan/test-core.ini
TEST_FOLDER := # Complete with local path like ~/Repos/ckan/ckan/tests/
TEST_PATH :=
PASTER := paster
SHELL := bash
SUDO :=

down:
	docker-compose down

remove:
	docker-compose down -v

up:
	docker-compose up

build:
	docker-compose build

bash-db:
	docker exec -it db /bin/bash

bash-solr:
	docker exec -it solr /bin/bash

add-users: | _check_virtualenv
	$(PASTER) --plugin=ckan user add admin password=12345678 email=admin@example.org -c $(CKAN_CONFIG_FILE)

start: | _check_virtualenv
	$(PASTER) --plugin=ckan db init -c $(CKAN_CONFIG_FILE)
	$(PASTER) --plugin=ckan serve --reload $(CKAN_CONFIG_FILE)

tests-py2:
	$(PASTER) --plugin=ckan db init -c $(CKAN_TEST_CONFIG_FILE)  && \
	nosetests --ckan --reset-db --nologcapture -v --with-pylons=$(CKAN_TEST_CONFIG_FILE) $(TEST_FOLDER)$(TEST_PATH) --with-id

failed-tests-py2:
	$(PASTER) --plugin=ckan db init -c $(CKAN_TEST_CONFIG_FILE)  && \
	nosetests --ckan --reset-db --nologcapture -v --with-pylons=$(CKAN_TEST_CONFIG_FILE) $(TEST_FOLDER)$(TEST_PATH) --failed


_check_virtualenv:
	@if [ -z "$(VIRTUAL_ENV)" ]; then \
	  echo "You are not in a virtual environment - activate your virtual environment first"; \
	  exit 1; \
	fi

.PHONY: down remove up build bash-db run-tests
