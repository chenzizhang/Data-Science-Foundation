# The following is based on the code for Chapter 3 of 
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

# This first chunk of code is needed to define a few utility functions and get results for 
# Naive Bayes probabilities and logodds based on words in messages. In retrospect, it probably
# would have been useful to store the word lists and the probability and logodds table to 
# R data files.
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

library(tm)
stopWords = stopwords()
cleanSW = tolower(gsub("[[:punct:]0-9[:blank:]]+", " ", stopWords))
SWords = unlist(strsplit(cleanSW, "[[:blank:]]+"))
SWords = SWords[ nchar(SWords) > 1 ]
stopWords = unique(SWords)

cleanText =
  function(msg)   {
    tolower(gsub("[[:punct:]0-9[:space:][:blank:]]+", " ", msg))
  }

findMsgWords = 
  function(msg, stopWords) {
    if(is.null(msg))
      return(character())
    
    words = unique(unlist(strsplit(cleanText(msg), "[[:blank:]\t]+")))
    
    # drop empty and 1 letter words
    # The allowNA=TRUE option is a modification from the text's code.
    # In current versions of R, this is needed to eliminate cases with 
    # unrecognized characters which now return NA but previously returned 
    # numbers.
    words = words[ nchar(words, allowNA=TRUE) > 1]
    words = words[ !( words %in% stopWords) ]
    invisible(words)
  }

processAllWords = function(dirName, stopWords)
{
  # read all files in the directory
  fileNames = list.files(dirName, full.names = TRUE)
  # drop files that are not email, i.e., cmds
  notEmail = grep("cmds$", fileNames)
  if ( length(notEmail) > 0) fileNames = fileNames[ - notEmail ]
  
  messages = lapply(fileNames, readLines, encoding = "latin1")
  
  # split header and body
  emailSplit = lapply(messages, splitMessage)
  # put body and header in own lists
  bodyList = lapply(emailSplit, function(msg) msg$body)
  headerList = lapply(emailSplit, function(msg) msg$header)
  rm(emailSplit)
  
  # determine which messages have attachments
  hasAttach = sapply(headerList, function(header) {
    CTloc = grep("Content-Type", header)
    if (length(CTloc) == 0) return(0)
    multi = grep("multi", tolower(header[CTloc])) 
    if (length(multi) == 0) return(0)
    multi
  })
  
  hasAttach = which(hasAttach > 0)
  
  # find boundary strings for messages with attachments
  boundaries = sapply(headerList[hasAttach], getBoundary)
  
  # drop attachments from message body
  bodyList[hasAttach] = mapply(dropAttach, bodyList[hasAttach], 
                               boundaries, SIMPLIFY = FALSE)
  
  # extract words from body
  msgWordsList = lapply(bodyList, findMsgWords, stopWords)
  
  invisible(msgWordsList)
}

msgWordsList = lapply(fullDirNames, processAllWords, 
                      stopWords = stopWords) 

numMsgs = sapply(msgWordsList, length)

isSpam = rep(c(FALSE, FALSE, FALSE, TRUE, TRUE), numMsgs)

msgWordsList = unlist(msgWordsList, recursive = FALSE)


# Determine number of spam and ham messages for sampling.
numEmail = length(isSpam)
numSpam = sum(isSpam)
numHam = numEmail - numSpam

# Set a particular seed, so the results will be reproducible.
set.seed(418910)

# Take approximately 1/3 of the spam and ham messages as our test spam and ham messages.
testSpamIdx = sample(numSpam, size = floor(numSpam/3))
testHamIdx = sample(numHam, size = floor(numHam/3))

# Use the test indices to select word lists for test messages.
# Use training indices to select word lists for training messages.
testMsgWords = c((msgWordsList[isSpam])[testSpamIdx],
                 (msgWordsList[!isSpam])[testHamIdx] )
trainMsgWords = c((msgWordsList[isSpam])[ - testSpamIdx], 
                  (msgWordsList[!isSpam])[ - testHamIdx])

# Create variables indicating which testing and training messages are spam and not.
testIsSpam = rep(c(TRUE, FALSE), 
                 c(length(testSpamIdx), length(testHamIdx)))
trainIsSpam = rep(c(TRUE, FALSE), 
                  c(numSpam - length(testSpamIdx), 
                    numHam - length(testHamIdx)))

computeFreqs =
  function(wordsList, spam, bow = unique(unlist(wordsList)))
  {
    # create a matrix for spam, ham, and log odds
    wordTable = matrix(0.5, nrow = 4, ncol = length(bow), 
                       dimnames = list(c("spam", "ham", 
                                         "presentLogOdds", 
                                         "absentLogOdds"),  bow))
    
    # For each spam message, add 1/2 to counts for words in message
    counts.spam = table(unlist(lapply(wordsList[spam], unique)))
    wordTable["spam", names(counts.spam)] = counts.spam + .5
    
    # Similarly for ham messages
    counts.ham = table(unlist(lapply(wordsList[!spam], unique)))  
    wordTable["ham", names(counts.ham)] = counts.ham + .5  
    
    
    # Find the total number of spam and ham
    numSpam = sum(spam)
    numHam = length(spam) - numSpam
    
    # Prob(word|spam) and Prob(word | ham)
    wordTable["spam", ] = wordTable["spam", ]/(numSpam + .5)
    wordTable["ham", ] = wordTable["ham", ]/(numHam + .5)
    
    # log odds
    wordTable["presentLogOdds", ] = 
      log(wordTable["spam",]) - log(wordTable["ham", ])
    wordTable["absentLogOdds", ] = 
      log((1 - wordTable["spam", ])) - log((1 -wordTable["ham", ]))
    
    invisible(wordTable)
  }

# Obtain the probabilities and log odds for the training data.
trainTable = computeFreqs(trainMsgWords, trainIsSpam)


# Load the emailStruct and emailDF from the .rda files they were stored in.
load("~/Stat480/RDataScience/Chapter3/emailXX.rda")

load("~/Stat480/RDataScience/Chapter3/spamAssassinDerivedDF.rda")

##########################################################################################################
