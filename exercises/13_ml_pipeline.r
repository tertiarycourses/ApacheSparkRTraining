### MLlib functions

# * suggest restart everyting * 

ml_decision_trees()
ml_random_forest()
ml_linear_regression()
ml_kmeans()
ml_naive_bayes()
ml_logistic_regression()
ml_multilayer_perceptron()
ml_pca()
ml_survival_regression()


### here we use the heart dataset because
#   there are too many NAs in the airlines dataset
#    which will interfere with the machine learning

heart_spark=tbl(sc,"heart")
tbl_cache(sc, "heart", force=T)
sdf_register(heart_spark,"heart_sparkdf")
heart_sparkdf_tbl=tbl(sc, "heart_sparkdf")

###################### model pipeline

#Requires that all predictors be compressed into a single vector column.
#Requires that the response column be numeric, even for classification problems.


partition_heart=sdf_partition(heart_sparkdf_tbl, training=0.7,
                              testing=0.3)   
sdf_register(partition_heart,c("heart_train",
                               "heart_test"))
# this will take 2 minutes

train_heart=tbl(sc,"heart_train") 
test_heart=tbl(sc,"heart_test")

model=ml_logistic_regression(train_heart, disease ~.)  
# this will take 10 minutes
model


ml_predict(model, test_heart) %>% head()
   select(disease, label, prediction, predicted_label) %>% head()



################## vector assembler

# A transformer that concatenates columns into a vector column.

vector_assb = ft_vector_assembler(sc, 
                                  input_cols=c("age","chol","thalach","trestbps"), 
                                  output_col="features")  
# all col names except disease > which is features
# does not support string column (categorical) > need to convert to dummy

vector_assb %>% ml_transform(train_heart) %>% glimpse()


################ string indexer

#An estimator to encode the disease column into a numeric column

string_indexer = ft_string_indexer(sc, "disease", "label")

string_indexer_model = string_indexer %>%
  ml_fit(train_heart)

string_indexer_model %>%
  ml_transform(train_heart) %>%
  select(disease, label) %>%
  head()

labels = ml_labels(string_indexer_model)
labels

########################### PIPELINE MODEL ######################

pipeline <- ml_pipeline(
  vector_assb,
  string_indexer_model
) %>%
  ml_logistic_regression() %>%
  ft_index_to_string("prediction", "predicted_label",
                     labels = labels)
# this will take 5 minutes

pipeline



pipeline_model = pipeline %>% ml_fit(train_heart)

pipeline_model %>% ml_transform(test_heart) %>% glimpse()

### saving our model

ml_save(pipeline_model, "path/to/model")

pipeline_model = ml_load(sc, "path/to/model")

#Reports on a schedule
#Automatic model refreshes
#Batch predictions over an API