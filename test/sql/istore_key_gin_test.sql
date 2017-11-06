BEGIN;
-- bigistore gin access should do index scan using gin;
-- ./spec/istore/istore_key_gin_spec.rb:23;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
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
-- bigistore gin access should find the matching rows for key 300;
-- ./spec/istore/istore_key_gin_spec.rb:31;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t WHERE s ? 300 ORDER BY i;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
-- bigistore gin access should find the matching rows for key 600;
-- ./spec/istore/istore_key_gin_spec.rb:40;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t WHERE s ? 600 ORDER BY i;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
-- bigistore gin access should find the matching rows for key 900;
-- ./spec/istore/istore_key_gin_spec.rb:49;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t WHERE s ? 900 ORDER BY i;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
-- istore gin access should do index scan using gin;
-- ./spec/istore/istore_key_gin_spec.rb:23;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
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
-- istore gin access should find the matching rows for key 300;
-- ./spec/istore/istore_key_gin_spec.rb:31;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t WHERE s ? 300 ORDER BY i;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
-- istore gin access should find the matching rows for key 600;
-- ./spec/istore/istore_key_gin_spec.rb:40;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t WHERE s ? 600 ORDER BY i;;
RESET enable_seqscan;;
ROLLBACK;
BEGIN;
-- istore gin access should find the matching rows for key 900;
-- ./spec/istore/istore_key_gin_spec.rb:49;
CREATE EXTENSION istore;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 100000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
;
CREATE INDEX ON t USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t WHERE s ? 900 ORDER BY i;;
RESET enable_seqscan;;
ROLLBACK;
