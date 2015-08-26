CREATE EXTENSION istore;
CREATE TABLE is_bench AS
  SELECT
    string_agg((random()*:keys)::int::text || '=>'|| (random()*10000)::int::text, ',')::istore AS a,
    string_agg((random()*:keys)::int::text || '=>'|| (random()*10000+1)::int::text, ',')::istore AS b,
    (random()*1000)::int as c
  FROM
      generate_series(0, 10000 * :scale) AS i,
      generate_series(i, i + (i % :size)) AS j
  GROUP BY i;


