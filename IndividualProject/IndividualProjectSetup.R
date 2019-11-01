# The following setup code is based on the code for Chapter 3 of 
# 
# Nolan, Deborah and Temple Lang, Duncan. Data Science in R: A Case Studies Approach to 
# Computational Reasoning and Problem Solving. CRC Press, 2015. 
# http://rdatasciencecases.org/
#
# The first 2 .rda files are attached to the assignment in compass,
# and contain msgWordsList and trainTable results obtained in 
# Chapter 3.
#
# Load the data file containing msgWordsList
load("~/Stat480/RDataScience/Chapter3/msgWordsList.rda")

# Load the data file containing trainTable
load("~/Stat480/RDataScience/Chapter3/trainTable.rda")

# Load the data frame .rda files from the chapter
load("~/Stat480/RDataScience/Chapter3/emailXX.rda")
load("~/Stat480/RDataScience/Chapter3/spamAssassinDerivedDF.rda")


# Basic computations needed for random test indices
numEmail = length(emailDF$isSpam)
numSpam = sum(emailDF$isSpam)
numHam = numEmail - numSpam

# Set a particular seed, so the results will be reproducible.
set.seed(418910)

# Take approximately 1/3 of the spam and ham messages as our test spam and ham messages.
testSpamIdx = sample(numSpam, size = floor(numSpam/3))
testHamIdx = sample(numHam, size = floor(numHam/3))


# LLR and Type I/II error functions likely useful for exercises
computeMsgLLR = function(words, freqTable) 
{
  # Discards words not in training data.
  words = words[!is.na(match(words, colnames(freqTable)))]
  
  # Find which words are present
  present = colnames(freqTable) %in% words
  
  sum(freqTable["presentLogOdds", present]) +
    sum(freqTable["absentLogOdds", !present])
}


typeIErrorRates = 
  function(llrVals, isSpam) 
  {
    # order the llr values and spam indicators
    o = order(llrVals)
    llrVals =  llrVals[o]
    isSpam = isSpam[o]
    
    # get indices for ham 
    idx = which(!isSpam)
    N = length(idx)
    # get the error rates and llr values for the ham indices
    list(error = (N:1)/N, values = llrVals[idx])
  }


typeIIErrorRates = function(llrVals, isSpam) {
  
  o = order(llrVals)
  llrVals =  llrVals[o]
  isSpam = isSpam[o]
  
  
  idx = which(isSpam)
  N = length(idx)
  list(error = (1:(N))/N, values = llrVals[idx])
}


# Function to replace logical variables with factor 
# variables for recursive partitioning
setupRpart = function(data) {
  logicalVars = which(sapply(data, is.logical))
  facVars = lapply(data[ , logicalVars], 
                   function(x) {
                     x = as.factor(x)
                     levels(x) = c("F", "T")
                     x
                   })
  cbind(facVars, data[ , - logicalVars])
}