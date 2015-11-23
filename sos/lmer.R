sink("diagnostics/lmer.txt")

library("lme4")
library("nortest")
library("RPostgreSQL")

#library("sp")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,host="localhost",port="5432",dbname="water_polo")

query <- dbSendQuery(con, "
select
distinct
r.game_id,
r.year,
r.team_name as team,
r.opponent_name as opponent,
r.team_score,
r.game_length
from ncaa.results r

where

not(r.team_score,r.opponent_score)=(0,0)

and not(team_name ilike '%varsity%')
and not(team_name like '% A')
and not(team_name like '% B')

and not(opponent_name ilike '%varsity%')
and not(opponent_name like '% A')
and not(opponent_name like '% B')

;")

games <- fetch(query,n=-1)

dim(games)

attach(games)

pll <- list()

# Fixed parameters

year <- as.factor(year)

game_length <- as.factor(game_length)

fp <- data.frame(game_length)
fpn <- names(fp)

# Random parameters

game_id <- as.factor(game_id)

offense <- as.factor(paste(year,"/",team,sep=""))

defense <- as.factor(paste(year,"/",opponent,sep=""))

rp <- data.frame(offense,defense)
rpn <- names(rp)

for (n in fpn) {
  df <- fp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("fixed",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

for (n in rpn) {
  df <- rp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("random",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

# Model parameters

parameter_levels <- as.data.frame(do.call("rbind",pll))
dbWriteTable(con,c("ncaa","_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)
g$score <- team_score
g$game_length <- game_length

detach(games)

dim(g)

model <- score ~ game_length+(1|offense)+(1|defense)+(1|game_id)
fit <- glmer(model,
             data=g,
	     verbose=TRUE,
	     family=poisson(link=log))
#	     nAGQ=0,
#	     control=glmerControl(optimizer = "nloptwrap")
#	     )

fit
summary(fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)

# Random factors

r <- ranef(fit)
rn <- names(r) 

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("ncaa","_basic_factors"),as.data.frame(combined),row.names=TRUE)

quit("no")
