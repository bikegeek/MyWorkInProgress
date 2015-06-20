proj2 <- function(){
      library(dplyr)
      library(reshape2)
      library(ggplot2)
      #Set the working diretory
      setwd("~/Coursera/ReproducibleResearch/Project2")

      #unzip and open the csv file
      #data.file <- bzfile("repdata_data_StormData.csv.bz")
     # data.file <- "repdata_data_StormData.csv"
      data.file <- "subdata.csv"
      raw.data <- read.csv(data.file, sep=",", header=TRUE, stringsAsFactors=FALSE)

      #Replace any NAs with 0
      raw.data[is.na(raw.data)] <- 0

      #Subset data to the columns that are pertinent to our analysis:
      #event type (EVTYPE), property damage (PROPDMG, PROPDMGEXP), crop
      #damage(CROPDMG, CROPDMGEXP), fatalities (FATALITIES), injuries (INJURIES).
      #We will also focus on just the 50 states (omitting the U.S. territories)
      #and we will use the begin date to get the year information, so we can
      #look at the trends through the years.

      #Subset on columns

      # dplyr
      selected.data <- select(raw.data, BGN_DATE,STATE,EVTYPE,PROPDMG,PROPDMGEXP,CROPDMG,CROPDMGEXP,FATALITIES,INJURIES)

      #Subset for the 50 states. Get a list of the unique states, the first 50
      #are the ones we want.
      states <- unique(selected.data$STATE)
      us <- head(states,50)

      #Now subset the selected.data dataframe to include only the 50 US states.


      # dplyr
      us.only <- filter(selected.data, STATE %in% us)

      #Convert the BGN_DATE string to a Date type and obtain the year.
      # We may want to use the year if we plan on doing an analysis that
      # looks at the data over each year.
      datetimes <- strptime(us.only$BGN_DATE, "%m/%d/%Y %H:%M:%S")
      years <- format(datetimes,format="%Y")
      years <- as.numeric(years)

      # dplyr
      us.only <- mutate(us.only, YEAR=c(years))

      #Convert the FATALITIES and INJURIES to numeric types so we can
      #calculate sums and means.
      fatalities <- as.numeric(us.only$FATALITIES)
      injuries <- as.numeric(us.only$INJURIES)
      us.only$FATALITIES <- fatalities
      us.only$INJURIES <- injuries

      #Convert the PROPDMG and CROPDMG columns to numeric types so we can
      #calculate the dollar value of damage.
      props <- as.numeric(us.only$PROPDMG)
      crops <- as.numeric(us.only$CROPDMG)
      us.only$PROPDMG <- props
      us.only$CROPDMG <- crops

      #Convert the codes in the PROPDMGEXP and CROPDMGEXP columns into numeric
      #values.  'K' = 1000, 'M' = 1,000,000 , 'B' = 1,000,000,000 and blank
      #is set to 1.  Create a vector of these values, append them to the
      #us.only dataframe and then multiply the PROPDMG/CROPDMG to the corresponding
      #PROPDMGEXP/CROPDMGEXP column to obtain the total cost in U.S. dollars.
      #Save these results to a new row in us.only, named PROPCOST and CROPCOST,
      #respectively.
      prop.multiplier <- c()
      for(i in 1:length(us.only$PROPDMG)){
            if( us.only[i,5] == 'B'){
                  #Set billions
                  prop.multiplier <- append(prop.multiplier, c(1000000000))
            }
            else if( us.only[i,5] == 'M'){
                  #Set millions
                  prop.multiplier <- append(prop.multiplier, c(1000000))
            }
            else if( us.only[i,5] == 'K'){
                  #Set thousands
                  prop.multiplier <- append(prop.multiplier, c(1000))
            }
            else{
                  #Blank, this is set to 1, so we will use the actual
                  #amount in the PROPDMG column as is.
                  prop.multiplier <- append(prop.multiplier, c(1))
            }

      }


      #Repeat for the CROPDMGEXP column
      crop.multiplier <- c()

      for(i in 1:length(us.only$CROPDMG)){
            if( us.only[i,7] == 'B'){
                  #Set billions
                  crop.multiplier <- append(crop.multiplier, c(1000000000))
            }
            else if( us.only[i,7] == 'M'){
                  #Set millions
                  crop.multiplier <- append(crop.multiplier, c(1000000))
            }
            else if( us.only[i,7] == 'K'){
                  #Set thousands
                  crop.multiplier <- append(crop.multiplier, c(1000))
            }
            else{
                  #Blank, this is set to 1, so we will use the actual
                  #amount in the PROPDMG column as is.
                  crop.multiplier <- append(crop.multiplier, c(1))
            }

      }

      #Make the crop.multiplier a numeric vector before we add it to the us.only
      #data frame
      crop.mult <- as.numeric(crop.multiplier)


      #Make the prop.multiplier a numeric vector before we add it to the us.only
      #data frame
      prop.mult <- as.numeric(prop.multiplier)



      # use dplyr to create new columns for the calculated cost of damage.
      us.only <- mutate(us.only, PROPMULT=c(prop.mult))
      us.only <- mutate(us.only, PROPCOST=PROPDMG*PROPMULT)
      us.only <- mutate(us.only, CROPMULT=c(crop.mult))
      us.only <- mutate(us.only, CROPCOST=CROPDMG*CROPMULT)

      #Calculte the totals for property damage and health impacts. These
      #will be used to subset the data further.
      us.only <- mutate(us.only, TOTALCOST=CROPCOST+PROPCOST)
      us.only <- mutate(us.only, TOTALHEALTH=FATALITIES+INJURIES)
      #total.cost <- sum(us.only$PROPCOST,us.only$CROPCOST)
      #us.only <- mutate(us.only, TOTALCOST = c(total.cost))
     # total.health <- sum(us.only$FATALITIES,us.only$INJURIES)
     # us.only <- mutate(us.only, TOATLHEALTH = c(total.health))

      #Create new dataframes for damages and health based on the relevant
      #data.
      us.data <- select(us.only, YEAR, EVTYPE, PROPCOST, CROPCOST, FATALITIES,INJURIES )
      us.damages <- select(us.only, EVTYPE, PROPCOST,CROPCOST,TOTALCOST)
      us.health <- select(us.only,  EVTYPE, FATALITIES, INJURIES,TOTALHEALTH)


      #Now generate plots to answer question1: Which event type(s) are the most
      #harmful to U.S. human health?
      #In other words, over the entire data set (all years available and the 50
      #U.S. states only), what are the average/mean number
      #of fatalities and what are the mean number of injuries for each
      #event type?

      # First, melt the data, then cast so that we can readily calculate the
      # average number of Fatalities and the average number of Injuries for
      # each event type. Subset data so we don't get overwhelmed with too
      # many event types, therefore, only include the events where the
      # total health impacts are above or equal to the mean.

      #Calculate the mean value for total health impact (sum of the mean
      #injuries and mean fatalities) to be used as subetting criteria.
      mean.health.total <- mean(us.health$TOTALHEALTH, na.rm=TRUE)
      us.health.sub <- subset(us.health, TOTALHEALTH >= mean.health.total)

      melted.us.health <- melt(us.health.sub, id=c("EVTYPE"),measure=c("FATALITIES","INJURIES"))
      mean.us.health <- dcast(melted.us.health,EVTYPE~variable,mean)
      mean.us.health.long <- melt(mean.us.health)

      #Generate the bar plot of the fatalities and injuries based on event.
      png(file="./health_impact.png",width=480, height=480)
      p1<-ggplot(mean.us.health.long, aes(EVTYPE,value,fill=variable))+
            geom_bar(stat="identity",position="dodge")+
            theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+
            xlab("Event Type") + ylab("Number of people") +
            ggtitle("Health impacts of U.S. Weather Events averaged from 1950-2011")+
            coord_flip()
      print(p1)
      dev.off()

    #Answer question 2, which event types have the most economic impact?
    #Generate a plot of the event type vs. cost, broken down by property
    #damage and crop damage.
    # First, melt the data, then cast so that we can readily calculate the
    # average number of Fatalities and the average number of Injuries for
    # each event type.

    #Calculate the mean cost of total damage (property and crop), and use this
    #as a criteria for subsetting the data.
    mean.property <- mean(us.damages$TOTALCOST,na.rm=TRUE)
    print(cat("Mean property damage: ", mean.property))
    us.damages.sub <- subset(us.damages, TOTALCOST >= mean.property)
    melted.us.damage <- melt(us.damages.sub, id=c("EVTYPE"),measure=c("PROPCOST","CROPCOST"))
    mean.us.damage <- dcast(melted.us.damage,EVTYPE~variable,mean)
    mean.us.damage.long <- melt(mean.us.damage)

    #Format the property cost and crop cost values so ggplot2 doesn't
    #generate warnings about changing widths for bar size.
    formatted.propcost <- format(mean.us.damage.long$PROPCOST, digits=2)
    formatted.cropcost <- format(mean.us.damage.long$CROPCOST, digits=2)
    print(head(mean.us.damage,10))

    #Generate the bar plot of property cost and crop cost due to event.
    png(file="./economic_impact.png",width=480,height=480)
    p2 <-ggplot(mean.us.damage.long, aes(EVTYPE,value,fill=variable))+
          geom_bar(stat="identity",position="dodge")+
          theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+
          xlab("Event Type") + ylab("Cost in U.S. Dollars") +
          ggtitle("Economic Impact of U.S. Weather Events averaged from 1950-2011")+
          coord_flip()
    print(p2)
    dev.off()

    #Summary of the max average property damage, crop damage, number of fatalities, and number of
    #injuries
    max.property <- max(mean.us.damage$PROPCOST)
    max.crop <- max(mean.us.damage$CROPCOST)
    max.fatalities <- max(mean.us.health$FATALITIES)
    max.injuries <- max(mean.us.health$INJURIES)
    print(cat("Max mean property damage: ", max.property, " Max mean crop damage: ", max.crop,
              " Max average number fatalities: ", max.fatalities, " Max average number of injuries: ",
               max.injuries))

}
