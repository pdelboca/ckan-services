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
  * Change the debug variable to `true`
* Execute `make docker-up` to start the services.
* Execute `make add-users` to add:
  * An `admin` user with password `12345678`
  * A `ckan_admin` user with password `test1234`
  * A `test_user` user with password `12345678`
* Execute `make start` to start CKAN.
* You can also execute `make test` to run the CKAN Core tests with `TEST_FOLDER := ../ckan/ckan/tests`:
  * `make test` to run all tests
  * `make test TEST_PATH=folder/test_file.py` to run all the tests of a specific file.

## More Help

Execute `make help` to see other useful commands.
