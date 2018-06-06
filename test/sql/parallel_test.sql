BEGIN;
CREATE EXTENSION istore;
SET max_parallel_workers_per_gather = 8;
SET force_parallel_mode = on;

CREATE TABLE data AS
SELECT id, isagg(k, id+dup+k) as data
FROM generate_series(1000,10000, 100) id, generate_series(1,10) k, generate_series(1,1000) dup
GROUP BY id, dup ORDER BY id;
ALTER TABLE data set (parallel_workers=8);

SELECT SUM(NULL::istore) FROM data;

SELECT SUM(data) FROM data;
EXPLAIN(COSTS OFF) SELECT SUM(data) FROM data;

SELECT id, SUM(data) FROM data GROUP BY id ORDER BY id LIMIT 10;
EXPLAIN(COSTS OFF) SELECT id, SUM(data) FROM data GROUP BY id ORDER BY id;

SELECT MIN(data) FROM data;
EXPLAIN(COSTS OFF) SELECT MIN(data) FROM data;

SELECT id, MIN(data) FROM data GROUP BY id ORDER BY id LIMIT 10;
EXPLAIN(COSTS OFF) SELECT id, MIN(data) FROM data GROUP BY id ORDER BY id;

SELECT MAX(data) FROM data;
EXPLAIN(COSTS OFF) SELECT MAX(data) FROM data;

SELECT id, MAX(data) FROM data GROUP BY id ORDER BY id LIMIT 10;
EXPLAIN(COSTS OFF) SELECT id, MAX(data) FROM data GROUP BY id ORDER BY id;


CREATE TABLE bigdata AS
SELECT id, isagg(k, (id+dup+k)::bigint) as data
FROM generate_series(1000,10000, 100) id, generate_series(1,10) k, generate_series(1,1000) dup
GROUP BY id, dup ORDER BY id;
ALTER TABLE bigdata set (parallel_workers=8);

SELECT SUM(data) FROM bigdata;
EXPLAIN(COSTS OFF) SELECT SUM(data) FROM bigdata;

SELECT id, SUM(data) FROM bigdata GROUP BY id ORDER BY id LIMIT 10;
EXPLAIN(COSTS OFF) SELECT id, SUM(data) FROM bigdata GROUP BY id ORDER BY id;

SELECT MIN(data) FROM bigdata;
EXPLAIN(COSTS OFF) SELECT MIN(data) FROM bigdata;

SELECT id, MIN(data) FROM bigdata GROUP BY id ORDER BY id LIMIT 10;
EXPLAIN(COSTS OFF) SELECT id, MIN(data) FROM bigdata GROUP BY id ORDER BY id;

SELECT MAX(data) FROM bigdata;
EXPLAIN(COSTS OFF) SELECT MAX(data) FROM bigdata;

SELECT id, MAX(data) FROM bigdata GROUP BY id ORDER BY id LIMIT 10;
EXPLAIN(COSTS OFF) SELECT id, MAX(data) FROM bigdata GROUP BY id ORDER BY id;


-- sanity checks

SELECT SUM(data->5) FROM data;
SELECT id, SUM(data->5) FROM data GROUP BY id ORDER BY id LIMIT 10;
SELECT MIN(data->5) FROM data;
SELECT id, MIN(data->5) FROM data GROUP BY id ORDER BY id LIMIT 10;
SELECT MAX(data->5) FROM data;
SELECT id, MAX(data->5) FROM data GROUP BY id ORDER BY id LIMIT 10;

SELECT SUM(data->5) FROM bigdata;
SELECT id, SUM(data->5) FROM bigdata GROUP BY id ORDER BY id LIMIT 10;
SELECT MIN(data->5) FROM bigdata;
SELECT id, MIN(data->5) FROM bigdata GROUP BY id ORDER BY id LIMIT 10;
SELECT MAX(data->5) FROM bigdata;
SELECT id, MAX(data->5) FROM bigdata GROUP BY id ORDER BY id LIMIT 10;

ROLLBACK;
