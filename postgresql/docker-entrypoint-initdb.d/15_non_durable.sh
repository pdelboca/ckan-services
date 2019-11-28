#!/bin/sh
# Script to set up non-durable options to improve test performance on Postgresql

# setting non-durable options: https://www.postgresql.org/docs/current/static/non-durability.html
# As suggested here: https://docs.ckan.org/en/latest/contributing/test.html#run-the-tests

if [ -v POSTGRES_NON_DURABLE_SETTINGS ]; then
    echo "Configuring postgres non-durable options."
    # no need to flush data to disk.
    echo "fsync = off" >> /var/lib/postgresql/data/postgresql.conf
    # no need to force WAL writes to disk on every commit.
    echo "synchronous_commit = off" >> /var/lib/postgresql/data/postgresql.conf
    # no need to guard against partial page writes.
    echo "full_page_writes = off" >> /var/lib/postgresql/data/postgresql.conf
fi