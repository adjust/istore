CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
EXPLAIN (COSTS OFF) SELECT * FROM t WHERE s ? 3;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT * FROM t WHERE s ? 300;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT * FROM t WHERE s ? 600;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT * FROM t WHERE s ? 900;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
EXPLAIN (COSTS OFF) SELECT * FROM t WHERE s ? 3;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT * FROM t WHERE s ? 300;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT * FROM t WHERE s ? 600;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT * FROM t WHERE s ? 900;;
RESET enable_seqscan;;
ROLLBACK;
