#install.packages("ggplot2")
#install.packages("AzureML")
library(AzureML)
library(ggplot2)
library(MASS)
library(car)

#data(package='MASS')
# setwd("/Users/Shep/git/SQLShepBlog/data")
# getwd()
# 
# write.csv(Robey, file="Robey.csv")
# write.csv(mtcars, file="mtcars.csv")
# write.csv(birthwt, file="birthwt.csv")

##########################################################
# Explore the imported data 
##########################################################

data(Robey)
View(Robey)
summary(Robey)

##########################################################
# Check for linearity assumption
##########################################################

#plot y contraceptors and x tfr
plot(Robey$tfr,Robey$contraceptors, # plthe ot X axis and y axis
     xlab="Fertility or Children/Woman",  #X axis label
     ylab="Percent on Contraception", #Y axis label
     pch=20, #shape of dot (1-20)
     cex=2, #size - int
     col="black")  #Color
#run a linear regressoin line through it to see if it is somewhat linear
abline(lm(Robey$contraceptors~Robey$tfr),
       lwd=4,col="red") # line widwth

#  GLM calls lm, so no need to run it twice
#robey.glm <- glm(contraceptors~tfr, data=Robey)
#summary(robey.glm)

# create a model 
robey.lm <- lm(contraceptors~tfr, data=Robey)
summary(robey.lm)

#mean Absolute error
mean(abs(robey.lm$residuals))
names(robey.lm)

##Root Mean Squared Error
sqrt(mean(residuals(robey.lm)^2))

# R Squared 
summary(robey.lm)$r.squared 

# Adjusted R Squared 
summary(robey.lm)$adj.r.squared

# Look for normal distribution in the hist
hist(robey.glm$residuals,breaks=10,col= "lightblue")

# For some reason, AMl uses abs fo rthe histogram
# You cannot check for normal distribution this way
# Aml os wrong, but here is how you ge there. 
hist(abs(robey.glm$residuals),breaks=10,col= "lightblue")

# ggplot with confidence interval around line 95% CI
ggplot(data=Robey, aes(x=tfr, y=contraceptors)) + 
  geom_smooth(method='lm',level=.00) +
  geom_point(aes(colour=factor(region))) 

# Perform a predictin with a tfr = 5.5 
predict(robey.lm,list(tfr=c(5.5)))


##########################################################################
##########################################################################
# Birth Weight
##########################################################################


#data(package='MASS')

data(birthwt)
View(birthwt)
?birthwt

#create pounds column to match AML input
birthwt$pounds <- birthwt$bwt/453.592

ggplot(data=birthwt, aes(x=pounds, y=age)) + 
  geom_point()+
  geom_smooth(method='lm',level=.95) 

ggplot(data=birthwt, aes(x=pounds, y=lwt)) + 
    geom_point()+
    geom_smooth(method='lm',level=.95) 


#birthwt.lm1 <- lm(pounds~age, data=birthwt)
#summary(birthwt.lm1)

birthwt.lm2 <- lm(pounds~age+lwt, data=birthwt)
summary(birthwt.lm2)

hist(birthwt.lm2$residuals,breaks=10, col= "lightblue")
hist(abs(birthwt.lm2$residuals),breaks=10, col= "lightblue")

## Plot the residuals
plot(birthwt$pounds, birthwt.lm2$residuals) 
abline(0, 0)                 
abline(2*sd(birthwt.lm2$residuals), 0, col="red",lty=5) 
abline(-2*sd(birthwt.lm2$residuals), 0, col="red",lty=5) 


# predict something using age and weight, dataframe required "c"
a <- c(22,34)
b <- c(125,135)
c <- data.frame(a,b)

names(c)[1] <- paste("age") 
names(c)[2] <- paste("lwt")

predict(birthwt.lm2,c)

##########################################################################
##########################################################################
#
#  Connect R to Azure ML   :p
#
##########################################################################

#Create workspace variable
ws <- workspace(
  id  <- "your id",
  auth  <- "your auth"
)

# list datasets 
head(datasets(ws))
datasets(ws)

head(ws$experiments,10)

webservices <- services(ws,name = "Birth Weight [Predictive Exp.]")

ep <- endpoints(ws, webservices[1, ])

class(ep)

names(ep)

a <- c(22,34)
b <- c(125,135)
c <- c(0,0)
d <- data.frame(a,b,c)

names(d)[1] <- paste("age") 
names(d)[2] <- paste("lwt")
names(d)[3] <- paste("pounds")


s <- services(ws, name = "Birth Weight [Predictive Exp.]")
s <- tail(s, 1) # use the last published function, in case of duplicate function names
ep <- endpoints(ws, s)

consume(ep, d)

##########################################################################
##########################################################################
#
#  Mtcars 
#
##########################################################################
# Demo 1 Explore the data 
##########################################################################

hist(mtcars$mpg,breaks=12, col='lightblue') 
plot(density(mtcars$mpg),lty=1,lwd=1, col='red')

ggplot(data=mtcars, aes(mpg)) +
  geom_histogram(bins=15,aes(y =..density..),
                 #breaks=seq(5, 40, by = 2),
                 col="black",
                 fill='blue',
                 alpha = .2) +
  geom_density(col='red') 

mtcars.lm1 <- lm(mpg~disp+wt+qsec+hp,data=mtcars)
summary(mtcars.lm1)

hist(mtcars.lm1$residuals,breaks=10)

ColNames <- c("cyl","vs","am","gear","carb")
mtcars[ColNames] <- lapply(mtcars[ColNames], factor)

mtcars.lm2 <- lm(mpg~disp+wt+qsec+hp+cyl+drat+vs+am+gear+carb,data=mtcars)
summary(mtcars.lm2)

hist(mtcars.lm2$residuals,breaks=10)
hist(abs(mtcars.lm2$residuals),breaks=10)

plot(mtcars.lm2)

