### Recategorise assistance type
assistance.case <- fread( file = "data/assistancecase1.csv",na="")

names(assistance.case)

### Check organisations names
#"Funded"             "Provide"            "Through"
# write.csv(as.data.frame(levels(assistance.case$Funded)), file = "data/Funded.csv",na="")
# write.csv(as.data.frame(levels(assistance.case$Provide)), file = "data/Provide.csv",na="")
# write.csv(as.data.frame(levels(assistance.case$Through)), file = "data/Through.csv",na="")

## Need to change UNHCR Lebanon to UNHCR & World Food Program to WFP
assistance.case[Funded == "UNHCR Lebanon", Funded:="UNHCR"]
assistance.case[Provide == "UNHCR Lebanon", Provide:="UNHCR"]
assistance.case[Through == "UNHCR Lebanon", Through:="UNHCR"]

assistance.case[Funded == "UNHCR Data Analysis Group", Funded :="UNHCR"]
assistance.case[Provide == "UNHCR Data Analysis Group", Provide :="UNHCR"]
assistance.case[Through == "UNHCR Data Analysis Group", Through :="UNHCR"]



assistance.case[Funded=="World Food Program",Funded:="WFP"]
assistance.case[Provide=="World Food Program",Provide:="WFP"]
assistance.case[Through=="World Food Program",Through:="WFP"]

## The data frame syntax crashes...
#assistance.case$Funded[assistance.case$Funded=="UNHCR Lebanon"] <-"UNHCR"
#assistance.case$Provide[assistance.case$Provide=="UNHCR Lebanon"] <-"UNHCR"
#assistance.case$Through[assistance.case$Through=="UNHCR Lebanon"] <-"UNHCR"

#assistance.case$Funded[assistance.case$Funded=="World Food Program"] <-"WFP"
#assistance.case$Provide[assistance.case$Provide=="World Food Program"] <-"WFP"
#assistance.case$Through[assistance.case$Through=="World Food Program"] <-"WFP"



## get level type for cleaning 
#assistancetype <- as.data.frame(levels(assistance.case$AssistanceTypeName))
#assistancetypetype <-  unique(assistance.case[c("SectorName",  "SubSectorName", "AssistanceTypeName")])
#write.csv(assistancetypetype, file = "data/assistancetypetype.csv",na="")
#rm(assistancetype , assistancetypetype)

## Now merge with manually recategorised assistance type
library(readxl)
assistancetypemap <- read_excel("data/assistancetypemap.xlsx",   sheet = "assistancetypetype")

names(assistancetypemap)
#assistance.case1 <- assistance.case[10000000:10200000,]

## need to create a key to merge
assistancetypemap$key <- paste(assistancetypemap$SectorName, assistancetypemap$SubSectorName, assistancetypemap$AssistanceTypeName, sep="-")
assistancetypemap <- assistancetypemap[ , c("key", "assist" ,  "AssistanceType", "AssistanceSubType", "Amount2", "Amountcur") ]

#names(assistance.case)
assistance.case$key <- paste(assistance.case$SectorName, assistance.case$SubSectorName, assistance.case$AssistanceTypeName, sep="-")

#### merging using data frame is failing -- because the dataset is too big...
#assistance.case <- merge(x=assistance.case, y=assistancetypemap, by=c("SectorName",  "SubSectorName", "AssistanceTypeName"), all.x=TRUE)
#assistance.case <- merge(x=assistance.case, y=assistancetypemap, by="key", all.x=TRUE)


assistance.case <- as.data.table(assistance.case)
assistancetypemap <- as.data.table(assistancetypemap)
setkey(assistance.case,"key")
setkey(assistancetypemap,"key")
assistance.case <- merge(x=assistance.case, y=assistancetypemap, by="key", all.x=TRUE)

rm(assistancetypemap)

#rm(assistance.case)

fwrite(assistance.case, file = "data/assistancecase.csv",na="")
