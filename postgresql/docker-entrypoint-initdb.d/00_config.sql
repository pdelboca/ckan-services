/*
Script to create the databases for CKAN and Datastore.

Based on Docs:
https://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html#setup-a-postgresql-database

*/

CREATE DATABASE ckan_default;
CREATE DATABASE ckan_test;
CREATE USER ckan_default WITH ENCRYPTED PASSWORD 'pass';
GRANT ALL PRIVILEGES ON DATABASE ckan_test TO ckan_default;
GRANT ALL PRIVILEGES ON DATABASE ckan_default TO ckan_default;

CREATE DATABASE datastore_default;
CREATE DATABASE datastore_test;
CREATE USER datastore_default WITH ENCRYPTED PASSWORD 'pass';
GRANT ALL PRIVILEGES ON DATABASE datastore_default TO ckan_default;
GRANT ALL PRIVILEGES ON DATABASE datastore_test TO ckan_default;
