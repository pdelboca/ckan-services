# ckan-services

A Beta version of a docker-compose setup to serve all the related services needed to do a [Source Install for Development](https://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html) of CKAN.

Services created:
 * PostgreSQL
 * Solr
 * Redis

## Postgres

Databases ckan_default:
 * Database: ckan_default
 * User: ckan_default
 * Password: pass

Database ckan_test:
 * Database: ckan_test
 * User: ckan_default (same as ckan_default)
 * Pasword: pass

Database datastore_default:
 * Database: datastore_default
 * User: datastore_default
 * Password: pass

Database datastore_test:
 * Database: datastore_test
 * User: datastore_default (same as datastore_default)
 * Password: pass

This should be the default values of the repository so there shouldn't be necessary to update you `.ini` files. Remember that the aim is to have a quick development environment, not a production Server.

Just to be sure check that your `development.ini` file looks like this:

```
## Database Settings
sqlalchemy.url = postgresql://ckan_default:pass@localhost/ckan_default

ckan.datastore.write_url = postgresql://ckan_default:pass@localhost/datastore_default
ckan.datastore.read_url = postgresql://datastore_default:pass@localhost/datastore_default
```

And your `test-core.ini` looks like this:
```
# Specify the Postgres database for SQLAlchemy to use
sqlalchemy.url = postgresql://ckan_default:pass@localhost/ckan_test

## Datastore
ckan.datastore.write_url = postgresql://ckan_default:pass@localhost/datastore_test
ckan.datastore.read_url = postgresql://datastore_default:pass@localhost/datastore_test
```
## Environment Variables

So far there is only one SOLR_USER, so copy `.env.template` and rename it `.env`

# How to do a source install for Python 2.7

I **strongly** recommend to read the [oficial guideline](https://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html) to get a sense of what are we going to do.

Be sure that you have all the ubuntu packages installed as described [here](https://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html#install-the-required-packages).

* clone the repository: `git clone https://github.com/ckan/ckan.git`
* Create a virtualenv: `virtualenv --python=/usr/bin/python2.7 --no-site-packages <virtual_env_directory>`
* Activate the virtualenv
* cd into the repository
* Install requirementes `pip install -r requirements-py2.txt` and `pip install -r dev-requirements.txt`
* Install ckan from the cloned repository executing: `python setup.py development`
* Create a config file using: `paster make-config ckan development.ini`
* Initialize the databases: `paster db init -c development.ini`
* Run a local serve: `paster serve development.ini --reload`

To run tests:
 * Initialize tests databases: `paster db init -c test-core.ini`
 * Run tests: `nosetests --with-pylons=test-core.ini ckan`