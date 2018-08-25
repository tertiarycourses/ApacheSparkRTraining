
heart_spark=tbl(sc,"heart")
tbl_cache(sc, "heart", force=T)
sdf_register(heart_spark,"heart_sparkdf")
heart_sparkdf_tbl=tbl(sc, "heart_sparkdf")

sdf_describe(heart_sparkdf_tbl)   # this will take 1 min

sdf_schema(heart_sparkdf_tbl)     # this will take 1 min

sdf_dim(heart_sparkdf_tbl)        # this will take 1 min

# there are many sdf_ functions simply > sparklyr::sdf_ to see them

glimpse(heart_sparkdf_tbl)



################ DATA FRAME

# data frame API with function that begin with sdf_ prefix, machine learning library
# with "feature transformation" functions that begin with ft_ prefix
# and machL functions that begin with ml_ prefix

# case1: binarize chol to higher than 100 (value 1) otherwise(0) 
# and convert to logical (TRUE or FALSE)
heart_sparkdf_tbl %>% select(chol) %>% 
                            mutate(chol=as.double(chol)) %>%
                            ft_binarizer("chol","highrisk", threshold=200) %>%
                            collect() %>%
                            ggplot() + aes(highrisk) + geom_bar()



# case2: converting a continous into categorical
# split the horsepower into 4 parts > define the split and the names
heart_sparkdf_tbl %>% select(chol) %>% mutate(chol=as.double(chol)) %>%
                                 ft_bucketizer("chol","chol_splits", splits=c(0,200,350,500,650))%>%
                                                      collect() %>%
                                                      mutate(chol_levels=factor(chol_splits, labels=c("low","med","high","vHigh"))) %>%
                                 ggplot() + aes(x=chol_levels, y=chol) + geom_boxplot()              



######### DATA CONVERSION AND SAMPLING

# case1: sorting > an alternative to dplyr arrange > does same thing but faster
sorted=heart_sparkdf_tbl %>% sdf_sort(c("chol","thalach","disease","restecg","chest_pain")) %>% collect()


# case2: converting spark df into dataframe (list)
schema_heart=sdf_schema(heart_sparkdf_tbl)
schema_heart %>% lapply(data.frame, stringsAsFactors=F) %>% bind_rows()


# case3: sampling the data
heart_sparkdf_tbl %>% sdf_sample(0.1, replacement=F, seed=100) %>%
                        compute("heart_sample")
                        # stores as temporary table called "heart_sample"
