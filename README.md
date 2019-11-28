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