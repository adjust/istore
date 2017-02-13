#!/bin/bash

make && make install && make installcheck
RESULT=$?
if test -f regression.diffs; then cat regression.diffs; fi
exit $RESULT
