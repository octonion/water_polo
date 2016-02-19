#!/bin/bash

psql waterpolo-m -c "drop table if exists ncaa.results;"

psql waterpolo-m -f sos/standardized_results.sql

psql waterpolo-m -c "vacuum full verbose analyze ncaa.results;"

psql waterpolo-m -c "drop table ncaa._basic_factors;"
psql waterpolo-m -c "drop table ncaa._parameter_levels;"

R --vanilla -f sos/lmer.R

psql waterpolo-m -c "vacuum full verbose analyze ncaa._parameter_levels;"
psql waterpolo-m -c "vacuum full verbose analyze ncaa._basic_factors;"

psql waterpolo-m -f sos/normalize_factors.sql
psql waterpolo-m -c "vacuum full verbose analyze ncaa._factors;"

psql waterpolo-m -f sos/schedule_factors.sql
psql waterpolo-m -c "vacuum full verbose analyze ncaa._schedule_factors;"

psql waterpolo-m -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv
