library(dplyr)

# use the heart dataset

########################## Data structure ################################

glimpse(heart)
lst(heart)
tbl_sum(heart)

na_if()   # converts unwanted values to NA


############################# Select() ###################################

#select() >> select variables >> something like subset (by columns)
# first put dataset name >> then followed by variable name
heartNUM=select(heart,age,trestbps,chol,thalach)
# can be used to rearrange columns if you want >> sequence you specify
heartNUM2=select(heart,trestbps,thalach,chol,age)
heartNUM2=select(heart,chol:disease)  # those from restecg till disease selected

# can be used to drop variable from dataset
heartNUM2=select(heartNUM2,trestbps,thalach, -chol,-age)
heartNUM2=select(heartNUM2,trestbps,-c(thalach,chol,age))

# sometimes can use column index instead of column name
heartNUM=select(heart, 1,2,3,4,5,6)
heartNUM=select(heart, 1:6)
heartNUM=select(heart, c(2,4,7))
heartNUM=select(heartNUM, -2,-3) # delete columns

# use to rename columns
heartNUM=select(heart, "gender"=sex, trestbps, chol) # change sex into gender
heartRN=rename(heart, "gender"=sex)


############################## Filter()####################################

# filter() >> select rows >> something like subset (by rows)
heartNEW1=filter(heart, disease=="negative")  # get the dataset with only ngative disease values
heartNEW2=filter(heart, disease=="negative" & sex=="female", thalach>160)
heartNEW3=filter(heart, chest_pain != "asympt")   # not equal
heartNEW3=filter(heart, chest_pain =="asympt"| sex=="male") # or operator
heartNEW3=filter(heart, chest_pain %in% c("asympt","atyp_angina"))   # in a group


# slice() >> see first 20 rows or from 20:40 rows and so on
slice(heart, 1:20)
slice(heart, 20:40)
slice(heart, 10:nrow(heart))  # from 10th row to end of dataset

############################# add_rownames() ###############################

#check it there are rownames or not
rownames(heart)

# create a new variable called dwightNum
heartNEW4=add_rownames(heart, "dwightNum") # deprecated but still works


############################## mutate() and transmute()######################

# mutate() >> when you want to create new variable which are function of exisiting variables
heartNEW5= mutate(heart, old = age>50) # this will give TRUE or FALSE
heartNEW5= mutate(heart, chol_class=chol/20)
heartNEW5= mutate(heart, chol_class=chol/20, trestbps_class=trestbps/5)

# add multiple and overlapping functions
heartNEW6=mutate(heart, chol_class=chol/20, trestbps_class=trestbps/5, ratio=chol_class-trestbps_class)

# using if_else function in mutate
heartNEW7=mutate(heart, cholLevel=if_else(chol>250,"highrisk","normal"), chol_class=chol/20)
heartNEW7=mutate(heart, cholLevel=if_else(chol>250,"highrisk",(if_else(chol>200, "normal","healthy"))), chol_class=chol/20)

heartNEW8=mutate(heart, cholLevel=if_else(chol>250 & age >50,"highrisk",
                                          if_else(chol>200 & age >40, "normal","healthy")))


# multiple layers of if_else (like in functions)

# transmute works exactly like mutate() except only show the mutated columns
heartNEW8=transmute(heart,chol_class = chol/20, trestbps_class =trestbps/5, ratio=chol_class-trestbps_class)

################################## data_frame #################################

mydataframe = data_frame(line= 1:4,
                        text=c(123,123,123,123),
                        data=c(456,456,456,456))

################################### count() ####################################

count(heart, chest_pain, sort = TRUE)
count(heart, disease, sort=TRUE)

################################### if_else()###################################

# shown above some examples

# if_else can be used replace factors or modify values or replace NA values
# if "Yes" is found will replace with "Sick", "No" replace with "Not Sick", 
# finally NAs values replace with "missing" 

heart$exang=if_else(heart$exang=="yes", "Sick","Not Sick", "missing")
# this is very useful for ETL when we replace "M" with "Male" and so on to standardize data

heart$sex=if_else(heart$sex=="female","F", "M")
heart$sex=if_else(heart$sex %in% c("male","gay"), "reject", "F")


##################################### case_when() ##############################

new_ages <- case_when(
  sim_ages >=  0 & sim_ages <= 3   ~ "Baby",
  sim_ages >  3 & sim_ages <= 5    ~ "Toddler",
  sim_ages >  5 & sim_ages <= 12   ~ "Kid",
  sim_ages >  12 & sim_ages <= 19  ~ "Teenager",
  sim_ages >  19 & sim_ages <= 30  ~ "Twenty something",
  sim_ages >  30 & sim_ages <= 65  ~ "Old'ish",
  sim_ages >  65 & sim_ages <= 90  ~ "Senior",
  sim_ages >  90 & sim_ages <= 125 ~ "Super Hero"
)
print(new_ages)



################################### distinct() and arrange() #####################

# distict() gives unique values or levels

distinct(heart, exang) # gives only 2 levels >> can also be seen in str()
distinct(heart, exang, disease) # look at 2 variables at same time 
distinct(heart,chest_pain, disease)
#like a table, but doesn't give the count

n_distinct(heart$age) # gives the number of distinct ages
n_distinct(heart$exang) # will give 2 for there are only 2 factors
n_distinct(heart$chest_pain)

# arrange() >> reshuffling of data

heartNEW9=arrange(heart, age) # arrange all the rows by the age var number
heartNEW9=arrange(heart, age, thalach) # arrange by age first then thalach
heartNEW9=arrange(heart, desc(age)) # descending order

############################### chaining ###########################################
library(dplyr)
library(ggplot2)

heart %>% select(1:5) %>%
  mutate(chol_class=chol/20, trestbps_class=trestbps/5) %>%
  ggplot(aes(trestbps_class,chol_class)) + geom_point()


heart %>% select(thalach) %>% 
  mutate(thalach_class=thalach/15) %>%
  ggplot(aes(thalach)) + geom_histogram(binwidth = 3, color = "black", fill = "red")


################################### joins()#########################################

# just like in SQL >> look at infographic

A=data.frame(col1=c("A","B","C"), col2=c(seq(1:3)));
B=data.frame(col1=c("A","B","D"), col3=c("T","E","F"));


# Mutating Joins
left_join(A,B, by="col1")  #join matching rows from B to A
right_join(A,B, by="col1") # join matching rows from B to A
inner_join(A,B, by="col1") # join data, retain only rows in both sets)
full_join(A,B, by="col1") # join data, retain all values, all rows)

# Filtering Joins
semi_join(A,B, by="col1")  # all rows in A that have a match in B
anti_join(A,B, by="col1")  # all rows in A that do not have a match in B

################################### sample_n() and sample_frac() #################

sample_n(heart,10) # randomly choose 10 rows from heart dataset
sample_frac(heart, 0.30)  # randomly choose 30% of dataset

# split into test and train data for datascience
train=sample_frac(heart, 0.7)
sid=as.numeric(rownames(train)) # because rownames() returns character
test=heart[-sid,]

################################## top_n() #########################################

heart %>% select(age) %>% top_n(20)

heart %>% select(age) %>% 
  arrange(desc(age)) %>%top_n(20)


lot_physics <- physics_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  group_by(author) %>% 
  top_n(15, tf_idf) %>%
  ungroup %>%
  mutate(author= ....)


################################ summarize() and group_by() ########################

# you can choose your own summary statistics

              summarize(heart,
                       count=n(),
                       avgAge=mean(age, na.rm=TRUE),
                       sdAge=sd(age, na.rm=TRUE),
                       medAge=median(age, na.rm=TRUE),
                       Q3rdAge=quantile(age, .75)
                        )


# disease is the variable which we want to create groups ["positive", "negative"]
groupHeartDisease=group_by(heart, disease)
groupHeartDisease2=group_by(heart, disease, fbs)
# can combine with  other function in R , dplyr

slice(groupHeartDisease2, 1:5)  # gives top 5 rows in each group


# for demonstration we pass into summary statistics >> we get 4 groups
            summarize(groupHeartDisease2,
                       count=n(),
                       avgAge=mean(age, na.rm=TRUE),
                       sdAge=sd(age, na.rm=TRUE),
                       medAge=median(age, na.rm=TRUE),
                       Q3rdAge=quantile(age, .75)
                        )
            
            
# we can modify our summary statsitics to filter off data
            summarize(groupHeartDisease2,
                      avgAge35=mean(age>35, na.rm=TRUE),
                      nobsAge35=sum(age>35, na.rm=TRUE)
                      )
            

heart %>% group_by(disease, chest_pain) %>% 
  summarize(count=n())            
            
            
total_words <- book_words %>% 
  group_by(book) %>% 
  summarize(total = sum(n))



#################################################################################
#                             examples with dplyr
#####################################################################
# first lets create a data frame
            
            data=data.frame(
              time_code=c(20150630,20150630,20150630,20150631,20150631,
                          20150701,20150701,20150701,20150702),
              prod_code=c(10,12,12,10,12,10,11,10,12),
              quantity=c(125,24,78,131,104,119,194,102,97)
            )
            
# first we filter prod_code and selecting time_code and qunatity
library(dplyr)
            
data%>%
  filter(prod_code %in% 10:11)%>%
  select(c(1,3))
            
# next we select sum of quantity group by product code
            
data%>%
  group_by(prod_code)%>%
  summarize(quantity=sum(quantity))%>%
  select(prod_code,quantity)
### must type column names coz i manually keyed it in summrize function

#####################################################################################################
#                                   Connect to database
#####################################################################################################
# this is used to populate a databse with a dataset NOT extract data from the database into R

dwishop=src_mysql(dbname="chinook", user='root', password='nu1977man', host='localhost')

dwishop %>% src_tbls()

dwishop %>% tbl("customer") %>%
 glimpse()


dwishop %>% tbl("customer") %>%
  group_by(City) %>%
  summarise(records = n()) %>%
  arrange(desc(records))

# there is src_postgre; src_sqlite

##### writing in table

remote<-conn %>%
  tbl("database_table_name") %>%
  select(everything()) %>%
  filter(price >= '2000')

## xyz is the database name
compute(remote, name = "xyz", temporary = FALSE)


###### direct SQL commands

con <- DBI::dbConnect(RSQLite::SQLite(), path = ":memory:")
DBI::dbWriteTable(con, "mtcars", mtcars)

db_analyze(con, "mtcars")
# "db_" > list of commands

query= tbl(lahman_m,
          sql("SELECT * FROM Batting WHERE YearID = 2008"))

######################################################################################################
#				Advanced Functions
#######################################################################################################

mtcars%>% select(starts_with("m"))     # columns starting with "m"
mtcars%>% select(ends_with("t"))       # columns ending with "t"
mtcars%>% select(contains("t"))        # columns containing "t"
mtcars%>% select(matches("wt"))        # columns matching "wt"
mtcars%>% distinct(drat)               # rows with distinct values in column
mtcars%>% count(gear, sort=T)%>% top_n(3) #count values in gear column top 3



#explain(dplyr variable) > convert to SQL code


######## set operations

mtcars$model <- rownames(mtcars)
first <- mtcars[1:20, ]
second <- mtcars[10:32, ]

intersect(first, second)
union(first, second)
setdiff(first, second)
setdiff(second, first)

union_all(first, second)
setequal(mtcars, mtcars[32:1, ])