#!/usr/bin/Rscript


arguments <- commandArgs(trailingOnly = T)
exponential <- as.numeric(arguments[1])
x <- 1:20
y <- x^exponential
png("plot_xy.png")
 plot(x,y,type="l",lwd=5)
dev.off()

system("display plot_xy.png & ")
