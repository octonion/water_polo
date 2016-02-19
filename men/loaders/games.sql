begin;

drop table if exists ncaa.games;

create table ncaa.games (
	year		      integer,
        team_name	      text,
        team_score	      integer,
        team_url	      text,
        opponent_name	      text,
        opponent_score        integer,
	opponent_url	      text,
	game_notes	      text
);

copy ncaa.games from '/tmp/games.csv' csv;

alter table ncaa.games add column game_id serial primary key;

commit;
