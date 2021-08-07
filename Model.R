#set work directory 
setwd("~/Dropbox/My Mac (XU的MacBook Air)/Desktop/MMM")

#read data
AF <- read.csv('AF_Final_with Transformation.csv',header = TRUE)
AF[,1] = as.Date(AF$Period,'%m/%d/%y')

plot(AF$Period, AF$Sales, type='l')

#create some dummy values: to mark the spike of special dates as 1
#first peak --Black Friday
AF$Black_Friday = 0
AF[which(AF$Period=='2014-11-24'),'Black_Friday'] = 1
AF[which(AF$Period=='2015-11-30'),'Black_Friday'] = 1
AF[which(AF$Period=='2016-11-28'),'Black_Friday'] = 1
AF[which(AF$Period=='2017-11-27'),'Black_Friday'] = 1
sum(AF$Black_Friday) # check 4 spikes

#second peak --July 4th
AF$July_4th = 0
AF[which(AF$Period=='2014-07-07'),'July_4th'] = 1
AF[which(AF$Period=='2015-07-06'),'July_4th'] = 1
AF[which(AF$Period=='2016-07-04'),'July_4th'] = 1
AF[which(AF$Period=='2017-07-03'),'July_4th'] = 1
sum(AF$July_4th) # check 4 spikes

#Build Model 
#Step 1: Baseline Model (if without marketing campaigns, what factor impact sales)
model1 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday)
summary(model1)

#Step2: add campaigns based on spending - TV
model2 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday+NationalTV2)
summary(model2)

#Step3: add campaigns based on spending - Paid search
model3 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday+NationalTV2+PaidSearch1)
summary(model3)

#Step4: add campaigns based on spending - Wechat
model4 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday+NationalTV2+PaidSearch1+Wechat2)
summary(model4)

#Step5: add campaigns based on spending - Magazine
model5 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine2)
summary(model5)

#Step6: add campaigns based on spending - Display
model6 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine2+Display3)
summary(model6)

#Step7: add campaigns based on spending - FB
model7 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine2+Display3+Facebook1)
summary(model7)

#check VIF
# In regression, "multicollinearity" refers to predictors that are correlated with other predictors.  Multicollinearity occurs when your model includes multiple factors that are correlated not just to your response variable, but also to each other. In other words, it results when you have factors that are a bit redundant.
# Variance inflation factor (VIF) is used to detect the severity of multicollinearity in the ordinary least square (OLS) regression analysis.)
#If the VIF is equal to 1 there is no multicollinearity among factors
#If the VIF is greater than 1, the predictors may be moderately correlated.
#A VIF between 5 and 10 indicates high correlation that may be problematic. And if the VIF goes above 10, you can assume that the regression coefficients are poorly estimated due to multicollinearity.
install.packages('car')
library('car')
vif(model7)#all vif of each variables < 3, which variables are moderately corelated-> accetaable

#AVM --actrual vs model
AVM = cbind.data.frame(AF$Period, AF$Sales,model7$fitted.values)
colnames(AVM) = c('Period','Sales','Modeled Sales') #change column name
write.csv(AVM,file = 'AVM1.csv', row.names=F)

#MAPE
MAPE = abs(AVM$Sales-AVM$`Modeled Sales`)/AVM$Sales
mean(MAPE)

#Calculate & Export contribution 
model7 =  lm (data = AF, Sales ~ CCI + Sales.Event + July_4th + Black_Friday+NationalTV2+PaidSearch1+Wechat2+Magazine2+Display3+Facebook1, x=TRUE) # x means aggregated the variables to a new column
View(model7$x)
model7$coefficients
contribution =  sweep(model7$x,2,model7$coefficients,"*") #different dimensions multiply
View(contribution)
contribution =  data.frame(contribution)
contribution$Perid = AF$Period
names(contribution) = c(names(model7$coefficients),'Period')

#Transform to long format to better visualize in Tableau
install.packages('reshape')
library(reshape)
contri = melt(contribution, id.vars = "Period")
View(contri)
write.csv(contri, file ='contribution.csv',row.names = F)


# remove environment 
rm(list = ls())
