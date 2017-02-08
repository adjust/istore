begin;

set parallel_setup_cost=0;
set parallel_tuple_cost=0;
set min_parallel_relation_size=0;
set max_parallel_workers_per_gather=4;

create extension istore;
create table test(id serial, data istore, bigdata bigistore) WITH (parallel_workers = 4);

insert into test(data, bigdata)
select istore(array_agg(t), array_agg(t)), istore(array_agg(t), array_agg(t))::bigistore
from (select t::integer from generate_series(1, 1e3) t) tt
group by t % 10;

explain (costs off,verbose)
select min(data), max(data), sum(data), min(bigdata), max(bigdata), sum(bigdata)
from test where id % 10 in (2,3,4,5,6);

rollback;
