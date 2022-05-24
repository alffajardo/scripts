#!/usr/bin/Rscript 

# Creation Date: August 25th 2021
# Author: Alfonso Fajardo
# https://github.com/alffajardo

#########################################################################################################################################
# Description of this script: estract all voxel time series from a 4d dataset and a ROI binary mask
# Compulsory arguments (positional): 
#nhp_chmx_get_timeseries <functional dataset> ROI mask, output name
# Example to run in bash: 
# nhp-chmx_get_timeseries.R errts.sub-032125.tproject+tlrc_masked.nii.gz vmPFC_CHARM_bin_in_sub-032125.nii.gz sub-032125_vmPFC.ts
# import command line args (bash shell) into the script
##########################################################################################################################################

# Section 1: import the command arguments from the bash shell
args <- commandArgs(T)

dataset <- as.character(args[1])
roi <- as.character(args[2])
output <- as.character(args[3])

# Section 2:  Set-up  and load required  R packages

if (!require(neurobase)){
  install.packages("neurobase") 
}
library(neurobase)

if (!require(magrittr)){
  install.packages("magrittr") 
}
library(magrittr)

if (!require(purrr)){
  install.packages("purrr") 
}
library(purrr)

# Section 3: import nifti files into R
func <- RNifti::readNifti(dataset)
roi <- readNIfTI(roi,reorient=F)



# Section 4: get the coordinates of func that overlap with the mask

coords <- which(roi@.Data !=0, arr.ind = T)
coords_chr <- map_chr(.x = 1:nrow(coords),.f = ~paste(coords[.x,1], "_", coords[.x,2],"_" ,coords[.x,3], sep = '') )
                                              
# Section 5: Draw the time series 
d <- dim(func)

ts <- matrix (func[roi== 1], ncol = d[4]) %>% t() %>%  data.frame() %>%
  set_names(coords_chr)

# Section 6. Save file
write.table(x = ts, file = output,sep = " ", row.names = F,quote = F,col.names =  T)
