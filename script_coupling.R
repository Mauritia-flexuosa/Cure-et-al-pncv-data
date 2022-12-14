# Author: Marcio Baldissera Cure - 2022
# Satellite data from <https:www.earthexplorer.usgs.gov> and precipitation data from CHIRPS <https://data.chc.ucsb.edu/products/CHIRPS-2.0/

# 1. Manipular dados do Landsdat 8 ====
rm(list = ls())

library(sp)
library(rgdal)
library(raster)
library(xts)
library(ncdf4)
library(tidyverse)

## Diretório

dir <- "/home/marcio/Documentos/data/landsat8 2021"
setwd(dir = dir)
getwd()

## geo ====
## Coordenadas das parcelas

x <- c(-47.75014, -47.74389, -47.76830, -47.72287, -47.73264, -47.73613, -47.68317,
       -47.66713, -47.69987, -47.70263, -47.76707, -47.71484, -47.71418, -47.67871,
       -47.67911, -47.68465, -47.63446, -47.63412, -47.63415, -47.69065, -46.97297,
       -46.98341, -46.98311, -46.98177, -47.84833, -47.84950, -47.84347, -46.97983,
       -46.98513, -46.98280, -47.63719, -47.63690, -47.63657, -47.63625, -47.63551,
       -47.63513, -47.63479, -47.63447, -47.63412, -47.63376, -47.63497, -47.63472,
       -47.63449, -47.63425, -47.63398, -47.63376, -47.63349, -47.63340, -47.63323,
       -47.63333)
y <- c(-14.14786, -14.14263, -14.13991, -14.13116, -14.12362, -14.12612, -14.12855,
       -14.12713, -14.12875, -14.12913, -14.13310, -14.13943, -14.13980, -14.11648,
       -14.11652, -14.11530, -14.09114, -14.09050, -14.08997, -14.12734, -13.92030,
       -13.88963, -13.88625, -13.88888, -14.20525, -14.20966, -14.20466, -13.89772,
       -13.88366, -13.88300, -14.10703, -14.10691, -14.10672, -14.10647, -14.10615,
       -14.10608, -14.10588, -14.10573, -14.10555, -14.10556, -14.09398, -14.09369,
       -14.09341, -14.09310, -14.09275, -14.09240, -14.09212, -14.09177, -14.09145,
       -14.09123)
xy <- cbind(x,y)
coordR <- SpatialPoints(xy, 
                        proj4string = crs("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

coordRU <- spTransform(coordR, crs("+proj=utm +zone=23 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"))

## untar files =====

dir = "/home/marcio/Documentos/data/landsat8 2021/Araripe"
setwd(dir)
zipfiles <- list.files(dir, pattern = ".tar", full.names = T)
#
#zipfiles <-gsub("//","/",zipfiles)
#

for(i in 61:75){ #esse foi o último
  a<-untar(zipfiles[i], exdir = "./unzipped")
}

for(i in 1:length(zipfiles)){
  a<-untar(zipfiles[i], exdir = "./unzipped")
}

## raster =====
Band4 <- list.files("./unzipped", 
                    recursive = T, pattern = "B4.TIF", full.names = T)

Band5 <- list.files("./unzipped", 
                    recursive = T, pattern = "B5.TIF", full.names = T)

BandQA <- list.files("./unzipped", 
                     recursive = T, pattern = "BQA.TIF", full.names = T)

b4 <- Band4; b5 <- Band5; qa <- BandQA

# Extent 191440,287828,-1574800,-1533780 (PNCV)


for (i in 1:length(b4)) {
  aux <- crop(b4[i]%>%raster,extent(191440,287828,-1574800,-1533780))
  if (i == 1){
    B4 <- stack(aux, nlayers = 1)
  }else{
    B4 <-  addLayer(B4, aux)
  }
}

for (i in 1:length(b5)) {
  aux <- crop(b5[i]%>%raster,extent(191440,287828,-1574800,-1533780))
  if (i == 1){
    B5 <- stack(aux, nlayers = 1)
  }else{
    B5 <-  addLayer(B5, aux)
  }
}

for (i in 1:length(qa)) {
  aux <- crop(qa[i]%>%raster,extent(191440,287828,-1574800,-1533780))
  if (i == 1){
    QA <- stack(aux, nlayers = 1)
  }else{
    QA <-  addLayer(QA, aux)
  }
}

# 2. Gerar um índice de vegetação (evi2)====
## 2-band enhanced vegetation index (evi2)

for (i in 1:nlayers(B5)){
  aux <-  2.5 * (B5[[i]] - B4[[i]])/(B5[[i]] + (2.4 * B4[[i]]) + 1)
  if (i == 1){
    evi2 <- stack(aux, nlayers = 1)
  }else{
    evi2 <- addLayer(evi2, aux)
  }
  rm(aux)
}


## Filtrar núvens (Função do Matheus)
filter_landsat_raster <- function(landsat, time_layer, band_rasterized){
  
  #PARA LANDSATS FROM LEDAPS GUIDE AND LARCS:
  clear <- c(322,386,834,898,1346,66,130)
  cloudandshadow <- unique(c(324, 388, 836, 900, 1348,
                             328, 392, 840, 904, 1350,
                             336, 368, 400, 432, 848, 880, 912, 944, 1352,
                             352, 368, 416, 432, 480, 864, 880, 928, 944, 992,
                             386, 388, 392, 400, 416, 432, 898, 900, 904, 928, 944,
                             322, 324, 328, 336, 352, 368, 834, 836, 840, 848, 864, 880,
                             480, 992,
                             322, 324, 328, 336, 352, 368, 386, 388, 392, 400, 416, 432, 480,
                             834, 836, 840, 848, 864, 880, 898, 900, 904, 912, 928, 944, 992,
                             68,132,72,136,80, 112, 144, 176,
                             96, 112, 160, 176, 224, 66, 68, 72, 80, 96, 112,
                             130, 132, 136, 144, 160, 176,224))
  if(landsat == 5){
    qa <- qaraster5[[time_layer]]
  }
  if(landsat == 7){
    qa <- qaraster7[[time_layer]]
  }
  if(landsat == 8){
    qa <- QA[[time_layer]]
  }
  
  qa[qa %in% clear] <- 1
  qa[qa %in% cloudandshadow] <- NA
  qa[qa == 0] <- NA
  
  
  filtered <- mask(band_rasterized[[time_layer]], qa)
  filtered
  
}

evi2 <- raster("/home/marcio/data/evi2rasterUnfiltred.tif")

### loop for pra filtrar e "empilhar" os dados
for (i in 1:dim(evi2)[3]) {
  Aux <- filter_landsat_raster(8,i,evi2)
  if (i == 1){
    evi8R <- stack(Aux, nl = 1)
  }else{
    evi8R <- addLayer(evi8R, Aux)
  }
  rm(Aux)
}

writeRaster(evi8R, filename = "./evi2_ls8_filtered_pncv.tif") # esse foi o último
	
#### Extrair dados dos pontos ====
evi2T <- raster::extract(evi8R,coordRU)
colnames(evi2T) <- substr(b4, 70,77)

write.table(evi2T, "/home/marcio/Documentos/data/evi2_todas_parcelas_LS8")

## Monthly time-series as a xts object
evi2.r <- matrix(NA,nrow=30, ncol = 147)

for (i in 1:dim(evi2.r)[1]){

    ep <- xts::endpoints(xts::xts(evi2T[i,],datas), on = "months")

    aux <- xts::period.apply(as.matrix(evi2T[i,]), INDEX = ep,
                             FUN = mean, na.action=na.pass)
    if (i == 1) {
  
      evi2.r <- aux
      
  }else{
  
    evi2.r <- cbind(evi2.r, aux)
  }
}

data.m <- seq(from = as.Date("2013-04-01"), to = as.Date("2018-06-01"), by = "month")
#data.m <- data.m[c(-12,-33)]

colnames(evi2.r) <- as.character(data.m)


# 3. Extrair a precipitação (CHIRPS 2.0)====

library(raster)
library(rgdal)
library(ncdf4)
library(xts)
library(tidyr)

# "/home/marcio/Documentos/data/chirps2020/chirps-v2.0.monthly_TSA_cropped_2013-2018.nc"
# "/home/marcio/Documentos/data/precipitação/chirps-v2.0.2020.days_p05_cortado.nc"
nc <- nc_open("/home/marcio/Documentos/data/chirps2020/chirps-v2.0.monthly_TSA_cropped_2013-2018.nc", readunlim = FALSE)

prec <- ncvar_get(nc, "precip")

# PNCV
 for (i in 1:dim(prec)[3]){
  aux <- apply(prec[ , ,i], 1, rev)
  pAux <- raster(aux, xmn = -48, xmx = -46, ymn = -14.5, ymx = -13)
  if (i == 1){
    precR <- stack(pAux, nl = 1)
  }else{
    precR <- addLayer(precR, pAux)
  }
  rm(aux, pAux)
}


crs(precR)<- crs(coordR)
prec.m <- raster::extract(precR, coordR)
prec.m <- prec.m[,4:66]

colnames(prec.m) <-  as.character(seq(from = as.Date("2013-01-01"), to = as.Date("2018-06-01"), by = "month")[4:66])
#data.prec <- seq(from = as.Date("1981-01-01"), to = as.Date("2018-06-01"), by = "month")


# 4. Calcular o acoplamento entre o EVI2 e a precipitação ====

library(quantmod)

for (i in 1:dim(prec.m)[1]) {

  aux <- cor.test(evi2.r[i,],
                         Lag(prec.m[i,],0),
                         method = "kendall",
                         na.action = na.pass)
  if ( i == 1){

    pos.zero <- c(aux$estimate)
  
  }else{
   
    pos.zero <- c(pos.zero, aux$estimate)
    
 }
}


for (i in 1:dim(prec.m)[1]) {
  
  aux <- cor.test(evi2.r[i,],
                  Lag(prec.m[i,],1),
                  method = "kendall",
                  na.action = na.pass)
  if ( i == 1){
    
    pos.1 <- c(aux$estimate)
    
  }else{
    
    pos.1 <- c(pos.1, aux$estimate)
    
  }
}

for (i in 1:dim(prec.m)[1]) {
  
  aux <- cor.test(evi2.r[i,],
                  Lag(prec.m[i,],2),
                  method = "kendall",
                  na.action = na.pass)
  if ( i == 1){
    
    pos.2 <- c(aux$estimate)
    
  }else{
    
    pos.2 <- c(pos.2, aux$estimate)
    
  }
}

for (i in 1:dim(prec.m)[1]) {
  
  aux <- cor.test(evi2.r[i,],
                  Lag(prec.m[i,],3),
                  method = "kendall",
                  na.action = na.pass)
  if ( i == 1){
    
    pos.3 <- c(aux$estimate)
    
  }else{
    
    pos.3 <- c(pos.3, aux$estimate)
    
  }
}

for (i in 1:dim(prec.m)[1]) {
  
  aux <- cor.test(evi2.r[i,],
                  Lag(prec.m[i,],4),
                  method = "kendall",
                  na.action = na.pass)
  if ( i == 1){
    
    pos.4 <- c(aux$estimate)
    
  }else{
    
    pos.4 <- c(pos.4, aux$estimate)
    
  }
}


for (i in 1:dim(prec.m)[1]) {
  
  aux <- cor.test(evi2.r[i,],
                  Lag(prec.m[i,],5),
                  method = "kendall",
                  na.action = na.pass)
  if ( i == 1){
    
    pos.5 <- c(aux$estimate)
    
  }else{
    
    pos.5 <- c(pos.5, aux$estimate)
    
  }
}


for (i in 1:dim(prec.m)[1]) {
  
  aux <- cor.test(evi2.r[i,],
                  Lag(prec.m[i,],6),
                  method = "kendall",
                  na.action = na.pass)
  if ( i == 1){
    
    pos.6 <- c(aux$estimate)
    
  }else{
    
    pos.6 <- c(pos.6, aux$estimate)
    
  }
}


lag.1 <- cbind(pos.zero, pos.1, pos.2, pos.3,
                 pos.4, pos.5, pos.6)

colnames(lag.1) <- 0:6

# Maior coupling dentre todos os lags
z <- lag.1
for (i in 1:dim(z)[1]){
  
  aux <- z[i,order(-abs(z[i,]))[1]]
  
  if (i == 1){
    
    coup_max <- aux
    
  }else{
    
    coup_max <- c(coup_max, aux)
    
  }
}

# Coupling médio
for (i in 1:dim(lag.1)[1]){
  
  aux <- mean(lag.1[i,1:7])
  
  if (i == 1){
    
    coup_mean <- aux
    
  }else{
    
    coup_mean <- c(coup_mean, aux)
    
  }
}

# lag at the maximum coupling
for (i in 1:dim(z)[1]){
  
  aux <- order(-abs(z[i,]))[1]
  
  if (i == 1){
    
    lag <- aux
    
  }else{
    
    lag <- c(lag, aux)
    
  }
}

coupling <- bind_cols(Strengh_relation = abs(coup_max), Maximum_coupling = coup_max, Lag = lag)


