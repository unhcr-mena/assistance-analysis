########### Access to proGres registration
library(RODBC)

## Connecting to SQL server using ODBC

#########################################
## Db handle for progres Data warehouse
#########################################

#progres <- readline("Give the odbc db name:")
#user <- readline("Give the username:")
#passw <- readline("Give the password:")
#dbhandleprogres <- odbcConnect(progres, uid=user, pwd=passw)

source("perso/password.R")

## fetching the view containing information aggregated at the case level and the event
#progres.case <-  sqlFetch(dbhandleprogres, "caseprofile")

## backup in CSV 
#write.csv(progres.case, file = "data/progrescase.csv",na="")


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

summary(assistance.case)
str(assistance.case)


## Reparse the date correctly
assistance.case$ProvidedDate <- as.Date(as.character(assistance.case$ProvidedDate), "%Y-%m-%d")

#summary(assistance.case$ProvidedDate1)
#str(assistance.case$ProvidedDate1)

## subset dataset so that we have records for each country around the same dates
# table(assistance.case$ProvidedDate1, assistance.case$instance)

## Clean
rm(assistance.case.jordan,assistance.case.iraq,assistance.case.lebanon,assistance.case.lebanon1)
rm(dbhandleprogres,dbhandlejordan,dbhandleiraq,dbhandlelebanon,iraq,jordan,lebanon,passw,progres,user,user1,passw1)

## need to use data.table instead of data.frame to handle large dataset...
## https://www.analyticsvidhya.com/blog/2016/05/data-table-data-frame-work-large-data-sets/ 
library(data.table)


## Convert to data table and save
assistance.case <- as.data.table(assistance.case)
#names(assistance.case)
assistance.case$key <- paste(assistance.case$SectorName, assistance.case$SubSectorName, assistance.case$AssistanceTypeName, sep="-")

setkey(assistance.case,"key")

fwrite(assistance.case, file = "data/assistancecase1.csv",na="")

