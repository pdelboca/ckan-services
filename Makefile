# Automate common development tasks here

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


run-tests:
	paster db init -c test-core.ini  && \
	nosetests --ckan --reset-db --nologcapture --with-coverage -v --with-pylons=test-core.ini ckan --with-id

run-failed-tests:
	paster db init -c test-core.ini  && \
	nosetests --ckan --reset-db --nologcapture --with-coverage -v --with-pylons=test-core.ini ckan --failed


.PHONY: down remove up build bash-db run-tests
