
air_spark=tbl(sc,"airways")
tbl_cache(sc, "airways", force=T)
sdf_register(air_spark,"air_sparkdf")
air_sparkdf_tbl=tbl(sc, "air_sparkdf")


####################### DATA ANALYSIS ##################################

# plot how many flights per uniquecarrier fill color by DaysOfWeek
air_sparkdf_tbl %>%
  count(uniquecarrier, dayofweek) %>%
  as.data.frame() %>%
  mutate(uniquecarrier=as.factor(uniquecarrier),
         dayofweek=as.integer(dayofweek),
         n=as.integer(n)) %>%
  ggplot()+aes(x=factor(uniquecarrier),
               y=n, 
               fill=factor(dayofweek))+
  geom_bar(stat="identity")


# plot mean Distance only with valid cancellation code, by DayOfWeek
air_sparkdf_tbl %>% 
  select(dayofweek,distance,cancellationcode) %>%
  filter(cancellationcode %in% c("A","B","C","D")) %>%
  group_by(dayofweek, cancellationcode)%>%
  summarize(count=n(),
            meanD=mean(distance, na.rm=TRUE)) %>%
  as.data.frame() %>%
  mutate(cancellationcode=as.factor(cancellationcode),
         dayofweek=as.integer(dayofweek),
         count=as.integer(count),
         meand=as.integer(meanD)) %>%
  ggplot() +
  aes(x=factor(dayofweek), y=meand) +
  geom_boxplot()


# plot arrival delays by month

air_sparkdf_tbl %>% select(month,arrdelay) %>%
  ggplot() + aes(month,arrdelay) + geom_violin(aes(group=month)) +
  labs(y="Arrival Delay (in minutes)") +
  ggtitle("Arrival flight Arrival delay by month")


################ Challenge ###############

#plot how many flights with valid cancellation code by months and  
#fill color with cancellation code

