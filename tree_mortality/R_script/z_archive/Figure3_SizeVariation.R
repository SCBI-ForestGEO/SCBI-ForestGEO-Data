####################################################################
#Figure 3: Size-Related variation in m and M
##########################################################################
#Tori Meakem, adapted by Ryan Helcoski 
#10/26/2016              #2017

#Q: stats: divided by width in paper??

#To run code:
#############
#Load R files: scbi.stem1.rdata, scbi.stem2.rdata, allmort.rdata
setwd("   ")
load(" scbi.stem1.rdata")
load(" scbi.stem2.rdata")
load(" allmort.rdata")

#Highlight and run all functions in the "Function List" (below)

#Run the lines of code directly below:
hectar=25.6 #Plot size in hectares
ddiv=c(10,12.5,15.5,19.5,24,30,37.5,46.5,58,72,90,112,140,174,217,270.5,337,420,523,652,812.5,10000) #Approximately log-even size bins
nreps=1000 #number of bootstrap replicates for calculating CIs
datadir="TreeMort" #Name on output file
outfilestem="Rate" #Name on output file
gridsize=50 # the dimension of the subplots to be used for bootstrapping: it is gridsize x gridsize m
alpha=c(0.05,0.01) # the p-value for confidence intervals

#Remove all previously dead stems; mark each tree as live (mind$mort=0) or dead (mind$mort=1)
  #Also includes initial dbh (dinit) and biomass change per year (agb) using exact time measurements
mind12<-indcalcmort12(scbi.stem1,scbi.stem2,10) #2008-13 census
mind23<-indcalcmort23(allmort) #2013-2014
mind34<-indcalcmort34(allmort) #2014-2015
  #Make subset with dead trees only
mortagb12<-mind12[mind12$mort==1&!is.na(mind12$mort),]
mortagb23<-mind23[mind23$mort==1&!is.na(mind23$mort),]
mortagb34<-mind34[mind34$mort==1&!is.na(mind34$mort),]

#Put all 3 censuses into a list
minds<-list(mind12,mind23,mind34)
mortagb<-list(mortagb12,mortagb23,mortagb34)
emszdata<-list() #Empty list prepared for biomass mortality
mszdata<-list() #Empty list prepared for mortality
ncensus<-c("2008-2013","2013-2014","2014-2015") #Census names

Runall(minds,mortagb,ncensus) #This function runs everything



##################################################################################
#Function List
####################################################################################
#Runall(): calls other functions
#treemort(): Calculates mortality rate per size class
#treeagbmort(): calculates biomass mortality per size class
#indcalcmort12(): removes previously dead trees; identifies new dead trees for 2008-13
#indcalcmort23(): removes previously dead trees; identifies new dead trees for 2013-14
#indcalcmort34(): removes previously dead trees; identifies new dead trees for 2014-15
    #Supporting Functions (modified from Helene's code):
#mszmn(): calculates mortality rate
#szcount(): calculates number of stems per size class
#szmn(): calculates mean per size class
#eszmn(): calculates sums per size class
#getmszmnbs(): calculate means for the bootstrapped mortality dataset 
#geteszmnbs(): calculate means for the bootstrapped biomass mortality dataset 
#sumbyquadndiv(): a generic function for summing data by xy quadrat of dimension gridsize and size classes ddiv
#countbyquadndiv(): a generic function for counting data by xy quadrat of dimension gridsize and size classes ddiv
#getszbs(): # calculate CIs on biomass mort and mort means by size class and on fitted parameters 
#graphmort(): power fit; divided by bin width
#graphmortU(): U-shaped curve; divided by bin width

##########################################
Runall<-function(minds,mortagb,ncensus){
##########################################
##############################
outecomortbiomassfn=paste(datadir,outfilestem,"ecomortbiomass.rdata",sep="")
outmortfn=paste(datadir,outfilestem,"mortsize.rdata",sep="")
nl=length(mortagb)
for (i in 1:nl){
  mszdata[[i]]=treemort(minds[[i]],ddiv,nreps) 
  emszdata[[i]]=treeagbmort(mortagb[[i]],ddiv,hectar,nreps)
}
  names(mszdata)=paste(ncensus[1:nl]) #mortality
  save(mszdata,file=outmortfn)

  names(emszdata)=paste(ncensus[1:nl]) #biomass mortality
  save(emszdata,file=outecomortbiomassfn)

graphmort()
#graphmortU() #Turn on if you want to view U-shaped curve
#dev.off()
dev.off()

 
} #end runall

#Runall(minds,mortagb)

############################################################
treemort=function(mind,ddiv,nreps)
##############################################################
{

mnsztrue=szcount(mind$dinit,ddiv) #Number of stems per size class
mdsztrue=szmn(mind$dinit,mind$dinit,ddiv) #Mean initial diameter per size class
mmsztrue=mszmn(mind$mort,mind$dinit,mind$timeint,ddiv) #mortality rate per size class
mtsztrue=szmn(mind$timeint,mind$dinit,ddiv) #mean time interval per size class

#Confidence Intervals
mbs=getmszmnbs(mind,gridsize,ddiv,nreps)
mszdata=getszbs(mnsztrue,ddiv,mdsztrue,mmsztrue,mtsztrue,mbs$mszbs,alpha,"mort")
return(mszdata)

}

###########################################################################
treeagbmort=function(mortagb,ddiv,hectar,nreps)
#####################################################################
{
emnsztrue=szcount(mortagb$dinit,ddiv) #Number of stems per size class
emtsztrue=szmn(mortagb$timeint,mortagb$dinit,ddiv) #Mean time interval per size class
emdsztrue=szmn(mortagb$dinit,mortagb$dinit,ddiv) #Mean initial diameter per size class
emsztrue=eszmn(mortagb$agb,mortagb$dinit,ddiv,hectar) #sum of biomass per size class
#Confidence Intervals
ems=geteszmnbs(mortagb,mortagb$agb,gridsize,hectar,ddiv,nreps) 
emszdata=getszbs(emnsztrue,ddiv,emdsztrue,emsztrue,emtsztrue,ems$xszbs,alpha,"ecomortbiomass")
return(emszdata)}

################################################
indcalcmort12=function(full1,full2,mindbh)
  ################################################
{
  inc=full1$dbh>=mindbh&!is.na(full1$dbh) #Exclude stems <mindbh and dead stems
  mort=ifelse(full2$dbh<0|is.na(full2$dbh),1,0) #Mark tree as dead (1) or alive (0)
  timeint=(full2$date-full1$date)/365.25 #Calculate time interval
  agb=(full1$agb)/timeint #Use exact time interval for biomass 
  mind=data.frame(gx=full1$gx[inc],gy=full1$gy[inc],dinit=full1$dbh[inc],mort=mort[inc],timeint=timeint[inc],agb=agb[inc],tag=full1$tag[inc],stemID=full1$stemID[inc])
  return(mind)
} # end indcalcmort12

################################################
indcalcmort23=function(allmort)
  ################################################
{
  inc=allmort$status.2013=="Live" #Include only live stems
  mort=ifelse(allmort$status.2014=="Dead",1,0) #Mark trees as alive (0) or dead (1)
  timeint=(allmort$date.2014-allmort$date.2013)/365.25 #Calculate time interval
  agb=(allmort$agb.2013)/timeint #Use exact time interval for biomass 
  mind=data.frame(gx=allmort$gx[inc],gy=allmort$gy[inc],dinit=allmort$dbh.2013[inc],mort=mort[inc],timeint=timeint[inc],agb=agb[inc],tag=allmort$tag[inc],stemID=allmort$stemID[inc])
  return(mind)
} # end indcalcmort23

################################################
indcalcmort34=function(allmort)
  ################################################
{

  inc=allmort$status.2014=="Live" #Include only live stems
  mort=ifelse(allmort$status.2015=="Dead",1,0) #Mark trees as alive (0) or dead (1)
  timeint=(allmort$date.2015-allmort$date.2014)/365.25 #Calculate time interval
  #For this census, dbh values were measured for dead trees
    #Select the highest value between agb.2013 and agb.2015 (in case of bark loss, etc.)
    agb.best<-(pmax(allmort$agb.2013,allmort$agb.2015,na.rm=T))/timeint
  mind=data.frame(gx=allmort$gx[inc],gy=allmort$gy[inc],dinit=allmort$dbh.2013[inc],mort=mort[inc],timeint=timeint[inc],agb=agb.best[inc],tag=allmort$tag[inc],stemID=allmort$stemID[inc])
  return(mind)
} # end indcalcmort34

################################################
mszmn=function(x,dinit,timeint,ddiv)
  # function for calculating mean mortality rate by size intervals
  ################################################
{
  inc=dinit>=min(ddiv)&dinit<max(ddiv)&!is.na(x) 
  dinit=dinit[inc]
  x=x[inc]
  timeint=timeint[inc]
  nclass=length(ddiv)-1
  dbhclass=as.numeric(cut(dinit,breaks=ddiv,right=F,labels=1:nclass)) #Assign each tree to a size class
  ninit=tapply(x,dbhclass,length) #number of initial trees per size class
  ndead=tapply(x,dbhclass,sum) #number of dead trees per size class
  mntime=tapply(timeint,dbhclass,mean,na.rm=T) #mean time interval per size class
  mtch=match((1:nclass),rownames(ninit))
  ninit=ninit[mtch]
  ndead=ndead[mtch]
  mntime=mntime[mtch]
  #mortrate=(log(ninit)-log(ninit-ndead))/mntime
  mortrate=100*(1-((ninit-ndead)/ninit)^(1/mntime)) #Calculate mortality rate
  names(mortrate)=paste(ddiv[1:nclass],"-",ddiv[2:(nclass+1)],sep="")
  return(mortrate)
} # end mszmn
######################################################

################################################
szcount=function(dinit,ddiv)
  ################################################
{
  inc=dinit>=min(ddiv)&dinit<max(ddiv)
  dinit=dinit[inc]
  nclass=length(ddiv)-1
  dbhclass=as.numeric(cut(dinit,breaks=ddiv,right=F,labels=1:nclass))
  n=tapply(dinit,dbhclass,length)
  mtch=match((1:nclass),rownames(n))
  n=n[mtch]
  names(n)=paste(ddiv[1:nclass],"-",ddiv[2:(nclass+1)],sep="")
  return(n)
} # end szcount
######################################################

################################################
szmn=function(x,dinit,ddiv)
  ################################################
{
  inc=dinit>=min(ddiv)&dinit<max(ddiv)
  dinit=dinit[inc]
  x=x[inc]
  nclass=length(ddiv)-1
  dbhclass=as.numeric(cut(dinit,breaks=ddiv,right=F,labels=1:nclass))
  xmn=tapply(x,dbhclass,mean,na.rm=T) 
  mtch=match((1:nclass),rownames(xmn))
  xmn=xmn[mtch]
  return(xmn)
} # end szmn
######################################################

################################################
eszmn=function(x,dinit,ddiv,hectar)
  ################################################
{
  inc=dinit>=min(ddiv)&dinit<max(ddiv)
  dinit=dinit[inc]
  x=x[inc]
  nclass=length(ddiv)-1
  dbhclass=as.numeric(cut(dinit,breaks=ddiv,right=F,labels=1:nclass))
  xmn=tapply(x,dbhclass,sum,na.rm=T)
  exmn=xmn/hectar
  mtch=match((1:nclass),rownames(exmn))
  exmn=exmn[mtch]
  names(exmn)=paste(ddiv[1:nclass],"-",ddiv[2:(nclass+1)],sep="")
  return(exmn)
} # end eszmn
######################################################

################################################
getmszmnbs=function(mind,gridsize,ddiv,nreps)
  ################################################
{
  nclass=length(ddiv)-1
  dn=countbyquadndiv(mind$dinit,mind$dinit,mind$gx,mind$gy,gridsize,ddiv)
  dsums=sumbyquadndiv(mind$dinit,mind$dinit,mind$gx,mind$gy,gridsize,ddiv)
  msums=sumbyquadndiv(mind$mort,mind$dinit,mind$gx,mind$gy,gridsize,ddiv)
  tsums=sumbyquadndiv(mind$timeint,mind$dinit,mind$gx,mind$gy,gridsize,ddiv)
  ngrid=dim(dn)[1]
  dszmnmatrix=mszmnmatrix=tszmnmatrix=matrix(NA,ncol=nclass,nrow=nreps)
  for (j in 1:nreps) {
    whichgrids=sample(ngrid,ngrid,replace=T)
    dszmnmatrix[j,]=apply(dsums[whichgrids,],2,sum)/apply(dn[whichgrids,],2,sum,na.rm=T)
    mszmnmatrix[j,]=100*(1-((apply(dn[whichgrids,],2,sum,na.rm=T)-apply(msums[whichgrids,],2,sum,na.rm=T))/apply(dn[whichgrids,],2,sum,na.rm=T))^(1/(apply(tsums[whichgrids,],2,sum,na.rm=T)/apply(dn[whichgrids,],2,sum,na.rm=T))))
    tszmnmatrix[j,]=apply(tsums[whichgrids,],2,sum)/apply(dn[whichgrids,],2,sum,na.rm=T)
  }
  colnames(dszmnmatrix)=colnames(mszmnmatrix)=colnames(tszmnmatrix)=paste(ddiv[1:nclass],"-",ddiv[2:(nclass+1)],sep="")
  results=list(dszmnmatrix,mszmnmatrix,tszmnmatrix)
  names(results)=c("dszbs","mszbs","tszbs")
  return(results)
} # end getmszmnbs
######################################################

################################################
sumbyquadndiv=function(z,dinit,x,y,gridsize,ddiv)
  # a generic function for summing z data by xy quadrat of dimension gridsize and size classes ddiv of dinit
  # NOTE: if there are no stems in an xy quadrat, then it will not be a column in the output file
  ################################################
{
  inc=!is.na(z)
  ndclass=length(ddiv)-1
  dbhclass=as.numeric(cut(dinit,breaks=ddiv,right=F,labels=1:ndclass))
  rowcol=paste("x",floor(x/gridsize),"y",floor(y/gridsize),sep="")
  rcs=sort(unique(rowcol))
  zsum=tapply(z[inc],list(rowcol[inc],dbhclass[inc]),sum)
  dmtch=match((1:ndclass),colnames(zsum))
  xmtch=match(rcs,rownames(zsum))
  zsum=zsum[xmtch,dmtch]
  colnames(zsum)=paste(ddiv[1:ndclass],"-",ddiv[2:(ndclass+1)],sep="")
  zsum[is.na(zsum)]=0
  return(zsum)
} # end sumbyquadndiv


################################################
countbyquadndiv=function(z,dinit,x,y,gridsize,ddiv)
  # a generic function for counting data by xy quadrat of dimension gridsize and size classes ddiv
  # NOTE: if there are no stems in an xy quadrat, then it will not be a column in the output file
  ################################################
{
  inc=!is.na(z)
  ndclass=length(ddiv)-1
  dbhclass=as.numeric(cut(dinit,breaks=ddiv,right=F,labels=1:ndclass))
  rowcol=paste("x",floor(x/gridsize),"y",floor(y/gridsize),sep="")
  rcs=sort(unique(rowcol))
  dn=tapply(dinit[inc],list(rowcol[inc],dbhclass[inc]),length)
  dmtch=match((1:ndclass),colnames(dn))
  xmtch=match(rcs,rownames(dn))
  dn=dn[xmtch,dmtch]
  colnames(dn)=paste(ddiv[1:ndclass],"-",ddiv[2:(ndclass+1)],sep="")
  dn[is.na(dn)]=0
  return(dn)
} # end countbyquadndiv


################################################
geteszmnbs=function(gind,x,gridsize,hectar,ddiv,nreps)
  ################################################
##Sum only
{
  nclass=length(ddiv)-1
  dn=countbyquadndiv(gind$dinit,gind$dinit,gind$gx,gind$gy,gridsize,ddiv)
  dsums=sumbyquadndiv(gind$dinit,gind$dinit,gind$gx,gind$gy,gridsize,ddiv)
  xsums=sumbyquadndiv(x,gind$dinit,gind$gx,gind$gy,gridsize,ddiv)
  tsums=sumbyquadndiv(gind$timeint,gind$dinit,gind$gx,gind$gy,gridsize,ddiv)
  
  ngrid=dim(dn)[1]
  dszmnmatrix=xszmnmatrix=tszmnmatrix=matrix(NA,ncol=nclass,nrow=nreps)
  for (j in 1:nreps) {
    whichgrids=sample(ngrid,ngrid,replace=T)
    dszmnmatrix[j,]=apply(dsums[whichgrids,],2,sum)/apply(dn[whichgrids,],2,sum,na.rm=T)
    xszmnmatrix[j,]=apply(xsums[whichgrids,],2,sum,na.rm=T)
    nxszmnmatrix=xszmnmatrix/hectar
    tszmnmatrix[j,]=apply(tsums[whichgrids,],2,sum)/apply(dn[whichgrids,],2,sum,na.rm=T)
  }
  colnames(dszmnmatrix)=colnames(nxszmnmatrix)=colnames(tszmnmatrix)=paste(ddiv[1:nclass],"-",ddiv[2:(nclass+1)],sep="")
  results=list(dszmnmatrix,nxszmnmatrix,tszmnmatrix)
  names(results)=c("dszbs","xszbs","tszbs")
  return(results)
} # end getxszmnbs


################################################
getszbs=function(nsztrue,ddiv,dsztrue,xsztrue,tsztrue,xszbs,alpha=c(0.05,0.01),xname="") 
################################################
  {
  nclass=length(ddiv)-1
  coredata=data.frame(mindbh=ddiv[1:nclass],maxdbh=ddiv[2:(nclass+1)],N0=nsztrue,dact=dsztrue,xactual=xsztrue,tact=tsztrue)
  names(coredata)[5]=paste(xname,"act",sep="")
  quants=apply(xszbs,2,quantile,probs=c(alpha[1]/2,1-alpha[1]/2,alpha[2]/2,1-alpha[2]/2), na.rm=T)
  quantdf=as.data.frame(t(quants))
  names(quantdf)=c(paste(xname,"lo1",sep=""),paste(xname,"hi1",sep=""),
                   paste(xname,"lo2",sep=""),paste(xname,"hi2",sep=""))
  alldata=cbind(coredata,quantdf)
  return(alldata)
} # end getszbs

############################################
graphmort=function(outfilestem="Rate") 
  {
  cols=c("darkblue","forestgreen","darkorange") 
  pchs=c(16,4,17) #Shapes
  ltys=c(1,1,1) #Line type
  space=c(.5,2,3.5) #Spaces between lines in the legend
  load(file=paste(datadir,outfilestem,"mortsize.rdata",sep=""))
  mortdata=mszdata #Load mortality data
  load(file=paste(datadir,outfilestem,"ecomortbiomass.rdata",sep=""))
  ecomortbiomassdata=emszdata #Load biomass mortality data
  nsites=length(mortdata)
  ncensus<-c("2008-2013","2013-2014","2014-2015")
  
  #Use exactly log-even bins for 1cm width:
  #binmin<-seq(2.3,6.7,.22)
  binmin<-c(2.30,2.52,2.74,2.96,3.18,3.40,3.62,3.84,4.06,4.28,4.50,4.72,4.94,5.16,5.38,5.60,5.82,6.04,6.26,6.48,6.70)
  binmax<-c(2.52,2.74,2.96,3.18,3.40,3.62,3.84,4.06,4.28,4.50,4.72,4.94,5.16,5.38,5.60,5.82,6.04,6.26,6.48,6.70,7.04)
  Width<-exp(binmax)-exp(binmin)
  Width<-Width/10 #convert to cm 
  
#Create tiff file:
 options(scipen = 999)
 windowsFonts(
   A=windowsFont("Arial"))
 tiff(file = "Figure3.tiff", width = 7.5, height = 8.75, units = "in", res = 600, family ="A", pointsize = 12,compression="lzw")
 par(mfrow=c(2,1),oma=c(5,0,2,2),mar=c(0,5,0,0))
  

  # graph mortality
  k=1
  for (i in 1:3) {
    mdata=mortdata[[i]]
    dataname=names(mortdata)[i]
    inc=mdata$dact>0&!is.na(mdata$dact)&mdata$mortact>0&!is.nan(mdata$mortact)&mdata$mortact<Inf
    mdata=mdata[inc,]
    tmean=mean(mdata$tact)
    if (k==1)
      plot(mdata$dact/10,mdata$mortact,col=cols[k],pch=pchs[k],
           log="xy",xlim=c(1,100), ylim=c(.2,20),
           xaxt="n",xlab="",ylab=expression(Mortality~Rate~("%"~y^{-1})))
    else
      points(mdata$dact/10,mdata$mortact,col=cols[k],pch=pchs[k])
    for (j in 1:dim(mdata)[1])
      if (mdata$mortlo1[j]>0) #Add CIs
        lines(c(mdata$dact[j]/10,mdata$dact[j]/10),c(mdata$mortlo1[j],mdata$morthi1[j]),col=cols[k]) 
     
     legend(1,.75,legend=paste(ncensus[k]),lty=ltys[k],lwd=1,pch=pchs[k],col=cols[k],y.intersp=space[k],bty="n")#,cex=1.5,pt.cex=1.5)
    #Fit Regression:
     
   if (i==1) { #2008-2013
        #Stems >10 cm
     data=mdata[mdata$dact>=100,]
     x=data$dact/10
     y=data$mortact
     logmod <- lm(log(y)~log(x))
     #logmod <- lm(log(y)~log(x)+x) #U-shaped curve
     logypred <- predict(logmod) 
     lines(exp(logypred)~x,col=cols[k])
        #All stems
     p=mdata$dact/10
     q=mdata$mortact
     logmod3 <- lm(log(q)~log(p))
     #logmod3 <- lm(log(q)~log(p)+p) #U-shaped curve 
     logypred3 <- predict(logmod3) 
     lines(exp(logypred3)~p, col=cols[k],lty=2)
     sum=summary(logmod)
     p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
     cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
     cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
     #cis3<-confint(logmod,'x',level=0.95,method="boot",nsim=1000)
     stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,b=sum$coefficients[[2]],bCIlo=cis[1],bCIhi=cis[2],b_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4])
     sum2=summary(logmod3)
     p2.value<-pf(sum2$fstatistic[1], sum2$fstatistic[2], sum2$fstatistic[3],lower.tail = FALSE)
     cis2<-confint(logmod3,'log(p)',level=0.95,method="boot",nsim=1000)
     cis2y<-confint(logmod3,'(Intercept)',level=0.95,method="boot",nsim=1000)
     #cis23<-confint(logmod3,'p',level=0.95,method="boot",nsim=1000)
     stats2=data.frame(census=ncensus[i],cutoff="all",r2=sum2$r.squared,r2adj=sum2$adj.r.squared,p.value=p2.value,b=sum2$coefficients[[2]],bCIlo=cis2[1],bCIhi=cis2[2],b_p=sum2$coefficients[2,4],y0=sum2$coefficients[[1]],yCIlo=cis2y[1],yCIhi=cis2y[2],y0_p=sum2$coefficients[1,4])
    stats=rbind(stats,stats2)} 
    
    if (i==2) #2013-2014
    {
     x=mdata$dact/10
     y=mdata$mortact
     logmod <- lm(log(y)~log(x)) 
     #logmod <- lm(log(y)~log(x)+x) #U-shaped curve
     logypred <- predict(logmod) 
     lines(exp(logypred)~x, col=cols[k]) 
     sum=summary(logmod)
     p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
     cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
     cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
     #cis3<-confint(logmod,'x',level=0.95,method="boot",nsim=1000)
     stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,b=sum$coefficients[[2]],bCIlo=cis[1],bCIhi=cis[2],b_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4])
    }
    
    if (i==3) #2014-2015
    {x=mdata$dact/10
      y=mdata$mortact
      logmod <- lm(log(y)~log(x)) 
     #logmod <- lm(log(y)~log(x)+x) #U-shaped curve
      logypred <- predict(logmod) 
      lines(exp(logypred)~x, col=cols[k],lty=ltys[k])
     sum=summary(logmod)
     p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
     cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
     cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
     #cis3<-confint(logmod,'x',level=0.95,method="boot",nsim=1000)
     stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,b=sum$coefficients[[2]],bCIlo=cis[1],bCIhi=cis[2],b_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4])
     }

    if (i==1)
      graphstats=stats
    if (i==2)
      graphstats=rbind(graphstats,stats)
    if (i==3)
      graphstats=rbind(graphstats,stats)
  
  if (i==3)
    {colnames(graphstats)=c("census","cutoff","mort_r2","mort_r2adj","mort_p.value","mort_b","mort_b_95CIlo","mort_b_95CIhi","mort_b_p","mort_y0","mort_y095CIlo","mort_y095CIhi","mort_y0_p")
    text(1,15,"A",font=2)}#,cex=1.5)}

    if (i<nsites) {
        k=k+1
    }
  } #End mortality graph
  
  
  # graph biomass mortality 
  k=1
  for (i in 1:nsites) {
    emdata=ecomortbiomassdata[[i]]
    dataname=names(ecomortbiomassdata)[i]
    inc=emdata$dact>0&!is.na(emdata$dact)&emdata$ecomortbiomassact>0
    emdata=emdata[inc,]
    width=Width[inc]
    tmean=mean(emdata$tact)
    if (k==1)
      plot(emdata$dact/10,emdata$ecomortbiomassact/width,col=cols[k],pch=pchs[k], log="xy",ylim=c(.001,.25),xlim=c(1,100),
           xlab="Diameter (cm)",ylab=expression(Biomass ~ Mortality ~ (Mg ~ ha^{-1} ~ y^{-1}~cm^{-1})))
    else
      points(emdata$dact/10,emdata$ecomortbiomassact/width,col=cols[k],pch=pchs[k])#,cex=1)
    for (j in 1:dim(emdata)[1])
      if (emdata$ecomortbiomasslo1[j]>=0)
        lines(c(emdata$dact[j]/10,emdata$dact[j]/10),c(emdata$ecomortbiomasslo1[j]/width[j],emdata$ecomortbiomasshi1[j]/width[j]),col=cols[k])
    emdata$ecomortbiomassact<-emdata$ecomortbiomassact/width
    emdata<-emdata[emdata$dact<800,]
    
    #Fit Regression
    if (i==1) #2008-2013
    { #>10 cm
     edata=emdata[emdata$dact>=99.5,]
     x=edata$dact/10
     y=edata$ecomortbiomassact
     logmod <- lm(log(y)~log(x)) 
     logypred <- predict(logmod) 
     lines(exp(logypred)~x, col=cols[k])
     #All sizes
     p=emdata$dact/10
     q=emdata$ecomortbiomassact
     logmod3 <- lm(log(q)~log(p)) 
     logypred3 <- predict(logmod3) 
     lines(exp(logypred3)~p, col=cols[k],lty=2)
     sum=summary(logmod)
     p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
     cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
     cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
     stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,b=sum$coefficients[[2]],bCIlo=cis[1],bCIhi=cis[2],b_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4])
     sum2=summary(logmod3)
     p2.value<-pf(sum2$fstatistic[1], sum2$fstatistic[2], sum2$fstatistic[3],lower.tail = FALSE)
     cis2<-confint(logmod3,'log(p)',level=0.95,method="boot",nsim=1000)
     cis2y<-confint(logmod3,'(Intercept)',level=0.95,method="boot",nsim=1000)
     stats2=data.frame(census=ncensus[i],cutoff="all",r2=sum2$r.squared,r2adj=sum2$adj.r.squared,p.value=p2.value,b=sum2$coefficients[[2]],bCIlo=cis2[1],bCIhi=cis2[2],b_p=sum2$coefficients[2,4],y0=sum2$coefficients[[1]],yCIlo=cis2y[1],yCIhi=cis2y[2],y0_p=sum2$coefficients[1,4])
     stats=rbind(stats,stats2)} 
    
  if (i==2) #2013-2014
    {
     x=emdata$dact/10
     y=emdata$ecomortbiomassact
     logmod <- lm(log(y)~log(x)) 
     logypred <- predict(logmod) 
     lines(exp(logypred)~x, col=cols[k]) 
     sum=summary(logmod)
     p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
     cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
     cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
     stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,b=sum$coefficients[[2]],bCIlo=cis[1],bCIhi=cis[2],b_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4])
    }
    
  if (i==3) #2014-2015
    {x=emdata$dact/10
     y=emdata$ecomortbiomassact
     logmod <- lm(log(y)~log(x)) 
     logypred <- predict(logmod) 
     lines(exp(logypred)~x, col=cols[k],lty=1)
     sum=summary(logmod)
     p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
     cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
     cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
     stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,b=sum$coefficients[[2]],bCIlo=cis[1],bCIhi=cis[2],b_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4])}
    
    if (i==1)
      agbgraphstats=stats
    if (i==2)
      agbgraphstats=rbind(agbgraphstats,stats)
    if (i==3)
      agbgraphstats=rbind(agbgraphstats,stats)
 
      if (i==3)
    {colnames(agbgraphstats)=c("census","cutoff","agb_r2","agb_r2adj","agb_p.value","agb_b","agb_b95CIlo","agb_b95CIhi","agb_b_p","agb_y0","agb_y095CIlo","agb_y095CIhi","agb_y0_p")
    text(1,.2,"B",font=2)}#,cex=1.5)}
    
    
    if (i<nsites) {
        k=k+1
    }
  } 
  Figure1graphstats<-merge(graphstats,agbgraphstats)
  #write.table(Figure1graphstats,file="Figure3graphstatsPowFit.txt")
  write.csv(Figure1graphstats,"Figure3graphstatsPowFit.csv")
mtext(expression("Diameter (cm)"), side = 1, outer = TRUE, line = 3)#, cex = 1.5,)

  
} # end graphmort
##############################################


#U-curve. 
graphmortU=function(outfilestem="Rate") 
  {
  cols=c("black","black","black")
  cols=c("darkblue","forestgreen","darkorange")
  pchs=c(16,4,17) #Good for color
  ltys=c(1,1,1)
  #space=c(.5,1,1.5,2,2.5,3)
  space=c(.5,2,3.5)
  ycoords=c(20,15,11)
  y2coords=c(1,.5,.25)
  load(file=paste(datadir,outfilestem,"mortsize.rdata",sep=""))
  mortdata=mszdata
  load(file=paste(datadir,outfilestem,"ecomortbiomass.rdata",sep=""))
  ecomortbiomassdata=emszdata
  nsites=length(mortdata)
  ncensus<-c("2008-2013","2013-2014","2014-2015")

  #Use exactly log-even bins for 1cm width:
  #binmin<-seq(2.3,6.7,.22)
  binmin<-c(2.30,2.52,2.74,2.96,3.18,3.40,3.62,3.84,4.06,4.28,4.50,4.72,4.94,5.16,5.38,5.60,5.82,6.04,6.26,6.48,6.70)
  binmax<-c(2.52,2.74,2.96,3.18,3.40,3.62,3.84,4.06,4.28,4.50,4.72,4.94,5.16,5.38,5.60,5.82,6.04,6.26,6.48,6.70,7.04)
  Width<-exp(binmax)-exp(binmin)
  Width<-Width/10 #convert to cm 
  
  #1 Figure:
  #win.graph(width=7.5,height=8.75,pointsize=12)
  options(scipen = 999)
  windowsFonts(
    A=windowsFont("Arial"))
  tiff(file = "Figure3_U.tiff", width = 7.5, height = 8.75, units = "in", res = 600, family ="A", pointsize = 12,compression="lzw")
  
  #par(mfrow=c(2,1))
  #m<-rbind(c(1,1,1,1),c(2,2,2,2))
  #layout(m)
  par(mfrow=c(2,1),oma=c(5,0,2,2),mar=c(0,5,0,0))
  
  
  # graph mortality
  minmort=min(mortdata[[1]]$mortact[mortdata[[1]]$mortact>0&mortdata[[1]]$mortact<Inf],na.rm=T)
  maxmort=max(mortdata[[1]]$mortact[mortdata[[1]]$mortact>0&mortdata[[1]]$mortact<Inf],na.rm=T)
  if (nsites>1) {
    for (i in 2:nsites) {
      minmort=min(c(minmort,mortdata[[i]]$mortact[mortdata[[i]]$mortact>0&mortdata[[i]]$mortact<Inf]),na.rm=T)
      maxmort=max(c(maxmort,mortdata[[i]]$mortact[mortdata[[i]]$mortact>0&mortdata[[i]]$mortact<Inf]),na.rm=T)
    }
  }
  k=1
  for (i in 1:3) {
    #if (k==1)
    ##win.graph(width=3.25,height=3.5)
    #win.graph(width=7,height=8)
    ##par(mar = c(5,6.5,4,2))
    #par(mar=c(5,6.5,2,2))
    mdata=mortdata[[i]]
    dataname=names(mortdata)[i]
    
    inc=mdata$dact>0&!is.na(mdata$dact)&mdata$mortact>0&!is.nan(mdata$mortact)&mdata$mortact<Inf
    mdata=mdata[inc,]
    #if (i==1)
    # {mdata[32,7]<-0.000000001} #For 35 bins
    #mdata$mortlo1<-ifelse(mdata$mortlo1==0,0.00000001,mdata$mortlo1)
    
    tmean=mean(mdata$tact)
    if (k==1)
      #main=as.character("Mortality Rate") #xlab=expression(bold("Diameter (cm)"))
      plot(mdata$dact/10,mdata$mortact,col=cols[k],pch=pchs[k],
           log="xy",xlim=c(1,100), ylim=c(.2,20),#ylim=c(.1,10), #ylim=c(.0002,20)
           xaxt="n",xlab="",ylab=expression(Mortality~Rate~("%"~y^{-1})))#,cex=1,cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5)
    else
      points(mdata$dact/10,mdata$mortact,col=cols[k],pch=pchs[k])#,cex=1)
    for (j in 1:dim(mdata)[1])
      if (mdata$mortlo1[j]>0)
        lines(c(mdata$dact[j]/10,mdata$dact[j]/10),c(mdata$mortlo1[j],mdata$morthi1[j]),col=cols[k]) 
    #if (nsites>1){
    #rect(20, 0.1, 150, 1, border = "black")
    #ylim=c(0.001,1)
    legend(1,.75,legend=paste(ncensus[k]),lty=ltys[k],lwd=1,pch=pchs[k],col=cols[k],y.intersp=space[k],bty="n")#,cex=1.5,pt.cex=1.5)
    #if (i==1|2)
    if (i==1)
    {data=mdata[mdata$dact>=100,]
    x=data$dact/10
    y=data$mortact
    #logmod <- lm(log(y)~log(x))
    logmod <- lm(log(y)~log(x)+x) #Attempt at u-fit
    logypred <- predict(logmod) 
    lines(exp(logypred)~x,col=cols[k])
    #lines(exp(logypred)~x,col="blue")
    #lines(exp(logypred)~log(x),col="purple")
    #abline(b=-.459, a= 2.1156,col="red") #slope looks the same, even if the points are higher
    #abline(b=-.459,a=.7493385,col="red")
    #lines(exp(logypred)~x, col=cols[k]) 
    #lines(logypred~x,col="blue")
    p=mdata$dact/10
    q=mdata$mortact
    #logmod3 <- lm(log(q)~log(p))
    logmod3 <- lm(log(q)~log(p)+p) 
    logypred3 <- predict(logmod3) 
    lines(exp(logypred3)~p, col=cols[k],lty=2)
    sum=summary(logmod)
    p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
    cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
    cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
    cis3<-confint(logmod,'x',level=0.95,method="boot",nsim=1000)
    stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,par2=sum$coefficients[[2]],par2CIlo=cis[1],par2CIhi=cis[2],par2_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4],par3=sum$coefficients[[3]],par3CIlo=cis3[1],par3CIhi=cis3[2],par3_p=sum$coefficients[3,4],y0_exp=exp(sum$coefficients[[1]]))
    sum2=summary(logmod3)
    p2.value<-pf(sum2$fstatistic[1], sum2$fstatistic[2], sum2$fstatistic[3],lower.tail = FALSE)
    cis2<-confint(logmod3,'log(p)',level=0.95,method="boot",nsim=1000)
    cis2y<-confint(logmod3,'(Intercept)',level=0.95,method="boot",nsim=1000)
    cis23<-confint(logmod3,'p',level=0.95,method="boot",nsim=1000)
    stats2=data.frame(census=ncensus[i],cutoff="all",r2=sum2$r.squared,r2adj=sum2$adj.r.squared,p.value=p2.value,par2=sum2$coefficients[[2]],par2CIlo=cis2[1],par2CIhi=cis2[2],par2_p=sum2$coefficients[2,4],y0=sum2$coefficients[[1]],yCIlo=cis2y[1],yCIhi=cis2y[2],y0_p=sum2$coefficients[1,4],par3=sum2$coefficients[[3]],par3CIlo=cis23[1],par3CIhi=cis23[2],par3_p=sum2$coefficients[3,4],y0_exp=exp(sum2$coefficients[[1]]))
    stats=rbind(stats,stats2)} 
    
    if (i==2)
    {#data=mdata[mdata$dact>=100,]
      x=mdata$dact/10
      y=mdata$mortact
      #logmod <- lm(log(y)~log(x)) 
      logmod <- lm(log(y)~log(x)+x) #Attempt at u-fit
      logypred <- predict(logmod) 
      lines(exp(logypred)~x, col=cols[k]) 
      #p=mdata$dact/10
      #q=mdata$mortact
      #logmod3 <- lm(log(q)~log(p)) 
      #logmod3 <- lm(log(q)~log(p)+p)
      #logypred3 <- predict(logmod3) 
      #lines(exp(logypred3)~p, col=cols[k],lty=2)
      sum=summary(logmod)
      p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
      cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
      cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
      cis3<-confint(logmod,'x',level=0.95,method="boot",nsim=1000)
      stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,par2=sum$coefficients[[2]],par2CIlo=cis[1],par2CIhi=cis[2],par2_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4],par3=sum$coefficients[[3]],par3CIlo=cis3[1],par3CIhi=cis3[2],par3_p=sum$coefficients[3,4],y0_exp=exp(sum$coefficients[[1]]))
      #sum2=summary(logmod3)
      #cis2<-confint(logmod3,'log(p)',level=0.95)
      #cis2y<-confint(logmod3,'(Intercept)',level=0.95)
      #stats2=data.frame(census=ncensus[i],cutoff="all",r2=sum2$r.squared,z=sum2$coefficients[[2]],zCIlo=cis2[1],zCIhi=cis2[2],y0=sum2$coefficients[[1]],yCIlo=cis2y[1],yCIhi=cis2y[2],par3=sum$coefficients[[3]],par3CIlo=cis3[1],par3CIhi=cis3[2],y0_exp=exp(sum2$coefficients[[1]]))
      #stats=rbind(stats,stats2)} 
    }
    
    if (i==3)
    {x=mdata$dact/10
    y=mdata$mortact
    #logmod <- lm(log(y)~log(x)) 
    logmod <- lm(log(y)~log(x)+x) #Attempt at u-fit
    logypred <- predict(logmod) 
    lines(exp(logypred)~x, col=cols[k],lty=ltys[k])
    sum=summary(logmod)
    p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
    cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
    cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
    cis3<-confint(logmod,'x',level=0.95,method="boot",nsim=1000)
    stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,par2=sum$coefficients[[2]],par2CIlo=cis[1],par2CIhi=cis[2],par2_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4],par3=sum$coefficients[[3]],par3CIlo=cis3[1],par3CIhi=cis3[2],par3_p=sum$coefficients[3,4],y0_exp=exp(sum$coefficients[[1]]))}
    #sum<-summary(logmod)
    #r2<-sum$r.squared
    #z<-sum$coefficients[[2]]
    
    if (i==1)
      graphstats=stats
    #if (i==2|3)
    if (i==2)
      graphstats=rbind(graphstats,stats)
    if (i==3)
      graphstats=rbind(graphstats,stats)
    
    #Question: do these values need to be log transformed? what's the deal with lines?
    stats100=graphstats[graphstats$cutoff==100,]
    z=stats100$z[i]
    hi=stats100$zCIhi[i]
    lo=stats100$zCIlo[i]
    #nums=c(1,2,3)
    #text(100,ycoords[i],paste("z = -",signif(z,digits=3),),cex=1.75)
    #text(50,ycoords[i],bquote("z"[.(paste0(ncensus[i]))]~.(paste0(" = ",signif(z,digits=3)))~.(paste0("(",signif(lo,digits=3)))~.(paste0(",",signif(hi,digits=3),")"))),cex=1.75)
    #text(50,ycoords[i],bquote("z"[.(paste0(ncensus[i]))]~.(paste0(" = ",signif(z,digits=3)))~.(paste0("(",signif(lo,digits=3),", ",signif(hi,digits=3),")"))),cex=2)
    #bquote("t"[0]~.(paste0('=',t0)
    if (i==3)
    {colnames(graphstats)=c("census","cutoff","mort_r2","mort_r2adj","mort_p.value","mort_par2","mort_par2_95CIlo","mort_par2_95CIhi","mort_par2_p","mort_y0","mort_y095CIlo","mort_y095CIhi","mort_y0_p","mort_par3","mort_par395CIlo","mort_par395CIhi","mort_par3_p","mort_y0_exp")
    text(1,15,"A",font=2)}#,cex=1.5)}
    #write.table(graphstats,file="graphstats.txt")}
    
    if (i<nsites) {
      #if (substr(names(mortdata)[i],1,3)==substr(names(mortdata)[i+1],1,3))
      k=k+1
      #else
      #k=1
    }
  }
  
  # graph biomass mortality ecosystem level
  minecomortbiomass=min(ecomortbiomassdata[[1]]$ecomortbiomassact[ecomortbiomassdata[[1]]$ecomortbiomassact>0&ecomortbiomassdata[[1]]$ecomortbiomassact<Inf],na.rm=T)
  maxecomortbiomass=max(ecomortbiomassdata[[1]]$ecomortbiomassact[ecomortbiomassdata[[1]]$ecomortbiomassact>0&ecomortbiomassdata[[1]]$ecomortbiomassact<Inf],na.rm=T)
  if (nsites>1) {
    for (i in 2:nsites) {
      minecomortbiomass=min(c(minecomortbiomass,ecomortbiomassdata[[i]]$ecomortbiomassact[ecomortbiomassdata[[i]]$ecomortbiomassact>0&ecomortbiomassdata[[i]]$ecomortbiomassact<Inf]),na.rm=T)
      maxecomortbiomass=max(c(maxecomortbiomass,ecomortbiomassdata[[i]]$ecomortbiomassact[ecomortbiomassdata[[i]]$ecomortbiomassact>0&ecomortbiomassdata[[i]]$ecomortbiomassact<Inf]),na.rm=T)
    }
  }
  k=1
  for (i in 1:nsites) {
    #if (k==1)
    #win.graph(width=3.25,height=3.5)
    ##par(mar = c(5,6.5,4,2))
    #par(mar=c(5,6.5,2,2))
    emdata=ecomortbiomassdata[[i]]
    dataname=names(ecomortbiomassdata)[i]
    
    inc=emdata$dact>0&!is.na(emdata$dact)&emdata$ecomortbiomassact>0
    emdata=emdata[inc,]
    width=Width[inc]
    tmean=mean(emdata$tact)
    #emdata$ecomortbiomasslo1<-ifelse(emdata$ecomortbiomasslo1==0,0.00000001,emdata$ecomortbiomasslo1)
    if (k==1)
      #main=as.character("Biomass Mortality")
      plot(emdata$dact/10,emdata$ecomortbiomassact/width,col=cols[k],pch=pchs[k],   log="xy",ylim=c(.0005,2),xlim=c(1,100),
           xlab="Diameter (cm)",ylab=expression(Biomass ~ Mortality ~ (Mg ~ ha^{-1} ~ y^{-1})))#,cex=1,cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5) #was cex=1.25, cex.lab=1.5
    else
      points(emdata$dact/10,emdata$ecomortbiomassact,col=cols[k],pch=pchs[k])#,cex=1)
    for (j in 1:dim(emdata)[1])
      if (emdata$ecomortbiomasslo1[j]>0)
        lines(c(emdata$dact[j]/10,emdata$dact[j]/10),c(emdata$ecomortbiomasslo1[j]/width[j],emdata$ecomortbiomasshi1[j]/width[j]),col=cols[k])
    #if (nsites>1){
    #rect(20, .0002, 150, .005, border = "black") 
    #legend(20,.005,legend=paste(ncensus[k]),lty=1,lwd=1,pch=pchs[k],col=cols[k],y.intersp=space[k],bty="n")}
    if (i==1)
    {edata=emdata[emdata$dact>=99.5,]
    x=edata$dact/10
    y=edata$ecomortbiomassact/width
    logmod <- lm(log(y)~log(x)) 
    logypred <- predict(logmod) 
    lines(exp(logypred)~x, col=cols[k]) 
    #lines(exp(logypred)~x,col="blue")
    #abline(b=1.0453,a= .00348,col="red",untf=T)
    #abline(b=1.0453,a= -2.5,col="purple")
    p=emdata$dact/10
    q=emdata$ecomortbiomassact
    logmod3 <- lm(log(q)~log(p)) 
    logypred3 <- predict(logmod3) 
    lines(exp(logypred3)~p, col=cols[k],lty=2)
    sum=summary(logmod)
    p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
    cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
    cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
    stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,z=sum$coefficients[[2]],zCIlo=cis[1],zCIhi=cis[2],z_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4],y0_exp=exp(sum$coefficients[[1]]))
    sum2=summary(logmod3)
    p2.value<-pf(sum2$fstatistic[1], sum2$fstatistic[2], sum2$fstatistic[3],lower.tail = FALSE)
    cis2<-confint(logmod3,'log(p)',level=0.95,method="boot",nsim=1000)
    cis2y<-confint(logmod3,'(Intercept)',level=0.95,method="boot",nsim=1000)
    stats2=data.frame(census=ncensus[i],cutoff="all",r2=sum2$r.squared,r2adj=sum2$adj.r.squared,p.value=p2.value,z=sum2$coefficients[[2]],zCIlo=cis2[1],zCIhi=cis2[2],z_p=sum2$coefficients[2,4],y0=sum2$coefficients[[1]],yCIlo=cis2y[1],yCIhi=cis2y[2],y0_p=sum2$coefficients[1,4],y0_exp=exp(sum2$coefficients[[1]]))
    stats=rbind(stats,stats2)} 
    
    if (i==2)
    {#edata=emdata[emdata$dact>=100,]
      x=emdata$dact/10
      y=emdata$ecomortbiomassact/width
      logmod <- lm(log(y)~log(x)) 
      logypred <- predict(logmod) 
      lines(exp(logypred)~x, col=cols[k]) 
      #data2=mdata[mdata$dact<=100,]
      #a=data2$dact/10
      #b=data2$mortact
      #logmod2 <- lm(log(b)~log(a)) 
      #logypred2 <- predict(logmod2) 
      #lines(exp(logypred2)~a, col=cols[k])
      #p=emdata$dact/10
      #q=emdata$ecomortbiomassact
      #logmod3 <- lm(log(q)~log(p)) 
      #logypred3 <- predict(logmod3) 
      #lines(exp(logypred3)~p, col=cols[k],lty=2)
      sum=summary(logmod)
      p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
      cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
      cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
      stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,z=sum$coefficients[[2]],zCIlo=cis[1],zCIhi=cis[2],z_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4],y0_exp=exp(sum$coefficients[[1]]))
      #sum2=summary(logmod3)
      #cis2<-confint(logmod3,'log(p)',level=0.95)
      #cis2y<-confint(logmod3,'(Intercept)',level=0.95)
      #stats2=data.frame(census=ncensus[i],cutoff="all",r2=sum2$r.squared,z=sum2$coefficients[[2]],zCIlo=cis2[1],zCIhi=cis2[2],y0=sum2$coefficients[[1]],yCIlo=cis2y[1],yCIhi=cis2y[2],y0_exp=exp(sum$coefficients[[1]]))
      #stats=rbind(stats,stats2)}
    }
    
    if (i==3)
    {x=emdata$dact/10
    y=emdata$ecomortbiomassact/width
    logmod <- lm(log(y)~log(x)) 
    logypred <- predict(logmod) 
    lines(exp(logypred)~x, col=cols[k],lty=1)
    sum=summary(logmod)
    p.value<-pf(sum$fstatistic[1], sum$fstatistic[2], sum$fstatistic[3],lower.tail = FALSE)
    cis<-confint(logmod,'log(x)',level=0.95,method="boot",nsim=1000)
    cisy<-confint(logmod,'(Intercept)',level=0.95,method="boot",nsim=1000)
    stats=data.frame(census=ncensus[i],cutoff="100",r2=sum$r.squared,r2adj=sum$adj.r.squared,p.value=p.value,z=sum$coefficients[[2]],zCIlo=cis[1],zCIhi=cis[2],z_p=sum$coefficients[2,4],y0=sum$coefficients[[1]],yCIlo=cisy[1],yCIhi=cisy[2],y0_p=sum$coefficients[1,4],y0_exp=exp(sum$coefficients[[1]]))}
    #sum<-summary(logmod)
    #r2<-sum$r.squared
    #z<-sum$coefficients[[2]]
    
    if (i==1)
      agbgraphstats=stats
    #if (i==2|3)
    if (i==2)
      agbgraphstats=rbind(agbgraphstats,stats)
    if (i==3)
      agbgraphstats=rbind(agbgraphstats,stats)
    #Question: do these values need to be log transformed? what's the deal with lines?
    agbstats100=agbgraphstats[agbgraphstats$cutoff==100,]
    z=agbstats100$z[i]
    hi=agbstats100$zCIhi[i]
    lo=agbstats100$zCIlo[i]
    #nums=c(1,2,3)
    #text(100,ycoords[i],paste("z = -",signif(z,digits=3),),cex=1.75)
    #text(2,y2coords[i],bquote("z"[.(paste0(ncensus[i]))]~.(paste0(" = ",signif(z,digits=3)))),cex=1.75)
    #text(3,y2coords[i],bquote("z"[.(paste0(ncensus[i]))]~.(paste0(" = ",signif(z,digits=3)))~.(paste0("(",signif(lo,digits=3),", ",signif(hi,digits=3),")"))),cex=2)
    if (i==3)
    {colnames(agbgraphstats)=c("census","cutoff","agb_r2","agb_r2adj","agb_p.value","agb_z","agb_z95CIlo","agb_z95CIhi","agb_z_p","agb_y0","agb_y095CIlo","agb_y095CIhi","agb_y0_p","agb_exp_y0")
    text(1,1,"B",font=2)}#,cex=1.5)}
    #write.table(agbgraphstats,file="agbgraphstats.txt")}
    #fit=lm(log(y) ~ log(x))
    #abline(fit)
    # adds lines for fits
    #predagbs=predgrowth(c(thisallefit$mindbh,thisallefit$maxdbh),thisallefit$empar1,thisallefit$empar2,tmean,gmethod="non-exact")
    #lines(c(thisallefit$mindbh,thisallefit$maxdbh)/10,predagbs,col=cols[k],lty=2)
    
    if (i<nsites) {
      #if (substr(names(ecomortbiomassdata)[i],1,3)==substr(names(ecomortbiomassdata)[i+1],1,3))
      k=k+1
      #else
      #k=1
    }
  } 
  Figure1graphstats<-merge(graphstats,agbgraphstats)
  write.table(Figure1graphstats,file="Figure1graphstats.txt")
  mtext(expression("Diameter (cm)"), side = 1, outer = TRUE, line = 3)#, cex = 1.5,)
  #mtext(expression(bold("Diameter (cm)")), side = 1, outer = TRUE, line = 3)#, cex = 1.5,)
  
  
  
} # end graphmort

