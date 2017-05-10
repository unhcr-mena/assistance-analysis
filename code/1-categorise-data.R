### Recategorise assistance type


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
