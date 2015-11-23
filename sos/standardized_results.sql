begin;

drop table if exists ncaa.results;

create table ncaa.results (
	game_id		      integer,
	year		      integer,
	team_name	      text,
	opponent_name	      text,
	team_score	      integer,
	opponent_score	      integer,
	game_length	      text
);

insert into ncaa.results
(game_id,year,
 team_name,
 opponent_name,
 team_score,opponent_score,game_length)
(
select
g.game_id,
g.year,
g.team_name,
g.opponent_name,
g.team_score,
g.opponent_score,
(case when g.game_notes is null then '0 OT'
      else g.game_notes end) as game_length
from ncaa.games g
where

    g.team_score is not NULL
and g.opponent_score is not NULL

and g.team_score >= 0
and g.opponent_score >= 0

and not((g.team_score,g.opponent_score)=(0,0))
);

insert into ncaa.results
(game_id,year,
 team_name,
 opponent_name,
 team_score,opponent_score,game_length)
(
select
g.game_id,
g.year,
g.opponent_name,
g.team_name,
g.opponent_score,
g.team_score,
(case when g.game_notes is null then '0 OT'
      else g.game_notes end) as game_length
from ncaa.games g
where

    g.team_score is not NULL
and g.opponent_score is not NULL

and g.team_score >= 0
and g.opponent_score >= 0

and not((g.team_score,g.opponent_score)=(0,0))
);

commit;
