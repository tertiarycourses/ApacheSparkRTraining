air_spark=tbl(sc,"airways")
tbl_cache(sc, "airways", force=T)
sdf_register(air_spark,"air_sparkdf")
air_sparkdf_tbl=tbl(sc, "air_sparkdf")

sdf_describe(air_sparkdf_tbl)   # this will take 1 min

sdf_schema(air_sparkdf_tbl)     # this will take 1 min

sdf_dim(air_sparkdf_tbl)        # this will take 1 min


############################# Query ###################################

# Total Number of Flights Cancelled Each Month

air_sparkdf_tbl %>% select(month, cancelled) %>%
              filter(cancelled == 1) %>%
              group_by(month) %>%
              summarize(count=n()) %>%
  as.data.frame() %>%
  mutate(month=as.integer(month),
         count=as.integer(count)) %>%
   arrange(month) %>% collect()                  
 

# top 5 airports and airline based on activity

air_sparkdf_tbl %>% select(uniquecarrier) %>%
              group_by(uniquecarrier)%>%
              summarize(cnt=n()) %>%
  as.data.frame() %>%
  mutate(uniquecarrier=as.factor(uniquecarrier),
         cnt=as.integer(cnt)) %>%
         arrange(desc(cnt))%>%
         slice(1:5) %>% collect()


air_sparkdf_tbl %>% select(origin) %>%
              group_by(origin) %>%
            summarize(cnt=n()) %>%
  as.data.frame() %>%
  mutate(origin=as.factor(origin),
         cnt=as.integer(cnt)) %>%
  arrange(desc(cnt))%>%
  slice(1:5) %>% collect()

# mean delay for top 5 airlines per year

air_sparkdf %>% select(uniquecarrier,arrdelay,depdelay,
                     carrierdelay,weatherdelay,nasdelay,
                     securitydelay,lateaircraftdelay) %>%
  mutate(totDelay=arrdelay + depdelay + carrierdelay + weatherdelay + nasdelay + securitydelay + lateaircraftdelay) %>%
  group_by(uniquecarrier)%>%
  summarize(cnt=n(),
            meandelay=mean(totDelay)) %>%
  as.data.frame() %>%
  mutate(uniquecarrier=as.factor(uniquecarrier),
         meandelay=as.integer(meandelay),
         cnt=as.integer(cnt)) %>%
  arrange(desc(cnt))%>%
  slice(1:5) %>% collect()




# Top 10 route(origin and dest) that has seen maximum diversions?

air_sparkdf_tbl %>% select(origin, dest, diverted) %>%
  filter(diverted==1) %>%
  group_by(origin, dest) %>%
  summarize(div=n()) %>%
  as.data.frame() %>%
  mutate(origin=as.factor(origin),
         dest=as.factor(dest),
         div=as.integer(div)) %>%
  arrange(desc(div)) %>% slice(1:10) %>%
  collect()
 
############# Challenge #####################

# using dplyr find the following :>
# Total Number of Flights Diverted Each Month
# Which month have seen the most number of cancellation due to bad weather? (cancellationcode=B)
# Top 5 most visited destination.