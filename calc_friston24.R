#!/usr/bin/Rscript

library(magrittr)

arguments <- commandArgs(trailingOnly = T)
mat <- as.character(arguments[1])

motion_pars <- read.table(mat,sep=' ',header=F) %>% as.matrix
 
d <- dim(motion_pars)[1]

extended_pars <- rbind(rep(0,6),motion_pars[1:d-1,]) %>%
                 cbind(motion_pars,.)
quadratic_pars <- extended_pars * extended_pars

friston24 <- cbind(extended_pars,quadratic_pars)

write.table(friston24,"friston24.mat",sep=' ',quote = F, col.names = F,row.names = F)

                 
                