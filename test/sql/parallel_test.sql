BEGIN;
SET max_parallel_workers_per_gather=4;
SET force_parallel_mode=on;
CREATE EXTENSION istore;
CREATE TABLE test(data istore, bigdata bigistore) WITH (parallel_workers = 4);
INSERT INTO test(data, bigdata)
SELECT istore(array_agg(i), array_agg(i+10*j)), bigistore(array_agg(i), array_agg(i+10*j))
FROM generate_series(1,10) i, generate_series(0,99999) j GROUP BY j;


--check that parallization is used
EXPLAIN (costs off,verbose)
SELECT min(data), max(data), sum(data), min(bigdata), max(bigdata), sum(bigdata)
FROM test;

--compare results
\x on
-- non parallel
SET max_parallel_workers_per_gather=0;
SET force_parallel_mode=on;

SELECT min(data), max(data), sum(data), min(bigdata), max(bigdata), sum(bigdata)
FROM test;

-- single gather
SET max_parallel_workers_per_gather=1;
SET force_parallel_mode=on;

SELECT min(data), max(data), sum(data), min(bigdata), max(bigdata), sum(bigdata)
FROM test;

SET max_parallel_workers_per_gather=2;
SET force_parallel_mode=on;

SELECT min(data), max(data), sum(data), min(bigdata), max(bigdata), sum(bigdata)
FROM test;

-- max gather
SET max_parallel_workers_per_gather=4;
SET force_parallel_mode=on;

SELECT min(data), max(data), sum(data), min(bigdata), max(bigdata), sum(bigdata)
FROM test;

CREATE TABLE paralllel_out AS
SELECT
min(data) as min_data, max(data) as max_data, sum(data) as sum_data,
min(bigdata) as min_bigdata, max(bigdata) as max_bigdata, sum(bigdata) as sum_bigdata
FROM test;

\d paralllel_out
SELECT * FROM paralllel_out;

ROLLBACK;
