library(tidyr)

# using the heart dataset and team and homeruns dataset(below)


team=data.frame(First_Name=c("Michael","Francis","Emily"),
                Last_Name=c("Vierra","Lara","Nunn"),
                Age=c(21,20,22), 
                HomeTown=c("Alison Viejo, CA", "San Diego, CA", "Concord,CA")
                )

homeruns=data.frame(Player=c("Mike Trout","Bruce Harper","Jose Bautista"),
                    YR2015=c(41,42,40),
                    YR2014=c(36,13,35),
                    YR2013=c(27,20,28)
                    )


########################################################################################
#                                       seperate() function
########################################################################################

# if your data contains 2 sets of inforamtion in 1 column  you can split them
# something like Excel text to columns

# first: datasetname, second: columnName, third: new col names to split column into (names)
# fourth: the seperator (what split the columns by)
separate(team, HomeTown, c("City", "State"), sep=",")

separate(heart, chest_pain, c("class", "Angina type"), sep="_")

## seperate restecg into 3 columns by separator "_"

########################################################################################
#                                       unite() function
########################################################################################

# opposite of seperate, combining columns

# first: dataset name, second: new col name to unite columns into, third: columns to combine
# fourth: the seperator in the new column

unite(team, "Full Name", c(First_Name, Last_Name), sep=" ")

unite(heart, "exang_disease", c(exang, disease), sep=" ")

## challenge > unite sex & chest_pain by "_" seperator

##########################################################################################
#                                       gather( ) function
##########################################################################################

# rearranging and re-orienting the columns by stacking them into 1 single year column

#first: dataset name, second: new column name (for columns we are stacking into), 
# third: new column names (for values of the stacked columns)
#fourth: columns that we are stacking

homeruns2=gather(homeruns, year, home_runs, YR2015:YR2013)

heart2=gather(heart, heartVAR, heart_Data, c(trestbps, chol, thalach)) 

# combining data of trestbps, chol and thalach into 2 columns so easier to see

##########################################################################################
#                                       spread( ) function
##########################################################################################

#opposite of gather, spreading out the columns
# first: dataset name, second: column to spread across multiple column, 
# third: values multiple columns will take

spread(homeruns2, year, home_runs)

#################################################################################
#                             examples with tidyr
#####################################################################
# first lets create a data frame

data=data.frame(
  time_code=c(20150630,20150630,20150630,20150631,20150631,
              20150701,20150701,20150701,20150702),
  prod_code=c("10_x","12_y","12_z","10_x","12_z","10_y","11_x","10_y","12_z"),
  quantity=c(125,24,78,131,104,119,194,102,97)
)

data2=separate(data,prod_code,c("prodNo","prod_index"),sep="_")

data2p2=gather(data2,prodNo_Qty,prodNo_data,c(prodNo,quantity))
