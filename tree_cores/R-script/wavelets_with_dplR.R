######################################################
# Purpose: Create wavelets for tree rings
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created January 2019
######################################################

########## If troubleshooting / running for only specific species, go down to next set of ##################

dirs <- dir("tree_cores/chronologies/current_chronologies", pattern="_drop_dead.rwl")

library(tools)
fileName <- file.path(dirs)
files <- file_path_sans_ext(fileName)
testFileName <- paste0(files, ".pdf")

pdf(file=testFileName)

for (i in seq(along=fileName)){
  library(dplR)
  sp <- read.rwl(fileName[i])
  spdead.rwi <- detrend(sp, method="Spline")
  spdead.crn <- chron(spdead.rwi, prefix="MES")
  plot(spdead.crn, add.spline=TRUE, nyrs=64)

  dat <- spdead.crn[, 1]
  op <- par(no.readonly = TRUE)

  yrs <- time(sp)
  out.wave <- morlet(y1=dat, x1=yrs, p2=8, dj=0.1, siglvl=0.99)
  wavelet.plot(out.wave, useRaster=NA, reverse.y = TRUE)

  library(waveslim)
  if (require("waveslim", character.only = TRUE)) {
    nYrs <- length(yrs)
    nPwrs2 <- trunc(log(nYrs)/log(2)) - 1
    dat.mra <- mra(dat, wf = "la8", J = nPwrs2, method = "modwt",
                    boundary = "periodic")
    YrsLabels <- paste(2^(1:nPwrs2),"yrs",sep="")
  
      par(mar=c(3,2,2,2),mgp=c(1.25,0.25,0),tcl=0.5,
           xaxs="i",yaxs="i")
    plot(yrs,rep(1,nYrs),type="n", axes=FALSE, ylab="",xlab="",
          ylim=c(-3,38))
    title(main="Multiresolution decomposition of dat",line=0.75)
    axis(side=1)
    mtext("Years",side=1,line = 1.25)
    Offset <- 0
    dat.mra2 <- scale(as.data.frame(dat.mra))
    for(i in nPwrs2:1){
      # x <- scale(dat.mra[[i]]) + Offset
         x <- dat.mra2[,i] + Offset
        lines(yrs,x)
        abline(h=Offset,lty="dashed")
        mtext(names(dat.mra)[[i]],side=2,at=Offset,line = 0)
        mtext(YrsLabels[i],side=4,at=Offset,line = 0)
        Offset <- Offset+5
        }
    box()
    par(op) #reset par
  }
  for (i in seq(along=fileName)){
    
    #pdf(i, ".pdf", sep="")
    plot(1:3)
    dev.off()
  }
}
  
  
################### start here for just running specific species
pdf(file="tree_cores/chronologies/current_chronologies/fram_drop_live_wavelet.pdf")
library(dplR)
sp <- read.rwl("tree_cores/chronologies/current_chronologies/fram_drop_live.rwl")
spdead.rwi <- detrend(sp, method="Spline")
spdead.crn <- chron(spdead.rwi, prefix="MES")
plot(spdead.crn, add.spline=TRUE, nyrs=64)

dat <- spdead.crn[, 1]
op <- par(no.readonly = TRUE)

yrs <- time(sp)
out.wave <- morlet(y1=dat, x1=yrs, p2=6, dj=0.1, siglvl=0.99)
wavelet.plot(out.wave, useRaster=NA, reverse.y = TRUE)

library(waveslim)
if (require("waveslim", character.only = TRUE)) {
  nYrs <- length(yrs)
  nPwrs2 <- trunc(log(nYrs)/log(2)) - 1
  dat.mra <- mra(dat, wf = "la8", J = nPwrs2, method = "modwt",
                 boundary = "periodic")
  YrsLabels <- paste(2^(1:nPwrs2),"yrs",sep="")
  
  par(mar=c(3,2,2,2),mgp=c(1.25,0.25,0),tcl=0.5,
      xaxs="i",yaxs="i")
  plot(yrs,rep(1,nYrs),type="n", axes=FALSE, ylab="",xlab="",
       ylim=c(-3,38))
  title(main="Multiresolution decomposition of dat",line=0.75)
  axis(side=1)
  mtext("Years",side=1,line = 1.25)
  Offset <- 0
  dat.mra2 <- scale(as.data.frame(dat.mra))
  for(i in nPwrs2:1){
    # x <- scale(dat.mra[[i]]) + Offset
    x <- dat.mra2[,i] + Offset
    lines(yrs,x)
    abline(h=Offset,lty="dashed")
    mtext(names(dat.mra)[[i]],side=2,at=Offset,line = 0)
    mtext(YrsLabels[i],side=4,at=Offset,line = 0)
    Offset <- Offset+5
  }
  box()
  par(op) #reset par
}

plot(1:3)
dev.off()

