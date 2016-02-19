#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'waterpolo-w';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb waterpolo-w;"
   eval $cmd
fi

psql waterpolo-w -f schema/ncaa.sql

cat csv/games_*.csv >> /tmp/games.csv
psql waterpolo-w -f loaders/games.sql
rm /tmp/games.csv
