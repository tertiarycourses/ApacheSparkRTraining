library(ggplot2)

# 1a. Line plot
ggplot(dahc.lab2) + aes(x=TG, y = TC) + geom_point()

# 1b. Line plot with colour and different shape
ggplot(dahc.lab2) + aes(x=TG, y = TC) + geom_point(size=4, colour="green")
# defining the size and colour
ggplot(dahc.lab2) + aes(x=TG, y = TC, colour=factor(BloodPressure)) + geom_point()  # different colour based on vs column
# this column vs values is only 1 or 0...so we put factor
ggplot(dahc.lab2) + aes(x=TG, y = TC, colour=HDL) + geom_point()
# now we have a range of values, so we get rid of factor part
ggplot(dahc.lab2) + aes(x=TG, y = TC, colour=factor(BloodPressure), shape=factor(ETHNIC), size=SBP) + geom_point()
# using multiple variables

# 2. Bar Plot
ggplot(dahc.lab2, aes(x = factor(BloodPressure))) + geom_bar(width = 0.5, color = "black", fill = "red")

# mean.mpg <- tapply(mtcars$mpg, mtcars$cyl, mean)
# mean.mpg
# names(mean.mpg)
# ggplot( mean.mpg, aes(x = factor( cyl), y = mean(mpg))) + 
#   geom_bar(stat = "identity", width = 0.5, color = "black", fill = "red")

# 3. Histogram
ggplot(dahc.lab2, aes(x = TG)) + geom_histogram(binwidth = 3, color = "black", fill = "red")
# using bin width
ggplot(dahc.lab2, aes(x = TG)) + geom_histogram(bins = 10, color = "black", fill = "red")
# using number of bins


# 4. Boxplot
ggplot(dahc.lab2, aes(x = factor(BloodPressure), y = TG)) + 
  geom_boxplot(width = 0.6, color = "black", fill = "red")
# divide by factor, other all the values in one plot
ggplot(dahc.lab2, aes(x = TC, y = TG)) + 
  geom_boxplot(width = 0.9, color = "black", fill = "red")  

# 5. scatter plot
ggplot(dahc.lab2) + aes(x=TC, y=BMI) + geom_point()

## Setting the size of the points in the scatter plot
ggplot(dahc.lab2) + aes(x=TC, y=BMI) + geom_point(size=3)

## Setting the color of the points in the scatter plot
ggplot(dahc.lab2) + aes(x=TC, y=BMI) + geom_point(size=3, colour = "blue")

## Setting the shape of the points in the scatter plot
ggplot(dahc.lab2) + aes(x=TC, y=BMI) + geom_point(size=3, colour = "blue", shape = 17)

## Changing labels
ggplot(dahc.lab2) + aes(x=TC, y=BMI) + geom_point() +
  labs(x = "TC", y = "BMI", title = "TC vs BMI") +
  theme(axis.text = element_text(colour = "blue"),
        axis.title = element_text(size = rel(1.5), angle = 0),
        plot.title = element_text(size = rel(2.5), colour = "green"))
  
## Changing x and y scale
ggplot(dahc.lab2) + aes(x=TC, y=BMI) + geom_point() +
  scale_x_continuous(limits = c(100,350)) +
  scale_y_continuous(limits = c(5,35))


## Grouping data points by variable
ggplot(dahc.lab2) + aes(x=TC, y=BMI, colour = HDL ) + 
  geom_point(size=3, shape = 17)

ggplot(dahc.lab2) + aes(x=TC, y=BMI, colour = factor(BloodPressure) ) + 
  geom_point(size=3, shape = 17)

ggplot(dahc.lab2) + aes(x=TC, y=BMI, colour = factor(BloodPressure), shape = factor(ETHNIC)) + 
  geom_point(size=2)

ggplot(dahc.lab2) + aes(x=TC, y=BMI, colour = factor(BloodPressure), shape = factor(ETHNIC)) + 
  geom_point(size=5) + scale_shape_manual(values = c(4,5,6,7))

ggplot(dahc.lab2) + aes(x=TC, y=BMI, colour = factor(BloodPressure), shape = factor(ETHNIC)) + 
  geom_point(size=2) + scale_shape_manual(values = c(17,18,19,20)) +
  scale_colour_brewer(palette = "Set1")

## Adding trend line
ggplot(dahc.lab2) + aes(x=TC, y=TG) + 
  geom_point(size=3, colour = "blue", shape = 17) +
  stat_smooth(method = "lm")

ggplot(dahc.lab2) + aes(x=TC, y=TG) + 
  geom_point(size=3, colour = "blue", shape = 17) +
  stat_smooth(method = "lm", se = FALSE)


## Faceting 1
ggplot(dahc.lab2) + aes(x=TC, y=TG) + 
  geom_point(size=3, colour = "blue", shape = 17) +
  facet_grid(. ~ BloodPscale)  # plot by columns

ggplot(dahc.lab2) + aes(x=TC, y=TG) + 
  geom_point(size=3, colour = "blue", shape = 17) +
  facet_grid( BloodPscale ~ .)   # plot by rows

ggplot(dahc.lab2) + aes(x=TC, y=TG) + 
  geom_point(size=3, colour = "blue", shape = 17) +
  facet_grid( BloodPscale ~ ETHNIC) #plot interaction btw BloodPscale and Ethnic


# 6. Setting legend properties using guide
ggplot(mtcars) + aes(x=wt, y = mpg, col = factor(am), shape = factor(cyl)) +
  geom_point(size = 3) + guides(col = guide_legend('am'), shape=guide_legend('cyl'))

# 7. Setting axis properties using theme
ggplot(mtcars) + aes(x=wt, y = mpg, col = factor(am), shape = factor(cyl)) +
  geom_point(size = 3) + guides(col = guide_legend('am'), shape=guide_legend('cyl')) +
  theme(axis.text=element_text(size = 15), axis.title=element_text(size=20))


## 8. Plotting subset of data in a separate panel: Facetting
ggplot(mtcars) + aes(x=wt, y=mpg) + 
  geom_point(size=3, color = "blue", shape = 17) +
  facet_wrap( ~ cyl)


## waterfall chart

# sample data

balance=data.frame(id=seq(1,8), desc=c("Start cash", "Sales","Refunds","Payouts","Losses","Wins","Contracts","End cash"),
                   type=c("net","in","out","out","out","in","in","net"),
                   start=c(0,2000,5400,4300,4200,-2400,1400,2800),
                   end=c(2000,5400,4300,4200,-2400,1400,2800,0),
                   amount=c(2000,3400,-1100,-10,-6600,3800,1400,2800))

ggplot(balance, aes(desc, fill=type)) + geom_rect(aes(x=desc, xmin=id -0.45, xmax=id + 0.45, ymin=end, ymax=start))



## Bubble plot

ggplot(mtcars, aes(carb,gear, size=mpg, label=vs)) + geom_point(colour="red") + geom_text(size=3) + xlab("mtcars CARB") + ylab("mtcars GEAR")

ggplot(mtcars, aes(wt,mpg)_ + geom_point(aes(size=qsec))

#### heat maps
ggplot(mtcars, aes(x=wt, y=gear, group=gear)) + geom_tile(aes(fill=mpg)) + scale_fill_gradient(low="white", high="red")

ggplot(iris, aes(x=Sepal.Length, y=Sepal.Width, group=Species)) + geom_tile(aes(fill=Petal.Length)) + scale_fill_gradient(low="white", high="red")


## Consultant chart

country=c("Australia","Canada","USA","Germany","France","Brazil","China",
          "India","Indonesia","Africa")

dd3=data.frame(var=country, value=sample(10, replace=T))
ggCONSULT=ggplot(dd3, aes(x=factor(var),y=value,fill=factor(var))) + geom_bar(width=1, stat='identity')+
  scale_y_continuous(breaks = 0:10) + coord_polar() + labs(x = "", y = "") + 
  theme(legend.position = "none",axis.text.x =element_blank(), axis.text.y = element_blank(),
  axis.ticks = element_blank()) +
  geom_text(aes(x=var, y=value, label=var))


## facet wrap

plot_austen %>% 
  group_by(book) %>% 
  top_n(15) %>% 
  ungroup %>%
  ggplot(aes(word, tf_idf, fill = book)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~book, ncol = 2, scales = "free") +
  coord_flip()


## others

tweet_bing %>% group_by(airline, sentiment) %>% summarize(freq= mean(n)) %>%
                spread(sentiment, freq) %>% ungroup() %>%
                mutate(ratio= positive/negative, airlines=reorder(airline, ratio)) %>%
                ggplot(aes(airline,ratio)) + geom_point() + coord_flip()