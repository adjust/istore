#!/bin/bash
: ${DB:=is_bench}
: ${PG_USER:=postgres}
: ${PG_PORT:=5432}
: ${SCALE:=10}
: ${SIZE:=30}
: ${KEYS:=30}
: ${TRANSACTIONS:=50}

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function init {
    psql -c "DROP DATABASE IF EXISTS $DB;" postgres
    psql -c "CREATE DATABASE $DB;" postgres
    psql -f "$ABSOLUTE_PATH/bench/init.sql" --set=scale=${SCALE} --set=size=${SIZE} --set=keys=${KEYS} "$DB"
    psql -c "CREATE TABLE bench_results(test text, branch text, tps numeric)" "$DB"
}

function bench {
    FILE=$1
    filename=$(basename "$FILE")
    testcase="${filename%.*}"

    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    res=$(pgbench -f "$FILE" -t $TRANSACTIONS -n $DB | grep "excluding connections establishing" | awk '{print $3}')
    psql -c "DELETE FROM bench_results WHERE (test, branch) = ('$testcase','$BRANCH')" "$DB"
    psql -c "INSERT INTO bench_results(test, branch, tps) VALUES('$testcase','$BRANCH',$res)" "$DB"
}


function run {
    for file in ${ABSOLUTE_PATH}/bench/*.sql
    do
        filename=$(basename "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"

        if [ "$filename" != "init" ]; then
            bench "$file"
            # echo $file
        fi
    done
}

function results {
    SQL="SELECT
    'COPY(SELECT test,'
    || array_to_string(
        array_agg('AVG(tps) FILTER (WHERE branch='''|| b ||''') as '|| b )
    ,', ')
    || ' FROM bench_results GROUP BY 1)
    TO STDOUT (FORMAT CSV, HEADER);'
    FROM (SELECT DISTINCT(branch) FROM bench_results)t(b);"

    out=$(psql -Aqtc "$SQL" $DB)
    psql -c "$out" $DB > bench_results.csv
}


$1


