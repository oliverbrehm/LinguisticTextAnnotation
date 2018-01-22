scenario3 = "
Dokumentation Zeitaufwand Intuitivität
3 2 2
2 1 2
2 2 1
4 4 4
1 1 2
4 4 4
1 1 2
"

#I Z D
#2 2 3
#2 1 2
#1 2 2
#4 4 4
#2 1 1
#4 4 4
#2 1 1

Data = read.table(text=scenario3,header=TRUE)
Data[Data==1] <- "trifft zu"
Data[Data==2] <- "trifft eher zu"
Data[Data==3] <- "weder noch"
Data[Data==4] <- "trifft eher nicht zu"
Data[Data==5] <- "trifft nicht zu"


### Change Likert scores to factor and specify levels

l = c("trifft zu", "trifft eher zu", "weder noch", "trifft eher nicht zu", "trifft nicht zu")
#l = c("1", "2", "3", "4", "5")

Data$Intuitivität = factor(Data$Intuitivität,
                       levels = l,
                       ordered = TRUE)

Data$Zeitaufwand = factor(Data$Zeitaufwand,
                       levels = l,
                       ordered = TRUE)

Data$Dokumentation = factor(Data$Dokumentation,
                       levels = l,
                       ordered = TRUE)

library(likert)
result = likert(Data)

colors = c('#47DB70', '#AFFFC5', '#DDDDDD', '#EB7D7E', '#DB181A')

plot(result, type="bar", col=colors)
