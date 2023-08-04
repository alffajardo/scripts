#!/usr/local/bin/Rscript

library(neurobase)
library(sommer)
library(scales)
 args<- commandArgs(trailingOnly = T )
 print(args)
 
 
 
 anat_file <- args[1]
 pet_file <- args[2]
 prefix <- args[3]
 
 output <- paste(prefix,"_TAU_SUVR.png",sep = "")


anat <- readNIfTI( fname = anat_file, reorient = F)
pet <- readNIfTI(pet_file,reorient = F)

#anat <- readNIfTI("anat/sub-CD001_TAU_T1w.nii.gz")
#pet <- readNIfTI("pet/sub-CD001_TAU_pet_time-4070_space-anat_ref-infcereg_suvr.nii.gz")
pet[is.nan(pet)] <- 0

max.pet <- max(pet)

coords <- which(pet == max.pet,arr.ind = T)


png(output,height = 1100,width = 1100,res = 100,units = "px",)



ortho2(x = anat, y = pet, xyz = coords,crosshairs = F,zlim.y = c(0.5,3.35), 
       col.y = alpha(jet.colors(100),.2),
       mar = c(0,0,0,0), bg = "black",NA.x = T,NA.y = F)
dev.off()


