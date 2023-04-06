-- bigistore gin access should do index scan using gin;
CREATE TABLE t1 AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t1 USING gin(s);;
SET enable_seqscan = 0;;
EXPLAIN (COSTS OFF) SELECT * FROM t1 WHERE s ? 3;;
RESET enable_seqscan;;
-- bigistore gin access should find the matching rows for key 300;
CREATE TABLE t2 AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t2 USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t2 WHERE s ? 300 ORDER BY i;;
RESET enable_seqscan;;
-- bigistore gin access should find the matching rows for key 600;
CREATE TABLE t3 AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t3 USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t3 WHERE s ? 600 ORDER BY i;;
RESET enable_seqscan;;
-- bigistore gin access should find the matching rows for key 900;
CREATE TABLE t4 AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t4 USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t4 WHERE s ? 900 ORDER BY i;;
RESET enable_seqscan;;
-- istore gin access should do index scan using gin;
CREATE TABLE t5 AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t5 USING gin(s);;
SET enable_seqscan = 0;;
EXPLAIN (COSTS OFF) SELECT * FROM t5 WHERE s ? 3;;
RESET enable_seqscan;;
-- istore gin access should find the matching rows for key 300;
CREATE TABLE t6 AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t6 USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t6 WHERE s ? 300 ORDER BY i;;
RESET enable_seqscan;;
-- istore gin access should find the matching rows for key 600;
CREATE TABLE t7 AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t7 USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t7 WHERE s ? 600 ORDER BY i;;
RESET enable_seqscan;;
-- istore gin access should find the matching rows for key 900;
CREATE TABLE t8 AS
SELECT i, string_agg(j::text || '=>0', ',')::istore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t8 USING gin(s);;
SET enable_seqscan = 0;;
SELECT s FROM t8 WHERE s ? 900 ORDER BY i;;
RESET enable_seqscan;;
