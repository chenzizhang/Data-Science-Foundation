####################################
# Code reference: Original examples written by James Balamuta for University of Illinois 
# Stat 430: Big Data Analysis Foundations in April 2015.
# Additional comment modifications also made by Darren Glosemeyer in April
# for Stat 480 offering at the University of Illinois.
# Code is modified by Chenzi Zhang in April 21, 2019 
# for Stat 480 homework9 at the University of Illinois.
####################################

# Before starting Exercise 1, install and loading packages. This code is modified from 'theme_river_and_stream_graphs.R'  made by Darren Glosemeyer in April
# for Stat 480 offering at the University of Illinois.

# Any package that is required by the script below is given here:
inst_pkgs = load_pkgs =  c("ggplot2","ggplot2movies", "dplyr","babynames","data.table","Rcpp","devtools", "Ecdat", "circlize", "stringr")
inst_pkgs = inst_pkgs[!(inst_pkgs %in% installed.packages()[,"Package"])]
if(length(inst_pkgs)) install.packages(inst_pkgs)

git_pkgs = git_pkgs_load = c("streamgraph","DT")

git_pkgs = git_pkgs[!(git_pkgs %in% installed.packages()[,"Package"])]

if(length(git_pkgs)){
  library(devtools)
  install_github('rstudio/DT')
  install_github('hrbrmstr/streamgraph')
}

load_pkgs = c(load_pkgs, git_pkgs_load)

# Dynamically load packages
pkgs_loaded = lapply(load_pkgs, require, character.only=T)


############
#Exercise 1#
############
#install.packages("Ecdat")
#library("Ecdat")
#head(Grunfeld)
#dim(Grunfeld)

#1. Investment by firm over time
Grunfeld %>%
  group_by(firm, year) %>% 
  streamgraph("firm", "inv", "year", interactive = TRUE) %>%
  sg_fill_brewer("PuOr") %>%
  sg_legend(show=TRUE, label="firm: ") %>%
  sg_title(title = "Investment by firm over time")

#2. Value by firm over time
Grunfeld %>%
  group_by(firm, year) %>% 
  streamgraph("firm", "value", "year", interactive = TRUE) %>%
  sg_fill_brewer("PuOr") %>%
  sg_legend(show=TRUE, label="firm: ") %>%
  sg_title(title = "Value by firm over time")

#3. Capital by firm over time
Grunfeld %>%
  group_by(firm, year) %>% 
  streamgraph("firm", "capital", "year", interactive = TRUE) %>%
  sg_fill_brewer("PuOr") %>%
  sg_legend(show=TRUE, label="firm: ") %>%
  sg_title(title = "Capital by firm over time")

############
#Exercise 2#
############

#Construct data frame, omitting obs with unknown mpaa
ex2 <- ggplot2movies::movies[-which(ggplot2movies::movies$mpaa == ""),]

#Construct a circular graphic with mpaa values as the sectors
par(mar = c(1, 1, 1, 1), lwd = 0.1, cex = 0.7)
circos.initialize(factors = ex2$mpaa, x = ex2$year)
circos.trackPlotRegion(factors = ex2$mpaa, y = ex2$length, track.height = 0.25, 
                       panel.fun = function(x, y) {
                         circos.axis()
                       })

#1. Scatter plot with movie length as the y coordinate and year as the x coordinate
col = c("#EA7575", "#5FB6B2", "#ADC1DB", "#C3ADDB")
circos.trackPoints(ex2$mpaa, ex2$year, ex2$length, col = col, pch = 16)
circos.text(1968, 1, "left", sector.index = "R", track.index = 1)
circos.text(2004, 1, "right", sector.index = "R")

#2. Add label for the mpaa rating
bgcol = rep(c("#EFEFEF", "#CCCCCC"), 2)
circos.track(ex2$mpaa, ex2$year, ex2$length, bg.col = bgcol, track.height = 0.1,  
             panel.fun = function(x,y){
               sector.index = get.cell.meta.data("sector.index")
               xlim = get.cell.meta.data("xlim")
               ylim = get.cell.meta.data("ylim")
               circos.text(mean(xlim), mean(ylim), sector.index)
             })

#3. Track lines with year as the x coordinate and budget as the y coordinate
ex2 = ex2[-which(is.na(ex2$budget)),] #drop NA in budget
circos.track(factors = ex2$mpaa, x = ex2$year, y = ex2$budget, track.height = 0.2, panel.fun = function(x, y) {
  od = order(x)
  circos.lines(x[od], y[od])
})

#4. Histograms for number of movies made
bgcol = rep(c("#EFEFEF", "#CCCCCC"), 2)
circos.trackHist(ex2$mpaa, ex2$year, bg.col = bgcol, col = col, bin.size = 2)
circos.clear()

############
#Exercise 3#
############
#setwd("~/Stat480/Visualization/")
local = read.csv("LocationData.csv", header = FALSE, stringsAsFactors = FALSE)
colnames(local) = c("depature","terminal")
start = local$depature
end = local$terminal
mat = matrix(0, nrow = length(unique(start)),
             ncol = length(unique(end))
)

rownames(mat) = unique(start)
colnames(mat) = unique(end)
for(i in seq_along(start)) mat[start[i], end[i]] = mat[start[i], end[i]] + 1
sorted.labels = sort(union(start, end))
chordDiagram(mat, order = sorted.labels, directional = 1)
circos.clear()

############
#Exercise 4#
############
detect = c("North", "Midwest", "South")
for(i in 1:3){
  start[str_detect(start, detect[i])] = detect[i]
  end[str_detect(end, detect[i])] = detect[i]
}
mat = matrix(0, nrow = length(unique(start)),
             ncol = length(unique(end))
)

rownames(mat) = unique(start)
colnames(mat) = unique(end)
for(i in seq_along(start)) mat[start[i], end[i]] = mat[start[i], end[i]] + 1
sorted.labels = sort(union(start, end))
chordDiagram(mat, order = sorted.labels, directional = 1)
circos.clear()

