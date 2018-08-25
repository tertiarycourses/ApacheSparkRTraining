############# connect to spark with LIVY server ##############
#devtools::install_github("rstudio/sparklyr")   # pls install latest version

library(sparklyr)
library(dplyr)
library(ggplot2)
library(readr)

#$/home/cloudera/livy/bin/livy-server start (stop)
# $  sudo R
# library(sparklyr)
# livy_service_start(spark_version="1.6.0") / livy_service_stop()

#$ ifconfig to check your IP address

##### memory allocation
# you must know how many instance, cores and Gb memory you have
conf=spark_config()
conf$`spark.driver.memory`="3G"                    #2G
conf$`spark.driver.cores`=1                        #1
conf$`spark.yarn.driver.memoryOverhead`="384m"     #384m
conf$`spark.executor.instances`=2                  #2
conf$`spark.executor.cores`=1                      #1        
conf$`spark.executor.memory`="3G"                  #2G
conf$`spark.yarn.executor.memoryOverhead`="384m"   #384m
conf$`spark.memory.fraction`=0.7    #0.75
#conf$`sparklyr.shell.files` = "/usr/lib/hive/conf/hive-site.xml"
#conf$`spark.sql.hive.metastore` ="/home/alessandro/spark-warehouse"
#conf$`hive.metastore.warehouse.dir`= "/home/alessandro/spark-warehouse"

# Driver is responsible for task scheduling 
# Executor is responsible for executing the concrete tasks in your job.

#executor-memory > amount of data spark can cache
#                  contorl heap size
#                  and max size of the shuffle data structures 
#                  (eg grouping, aggregation, joins)
#executor-cores > no of cores to invoke spark-submitm spark-shell
#                  no of concurrent task that can run at the same time
# memory.fraction > higher allocated more to storage/execution > rest user memory

conf2=livy_config(user="", 
                  password="", 
                  config=conf)

sc <- spark_connect(master="192.168.1.118:8998",    # connect to spark
                    method="livy",    # this will take 5minutes
                    spark_version="1.6.0",
                    config=conf2)


### EMR
# spark_connect("master=spark://ip-xxx-xx-x-xxx.eu-west-1.compute.internal:7077",
#              config=config)



spark_disconnect(sc) # disconnect from spark
#spark_disconnect_all()

############## setting Hive tables ###############

## check hive tables
src_tbls(sc)
# look at the databases
src_databases(sc)
# change from default database
tbl_change_db(sc,"default")  # click refresh button in UI

############## setting Spark tables ###############

#link to the heart table in Spark > create spark data frame
air_spark=tbl(sc,"airways")

############## caching

# Force a Spark table with name name to be loaded into memory
tbl_cache(sc, "airways", force=T)

# Force a Spark table with name name to be unloaded from memory
tbl_uncache(sc, "airways")

############## spark web UI

#You can view the Spark web console using the spark_web function:

spark_web(sc)


################# configuration ################

spark_home_dir()
spark_installed_versions()
spark_version(sc) # what version of spark
spark_log()