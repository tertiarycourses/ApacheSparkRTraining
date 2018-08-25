
#### convert to spark dataframe

spark_write_table(sc,"airways") 
# writes a spark data frame into a spark table
#mode="overwrite", "append"

spark_read_table(sc, "airways", memory=TRUE)  
#Reads from a Spark Table into a Spark DataFrame
# memory=TRUE > shoule the df be cahced
# creates a new spark df object

spark_save_table(sc, path_to_file)   
# saves as spark df and as a file
#mode=overwrite_append
#"hdfs://","s3a://","file://"

############## copy data to spark #################

# read/write data from/to /S3/HDFS
spark_read_csv(sc, "table","hdfs:///<path>")  
 s3n:///   #(need AWS access/secret in env)    
 file:///
  
## write results to local
spark_write_csv(myresults,"local_csv_file/results.csv", header=TRUE)

# copy to SPARK from R env (very slow)
heart_spark=copy_to(sc, heart,"heart", overwrite=T)
diamonds_spark=copy_to(sc, diamonds, "diamonds", overwrite=T)
# returns a sparkDF


# copy to SPARK from csv (very slow)
spark_read_csv(sc,"heart",file.choose(), memory="FALSE")  # choose a CSV file


######################################################
#                 TRANSFORMING SPARK DF
######################################################

sdf_register(x, name)   #registeing sparkDF giving it a tbl name

# the family of functions prefixed with sdf_ uses scala spark
# DF api such that the returning tbl_spark object
# will no longer be attached to lazy SQL operations.
# operations need collect() to be executed.


# cache load the results into an Spark RDD in memory so any
# analysis will not nede to be re-read and retransofrm the original
# file.

air_spark=tbl(sc,"airways")   # from hive table

tbl_cache(sc, "airways", force = TRUE) # cache a hive table
# loads the results into an Spark RDD 
tbl_uncache(sc,"airways")
# releases from memory


############ data manipulation

# you can manipulate  spark DF like any other DF

sdf_bind_cols()    # binding many sparkDF into one
sdf_bind_rows()   # appending spark DFs into one

sdf_coalesce() # break sparkDF into partitions

sdf_mutate() # mutate a sparkDF

sdf_separate_column()
sdf_read_column()

# there are many sdf_ functions simply > sparklyr::sdf_ to see them

sdf_collect(air_sparkDF)  # collects sparkDF into R


glimpse(air_sparkDF)


### retrieve data

# collect() executes the query and returns the results to R.

# compute() executes the query and stores the results in a temporary table in the database.
# compute(name="table1", temporary=FALSE)
# impala doesn't support temporary tables


# collapse() turns the query into a table expression.
# generates an SQL query which you can use later on
