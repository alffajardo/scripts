#!/usr/bin/Rscript

# libreria
library(oro.nifti)
arguments <- commandArgs(TRUE)
dataset <- as.character(arguments[1])
n <- as.numeric(arguments[2])
output <- as.character(arguments[3])
### Este script toma como imput una imagen o mapa estadístico y realiza una clusterización jerarquica de los voxeles dependiendo de su ubicación 
### espacial

# Set de datos
nii <- readNIfTI(dataset)
D <- dim(nii)

# Coordenadas
coord <- which(nii@.Data!=0,arr.ind = TRUE)


# Agregar los valores de Z en la columna 4 de coord
zvalue <- nii@.Data [coord]
coord <- cbind(coord,zvalue)
# Obtain a Euclidean Distance matrix
d <- dist(coord,method = "euclidean")

# Cluster the data with Ward Method
hcc <- hclust(d,method = "ward.D")

# Dendrograma de todos los voxeles
plot(hcc)

# Define N clusters
clusters <- cutree(hcc,k = n)

# Data frame con valores de la particion
particion <- data.frame(cbind(coord,clusters))

# Matriz vacia
nii.particion <- array(0,D)

# Llenar la matriz con las particiones
for (i in 1:length(clusters)) {
  nii.particion[particion[i,1],particion[i,2],particion[i,3]] <- particion[i,5]
}

# Guardar la partición
nii.clust <- nii
nii.clust@.Data <- nii.particion


writeNIfTI(nii.clust,output)
