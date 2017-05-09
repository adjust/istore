BEGIN;
CREATE EXTENSION istore;
SELECT id, isagg(NULLIF(i%10,3), NULLIF(i::int, 50) ) FROM generate_series(1,100) i, generate_series(1,3) id GROUP BY id;
SELECT id, isagg(NULLIF(i%10,3), NULLIF(i::bigint, 50) ) FROM generate_series(1,100) i, generate_series(1,3) id GROUP BY id;
SELECT id, isagg((i%10), NULL::int) FROM generate_series(1,100) i, generate_series(1,3) id GROUP BY id;
SELECT id, isagg((i%10), NULL::bigint) FROM generate_series(1,100) i, generate_series(1,3) id GROUP BY id;
ROLLBACK;
