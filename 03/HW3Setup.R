# The following initial code is based on the code for Chapter 3 of 
# 
# Nolan, Deborah and Temple Lang, Duncan. Data Science in R: A Case Studies Approach to 
# Computational Reasoning and Problem Solving. CRC Press, 2015. 
# http://rdatasciencecases.org/
#
# the original code is provided on
# http://rdatasciencecases.org/Spam/code.R
# 
# Modifications are by Darren Glosemeyer for the Spring 2016 through 2019 sections of 
# Stat 480: Data Science Foundations at the University of Illinois at Urbana-Champaign.
#
# The contents of this include segments of code from Chapter 3 up through section 3.5.4.
#
# The following lines from previous sections are needed to define sampleSplit, getBoundary,
# and dropAttach.
spamPath = "~/Stat480/RDataScience/SpamAssassinMessages"

dirNames = list.files(path = paste(spamPath, "messages", 
                                   sep = .Platform$file.sep))
fullDirNames = paste(spamPath, "messages", dirNames, 
                     sep = .Platform$file.sep)

indx = c(1:5, 15, 27, 68, 69, 329, 404, 427, 516, 852, 971)
fn = list.files(fullDirNames[1], full.names = TRUE)[indx]
sampleEmail = sapply(fn, readLines)

splitMessage = function(msg) {
  splitPoint = match("", msg)
  header = msg[1:(splitPoint-1)]
  body = msg[ -(1:splitPoint) ]
  return(list(header = header, body = body))
}

sampleSplit = lapply(sampleEmail, splitMessage)

getBoundary = function(header) {
  boundaryIdx = grep("boundary=", header)
  boundary = gsub('"', "", header[boundaryIdx])
  gsub(".*boundary= *([^;]*);?.*", "\\1", boundary)
}

dropAttach = function(body, boundary){
  
  bString = paste("--", boundary, sep = "")
  bStringLocs = which(bString == body)
  
  # if there are fewer than 2 beginning boundary strings, 
  # there is on attachment to drop
  if (length(bStringLocs) <= 1) return(body)
  
  # do ending string processing
  eString = paste("--", boundary, "--", sep = "")
  eStringLoc = which(eString == body)
  
  # if no ending boundary string, grab contents between the first 
  # two beginning boundary strings as the message body
  if (length(eStringLoc) == 0) 
    return(body[ (bStringLocs[1] + 1) : (bStringLocs[2] - 1)])
  
  # typical case of well-formed email with attachments
  # grab contents between first two beginning boundary strings and 
  # add lines after ending boundary string
  n = length(body)
  if (eStringLoc < n) 
    return( body[ c( (bStringLocs[1] + 1) : (bStringLocs[2] - 1), 
                     ( (eStringLoc + 1) : n )) ] )
  
  # fall through case
  # note that the result is the same as the 
  # length(eStringLoc) == 0 case, so code could be simplified by 
  # dropping that case and modifying the eStringLoc < n check to 
  # be 0 < eStringLoc < n
  return( body[ (bStringLocs[1] + 1) : (bStringLocs[2] - 1) ])
}




# Set the working directory. This is where R will look for files and save files if a full path is not specified.
setwd("~/Stat480/RDataScience/Chapter3")

####################################################################################
