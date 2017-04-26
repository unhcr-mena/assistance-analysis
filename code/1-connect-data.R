########### Access to proGres registration
library(RODBC)

## Connecting to SQL server using ODBC

#########################################
## Db handle for progres Data warehouse
#########################################

progres <- readline("Give the odbc db name:")
user <- readline("Give the username:")
passw <- readline("Give the password:")
dbhandleprogres <- odbcConnect(progres, uid=user, pwd=passw)

## source("perso/password.R")

## fetching the view containing information aggregated at the case level and the event
progres.case <-  sqlFetch(dbhandleprogres, "caseprofile")

## backup in CSV 
write.csv(progres.case, file = "data/progrescase.csv",na="")


#################################
## Db handle for RAIS
#################################
#rais <- readline("Give the odbc db name:")

## fetching the view containing assistance information aggregated at the case level

dbhandlejordan <- odbcConnect(jordan, uid=user1, pwd=passw1)
assistance.case.jordan  <- sqlQuery(dbhandlejordan , 'SELECT * FROM [Assistance].[vAssistanceSearch]')

dbhandleiraq <- odbcConnect(iraq, uid=user1, pwd=passw1)
assistance.case.iraq  <- sqlQuery(dbhandleiraq , 'SELECT * FROM [Assistance].[vAssistanceSearch]')

dbhandlelebanon <- odbcConnect(lebanon, uid=user1, pwd=passw1)
assistance.case.lebanon  <- sqlQuery(dbhandlelebanon , 'SELECT * FROM [Assistance].[vAssistanceSearch]')


assistance.case <- rbind(assistance.case.jordan,assistance.case.iraq,assistance.case.lebanon)
rm(assistance.case.jordan,assistance.case.iraq,assistance.case.lebanon)

write.csv(assistance.case, file = "data/assistancecase.csv",na="")

rm(dbhandleprogres,dbhandlejordan,dbhandleiraq,dbhandlelebanon ,passw,progres,user)