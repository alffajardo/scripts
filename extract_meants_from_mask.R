#!/usr/bin/Rscript
library(oro.nifti)
library(DescTools)
library(Matrix)
library(corrplot)

# $1 = functional dataset
## $2 = roi mask
## $output name


## importar imagen funcional
arguments <- commandArgs(TRUE)

dataset <- as.character(arguments[1])
roi_mask <- as.character(arguments[2])
name <- as.character(arguments[3])
output <- paste(name,".csv",sep = '')



func <- RNifti::readNifti(dataset)
D <- dim(func)
roi_mask <- readNIfTI(roi_mask)
roi_max <- max(roi_mask)

meants <- function(nifti4d,mask,index){
  D <- dim (nifti4d)
  
  vals <- matrix(nifti4d[mask==index],ncol=D[4])
  meants <- colMeans(vals)
  return(meants)
  
}

ts_matrix  <- matrix(NA,nrow = D[4],ncol = roi_max)

for (i in 1:roi_max){
  
  ts <- meants(func,roi_mask,i)
  ts_matrix[,i] <- ts
  rm(ts)
  
  
}

write.table(ts_matrix,file=output,
            quote = F,sep=',',
            row.names = F,col.names = F)
