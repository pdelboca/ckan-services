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

# How to do a source install for Python 2.7

I **strongly** recommend to read the [oficial guideline](https://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html) to get a sense of what are we going to do.

Be sure that you have all the ubuntu packages installed as described [here](https://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html#install-the-required-packages).

* clone the repository: `git clone https://github.com/ckan/ckan.git`
* Create a virtualenv:
  * Python 2: `virtualenv --python=/usr/bin/python2.7 --no-site-packages <virtual_env_directory>`
  * Python 3: `virtualenv --python=/usr/bin/python2 --no-site-packages <virtual_env_directory>`
* Activate the virtualenv
* cd into the repository
* Install requirementes
  * Python 2: `pip install -r requirements-py2.txt` and `pip install -r dev-requirements.txt`
  * Python 3: `pip install -r requirements.txt` and `pip install -r dev-requirements.txt`
* Install ckan from the cloned repository executing: `python setup.py develop`
* Create a config file using:
  * Python 2: `paster make-config ckan development.ini`
  * Python 3: TODO
* Edit `development.ini` file and add a name for `ckan.site_url` like `http://ckan:5000` (ckan will need to be added to your `/etc/hosts` file!)
* Edit `development.ini` file to add the solr url: `solr_url = http://127.0.0.1:8983/solr/ckan`
* Initialize the databases:
  * Python 2: `paster db init -c development.ini`
  * Python 2: `ckan db init`
* You can add a user to the system using:
  * Python 2: `paster --plugin=ckan user add admin password=12345678 email=admin@admin.org -c development.ini && paster --plugin=ckan sysadmin add admin -c development.ini`
  * Python 3: `ckan user add admin password=12345678 email=admin@admin.org && ckan sysadmin add admin`
* Run a local server:
  * Python 2: `paster serve development.ini --reload`
  * Python 3: `ckan -c development.ini run`

To run tests:
 * Initialize tests databases:
   * Python 2: `paster db init -c test-core.ini`
   * Python 3: `ckan -c test-core.ini db init`
 * Run tests: `python -m pytest --ckan-ini=test-core.ini`
