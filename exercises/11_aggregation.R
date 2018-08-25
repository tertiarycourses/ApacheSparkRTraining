######################################################
# -------------- AGGREGATION --------------------------
######################################################

air_spark=tbl(sc,"airways")
tbl_cache(sc, "airways", force=T)
sdf_register(air_spark,"air_sparkdf")
air_sparkdf_tbl=tbl(sc, "air_sparkdf")

######### grouping

air_sparkdf_tbl %>%
  select(dayofweek, distance) %>%
  filter(!is.na(dayofweek)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>% 
  groups() %>%   # see the groups
  collect()

air_sparkdf_tbl %>%
  select(dayofweek, distance) %>%
  filter(!is.na(dayofweek)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>% # see members in group
  group_size() %>%
  collect()

######### Cumulative

# cumulative sum

air_sparkdf_tbl %>%
  select(dayofweek, distance) %>%
  filter(!is.na(dayofweek)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>%
  mutate(running = cumsum(distance)) %>%
  collect()
  
# cumulative min

air_sparkdf_tbl %>%
  select(dayofweek, distance) %>%
  filter(!is.na(dayofweek)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>%
  mutate(running = cummin(distance)) %>%
  collect()

# cumulative max

air_sparkdf_tbl %>%
  select(dayofweek, distance) %>%
  filter(!is.na(dayofweek)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>%
  mutate(running = cummax(distance)) %>%
  collect()

########### Summarize

air_sparkdf_tbl %>%
  select(dayofweek, distance, weatherdelay) %>%
  filter(!is.na(dayofweek)) %>%
  filter(!is.na(weatherdelay)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>% 
  summarise_all(funs(mean)) %>%   # for all the columns
  collect()


air_sparkdf_tbl %>%
  select(dayofweek, distance, weatherdelay) %>%
  filter(!is.na(dayofweek)) %>%
  filter(!is.na(weatherdelay)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>% 
  summarise_at(vars(weatherdelay), funs(mean)) %>% # for selected columns only
   collect()


air_sparkdf_tbl %>%
  select(dayofweek, distance, weatherdelay, origin) %>%
  filter(!is.na(dayofweek)) %>%
  filter(!is.na(weatherdelay)) %>%
  arrange(dayofweek) %>%
  group_by(dayofweek) %>% 
  summarise_if(
    function(x) is.numeric(x), funs(mean)) %>% 
  collect()                 # for numeric columns only


############# Ranking

air_sparkdf_tbl %>%
  select(distance) %>%
  collect() %>%
  as.data.frame() %>%     # arrange lowest to highest
  ntile(3) %>% table()    # break your data into 3 parts
                      


air_sparkdf_tbl %>%
  select(distance) %>%
  collect() %>%
  as.data.frame() %>%     # arrange lowest to highest
  min_rank() %>% head()   # order data from lowest to highest



air_sparkdf_tbl %>%
  select(distance) %>%
  collect() %>%
  as.data.frame() %>%     # arrange lowest to highest
  cume_dist() %>% head()  # order data from lowest to highest

#CUME_DIST calculates the cumulative distribution of a value in a group of values


############ Challenge

# Using dplyr find the following :>

# find the cumulative max of distance grouped by dayofweek and month arranged in order of month

# find the summary table for mean and max of weatherdelay and distance