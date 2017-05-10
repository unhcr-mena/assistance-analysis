source("code/0-packages.R")
## Lib

### generate a few initial graphs

#names(assistance.case)

assistance.case <- fread( file = "data/assistancecase.csv",na="")

## Reparse correctly the date
assistance.case$ProvidedDate <- as.Date(as.character(assistance.case$ProvidedDate), "%Y-%m-%d")

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
  ggtitle("Asisstance Type")+
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
  ggtitle("Asisstance Type per instance")+
  theme(plot.title=element_text(face="bold", size=9),
        plot.background = element_rect(fill = "transparent",colour = NA))

plotfreq.instance

ggsave(plotfreq.instance, filename="out/assistancetype-instance.png",  dpi=300)




#### hsitogramme
assistance.case2$ProvidedDate2 <- as.POSIXct(assistance.case2$ProvidedDate)

p <- ggplot(assistance.case2, aes(ProvidedDate2, ..count..)) + 
  geom_histogram() +
  theme_bw() + 
  xlab(NULL) +
  scale_x_datetime(breaks = date_breaks("3 months"),
                   labels = date_format("%Y-%b"),
                   limits = c(as.POSIXct("2014-03-01"), 
                              as.POSIXct("2017-03-01")) )

p


# convert the Date to its numeric equivalent
# Note that Dates are stored as number of days internally,
# hence it is easy to convert back and forth mentally
assistance.case2$ProvidedDate.num <- as.numeric(assistance.case2$ProvidedDate1)

bin <- 60 # used for aggregating the data and aligning the labels

p <- ggplot(assistance.case2, aes(ProvidedDate.num, ..count..)) +
     geom_histogram(binwidth = bin, colour="white") +

    # The numeric data is treated as a date,
    # breaks are set to an interval equal to the binwidth,
    # and a set of labels is generated and adjusted in order to align with bars
    #scale_x_date(     breaks = seq(min(assistance.case2$ProvidedDate.num)-20, # change -20 term to taste
                                   max(assistance.case2$ProvidedDate.num), 
                                   bin),
                     # labels = date_format("%Y-%b"),
                     # limits = c(as.Date("2014-03-01"), as.Date("2017-03-01"))
                     # ) +
                      theme_bw() #+ 
                     # xlab(NULL)  
p


### Histogram by date

assistance.bydate <- as.data.frame(table(assistance.case2$ProvidedDate1, assistance.case2$AssistanceType))
assistance.bydate$Var1 <- as.Date(as.character(assistance.bydate$Var1), "%Y-%m-%d")

#,sum(AssistanceType))

bydate <-  ggplot(assistance.bydate,
                  aes(x=format(Var1,"%d-%b")), y = Freq) + 
                    geom_bar(stat="identity") +
                    labs(x="Date")
bydate

ggsave(bydate, "out/bydate.png", width=15, height=8,units="in", dpi=300)
