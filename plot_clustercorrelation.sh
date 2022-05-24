#!/usr/bin/Rscript
## a function to plot IQ vs a particular voxel corditanate or mask
### to run this script with bash arguments, supply the following
# $1= 4d Nifti File
#  $2 = Nifti File cluster mask
# $3 = cluster index
# $4 Either one of this Congitive index : IQ, VCI, PS, PR, WMI, VMI,VWMI,AMI,DMI, IMI

arguments <- commandArgs(TRUE)
dataset <- as.character(arguments[1])
mask <- as.character(arguments[2])
cluster_index<- as.numeric(arguments[3])
index_name <- as.character(arguments[4])

library(oro.nifti)


# import a 4d dataset 
dataset <- readNIfTI(dataset)
mask <- readNIfTI(mask)
timepoints <- dim(dataset)[4]
cluster_size <- nrow(which(mask==cluster_index,arr.ind = T))


## calculate meants
voxel <- matrix(dataset[,,,1:timepoints][mask==cluster_index],ncol=timepoints)
voxel <- apply(voxel,2,mean)





# first lets try to plot a single voxel
neuropsy <- read.csv("/misc/purcell/alfonso/Github/proyecto_RS/neuropsicologia/neuropsy_normalized.csv")

index <- as.numeric(which(names(neuropsy)==index_name))

neuropsy <- neuropsy[,c(4,5,index)]
index <- neuropsy[,3]
attach(neuropsy)

general_correlation <- cor.test(voxel,index)
control_correlation <- cor.test(voxel[subtype=="Healthy"],index[subtype=="Healthy"])
tle_left_correlation <- cor.test(voxel[subtype=="Left-TLE"],index[subtype=="Left-TLE"])
tle_right_correlation <- cor.test(voxel[subtype=="Right-TLE"],index[subtype=="Right-TLE"])
ylims <- c(min(voxel),max(voxel)) * 1.2 
col_vector <- c("red","darkgreen","purple4")[subtype]


png("cluster_scatterplot.png",height = 15,width = 20,units = "cm",res = 300)
plot(index,voxel, type = "n",xlim=c(-3.5,3.5),axes=F,ylim = ylims,main = 'cluster mean z value vs cognitive score',cex.main=2,
     ylab=expression(bold(' mean Z cluster correlation value')),xlab=index_name)
axis(side = 1, at= -3:3,lwd=5,font=2)
axis(side =2 ,at= round(seq(min(voxel)-0.1,max(voxel),length.out = 5),digits = 1),lwd=5,font=2)
points(index,voxel,pch=16,col=col_vector,cex=1.5)


if (general_correlation$p.value < 0.05){
  abline(lm(voxel~index),col="darkgoldenrod",lwd=4,lty=1)
  rvalue <- paste("r =",round(general_correlation$estimate,digits = 2),sep = ' ')
text(2.5,min(voxel)+0.1,labels = rvalue,font = 2 )  
}

if (control_correlation$p.value < 0.05){
  
  abline (lm(voxel[subtype=="Healthy"] ~ index[subtype=="Healthy"]),lwd=2,col=col_vector[subtype=="Healthy"],lty=2)
  
  
}

if (tle_left_correlation$p.value < 0.05){
  
  abline (lm (voxel[subtype=="Left-TLE"] ~ index [subtype=="Left-TLE"]),lwd=2,col=col_vector[subtype=="Left-TLE"],lty=2)
  
}
if (tle_right_correlation$p.value < 0.05){
  
  abline (lm (voxel[subtype=="Right-TLE"] ~ index [subtype=="Right-TLE"]),lwd=2,col=col_vector[subtype=="Right-TLE"],lty=2)
  
}
legend(-3.5,max(voxel),legend =c("Healthy","Left-TLE","Right-TLE"),cex=0.8,text.col = c("red","darkgreen","purple4"),
       text.font = 2, box.lwd = 2)
text(2.5,min(voxel)+0.2,paste("cluster size = ",cluster_size,sep = ' '),font = 2,col="blue")
dev.off()
system("display cluster_scatterplot.png &")




