library(maps)
library(mapdata)
library(ggplot2)


all_states <- map_data("state")
alaska<-map_data("world", regions = "USA:Alaska")
hawaii<-map_data("world", regions = "USA:Hawaii")

#qplot(long, lat, geom="polygon", data=hawaii, group=group)


#adjust order/group
alaska$order<-max(all_states$order) + alaska$order
alaska$group<-max(all_states$group) + alaska$group
hawaii$order<-max(alaska$order) + hawaii$order
hawaii$group<-max(alaska$group) + hawaii$group

#move alaska
alaska$region<-"alaska"
alaska$long<-alaska$long + 40
alaska$long[alaska$long>0]<-alaska$long[alaska$long>0] - 360
alaska$lat<-alaska$lat-35

#move hawaii
hawaii$region<-"hawaii"
hawaii$lat<-hawaii$lat + 3
hawaii$long<-hawaii$long + 70

#rescale alaska
alaska$lat<-(alaska$lat-mean(alaska$lat))/3 + mean(alaska$lat)
alaska$long<-(alaska$long-mean(alaska$long))/3 + mean(alaska$long)


#combine into single df
all_states_al_hi<-rbind(all_states,alaska,hawaii)

#plot
qplot(long, lat, geom="polygon", data=all_states_al_hi, group=group) 
