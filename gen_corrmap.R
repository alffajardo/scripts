#!/usr/bin/Rscript

args <- commandArgs(T)

dataset <- as.character(args[1])
roi <- as.character(args[2])
output <- as.character(args[3])
library(magrittr)
library(oro.nifti)
library(DescTools)
func <- RNifti::readNifti(dataset)
roi <- readNIfTI(roi,reorient=F)
d <- dim(func)

func_mean <- matrix(func,ncol = 200) %>%
             rowMeans() %>%
             array(data = .,dim = c(d[1],d[2],d[3]))
func_mask <- roi
func_mask@.Data <- func_mean

ts <- matrix(func[roi!=0],ncol = d[4]) %>%
      colMeans()

rvalues <- matrix(func[func_mask !=0],ncol=d[4]) %>%
          apply(.,1,cor,ts) %>%
          FisherZ()
          

rmap <- func_mask
rmap[rmap !=0] <- rvalues

neurobase::write_nifti(rmap,output)
