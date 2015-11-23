#!/bin/bash

psql water_polo -c "drop table if exists ncaa.results;"

psql water_polo -f sos/standardized_results.sql

psql water_polo -c "vacuum full verbose analyze ncaa.results;"

psql water_polo -c "drop table ncaa._basic_factors;"
psql water_polo -c "drop table ncaa._parameter_levels;"

R --vanilla -f sos/lmer.R

psql water_polo -c "vacuum full verbose analyze ncaa._parameter_levels;"
psql water_polo -c "vacuum full verbose analyze ncaa._basic_factors;"

psql water_polo -f sos/normalize_factors.sql
psql water_polo -c "vacuum full verbose analyze ncaa._factors;"

psql water_polo -f sos/schedule_factors.sql
psql water_polo -c "vacuum full verbose analyze ncaa._schedule_factors;"

psql water_polo -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv
