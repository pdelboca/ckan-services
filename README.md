# ckan-services

A docker-compose setup to serve all the related services needed to do a [Source Install for Development](https://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html) of CKAN.

Services created:
 * PostgreSQL
 * Solr
 * Redis

## How to use for Python 3

Clone this repository in your machine in the same folder of CKAN projects so
both repositories have the same root folder. Like for example:

```
~/projects/ckan
~/projects/ckan-services
```

After clonning the repo:
* Create a Python 3 virtualenv.
* Activate the virtualenv.
* Execute `make install-requirements`
* Execute `make install-ckan` (this will create a config file in CKAN's folder called ckan.ini)
* Edit the `ckan.ini` file to:
  * Add the config variable `ckan.site_url`
  * Change the `solr_url` config to `solr_url = http://127.0.0.1:8983/solr/ckan`
* Execute `make docker-up` to start the services.
* Execute `make add-users` to add an admin user with password 12345678 to the system
* Execute `make start` to start CKAN.
* You can also execute `make test` to run the CKAN Core tests.
