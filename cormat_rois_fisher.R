#!/usr/bin/Rscript

## run this script directly from shell (works with linux)

###########################################
### REQUIRED ARGUMENTS :###################
 # $1 = functional dataset ################
 ## $2 = mask with several rois ###########
 ## $3output name ##########################
###########################################

library(magrittr)

##  allows to spectify arguments from bash command line
arguments <- commandArgs(TRUE)
## transform command line arguments into r text objets
dataset <- as.character(arguments[1])
roi_mask <- as.character(arguments[2])
output_name <- as.character(arguments[3])
output_name <- paste(output_name,".csv",sep = '')


## import functional dataset 
func <- RNifti::readNifti(dataset)
## read mask with rois
roi_mask <- oro.nifti::readNIfTI(roi_mask)
## number of rois within the mask
roi_max <- max(roi_mask)
## create a function to draw mean timeseries from rois
draw_meants <- function (nifti4d,mask,index) {
  D <- dim (nifti4d)
  vals <- matrix(nifti4d[mask==index],ncol=D[4])
  meants <- colMeans(vals)
  return(meants)
  
 }
## calculate correlation matrix
cormat_fisher <- sapply(X = 1:roi_max,FUN = draw_meants,nifti4d=func,mask=roi_mask) %>%
  cor() %>%
 DescTools::FisherZ() %>%
  round(digits = 4)
## exchange infinite values for 1 in diagonal of matrix
diag(cormat_fisher) <- 1
## write correlation matrix in csv format file
write.table(cormat_fisher,file=output_name,
            quote = F,sep=',',
            row.names = F,col.names = F)

  
 
 
 
 
