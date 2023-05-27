-- bigistore gin access should do index scan using gin;
CREATE TABLE t AS
SELECT i, string_agg(j::text || '=>0', ',')::bigistore AS s
FROM
generate_series(0, 10000) AS i,
generate_series(i, i + (i % 10)) AS j
GROUP BY i;
CREATE INDEX ON t USING gin(s);
SET enable_seqscan = 0;
EXPLAIN (COSTS OFF) SELECT * FROM t WHERE s ? 3;
-- bigistore gin access should find the matching rows for key 300;
SELECT s FROM t WHERE s ? 300 ORDER BY i;
-- bigistore gin access should find the matching rows for key 600;
SELECT s FROM t WHERE s ? 600 ORDER BY i;
-- bigistore gin access should find the matching rows for key 900;
SELECT s FROM t WHERE s ? 900 ORDER BY i;
-- istore gin access should do index scan using gin;
EXPLAIN (COSTS OFF) SELECT * FROM t WHERE s ? 3;
-- istore gin access should find the matching rows for key 300;
SELECT s FROM t WHERE s ? 300 ORDER BY i;
-- istore gin access should find the matching rows for key 600;
SELECT s FROM t WHERE s ? 600 ORDER BY i;
-- istore gin access should find the matching rows for key 900;
SELECT s FROM t WHERE s ? 900 ORDER BY i;
RESET enable_seqscan;
