begin;

create temporary table r (
       rk	 serial,
       team 	 text,
       year	 integer,
       str	 float,
       ofs	 float,
       dfs	 float,
       sos	 float
);

insert into r
(team,year,str,ofs,dfs,sos)
(
select
sf.team_id,
sf.year,
sf.strength as str,
sf.offensive as ofs,
sf.defensive as dfs,
sf.schedule_strength as sos
from ncaa._schedule_factors sf
where sf.year in (2016)
order by str desc);

select
row_number() over (order by str desc nulls last) as rk,
team,
str::numeric(5,2),
ofs::numeric(5,2),
dfs::numeric(5,2),
sos::numeric(5,2)
from r
order by rk asc;

copy
(
select
rk,
team,
str::numeric(5,2),
ofs::numeric(5,2),
dfs::numeric(5,2),
sos::numeric(5,2)
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;


commit;
