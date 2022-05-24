#!/usr/bin/Rscript

library(magrittr)
arguments <- commandArgs(trailingOnly = T)

arguments <- commandArgs(T)
dataset <- as.character(arguments[1]) 
roi <- as.character(arguments[2])
output <- as.character(arguments[3])
output_name <- paste(output,".txt",sep = "")

## read files
func <- RNifti::readNifti(dataset)
roi <- RNifti::readNifti(roi)

d <- dim(func)
timeseries <- matrix(func[roi !=0],ncol = d[4]) %>%
              colMeans() %>%
              as.data.frame()


write.table(timeseries,output_name,quote = F,sep='',col.names = FALSE,row.names = F)




