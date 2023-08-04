#!/usr/local/bin/Rscript

library(neurobase)
library(sommer)

 args<- commandArgs(trailingOnly = T )
 print(args)
 
 
 
 anat_file <- args[1]
 pet_file <- args[2]
 prefix <- args[3]
 
 output <- paste(prefix,"_TAU_SUVR.png",sep = "")


anat <- readNIfTI( fname = anat_file, reorient = F)
pet <- readNIfTI(pet_file,reorient = F)
pet[is.nan(pet)] <- 0

max.pet <- max(pet)

coords <- which(pet == max.pet,arr.ind = T)


png(output,height = 1100,width = 1100,res = 100,units = "px",)



ortho2(x = anat, y = pet, xyz = coords,crosshairs = F,zlim.y = c(0.5,3), col.y = jet.colors(100),
       mar = c(0,0,0,0), bg = "black",NA.x = T,NA.y = F)
dev.off()


