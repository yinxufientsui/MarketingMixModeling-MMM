#set work directory
setwd('C:/MarTech')

#read data
data = read.csv("MMM_AF.csv", header =TRUE)
data <- read.csv("MMM_AF.csv", header =TRUE)

#update period column to date format
data$Period   = as.Date(data$Period, '%m/%d/%Y')
data[,'Period']

#data type
a = c(1:4) #vector
c(1,'A',3)
b = matrix(data = 2, nrow=2,ncol=2) #matrix
data #dataframe
c = array(0, dim = c(2,2,2)) #array
d = list(a, b,c)

#missing value
a = c(1, NA,3)
is.na(a)
sum(a, na.rm=TRUE)
mean(a, na.rm=TRUE)

#install packages
install.packages("ggplot2")
library (ggplot2)

#line chart
plot(data$Period, data$Sales, type='l', xlab = 'Period', ylab = 'Sales')

#add another line
par (new = TRUE) #add another line on the previous line
plot(data$Period, data$Sales.Event, type='l', col='green', xlab = "",ylab="", axes =FALSE)
axis (side=4)

#scatter plot
plot(data$Facebook.Impressions, data$Sales, xlab = 'FB', ylab = 'Sales')

#correlation matrix
correl = cor(data[,c(-1,-2)])
write.csv(correl, file='correl.csv')

#correlation matrix chart
install.packages('corrplot')
library ("corrplot")
corrplot(correl, tl.cex=0.7, tl.col = 'black')
