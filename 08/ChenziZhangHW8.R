#Command line code in 'ChenziZhangHW8.R' was modified by Chenzi Zhang from R help for heatmap. 
#It is also based on code segments written by James Balamuta for University of Illinois course Stat 430 Big Data Analysis Foundations in Spring 2015 
#and Darren Glosemeyer's codes 'heatmaptreemapdensityplot.R' for University of Illinois course Stat 480 Data Science Foundations in Spring 2019. 

############
#Exercise 1#
############
data("USArrests")
library(gplots)
y = as.matrix(USArrests)
row.names(y) = state.abb
colnames(y) = paste(colnames(y),"Rate", sep = " ")
colnames(y)[3] = "Urban Population"

heatmap.2(y, scale = "column", trace = "none", 
          density.info = "none", dendrogram="row", col = cm.colors(256), 
          cexRow = 0.3, cexCol = 0.8,
          xlab="crime rate and population", ylab="state", main="US Arrest Heatmap")

############
#Exercise 2#
############
library(treemap)
y = cbind(as.data.frame(y), as.character(state.region), state.abb)
colnames(y)[5] = 'Region'
colnames(y)[6] = 'State'

treemap(y,
        index=c("Region", "State"),
        vSize="Urban Population",
        vColor="Assault Rate",
        type="value")

treemap(y,
        index=c("Region", "State"),
        vSize="Assault Rate",
        vColor="Urban Population",
        type="value")

############
#Exercise 3#
############
treemap(y,
        index=c("Region", "State"),
        vSize="Murder Rate",
        vColor="Assault Rate",
        type="value")

treemap(y,
        index=c("Region", "State"),
        vSize="Assault Rate",
        vColor="Murder Rate",
        type="value")

############
#Exercise 4#
############
library(MASS)
fit0 = kde2d(y$`Murder Rate`, y$`Assault Rate`, h = c(5,100))
contour(fit0, col = topo.colors(20), xlab = 'Murder Rate', ylab = 'Assault Rate', main = 'Kernal Density Estimates')

fit1 = kde2d(y$`Murder Rate`, y$`Urban Population`, h = c(5,25))
contour(fit1, col = topo.colors(20), xlab = 'Murder Rate', ylab = 'Urban Population', main = 'Kernal Density Estimates')

fit2 = kde2d(y$`Assault Rate`, y$`Urban Population`, h = c(100,25))
contour(fit2, col = topo.colors(20), xlab = 'Assault Rate', ylab = 'Urban Population', main = 'Kernal Density Estimates')

############
#Exercise 5#
############
library(foreach)
n = nrow(y)
regionId <- split(1:n, y[, "Region"])
fitall <- foreach(regionInd = regionId) %do% {
  kde2d(y[regionInd, "Murder Rate"], y[regionInd, "Assault Rate"])
}

nregion = length(levels(y$Region))
par(mfrow = c(nregion/2,nregion/2))
for(i in 1:nregion){
  contour(fitall[[i]]$x, fitall[[i]]$y, fitall[[i]]$z,col = topo.colors(20), xlab = 'Murder Rate', ylab = 'Assault Rate', main = paste(levels(y$Region)[i],'Kernal Density Estimates', sep = " "))
}
