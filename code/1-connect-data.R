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
assistance.case.jordan$instance <- "Jordan"
dbhandleiraq <- odbcConnect(iraq, uid=user1, pwd=passw1)
assistance.case.iraq  <- sqlQuery(dbhandleiraq , 'SELECT * FROM [Assistance].[vAssistanceSearch]')
assistance.case.iraq $instance <- "Iraq "
dbhandlelebanon <- odbcConnect(lebanon, uid=user1, pwd=passw1)
assistance.case.lebanon  <- sqlQuery(dbhandlelebanon , 'SELECT * FROM [Assistance].[vAssistanceSearch]')

assistance.case.lebanon1 <- assistance.case.lebanon[ , c("CaseAssistanceId", "ProvidedDate",  "SectorName",   
                                                         "SubSectorName", "AssistanceTypeName", "CaseNo",            
                                                         "OrganizationId",  "Funded", "Provide", "Through", "Unit", "IsCaseBase",        
                                                         "Quantity", "Value", "RationCard", "IsConfidential", "IsColleted" )]
assistance.case.lebanon1$instance <- "Lebanon"

names(assistance.case.jordan)
names(assistance.case.iraq)
names(assistance.case.lebanon)

assistance.case <- rbind(assistance.case.jordan,assistance.case.iraq,assistance.case.lebanon1)
rm(assistance.case.jordan,assistance.case.iraq,assistance.case.lebanon,assistance.case.lebanon1)

write.csv(assistance.case, file = "data/assistancecase.csv",na="")

## get level type

assistancetype <- as.data.frame(levels(assistance.case$AssistanceTypeName))

rm(dbhandleprogres,dbhandlejordan,dbhandleiraq,dbhandlelebanon ,passw,progres,user)