#############################################################################
# Purpose: Produce summaries of mortality rate and biomass mortality by species, by genus, and for all species combined
# Notes, this is inspired Figure4_SpeciesMortality_2017.R, a script based on Tori Meakem (10/26/2016) and adapted by Ryan Helcoski (8/21/2017)
# Developped by: Valentine Herrmann - HerrmannV@si.edu - 2/11/2019
# R version 3.4.4 (2018-03-15)
##########################################################################

# Clean environment ####
rm(list = ls())

# Set working directory ####
setwd(".")

# Load libraries ####


# Load data ####
load("tree_mortality/data/allmort.rdata")

# set parameters ####
mindbh = 100 # 100 mm
hectar = 25.6

# Change agb to C biomass
agb.columns <- grep("agb", names(allmort), value = T)

for(agb.c  in agb.columns) {
  allmort[, agb.c] <-  allmort[, agb.c]  * 0.47
}


#Calculate mortality rates for each inter-census period
census.years <- sort(as.numeric(unique(sapply(strsplit(grep("[0-9]", names(allmort), value = T), "\\."), tail, 1)))) # get the years we have data for.

mortality.rates <- NULL
biomass.mortality.rates <- NULL

for(c.y in census.years[-1]) { # start looking at second census (so that there is census to look back)

  if(c.y == 2013) dbh.to.look.at = "dbh.2008"
  if(c.y %in% c(2014:2018)) dbh.to.look.at = "dbh.2013"
  if(c.y >= 2019) dbh.to.look.at = "dbh.2018"
  
  # get the elements we need ####
  year.previous.census <- census.years[which(census.years %in% c.y) -1]
     
  # get index of trees that were stared big enough (in 2008, 2013 or 2018) and were Live in the previous census
  idx.Live1 <- !is.na(allmort[, dbh.to.look.at]) & allmort[, dbh.to.look.at] >= mindbh & allmort[, paste0("status.", year.previous.census)] %in% "Live"
  

  
  # giev 1 to dead trees, 0 to others
  mort <- ifelse(allmort[, paste0("status.", c.y )] %in% "Dead", 1, 0)
  
  # get time inerval for each tree
  timeint <- as.numeric((allmort[, paste0("date.", c.y )] - allmort[, paste0("date.", year.previous.census)]) / 365.25)
  
  # find best agb (defined as maximum of the 2 years, or the non NA one) and divide by time interval to get rate
  if(c.y == 2013) best.agb.rate <- pmax(allmort$agb.2008, allmort$agb.2013, na.rm = T) / timeint
  if(c.y != 2013) best.agb.rate <- (pmax(allmort$agb.2013, allmort[, paste0("agb.", ifelse(c.y == 2014, "", "if.dead."), year.previous.census)], allmort[, paste0("agb.if.dead.", c.y)], na.rm = T)) / timeint
  
  # calculates mortality rates ####
  
  ## for all
  
  ninit <- length(mort[idx.Live1])
  ndead <- sum(mort[idx.Live1], na.rm = T)
  meantime <- mean(timeint[idx.Live1], na.rm = T)
  
  mortrate <- 100 * (1 - ((ninit - ndead) / ninit) ^ (1 / meantime))
  
  genus = "All" # just a trick to save later
  species = "All" # just a trick to save later
  sp = NA # just a trick to save later
  
  ## per genus
  
  ninit.genus <- tapply(mort[idx.Live1], allmort$Genus[idx.Live1], length)
  ndead.genus <- tapply(mort[idx.Live1], allmort$Genus[idx.Live1], sum, na.rm = T)
  meantime.genus <- tapply(timeint[idx.Live1],allmort$Genus[idx.Live1], mean, na.rm = T)
  
  mortrate.genus <- 100 * (1 - ((ninit.genus - ndead.genus) / ninit.genus) ^ (1 / meantime.genus))
  
  
  genus.genus = tapply(allmort$Genus[idx.Live1], allmort$Genus[idx.Live1], unique) # just a trick to save later
  species.genus = rep("All", length(genus.genus)) # just a trick to save later
  sp.genus = rep(NA, length(genus.genus)) # just a trick to save later
  
  
  ## per species
  
  ninit.sp <- tapply(mort[idx.Live1], allmort$sp[idx.Live1], length)
  ndead.sp <- tapply(mort[idx.Live1], allmort$sp[idx.Live1], sum, na.rm = T)
  meantime.sp <- tapply(timeint[idx.Live1],allmort$sp[idx.Live1], mean, na.rm = T)
  
  mortrate.sp <- 100 * (1 - ((ninit.sp - ndead.sp) / ninit.sp) ^ (1 / meantime.sp))
  
  genus.sp = tapply(allmort$Genus[idx.Live1], allmort$sp[idx.Live1], unique) # just a trick to save later
  species.sp = tapply(allmort$Species[idx.Live1], allmort$sp[idx.Live1], unique) # just a trick to save later
  sp.sp = tapply(allmort$sp[idx.Live1], allmort$sp[idx.Live1], unique) # just a trick to save later
  
  # save ###
  
  mortality.rates <- rbind(mortality.rates, 
                           data.frame(census = paste("census", year.previous.census, "and", c.y),
                                      genus = c(genus, genus.genus, genus.sp),
                                      species = c(species, species.genus, species.sp),
                                      sp = c(sp, sp.genus, sp.sp),
                                      ninit = c(ninit, ninit.genus, ninit.sp),
                                      ndead = c(ndead, ndead.genus, ndead.sp),
                                      mean.timint = c(meantime, meantime.genus, meantime.sp),
                                      mortality.rates.yr.1 = c(mortrate, mortrate.genus, mortrate.sp)))
  
  
  # Calculate biomass mortality rate ####
  
  ## for all
  
  biomassmortrate <- sum(best.agb.rate[idx.Live1 & mort %in%  1], na.rm = T) / hectar
  
  genus = "All" # just a trick to save later
  species = "All" # just a trick to save later
  sp = NA # just a trick to save later
  
  ## per genus
  
  biomassmortrate.genus <- tapply(best.agb.rate[idx.Live1 & mort %in%  1], allmort$Genus[idx.Live1 & mort %in%  1], sum, na.rm = T) / hectar
  
  genus.genus = tapply(allmort$Genus[idx.Live1 & mort %in%  1], allmort$Genus[idx.Live1 & mort %in%  1], unique) # just a trick to save later
  species.genus = rep("All", length(genus.genus)) # just a trick to save later
  sp.genus =rep(NA, length(genus.genus)) # just a trick to save later
  
  
  ## per species
  
  biomassmortrate.sp <- tapply(best.agb.rate[idx.Live1 & mort %in%  1], allmort$sp[idx.Live1 & mort %in%  1], sum, na.rm = T) / hectar
  
  genus.sp = tapply(allmort$Genus[idx.Live1 & mort %in%  1], allmort$sp[idx.Live1 & mort %in%  1], unique) # just a trick to save later
  species.sp = tapply(allmort$Species[idx.Live1 & mort %in%  1], allmort$sp[idx.Live1 & mort %in%  1], unique) # just a trick to save later
  sp.sp = tapply(allmort$sp[idx.Live1 & mort %in%  1], allmort$sp[idx.Live1 & mort %in%  1], unique) # just a trick to save later
  
 
  # save ####
  
  biomass.mortality.rates <- rbind(biomass.mortality.rates, 
                           data.frame(census = paste("census", year.previous.census, "and", c.y),
                                      genus = c(genus, genus.genus, genus.sp),
                                      species = c(species, species.genus, species.sp),
                                      sp = c(sp, sp.genus, sp.sp),
                                      biomass.mortality.Mg.C.ha.1.yr.1 = c(biomassmortrate, biomassmortrate.genus, biomassmortrate.sp)))
  

  

} # for(c.y in census.years[-1]) 


# Calculate CIS for mortality rates ####
## Using Exact Binomial test. NOte: orignally we did Normal Approximation when at least 5 successes and 5 failures, but no need to since we have the exact test

## Exact Binomial test function
exactci <-  function(x, n, conf.level){
  alpha <- (1 - conf.level)
  if (x == 0) {
    ll <- 0
    ul <- 1 - (alpha/2)^(1/n)
  }
  else if (x == n) {
    ll <- (alpha/2)^(1/n)
    ul <- 1
  }
  else {
    ll <- 1/(1 + (n - x + 1) / (x * qf(alpha/2, 2 * x, 2 * (n-x+1))))
    ul <- 1/(1 + (n - x) / ((x + 1) * qf(1-alpha/2, 2 * (x+1), 2 *
                                           (n-x))))
  }
  
  cint <- c(ll,ul)
  attr(cint, "conf.level") <- conf.level
  rval <- list(conf.int = cint)
  class(rval) <- "htest"
  return(rval)
}

## get the CIs

mortality.rates$ci.lo <- NA
mortality.rates$ci.hi <- NA

for(i in 1:nrow(mortality.rates)) {
  ci <- exactci(mortality.rates$ndead[i], mortality.rates$ninit[i], 0.95)
  
  ci1 <- ci$conf.int[1] * mortality.rates$ninit[i]
  ci2 <- ci$conf.int[2] * mortality.rates$ninit[i]
  
  mortality.rates$ci.lo[i] <- 100*(1 - ((mortality.rates$ninit[i] - ci1) / mortality.rates$ninit[i]) ^ (1 / mortality.rates$mean.timint[i]))
  mortality.rates$ci.hi[i] <- 100*(1 - ((mortality.rates$ninit[i] - ci2) / mortality.rates$ninit[i]) ^ (1 / mortality.rates$mean.timint[i]))
  
}

# Plot results ####

# Barplots of mortality rates and Biomass mortality ####
tiff("tree_mortality/R_results/Barplots_MortalityRates_and_BiomassMortality2020.tiff", width = 2500, height = 2500, units = "px", res = 300)

par(mfrow = c(1,2), mar = c(3, 5.1, 0, 0), oma = c(2,0,3,0), xpd=F)

## plot Mortality rates ####

x <- droplevels(mortality.rates[!is.na(mortality.rates$sp) & !mortality.rates$sp %in% "unk" & mortality.rates$ninit > 100 , ])

# species_that_always_have_at_leat_100_to_start_with <- tapply( mortality.rates$ninit,  mortality.rates$sp, function(x) all(x > 100))
# species_that_always_have_at_leat_100_to_start_with <- names(species_that_always_have_at_leat_100_to_start_with[species_that_always_have_at_leat_100_to_start_with])
# x <- droplevels(mortality.rates[!is.na(mortality.rates$sp) & mortality.rates$sp %in% species_that_always_have_at_leat_100_to_start_with, ])

b <- barplot(x$mortality.rates.yr.1 ~ x$census +x$sp , beside = T, legend.text = T, space  = c(0.01, 2), 
        col = hcl.colors(nlevels(x$census)), 
        border = hcl.colors(nlevels(x$census)),
        args.legend = list(x = 2,
                           y = 22,
                           xjust = 0,
                           bty = "n",
                           title = expression(bold("SCBI\nn>100 & dbh>10cm")),
                           xpd = NA,
                           ncol = 1,
                           cex = 0.9
                           ),
        las = 2,
        xlab = "",# "Species",
        ylab = expression("Mortality Rates (%y"^"-1"*")"),
        ylim = c(0, max(x$ci.hi))
)


arrows(b, tapply(x$ci.lo,  list(x$census ,x$sp ), function(x) x), b,
       tapply(x$ci.hi,  list(x$census ,x$sp ), function(x) x), lwd = 1, angle = 90,
       code = 3, length = 0.01)

## plot Biomass mortality ####


x <- droplevels(biomass.mortality.rates[biomass.mortality.rates$sp %in% x$sp, ])

b <- barplot(x$biomass.mortality.Mg.C.ha.1.yr.1 ~ x$census +x$sp
, beside = T, legend.text = F, space  = c(0.01, 2), 
             col = hcl.colors(nlevels(x$census)), 
             border = hcl.colors(nlevels(x$census)),
             args.legend = list(x = 2,
                                y = 1,
                                xjust = 0,
                                bty = "n",
                                title = "SCBI\nN>100 & DBH>10cm"),
             las = 2,
             # xlab = "Species",
             ylab = expression("Biomass Mortality (Mg C ha"^"-1"*"y"^"-1"*")")
)

mtext("Species", 1, line = 0, outer = T)
#####GGPLOT equivalent
library(gridExtra)
library(ggplot2)


x <- subset(x, sp != "ulru")
x1 <- droplevels(mortality.rates[!is.na(mortality.rates$sp) & !mortality.rates$sp %in% "unk" & mortality.rates$ninit > 100 , ])
x1 <- subset(x1, sp != "ulru")

x2 <- droplevels(biomass.mortality.rates[biomass.mortality.rates$sp %in% x$sp, ])
x2 <- subset(x2, sp != "ulru")

tiff("tree_mortality/R_results/Barplots_MortalityRates_and_BiomassMortality2020.tiff", width = 2500, height = 2500, units = "px", res = 300)
grid.arrange(
  ggplot(x1, aes(x = sp, y = mortality.rates.yr.1, fill = census))+geom_bar(stat = "identity",width = 0.8, position = position_dodge(0.8, preserve = "single"))+
    geom_errorbar(aes(ymin = ci.lo, ymax = ci.hi), width = 0.2, position = position_dodge(0.8))+
    labs(fill = "n>100 & dbh>10cm", x = "", y = expression("Mortality Rates (%y"^"-1"*")"))+
    theme( legend.position = c(0.2, 0.7), legend.text = element_text(size = 10))+
    theme(axis.line.y = element_line(color="black", size = 1),axis.ticks.x=element_blank ())+
    theme(
      panel.background = element_rect(fill = "transparent"), # bg of the panel
      plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
      panel.grid.major = element_blank(), # get rid of major grid
      panel.grid.minor = element_blank(), # get rid of minor grid
      legend.background = element_rect(fill = "transparent"), # get rid of legend bg
      legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
    ),
ggplot(x2, aes(x = sp, y = biomass.mortality.Mg.C.ha.1.yr.1, fill = census))+geom_bar(stat = "identity",width = 0.8, position = position_dodge(0.8, preserve = "single"))+labs(fill = "n>100 & dbh>10cm", x = "Species", y = expression("Biomass Mortality (Mg C ha"^"-1"*"y"^"-1"*")"))+
  theme( legend.position = "none", legend.text = element_text(size = 10))+
  theme(axis.line.y = element_line(color="black", size = 1),axis.ticks.x=element_blank ())+
  theme(
    panel.background = element_rect(fill = "transparent"), # bg of the panel
    plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
    panel.grid.major = element_blank(), # get rid of major grid
    panel.grid.minor = element_blank(), # get rid of minor grid
    legend.background = element_rect(fill = "transparent"), # get rid of legend bg
    legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
  )

, as.table = FALSE, nrow = 2 , ncol=1)
# dev.off() ####
dev.off()

# SAVE ####
write.csv(mortality.rates, paste0("tree_mortality/R_results/SCBI_mortality_rates_up_to_", max(census.years), ".csv"), row.names = F)
write.csv(biomass.mortality.rates, paste0("tree_mortality/R_results/SCBI_biomass_mortality_rates_up_to_", max(census.years), ".csv"), row.names = F)
