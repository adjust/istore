#!/bin/bash

set -eux

# stop running instances of PostgreSQL
sudo service postgresql stop

# exit status
status=0

# create cluster owned by travis user
CLUSTER_PATH=$(pwd)/travis_cluster
initdb -D $CLUSTER_PATH -U $USER -A trust

# build and install extension
make CFLAGS_SL="$(pg_config --cflags_sl) -coverage" || status=$?
sudo make install || status=$?

# run cluster
sudo chown $USER /var/run/postgresql/
pg_ctl -D $CLUSTER_PATH start -l postgres.log -w

# run regression tests
PGUSER=$USER make installcheck || status=$?

# in case of the test fail show diffs
if test -f regression.diffs; then cat regression.diffs; fi

# build coverage files
gcov src/*.c src/*.h

# return the exit status
exit $status
