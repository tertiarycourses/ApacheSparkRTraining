############# copy data to impala ###############

library(DBI)
library(dbplyr)
library(odbc)
library(ggplot2)
library(dplyr)
library(RODBC)
library(readr)

### wait for the hive server to start in your VM > takes about 10 minutes
# $ifconfig


impalacon=dbConnect(drv = odbc::odbc(),
                     driver = "Cloudera ODBC Driver for Impala",
                     host = "192.168.1.124",
                     port = 21050,
                     database = "default")

dbListTables(impalacon)
dbRemoveTable(impalacon, "airways")

dbDisconnect(impalacon)

################# airlines dataset ####################

# *** hadoop is designed for large datasets only
#     small datasets will not perform well
#     usually for datasets 10GB and above only


#### loop

# for dbWriteTable
# the following data types are accepted (from DBI documentation):
  
#integer
#numeric
#logical for Boolean values (some backends may return an integer)
#NA
#character
#factor (bound as character, with warning)
#Date
#POSIXct timestamps
#POSIXlt timestamps
#lists of raw for blobs (with NULL entries for SQL NULL values)
#objects of type blob::blob


air1="http://stat-computing.org/dataexpo/2009/2008.csv.bz2"


library(RCurl) 
download.file(air1, destfile = "air1.csv.bz2", method="curl")
air1="air1.csv.bz2"
#specify the column types
spec_csv(air1)



air=c(air1) # specify your files
tbl="airways"

for(i in air){                       # WARNING ! -- THIS WILL TAKE 45 minutes
  library(R.utils)
  n1=length(count.fields(i))
  n2=floor(n1/250000)
  print("bz2 file unzipping")
  bunzip2(i, "mydata.csv", remove=F, skip=T)   # unzip the bz2 file
  print("bz2 file finished unzipped")
  print("csv file being read")
 df22=read.csv("mydata.csv", header=T, sep=",", 
              dec=".", stringsAsFactors=F,
              na.strings=NA)
  print("csv file finished read")
  print(paste("there are",n1,"rows in this file"))
  colNames=names(df22)
  for(j in 0:n2){
    jn=j * 250000                 # we insert data in chunks of 10000 rows
    j1=jn+1
    j2=jn+250000
    tryCatch({
      dd22=df22[j1:j2,]},
      error=function(e){dd22=df22[j1:n1,]}
    )
    # if(nrow(dd22)==0L) return(FALSE)
    colnames(dd22)=colNames
    if(j==0 & i==air[1]){
      dbCreateTable(conn=impalacon,
                    name=tbl,
                    fields=dd22,
                    row.names = NULL,
                    temporary=F)
      print(paste("table",tbl,"created"))
    }else{
      tryCatch({
        dbWriteTable(conn=impalacon,
                     name=tbl,
                     value=dd22,
                     row.names=F,
                     temporary=F,
                     append=T)},
        error=function(e)NA)
      print("250000 rows appended")
    }
    rm(dd22); gc();
  }
  rm(df22); file.remove("mydata.csv")
  print("mydata.csv file removed")
}


### testing
impalacon %>% tbl("airways") %>%
  select(distance, dayofweek) %>%
  filter(!is.na(distance)) %>%
  filter(!is.na(dayofweek)) %>%
  group_by(dayofweek) %>% 
  summarize(ss=sum(distance)) %>%
  as.data.frame() %>%
  mutate(dayofweek=as.factor(dayofweek),
         ss=as.integer(ss)) %>% 
  ggplot()+ aes(x=dayofweek, y=ss) + geom_bar(stat="identity")


### retrieve data

# collect() executes the query and returns the results to R.

# compute() executes the query and stores the results in a temporary table in the database.
# compute(name="table1", temporary=FALSE)
# impala doesn't support temporary tables


################# heart dataset ####################
    
heart=read.csv(file.choose())   # import heart dataset
    df22=heart
    colNames=names(df22)
    dbCreateTable(conn=impalacon,
                  name="heart",
                  fields=df22,
                  row.names = NULL,
                  temporary=F)
    dbWriteTable(conn=impalacon,
                 name="heart",
                 value=df22,
                 row.names=F,
                 temporary=F,
                 overwrite=T)
    rm(df22); gc()
    

###################### retrieve data
    
    # collect() executes the query and returns the results to R.
    
    # compute() executes the query and stores the results in a temporary table in the database.
    # compute(name="table1", temporary=FALSE)
    # impala doesn't support temporary tables
    
    
    # collapse() turns the query into a table expression.
    # generates an SQL query which you can use later on
