begin;

set timezone to 'America/New_York';

create temporary table m (
       site	       text,
       team	       text,
       h_mu	       float,
       ho_mu	       float,
       opponent	       text,
       a_mu	       float,
       ao_mu	       float
);

/*
insert into m
(game_date,site,home,h_div,h_mu,ho_mu,away,a_div,a_mu,ao_mu)
(select

g.game_date::date as date,
'home' as site,
hd.school_name as home,
'D'||hd.div_id as h_div,
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor) as h_mu,
(10.0/90.0)*(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor) as ho_mu,

vd.school_name as away,
'D'||vd.div_id as a_div,
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor) as a_mu,
(10.0/90.0)*(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive*d.exp_factor) as ao_mu

from ncaa.games g
join ncaa._schedule_factors h
  on (h.year,h.school_id)=(g.year,g.school_id)
join ncaa._schedule_factors v
  on (v.year,v.school_id)=(g.year,g.opponent_id)
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa._factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join ncaa._basic_factors i
  on (i.factor)=('(Intercept)')
where
    not(g.game_date='')
and g.game_date::date between current_date and current_date
and g.location='Home'

union
*/

create temporary table g (
       team_name       	  text,
       opponent_name	  text
);

insert into g
(team_name,opponent_name)
values
('Princeton','UC San Diego'),
('USC','Claremont Mudd Scripps'),
('UCLA','UC San Diego'),
('USC','California'),
('UCLA','California'),
('USC','UCLA');

insert into m
(site,team,h_mu,ho_mu,opponent,a_mu,ao_mu)
(       
select

'neutral' as site,
g.team_name as team,
(exp(i.estimate)*h.offensive*v.defensive) as h_mu,
(3.0/32.0)*(exp(i.estimate)*h.offensive*v.defensive) as ho_mu,

g.opponent_name as opponent,

(exp(i.estimate)*v.offensive*h.defensive) as a_mu,
(3.0/32.0)*(exp(i.estimate)*v.offensive*h.defensive) as ao_mu

from g
join ncaa._schedule_factors h
  on (h.team_id)=(g.team_name)
join ncaa._schedule_factors v
  on (v.team_id)=(g.opponent_name)
join ncaa._basic_factors i
  on (i.factor)=('(Intercept)')
order by team asc
);

select

site,
team,
h_mu::numeric(4,2) as score,

opponent,
a_mu::numeric(4,2) as score,

(skellam(h_mu,a_mu,'win')
+skellam(h_mu,a_mu,'draw')*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as win,

(skellam(h_mu,a_mu,'lose')
+skellam(h_mu,a_mu,'draw')*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as lose,

skellam(h_mu,a_mu,'win')::numeric(4,3) as wr,
skellam(h_mu,a_mu,'lose')::numeric(4,3) as lr,
skellam(h_mu,a_mu,'draw')::numeric(4,3) as dr,

(skellam(h_mu,a_mu,'draw')*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as wo1,
(skellam(h_mu,a_mu,'draw')*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as lo1,

(skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as wo2,
(skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as lo2,

(0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as wso,
(0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as lso

from m;

copy
(
select

site,
team,
h_mu::numeric(4,2) as score,

opponent,
a_mu::numeric(4,2) as score,

(skellam(h_mu,a_mu,'win')
+skellam(h_mu,a_mu,'draw')*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as win,

(skellam(h_mu,a_mu,'lose')
+skellam(h_mu,a_mu,'draw')*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu))
+0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as lose,

skellam(h_mu,a_mu,'win')::numeric(4,3) as wr,
skellam(h_mu,a_mu,'lose')::numeric(4,3) as lr,
skellam(h_mu,a_mu,'draw')::numeric(4,3) as dr,

(skellam(h_mu,a_mu,'draw')*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as wo1,
(skellam(h_mu,a_mu,'draw')*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as lo1,

(skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ho_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as wo2,
(skellam(h_mu,a_mu,'draw')*exp(-ho_mu-ao_mu)*ao_mu/(ho_mu+ao_mu)*(1-exp(-ho_mu-ao_mu)))::numeric(4,3) as lo2,

(0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as wso,
(0.5*skellam(h_mu,a_mu,'draw')*exp(-2*ho_mu)*exp(-2*ao_mu))::numeric(4,3) as lso

from m
) to '/tmp/predict.csv' csv header;

commit;
