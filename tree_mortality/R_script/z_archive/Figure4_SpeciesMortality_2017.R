##########################################################################
#Figure 4 from Tree Mortality Paper: Species-Level Tree Mortality
#Adapted to work at all sites
# Author: Based on Tori Meakem - 10/26/2016; # Adapted by Ryan Helcoski - 8/21/2017

##########################################################################
### NOTE!! This is currently only to be used for including 2016 and 2017 mortality data into the previous figure 3 that only included up to 2015. It is not standardized to be used for coming years


rm(list = ls())

# Set up working directory ####
setwd(" ")


# INPUT DATA LOCATION ####
Input_data_location <- "INPUT_FILES/"

# OUTPUT DATA LOCATION ####
Output_data_location_Stats <- "OUTPUT_FILES/Stats/"
Output_data_location_Graphs <- "OUTPUT_FILES/Graphs/"

# Load Data ####
## Load ForestGEO Census data (stem R tables)
load(paste0(Input_data_location, "scbi.stem1.rdata"))
load(paste0(Input_data_location, "scbi.stem2.rdata"))

## Load annual mortality data
# load(paste0(Input_data_location, "allmort17.rdata"))
allmort17 <- read.csv(paste0(Input_data_location, "allmort17.csv"))

### NOTE### this was a minor correction of an incorrect date entered in 2016, date was accidently entered as 2106 instead of 2016. It has since been corrected in the original raw csv file, however, this  script is using the original allmort17.csv. It has been corrected in the newest version and is no longer necessary
#allmort17[allmort17$date.2016 %in% 53539,]$date.2016 <- as.numeric(as.Date("2016-08-02"))




#Run lines directly below
library(ggplot2)
library(RColorBrewer)
library(cowplot)
library(kSamples)
library(grid)
library(gridExtra)


#Enter censuses here
censuslist<-list(scbi.stem1,scbi.stem2)



  
#FUNCTION LIST
#############################################
runplot=function(censuslist,hectar,mindbh,ncuts,rnd,zdead,taper,rm.secondary,stem.match,units.C,site,which.plot){
#Set number of loops
  if (site=="scbi"&mindbh>=100)
    {nsets=5 
    nrot=6
    if (units.C==F)
      {allmort=allmort17
      allmort$agb.2013<-allmort$agb.2013*.47
      allmort$agb.2015<-allmort$agb.2015*.47
      allmort$agb.2016<-allmort$agb.2016*.47
      allmort$agb.2017<-allmort$agb.2017*.47}
      }
  else
    {nsets=length(censuslist)-1
    nrot=length(censuslist)}
  yearlist=list()
  

    

#Determine which species will be included
#Change: >100 species >100 dbh in at least 1 of census periods (could have 99 individuals in another)
  #if (hectar>=40)
    #ncut=200
  #if (hectar>=20&hectar<40)
    #ncut=100
  #if (hectar<=20)
    ncut=ncuts

    #To show all census years
  #for (i in 1:nrot){
    #if (site!="scbi"){
    #cen<-(censuslist[[i]])
    #cen<-cen[cen$dbh>=mindbh&!is.na(cen$dbh),]
    #tab<-table(cen$sp);tab<-tab[tab>=ncut]
    #sp<-names(tab)
   # if (i==1)
     # splist=sp
    #else
      #splist<-c(splist,sp)
    #splist<-unique(splist)}
    
    #if (site=="scbi"&i==1|site=="scbi"&i==2)
   # {
      #cen<-(censuslist[[i]])
     # cen<-cen[cen$dbh>=mindbh&!is.na(cen$dbh),]
     # tab<-table(cen$sp);tab<-tab[tab>=ncut]
     # sp<-names(tab)
      #if (i==1)
       # splist=sp
     # else
       # splist<-c(splist,sp)
     # }
   # if (site=="scbi"&i==3)
    #{
     # cen<-allmort[allmort$dbh.2013>=mindbh&allmort$status.2014!="Dead",]
     # tab<-table(cen$sp);tab<-tab[tab>=ncut]
      #splist<-c(splist,sp)}
    
    #if (site=="scbi"&i==4)
   # {
     # cen<-allmort[allmort$dbh.2013>=mindbh&allmort$status.2015!="Dead",]
      #tab<-table(cen$sp);tab<-tab[tab>=ncut]
      #splist<-c(splist,sp)
      #splist<-unique(splist)}
    
    #}
    
    
  
    #Rounddown set
    if (mindbh<55&rnd==T)
      rnds=c(T,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F)
    else
      rnds=c(F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F) #hack, fix this!
    
    #Zerosdead set
    if (mindbh==10&zdead==T)
      zdeads=T
    else
      zdeads=F
    
#Calculate mortality rates for each site
  for (i in 1:nsets)
  {
  
  #Identify dead trees, apply filters
  if(site!="scbi")
    {stem1=censuslist[[i]]
    stem2<-censuslist[[i+1]]
    
    #Site-specific issues
    if (taper==TRUE)
    {stem1$agb<-stem1$equiv.agb; stem1$dbh<-stem1$equiv.dbh
    stem2$agb<-stem2$equiv.agb; stem2$dbh<-stem2$equiv.dbh}
    
    if (stem.match==TRUE)
    {stem1$stemID<-stem1$stem.ID
    stem2$stemID<-stem2$stem.ID}
    
    #Set biomass to units C
    if (units.C==F)
      {stem1$agb<-stem1$agb*.47
      stem2$agb<-stem2$agb*.47}
    
    #BCI
    if (site=="bci"&rm.secondary==TRUE)
      {stem1<-stem1[!stem1$habitat=="young"|is.na(stem1$habitat),]
      stem2<-stem2[!stem2$habitat=="young"|is.na(stem2$habitat),]}
    if (site=="sherman"&rm.secondary==TRUE)
      {stem1<-stem1[!stem1$gy>=340,]
      stem2<-stem2[!stem2$gy>=340,]}
      
   
    mind<-indcalcmort(stem1,stem2,mindbh,rounddown=rnds[i],zerosdead=zdeads)}
  
  
    
#SCBI
    
  if (i==1&site=="scbi")
    {stem1=censuslist[[i]]
    stem2<-censuslist[[i+1]]
    #Set biomass to units C
    if (units.C==F)
    {stem1$agb<-stem1$agb*.47
    stem2$agb<-stem2$agb*.47}
    mind<-indcalcmort(stem1,stem2,mindbh,rounddown=rnds[i],zerosdead=zdeads)
    }
  if (i==2&site=="scbi")
    mind<-indcalcmort23(allmort)
  if (i==3&site=="scbi")
    mind<-indcalcmort34(allmort)
  if (i==4&site=="scbi")
    mind<-indcalcmort45(allmort)
  if (i==5&site=="scbi")
    mind<-indcalcmort56(allmort)
  #Set number
  #if (hectar>=45)
    #ncut=200
  #if (hectar>=20)
    #ncut=100
  #if (hectar<=20)
    #ncut=20
  #tab<-table(mind$species);tab<-data.frame(tab[tab>=ncut]) #will need to update for round 2
  #####tab<-table(mind$species);tab2<-tab/hectar;tab<-data.frame(tab[tab2>=3&tab>=20]) #3 per hectar
  #tab$Species<-rownames(tab)
  #mind<-mind[mind$species%in%tab$Species,]
  
  #Calculate Overall mortality rate (community-wide mean? Ask Krista)
  allmean<-mszmnORIG(mind$mort,mind$dinit,mind$timeint,ddiv=c(10,3501))
  
  
 # mind<-mind[mind$species%in%splist,]
  
  tab<-table(mind$species)
  tab<-data.frame(tab[tab>=ncut]) 
  #tab$Species<-rownames(tab)
  colnames(tab)[1] <- "Species"
  mind<-mind[mind$species%in%tab$Species,]
  
      
  
  #Calculate mortality rate
  ##################################
  mortrate<-mszmn(mind$mort,mind$species,mind$timeint)
  #Determine census years 
  y1<-mean(stem1$date,na.rm=TRUE)
  year1<-as.numeric(format(as.Date(y1,origin="1960-01-01"), '%Y')) 
  y2<-mean(stem2$date,na.rm=TRUE)
  year2<-as.numeric(format(as.Date(y2,origin="1960-01-01"), '%Y')) 
  mortrate$Census<-paste(year1,"-",year2,sep="")
  
  #For plotting later; years
  census=paste(year1,"-",year2,sep="")
  yearlist[[i]]=census
  
  if (i==2&site=="scbi")
  {year1=2013
  year2=2014
  mortrate$Census<-paste(year1,"-",year2,sep="")
  census=paste(year1,"-",year2,sep="")
  yearlist[[i]]=census}
  if (i==3&site=="scbi")
  {year1=2014
  year2=2015
  mortrate$Census<-paste(year1,"-",year2,sep="")
  census=paste(year1,"-",year2,sep="")
  yearlist[[i]]=census}
  if (i==4&site=="scbi")
  {year1=2015
  year2=2016
  mortrate$Census<-paste(year1,"-",year2,sep="")
  census=paste(year1,"-",year2,sep="")
  yearlist[[i]]=census}
  if (i==5&site=="scbi")
  {year1=2016
  year2=2017
  mortrate$Census<-paste(year1,"-",year2,sep="")
  census=paste(year1,"-",year2,sep="")
  yearlist[[i]]=census}
  
  #Biomass mortality
  mortagb<-mind[mind$mort==1&!is.na(mind$mort),]
  biomassmort=eszmn(mortagb$agb,mortagb$species,hectar)
  biomassmort$Census<-paste(year1,"-",year2,sep="")

if (i==1)
  {speciesmort<-mortrate
  speciesagbmort<-biomassmort
  allmortmean<-allmean}
else
  {speciesmort<-rbind(speciesmort,mortrate)
  speciesagbmort<-rbind(speciesagbmort,biomassmort)
  allmortmean<-rbind(allmortmean,allmean)}
  
} #end loop
  
  
  
  #Need all 
  #speciesmort<-rbind(mortrate12,mortrate23,mortrate34)
  speciesmort<-speciesmort[!is.na(speciesmort$mortrate)&speciesmort$mortrate!=Inf,]
  row.names(speciesmort)<-seq(nrow(speciesmort))
  
 # speciesagbmort<-rbind(biomassmort34,biomassmort45,biomassmort56,biomassmort67) #,biomassmort78)
  speciesagbmort<-speciesagbmort[!is.na(speciesagbmort$agb)&speciesagbmort$agb!=Inf,]
  row.names(speciesagbmort)<-seq(nrow(speciesagbmort))
  
  #Calculate CIS: Normal Approximation
#########################################
  
  species.morts<-speciesmort[speciesmort$ndead>5,]
  species.morts$mrtrate<-100*(1-((species.morts$ninit-species.morts$ndead)/species.morts$ninit))
  #mortrate12<-100*(1-((speciesmort$ninit-speciesmort$ndead)/speciesmort$ninit)^(1/speciesmort$timeint))
  ntot<-nrow(species.morts)
  for (i in 1:ntot){
    if (species.morts$mrtrate[i]!=100)
      {prop<-prop.test(species.morts$ndead[i],species.morts$ninit[i],species.morts$mrtrate[i]/100)
      ci1<-prop$conf.int[1]*species.morts$ninit[i]
      ci2<-prop$conf.int[2]*species.morts$ninit[i]
      ci.lo<-100*(1-((species.morts$ninit[i]-ci1)/species.morts$ninit[i])^(1/species.morts$timeint[i]))
      ci.hi<-100*(1-((species.morts$ninit[i]-ci2)/species.morts$ninit[i])^(1/species.morts$timeint[i]))
      prop=data.frame(Species=species.morts$Species[i],Census=species.morts$Census[i],ci.lo=ci.lo,ci.hi=ci.hi)}
    if (species.morts$mrtrate[i]==100)
      prop=data.frame(Species=species.morts$Species[i],Census=species.morts$Census[i],ci.lo=NA,ci.hi=NA)
    
    if (i==1)
      props=prop
    else
      props=rbind(props,prop)}
  
  if (any(speciesmort$ndead<=5))
  {#If ndead <= 5: Exact Binomial Test
  species_morts<-speciesmort[speciesmort$ndead<=5&speciesmort$ndead>0,]
  species_morts$mrtrate<-100*(1-((species_morts$ninit-species_morts$ndead)/species_morts$ninit))
  ntots<-nrow(species_morts)
  for (i in 1:ntots){
    if (species_morts$mrtrate[i]!=100)
      {binom<-binom.test(species_morts$ndead[i],species_morts$ninit[i],species_morts$mrtrate[i]/100)
      ci1<-binom$conf.int[1]*species_morts$ninit[i]
      ci2<-binom$conf.int[2]*species_morts$ninit[i]
      ci.lo<-100*(1-((species_morts$ninit[i]-ci1)/species_morts$ninit[i])^(1/species_morts$timeint[i]))
      ci.hi<-100*(1-((species_morts$ninit[i]-ci2)/species_morts$ninit[i])^(1/species_morts$timeint[i]))
      Binom=data.frame(Species=species_morts$Species[i],Census=species_morts$Census[i],ci.lo=ci.lo,ci.hi=ci.hi)
      }
    if (species_morts$mrtrate[i]==100)
      Binom=data.frame(Species=species_morts$Species[i],Census=species_morts$Census[i],ci.lo=NA,ci.hi=NA)
    
    if (i==1)
      binoms=Binom
    else
      binoms=rbind(binoms,Binom)}
  allcis<-rbind(props,binoms)
  } #end if statement
  if (!any(speciesmort$ndead<=5))
    allcis<-props
  
  speciesmort<-merge(speciesmort,allcis,all.x=T,all.y=T)
################################################  
  
  #Fix formatting!
#############################
  cens=list()
  agbcens=list()
  for (i in 1:nsets){
    #format for csv
    #m
    cen<-speciesmort[speciesmort$Census==yearlist[[i]],]
    cen$timeint<-NULL;cen$Census<-NULL#;cen$ndead<-NULL;cen$ninit<-NULL
    cen<-cen[c(1,2,5,6,3,4)]
    colnames(cen)<-c("Species",paste("mortrate",yearlist[[i]],sep=""),paste("ci.lo",yearlist[[i]],sep=""),paste("ci.hi",yearlist[[i]],sep=""),paste("ninit",yearlist[[i]],sep=""),paste("ndead",yearlist[[i]],sep=""))
    cens[[i]]=cen
    #M
    agbcen<-speciesagbmort[speciesagbmort$Census==yearlist[[i]],]
    agbcen$Census<-NULL
    agbcen<-agbcen[c(2,1)]
    #colnames(agbcen)<-c(paste("agb",yearlist[[i]],sep=""),"Species")
    colnames(agbcen)<-c("Species",paste("agb",yearlist[[i]],sep=""))
    agbcens[[i]]=agbcen
  }
  
  if (nsets<2)
  {speciesmorts<-cens[[1]]
  speciesagbmorts<-agbcens[[1]]}
  
  if (nsets>=2)
  {speciesmorts<-merge(cens[[1]],cens[[2]],all.x=T,all.y=T)
  speciesagbmorts<-merge(agbcens[[1]],agbcens[[2]],all.x=T,all.y=T)}
    
  if(nsets>=3){
  for (i in 3:nsets)
  {speciesmorts<-merge(speciesmorts,cens[[i]],all.x=T,all.y=T)
  speciesagbmorts<-merge(speciesagbmorts,agbcens[[i]],all.x=T,all.y=T)} 
    }
  

  #Write csv 
  mortality_rates<-merge(speciesmorts,speciesagbmorts,all.x=T,all.y=T)
  write.csv(mortality_rates,paste(site,".mortality_rates_2017.csv",sep=""))
  
  #Now need to rbind again
  speciesmorts[is.na(speciesmorts)]<-0
  speciesmorts<-speciesmorts[c(2:ncol(speciesmorts),1)]
  speciesagbmorts[is.na(speciesagbmorts)]<-0 #Fix later in code somehow
  output<-seq(from=1,by=5,length.out=100)
  for (i in 1:nsets){
    #Biomass mortality: Sp, then agb1:nsets
    #STUCK HERE! ITERATIONS
    v<-output[i]
    m<-data.frame(Species=speciesmorts$Species,mortrate=speciesmorts[[v]],ci.lo=speciesmorts[[v+1]],ci.hi=speciesmorts[[v+2]],Census=yearlist[[i]])
    agb<-data.frame(Species=speciesagbmorts$Species,agb=speciesagbmorts[[i+1]],Census=yearlist[[i]])
    if (i==1)
    {speciesagbmort=agb
    speciesmort=m}
    else
    {speciesagbmort=rbind(speciesagbmort,agb)
    speciesmort=rbind(speciesmort,m)}
    
  }
  #Fix order for m
  speciesmort <- with(speciesmort, speciesmort[order(Census, -as.numeric(mortrate)), ])
  speciesmort$Species <- factor(speciesmort$Species)# levels=speciesmort$Species) #error
  #Fix order for M
  speciesagbmort <- with(speciesagbmort, speciesagbmort[order(Census, -as.numeric(agb)), ])
  speciesagbmort$Species <- factor(speciesagbmort$Species)# levels=speciesagbmort$Species)
############################
 
  
   dodge <- position_dodge(width=.75)
  if (site=="scbi")
    cols<-c("darkblue","forestgreen","darkorange","purple","chocolate4")
  else
    cols<-c("red","darkorange","gold","green3","blue","purple","turquoise")
  
  sz=10;dims1=7.5; dims2=12
  
  if (site=="bci"&ncut<50)
  {sz=6; dims1=20; dims2=20}
  
  if (site=="bci"&ncut>50)
  {sz=8; dims1=20; dims2=20}
  
  if (site=="sherman"&ncut<50&mindbh==10)
  {sz=8; dims1=12; dims2=20}

  #Plot mortality rate by species
  c1<-ggplot(data=speciesmort,aes(x=Species,y=speciesmort$mortrate)) + geom_bar(stat="identity",position=dodge,aes(fill=Census))+ geom_errorbar(aes(ymin=ci.lo,ymax=ci.hi,fill=Census),width=0.75,size=.2,position=dodge) + labs(x = expression("Species"), y = expression(Mortality~Rate~("%"~y^{-1}))) + scale_fill_manual(values=cols,name=paste(site,"\n(",ncut," N > ",mindbh," mm dbh)",sep=""))+scale_y_continuous(expand = c(0,0)) + theme(axis.text.x = element_text(angle = 45,size=sz,hjust=1,vjust=1),text=element_text(size=12),axis.text.y=element_text(size=sz),legend.text=element_text(size=12),legend.title=element_text(size=12),legend.position=c(.25,.75),legend.key.size=unit(.4,"cm")) #+annotate("text",x=1,y=30,label="a)",size=8) 
  
  #if (units.C==T)
    units<-Mg~C~ha^{-1}~y^{-1}
  #else
   # units<-Mg~ha^{-1}~y^{-1}

#Plot biomass mortality rate by species
  c2<-ggplot(data=speciesagbmort,aes(x=Species,y=speciesagbmort$agb)) + geom_bar(stat="identity",position="dodge",aes(fill=Census)) + labs(x = expression("Species"), y = substitute(paste("Biomass Mortality (", h,")"), list(h=units)))+ scale_fill_manual(values=cols)+scale_y_continuous(expand = c(0,0))+ theme(axis.text.x = element_text(angle = 45, vjust = 1,hjust=1,size=sz),text=element_text(size=12),axis.text.y=element_text(size=sz),legend.text=element_text(size=12),legend.title=element_text(size=12),legend.position="none")#+annotate("text",x=10,y=0.4,label=paste(site,ncut,"N >",mindbh,"dbh",sep=" ")) #+annotate("text",x=2,y=2.5,label="b)",size=8) 
  
  
  
#PART 2: Histograms  
  
  
  #Calculate histograms for mortality
  highests<-max(speciesmort$mortrate,na.rm=T)
  for (i in 1:nsets)
  {v<-output[[i]]
  mrate<-speciesmorts[,v]
  minbin<-seq(from=0, to=highests+2,by=2);maxbin<-minbin+2
  nbins<-length(minbin)-1
  midcut<-minbin[1:nbins]+1
  
  bins=as.numeric(cut(mrate,breaks=minbin,right=F),labels=speciesmorts$Species)
  n=tapply(mrate,bins,length)
  mtch=match((1:nbins),rownames(n))
  n=n[mtch]
  names(n)=paste(minbin[1:nbins],"-",maxbin[1:nbins],sep="")
  n[is.na(n)]<-0
  all.n<-data.frame(binning=rownames(n),n=n,Census=yearlist[[i]],midcut=midcut)
  
  if (i==1)
    all.n.mort<-all.n
  else
    all.n.mort<-rbind(all.n.mort,all.n)
  m.minbin=minbin}
  
  #Calculate histograms for biomass mortality
  highest<-round(max(speciesagbmort$agb,na.rm=T),digits=1)
  for (i in 1:nsets)
  {
    arate<-speciesagbmorts[,i+1]
    minbin<-seq(from=0, to=highest+.1,by=.1);maxbin<-minbin+0.1
    nbins<-length(minbin)-1
    midcut<-minbin[1:nbins]+0.05
    
    
    bins=as.numeric(cut(arate,breaks=minbin,right=F),labels=speciesagbmorts$Species)
    n=tapply(arate,bins,length)
    mtch=match((1:nbins),rownames(n))
    n=n[mtch]
    names(n)=paste(minbin[1:nbins],"-",maxbin[1:nbins],sep="")
    n[is.na(n)]<-0
    all.n<-data.frame(binning=rownames(n),n=n,Census=yearlist[[i]],midcut=midcut)
    
    if (i==1)
      all.n.agb<-all.n
    else
      all.n.agb<-rbind(all.n.agb,all.n)
    agb.minbin=minbin}
  

  test<-c(seq(0,100,2))
  #test2<-c(0,"",4,"",8,"",12,"",16,"",20)
  
  if (highests>=70)
    test<-c(0,rep("",4),10,rep("",4),20,rep("",4),30,rep("",4),40,rep("",4),50,rep("",4),60,rep("",4),70,rep("",4),80,rep("",4),90,rep("",4),100)

  #Histograms:
  #Mortality
  c3<-ggplot(data=all.n.mort,aes(x=midcut,y=n,fill=Census))+geom_bar(stat="identity",position="dodge",width=1.5)+ labs(y = expression("n Species"), x = expression(Mortality ~ Rate ~("%"~y^{-1})))+ scale_fill_manual(name="\nCensus Period\n",values=cols)+ scale_color_manual(name="\nCensus Period\n",values=cols)+scale_y_continuous(expand = c(0,0),limits=c(0,max(all.n.mort$n)))+scale_x_continuous(breaks=c(seq(0,100,2)),labels=test)+theme(text=element_text(size=12),axis.text.x=element_text(size=sz),axis.text.y=element_text(size=sz),legend.text=element_text(size=12),legend.title=element_text(size=12),legend.position="none")+geom_vline(xintercept=c(allmortmean),linetype="dashed",col=cols[1:nsets])
  
  test2<-c(0,"",.2,"",.4,"",.6,"",.8,"",1,"",1.2,"",1.4,"",1.6,"",1.8,"",2,"",2.2,"",2.4,"",2.6,"",2.8,"",3)
  
  #Biomass mortality
  c4<-ggplot(data=all.n.agb,aes(x=midcut,y=n,fill=Census))+geom_bar(stat="identity",position="dodge",width=0.075)+ labs(y = expression("n Species"), x = substitute(paste("Biomass Mortality (", h,")"), list(h=units)))+ scale_fill_manual(name="\nCensus Period\n",values=cols)+ scale_color_manual(name="\nCensus Period\n",values=cols)+scale_y_continuous(expand = c(0,0),limits=c(0,max(all.n.agb$n)))+scale_x_continuous(breaks=c(seq(0,3,.1)),labels=test2)+theme(text=element_text(size=12),axis.text.x=element_text(size=sz),axis.text.y=element_text(size=sz),legend.text=element_text(size=12),legend.title=element_text(size=12),legend.position="none")#+geom_vline(xintercept=c(magb12,magb23,magb34),linetype="dashed",col=c("darkblue","forestgreen","darkorange"))
  
  if (which.plot=="AB")
  {tiff(file = "MortRates.ABonly_2017.tiff", width = dims1, height = dims1, units = "in", res=600, compression = "lzw",family ="A",pointsize=12)
    #plot_grid(c1,c2,labels=c("A","B"),label_size=12,nrow=2,ncol=1) }
    grid.arrange(c1, c2, ncol=1)}
  
  #All Plots in one figure:
  windowsFonts(A=windowsFont("Arial")) #Change font to Arial
  
  if (which.plot=="Hist")
  {tiff(file = "MortRates.Hist_2017.tiff", width =dims2, height = dims2, units = "in", res=600, compression = "lzw",family ="A",pointsize=12)
  
  plot_grid(c1,c2,c3,c4,labels=c("A","B","C","D"),label_size=12) }
  
  
  
  }
  
  
  
  
  
  ################################################
  indcalcmort=function(full1,full2,mindbh,rounddown=F,zerosdead=F)
    ################################################
  {
    if(rounddown) {
      sm=(full1$dbh<55&!is.na(full1$dbh) | full2$dbh<55&!is.na(full2$dbh) )
      full1$dbh[sm]=5*floor(full1$dbh[sm]/5)
      full2$dbh[sm]=5*floor(full2$dbh[sm]/5)
    }
    inc=full1$dbh>=mindbh&!is.na(full1$dbh)
    if (zerosdead)
      mort=ifelse(full2$dbh<mindbh|is.na(full2$dbh),1,0)
    else
      mort=ifelse(full2$dbh<0|is.na(full2$dbh),1,0)
    timeint=(full2$date-full1$date)/365.25
    agb=(full1$agb)/timeint 
    mind=data.frame(species=full1$sp[inc],gx=full1$gx[inc],gy=full1$gy[inc],dinit=full1$dbh[inc],mort=mort[inc],timeint=timeint[inc],agb=agb[inc],tag=full1$tag[inc],stemID=full1$stemID[inc],status=full1$status[inc],dbh2=full2$dbh[inc])
    return(mind)
  } # end indcalcmort12
  
  
  ################################################
  mszmn=function(x,species,timeint)
    # function for calculating mean mortality rate by size intervals
    ################################################
  {
    inc=!is.na(x) #Tori added is.na(x)
    x=x[inc]
    species=species[inc]
    timeint=timeint[inc]
    tab=table(species) #move to before !is(na)?
    nclass=length(tab)
    ninit=tapply(x,species,length)
    ndead=tapply(x,species,sum)
    mntime=tapply(timeint,species,mean,na.rm=T) #Tori added na.rm=T
    mortrate=100*(1-((ninit-ndead)/ninit)^(1/mntime))
    #mortrate=100*((log(ninit)-log(ninit-ndead))/mntime) #Helene's
    names(mortrate)=paste(rownames(ninit))
    mortrate<-data.frame(mortrate)
    mortrate$Species <- rownames(mortrate)
    mortrate$ninit<-ninit
    mortrate$ndead<-ndead
    mortrate$timeint<-mntime
    row.names(mortrate)<-seq(nrow(mortrate))
    return(mortrate)
  } # end mszmn
  ######################################################
  
  ################################################
  eszmn=function(x,species,hectar)
    ################################################
  {
    inc=!is.na(x)
    x=x[inc]
    species=species[inc]
    tab=table(species) #move to before !is(na)?
    nclass=length(tab)
    xmn=tapply(x,species,sum,na.rm=T)
    agb=xmn/hectar
    agb<-data.frame(agb)
    agb$Species<-rownames(agb)
    row.names(agb)<-seq(nrow(agb))
    return(agb)
  } # end eszmn
  ######################################################
  
  
  ################################################
  indcalcmort23=function(allmort)
    ################################################
  {
    inc=allmort$status.2013=="Live"
    mort=ifelse(allmort$status.2014=="Dead",1,0)
    timeint=(allmort$date.2014-allmort$date.2013)/365.25
    agb=(allmort$agb.2013)/timeint #flip to make positive for dead trees
    mind=data.frame(species=allmort$sp[inc],gx=allmort$gx[inc],gy=allmort$gy[inc],dinit=allmort$dbh.2013[inc],mort=mort[inc],timeint=timeint[inc],agb=agb[inc],tag=allmort$tag[inc],stemID=allmort$stemID[inc],status=allmort$status.2013[inc])
    return(mind)
  } # end indcalcmort23
  
  ################################################
  indcalcmort34=function(allmort)
    ################################################
  {
    
    inc=allmort$status.2014=="Live"
    mort=ifelse(allmort$status.2015=="Dead",1,0)
    timeint=(allmort$date.2015-allmort$date.2014)/365.25
    #agb=allmort$agb.ctfs.2013/timeint
    #Multi-Year AGB Problema Corregida:
    best.agb<-(pmax(allmort$agb.2013,allmort$agb.2015,na.rm=T))/timeint
    mind=data.frame(species=allmort$sp[inc],gx=allmort$gx[inc],gy=allmort$gy[inc],dinit=allmort$dbh.2013[inc],mort=mort[inc],timeint=timeint[inc],agb=best.agb[inc],tag=allmort$tag[inc],stemID=allmort$stemID[inc],status=allmort$status.2014[inc])
    return(mind)
  } # end indcalcmort34
  
  
################################################
mszmnORIG=function(x,dinit,timeint,ddiv)
  # function for calculating mean mortality rate by size intervals
  ################################################
{
  inc=dinit>=min(ddiv)&dinit<max(ddiv)
  dinit=dinit[inc]
  x=x[inc]
  timeint=timeint[inc]
  nclass=length(ddiv)-1
  dbhclass=as.numeric(cut(dinit,breaks=ddiv,right=F,labels=1:nclass))
  ninit=tapply(x,dbhclass,length)
  ndead=tapply(x,dbhclass,sum,na.rm=T)
  mntime=tapply(timeint,dbhclass,mean,na.rm=T) #Tori added na.rm=T
  mtch=match((1:nclass),rownames(ninit))
  ninit=ninit[mtch]
  ndead=ndead[mtch]
  mntime=mntime[mtch]
  #mortrate=(log(ninit)-log(ninit-ndead))/mntime
  mortrate=100*(1-((ninit-ndead)/ninit)^(1/mntime))
  names(mortrate)=paste(ddiv[1:nclass],"-",ddiv[2:(nclass+1)],sep="")
  return(mortrate)
} # end mszmn
######################################################
  

################################################
indcalcmort45=function(allmort)
  ################################################
{
  
  inc=allmort$status.2015=="Live"
  mort=ifelse(allmort$status.2016=="Dead",1,0)
  timeint=(allmort$date.2016-allmort$date.2015)/365.25
  #agb=allmort$agb.ctfs.2013/timeint
  #Multi-Year AGB Problema Corregida:
  best.agb<-(pmax(allmort$agb.2013,allmort$agb.2016,na.rm=T))/timeint
  mind=data.frame(species=allmort$sp[inc],gx=allmort$gx[inc],gy=allmort$gy[inc],dinit=allmort$dbh.2013[inc],mort=mort[inc],timeint=timeint[inc],agb=best.agb[inc],tag=allmort$tag[inc],stemID=allmort$stemID[inc],status=allmort$status.2016[inc])
  return(mind)
} # end indcalcmort45


################################################
indcalcmort56=function(allmort)
  ################################################
{
  
  inc=allmort$status.2016=="Live"
  mort=ifelse(allmort$status.2017=="Dead",1,0)
  timeint=(allmort$date.2017-allmort$date.2016)/365.25
  #agb=allmort$agb.ctfs.2013/timeint
  #Multi-Year AGB Problema Corregida:
  best.agb<-(pmax(allmort$agb.2013,allmort$agb.2017,na.rm=T))/timeint
  mind=data.frame(species=allmort$sp[inc],gx=allmort$gx[inc],gy=allmort$gy[inc],dinit=allmort$dbh.2013[inc],mort=mort[inc],timeint=timeint[inc],agb=best.agb[inc],tag=allmort$tag[inc],stemID=allmort$stemID[inc],status=allmort$status.2016[inc])
  return(mind)
} # end indcalcmort56

##########################################################






#plotting it
################################################



#which.plot="AB": 2 panels, no histogram
runplot(censuslist,hectar=25.6,mindbh=100,ncuts=100,rnd=F,zdead=T,taper=F,rm.secondary=F,stem.match=F,units.C=F,site="scbi",which.plot="AB")
dev.off()
#which.plot="Hist": 4-paneled histogram
runplot(censuslist,hectar=25.6,mindbh=100,ncuts=100,rnd=F,zdead=T,taper=F,rm.secondary=F,stem.match=F,units.C=F,site="scbi",which.plot="Hist")
dev.off()

#Function arguments
#mindbh: DBH cutoff in mm
#ncuts: Population size cutoff
#rnd = rounddown stems for precision. Not necessary for big stems.Only set to "T" for BCI  - written specifically for that site only right now.
#zdead: count those that fall below the mindbh as dead (should only be considered for 10 mm cutoff)
#taper: Only set to true if using Tori's Panama census files, which have different columns for dbh and taper corrected dbh. For Valentine's census data, set to False.
#rm.secondary: remove secondary forest for BCI or Sherman
#stem.match = Has it been run through the stem matching code and has column "stem.ID"? If not, will use "stemID" column.

