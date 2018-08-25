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
tbl_uncache(sc,"airways") # remove from spark memory
library(DBI)
dbRemoveTable(sc, "air_sparkdf")
# click refresh tables icon

heart_spark=tbl(sc,"heart")
tbl_cache(sc, "heart", force=T)
sdf_register(heart_spark,"heart_sparkdf")
heart_sparkdf_tbl=tbl(sc, "heart_sparkdf")

partition_heart=sdf_partition(heart_sparkdf_tbl, training=0.7,
                              testing=0.3)   
sdf_register(partition_heart,c("heart_train",
                               "heart_test"))
# this will take 2 minutes

train_heart=tbl(sc,"heart_train") 
test_heart=tbl(sc,"heart_test")


###### decision tree ##############

dd = setdiff(colnames(heart_sparkdf_tbl),"disease")

model_heart_dt=train_heart %>% ml_decision_tree(response="chest_pain",
                                                features=dd)
# this will take 10 minutes

summary(model_heart_dt)

pred_heart_dt=ml_predict(model_heart_dt, test_heart) %>% collect
# this will take 2 minutes

pred_heart_dt2=pred_heart_dt %>%filter(!prediction=="")


library(ggplot2)
library(gridExtra)
p1= ggplot(pred_heart_dt2)+aes(chol,age, col=factor(chest_pain))+
  geom_point() + ggtitle("actual")
p2= ggplot(pred_heart_dt2)+aes(chol,age, col=factor(prediction))+
  geom_point() + ggtitle("test DTree")

grid.arrange(p1,p2, ncol=1)


newChest=as.numeric(as.factor(pred_heart_dt2$chest_pain))-1

library(caret)
xtab=table(newChest, pred_heart_dt2$prediction)
confusionMatrix(xtab)

mean(newChest==pred_heart_dt2$prediction)

gc()

######## linear regression ##################

dd2=c("age","chol","thalach","trestbps")

model_heart_lm=train_heart %>% ml_linear_regression(response="trestbps",
                                             features=dd2)
# this will take 10 minutes
summary(model_heart_lm)

pred_heart_lm=ml_predict(model_heart_lm, test_heart) %>% 
  collect()
# this will take 2 minutes

library(ggplot2)
ggplot(pred_heart_lm)+aes(trestbps,prediction)+geom_point()

RMSE = function(m, o){
  sqrt(mean((m - o)^2))
}
#m is for model (fitted) values, o is for observed (true) values.

RMSE(pred_heart_lm$prediction, pred_heart_lm$trestbps)

gc()

################## logistic regression ######################

dd3=c("age","chol","thalach","trestbps","disease")

model_heart_log=train_heart %>% ml_logistic_regression(response="disease",
                                                  features=dd3)
# this will take 10 minutes
summary(model_heart_log)

pred_heart_log=ml_predict(model_heart_log, test_heart) %>% collect
# this will take 2 minutes

library(ggplot2)
library(gridExtra)
p3=ggplot(train_heart)+aes(age,chol, col=factor(disease))+
  geom_point()
p4=ggplot(pred_heart_log)+aes(age,chol, col=factor(disease))+
  geom_point()
grid.arrange(p3,p4, ncol=1)

gc()

################## kmeans #######################

dd4=c("age","chol","thalach","trestbps")

model_heart_km = train_heart %>% ml_kmeans(centers=3,
                                           features=dd4)
                  # this will take 10 minutes
summary(model_heart_km)

train_heart_km=ml_predict(model_heart_km, train_heart) %>% collect
# this will take 2 mins
pred_heart_km=ml_predict(model_heart_km, test_heart) %>% collect
# this will take 2 mins

library(ggplot2)
library(gridExtra)
p5 = train_heart_km  %>%
  ggplot() + aes(age,chol, color=factor(prediction)) +
  geom_point() + ggtitle("train Kmean")
p6 = pred_heart_km  %>%
  ggplot() + aes(age,chol, color=factor(prediction)) +
  geom_point() + ggtitle("test Kmeans")
grid.arrange(p5,p6, ncol=1)

gc()


######## challenge

# 2 > do a random forest regression using chol as the predictor
#     plot your results using ggplot2 


