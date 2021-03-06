#'
#' @param pathList the value of a list property, probably represented as a single string
#' @describeIn writeFilePath use writeFilePath for each element of a list.
#' 
writeFilePathList <- function(pathList, projectDir, useRelPath){
    paths = BioLockR::parseListProp(pathList)
    newPaths = sapply(paths, writeFilePath, projectDir=projectDir, useRelPath=useRelPath)
    return(BioLockR::printListProp(newPaths))
}