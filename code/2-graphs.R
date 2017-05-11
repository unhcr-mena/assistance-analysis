
## Loading Libraries
source("code/0-packages.R")


### generate a few initial graphs

#names(assistance.case)

assistance.case <- fread( file = "data/assistancecase.csv",na="")

str(assistance.case)

## Reparse correctly the date
#assistance.case$ProvidedDate <- as.Date(as.character(assistance.case$ProvidedDate), "%Y-%m-%d")
## better with data.table syntax
assistance.case <- assistance.case[, ProvidedDate := as.Date(fast_strptime(ProvidedDate, "%Y-%m-%d"))]

## need to remove records with wrong date..
assistance.case <- assistance.case[year(ProvidedDate) %in%  c("2011","2012","2013","2014","2015","2016","2017")]

assistance.case <- assistance.case[ ProvidedDate > as.Date(fast_strptime("2012-06-01", "%Y-%m-%d"))]
assistance.case <- assistance.case[ ProvidedDate < as.Date(fast_strptime("2017-04-01", "%Y-%m-%d"))]


## Checking structure
#str(assistance.case)
#levels(assistance.case$AssistanceType) 

##frequ <- table (assistance.case[ , c("AssistanceType")])
## with data.table
frequ <- assistance.case[, .N ,by = AssistanceType]
frequ <- frequ[order(frequ$N),]
frequ.level <- as.character(frequ$AssistanceType)
frequ$AssistanceType1 <- factor(frequ$AssistanceType, levels=frequ.level)
levels(frequ$AssistanceType1)
frequ$Frequency <- frequ$N/sum(frequ$N)

## Old 
# assistance.case$AssistanceType <- factor(assistance.case$AssistanceType, levels=names(frequ[rev(order(frequ, decreasing = TRUE))]))
#assistance.case[ , "AssistanceType"] <- factor(assistance.case[ , "AssistanceType"], levels=names(frequ[rev(order(frequ, decreasing = TRUE))]))

## Because of the size of the dataset, attributes are set differently
## change the levels by reference with no copy within data.table
setattr(assistance.case$AssistanceType,"levels",frequ.level )



## and now the graph
plotfreq <- ggplot(frequ, aes(x=AssistanceType1,y = Frequency)) +
  geom_bar(stat="identity", fill="skyblue3",colour="#2a87c8") +
  #facet_wrap(~ instance, ncol=3) +
  guides(fill=FALSE) +
  ylab("Frequency") +
  #scale_y_continuous(labels=percent)+
  xlab("") +
  coord_flip() +
  ggtitle("Assistance Type")+
  theme(plot.title=element_text(face="bold", size=9),
        plot.background = element_rect(fill = "transparent",colour = NA))

plotfreq

ggsave(plotfreq, filename="out/assistancetype.png",  dpi=300)



###########################################################################################################
## graph per instance

###########################################################################################################

#frequ.instance <- assistance.case[, .N ,by = .(AssistanceType, instance)]

## Getting directly relative percentage per instance
frequ.instance <-assistance.case[, as.data.table(prop.table(table(AssistanceType, instance),2))]

frequ.instance$AssistanceType1 <- factor(frequ.instance$AssistanceType, levels=frequ.level)
levels(frequ.instance$AssistanceType1)


plotfreq.instance <- ggplot(frequ.instance, aes(x=AssistanceType1,y = N)) +
  geom_bar(stat="identity",  fill="skyblue3",colour="#2a87c8") +
  facet_wrap(~ instance, ncol=3) +
  guides(fill=TRUE) +
  ylab("Frequency") +
  #scale_y_continuous(labels=percent)+
  xlab("") +
  coord_flip() +
  ggtitle("Assistance Type per instance")+
  theme(plot.title=element_text(face="bold", size=9),
        plot.background = element_rect(fill = "transparent",colour = NA))

plotfreq.instance

ggsave(plotfreq.instance, filename="out/assistancetype-instance.png",  dpi=300)

###########################################################################################################
## graph per instance & organisation Provide

###########################################################################################################

#frequ.instance <- assistance.case[, .N ,by = .(AssistanceType, instance)]

## Getting directly relative percentage per instance
frequ.instance.provide <-assistance.case[, as.data.table(prop.table(table(AssistanceType, instance, Provide),2))]
frequ.instance.provide$AssistanceType1 <- factor(frequ.instance.provide$AssistanceType, levels=frequ.level)

## let's subset values that are above 5%
frequ.instance.provide1 <- frequ.instance.provide[frequ.instance.provide$N >= 0.05, ]
frequ.instance.provide1$Provide1 <- as.factor(as.character(frequ.instance.provide1$Provide))

plotfreq.instance.provide <- ggplot(frequ.instance.provide1, aes(x=AssistanceType1,y = N,  fill=Provide)) +
  geom_bar(stat="identity" ,colour="#2a87c8") +
  facet_wrap(~ instance, ncol=3) +
  ylab("Frequency") +
  scale_fill_brewer(palette = "Paired") + 
  xlab("") +
  coord_flip() +
  ggtitle("Assistance Type per instance for delivering Organisation", 
          subtitle = "Only organisation that have assistance records accounting for more than 5% within countries are displayed" )+
  theme(plot.title=element_text(face="bold", size=9),
        plot.subtitle=element_text( size=8),
        plot.background = element_rect(fill = "transparent",colour = NA))
plotfreq.instance.provide
ggsave(plotfreq.instance.provide, filename="out/assistancetype-instance-provide.png", width=20,  dpi=300)

###########################################################################################################
## graph per instance & organisation Through

###########################################################################################################

#frequ.instance <- assistance.case[, .N ,by = .(AssistanceType, instance)]

## Getting directly relative percentage per instance
frequ.instance.Through <-assistance.case[, as.data.table(prop.table(table(AssistanceType, instance, Through),2))]
frequ.instance.Through$AssistanceType1 <- factor(frequ.instance.Through$AssistanceType, levels=frequ.level)

## let's subset values that are above 2%
frequ.instance.Through1 <- frequ.instance.Through[frequ.instance.Through$N >= 0.01, ]
frequ.instance.Through1$Through1 <- as.factor(as.character(frequ.instance.Through1$Through))

plotfreq.instance.Through <- ggplot(frequ.instance.Through1, aes(x=AssistanceType1,y = N,  fill=Through)) +
  geom_bar(stat="identity" ,colour="#2a87c8") +
  facet_wrap(~ instance, ncol=3) +
  ylab("Frequency") +
  scale_fill_brewer(palette = "Paired") + 
  xlab("") +
  coord_flip() +
  ggtitle("Assistance Type per instance for Intermediate Organisation", 
          subtitle = "Only organisation that have assistance records accounting for more than 1% within countries are displayed" )+
  theme(plot.title=element_text(face="bold", size=9),
        plot.subtitle=element_text( size=8),
        plot.background = element_rect(fill = "transparent",colour = NA))
plotfreq.instance.Through
ggsave(plotfreq.instance.Through, filename="out/assistancetype-instance-Through.png", width=20,  dpi=300)



###########################################################################################################
## graph per instance & organisation Funded

###########################################################################################################

#frequ.instance <- assistance.case[, .N ,by = .(AssistanceType, instance)]

## Getting directly relative percentage per instance
frequ.instance.Funded <-assistance.case[, as.data.table(prop.table(table(AssistanceType, instance, Funded),2))]
frequ.instance.Funded$AssistanceType1 <- factor(frequ.instance.Funded$AssistanceType, levels=frequ.level)

## let's subset values that are above 1%
frequ.instance.Funded1 <- frequ.instance.Funded[frequ.instance.Funded$N >= 0.01, ]
frequ.instance.Funded1$Funded1 <- as.factor(as.character(frequ.instance.Funded1$Funded))

plotfreq.instance.Funded <- ggplot(frequ.instance.Funded1, aes(x=AssistanceType1,y = N,  fill=Funded)) +
  geom_bar(stat="identity" ,colour="#2a87c8") +
  facet_wrap(~ instance, ncol=3) +
  ylab("Frequency") +
  scale_fill_brewer(palette = "Paired") + 
  xlab("") +
  coord_flip() +
  ggtitle("Assistance Type per instance for Funding Organisation", 
          subtitle = "Only organisation that have assistance records accounting for more than 1% within countries are displayed" )+
  theme(plot.title=element_text(face="bold", size=9),
        plot.subtitle=element_text( size=8),
        plot.background = element_rect(fill = "transparent",colour = NA))
plotfreq.instance.Funded
ggsave(plotfreq.instance.Funded, filename="out/assistancetype-instance-Funded.png",  width=20, dpi=300)


###########################################################################################################
## graph per instance & date

###########################################################################################################


#frequ.instance.date <-assistance.case[, as.data.table(table(AssistanceType, instance, year(ProvidedDate)))]
#frequ.instance.month <-assistance.case[, as.data.table(table(AssistanceType, instance, month(ProvidedDate)))]
frequ.instance.monthyear <-assistance.case[, as.data.table(table(AssistanceType, instance, format(ProvidedDate, "%Y-%m")))]
 
## Reorder factors
frequ.instance.monthyear$AssistanceType1 <- factor(frequ.instance.monthyear$AssistanceType, levels=frequ.level)

plotfreq.instance.monthyear <- ggplot(frequ.instance.monthyear, aes(x=V1, y = N,  fill=AssistanceType1)) +
  geom_bar(stat="identity" ,colour="#2a87c8") +
  facet_wrap(~ instance, nrow=3) +
  ylab("# of records") +
  scale_fill_brewer(palette = "Paired") + 
  xlab("") +
  
  ## setting up a focus in 
 # coord_flip() +
  ggtitle("Assistance Type per instance and year", 
          subtitle = " " )+
  theme(plot.title=element_text(face="bold", size=9),
        plot.subtitle=element_text( size=8),
        plot.background = element_rect(fill = "transparent",colour = NA),
        #legend.position="top",
        legend.position="bottom",
        legend.title=element_blank(),
        axis.text.x = element_text(angle = 30, vjust = 0.5, hjust=1))
plotfreq.instance.monthyear
ggsave(plotfreq.instance.monthyear, filename="out/assistancetype-instance-monthyear.png",  width=20, dpi=300)




