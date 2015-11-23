#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'water_polo';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb water_polo;"
   eval $cmd
fi

psql water_polo -f schema/ncaa.sql

cat csv/games_*.csv >> /tmp/games.csv
psql water_polo -f loaders/games.sql
rm /tmp/games.csv
