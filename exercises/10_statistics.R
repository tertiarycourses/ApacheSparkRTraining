library(broom)

air_spark=tbl(sc,"airways")
tbl_cache(sc, "airways", force=T)
sdf_register(air_spark,"air_sparkdf")
air_sparkdf_tbl=tbl(sc, "air_sparkdf")

## correlation
## is there a relationship between taxi in and taxi out

air_sparkdf_tbl %>%
  select(taxiin, taxiout) %>%
  filter(!is.na(taxiin)) %>%
  filter(!is.na(taxiout)) %>%
  as.data.frame() %>%
  collect() %>%
  do(tidy(cor(.$taxiin, .$taxiout)))


# t-test
# is there a difference bewteen distance flight of those cancelled
# by code A and code B

air_sparkdf_tbl %>%
  select(distance, cancellationcode) %>%
  filter(cancellationcode %in% c("A","B")) %>%
  mutate(distance=as.numeric(distance),
         cancellationcode=as.character(cancellationcode)) %>%
  as.data.frame() %>%
  collect() %>%
  do(tidy(t.test(distance ~ cancellationcode, data=.))) %>%
  View()
gc()

## anova
# is there a difference betweeen flights in the 4 quarters of the year
# are there more flights in certain periods of the year ?

air_sparkdf_tbl %>%
  select(distance, month) %>%
  mutate(quarter=ifelse(month %in% c(1,2,3),1,
                        ifelse(month %in% c(4,5,6),2,
                               ifelse(month %in% c(7,8,9),3,4)))) %>%
  collect() %>%
  mutate(distance = as.numeric(distance),
         month=factor(month),
         quarter=factor(quarter)) %>%
  as.data.frame()%>%
  do(tidy(aov(distance ~ quarter, data=.))) %>%
  View()
gc()


######################## using groupings ########################
library(broom)
library(purrr)

air_sparkdf_tbl %>%
  select(taxiin, taxiout, dayofweek) %>%
  filter(!is.na(taxiin)) %>%
  filter(!is.na(taxiout)) %>%
  collect() %>%
  nest(-dayofweek) %>%
  mutate(test=map(data, ~ cor(.x$taxiin, .x$taxiout)),
         tidied=map(test, tidy)
         )%>%
unnest(tidied, .drop=TRUE) %>%
  arrange(dayofweek) %>%
  View()



air_sparkdf_tbl %>%
  select(distance, cancellationcode, dayofweek) %>%
  filter(cancellationcode %in% c("A","B")) %>%
  collect() %>%
  mutate(distance=as.numeric(distance),
         cancellationcode=as.character(cancellationcode)) %>%
  nest(-dayofweek)%>%
  mutate(test=map(data, ~ t.test(.x$distance ~ .x$cancellationcode)),
         tidied=map(test,tidy)
  )%>%
  unnest(tidied, .drop=TRUE) %>%
  arrange(dayofweek) %>%
  View()


################## challenge ##################

# using dplyr and statistic answer the following :>

## is there a relationship between distance and lateaircraftdelay
# do longer distance flights always arrive late?


# is the weather delay the same for months of april and may?
# is there a difference


# is the relationship between distance and lateaircraft delay
# the same for every month?




