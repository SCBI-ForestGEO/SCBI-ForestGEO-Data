######################################################
# Purpose: Estimate AGB for stems at SCBI. 
# Developped by: Valentine Herrmann - HerrmannV@si.edu
# Date: original writen in 2017?? multiple modifications added thereafter
#######################################################


## Organize your data in this case, 
##  x is a table with:
# a column called 'dbh' which has dbh of every stems in mm
# a column called 'SPPCODE' which has species 4-letter species code (this sp code is unique per site)

x$agb_ctfs  <-  x$agb

x$order <- 1:nrow(x)

list.object.before <- ls()

#Calculating biomass in shrubs is a little complicated, so we came up with 2 approaches:

# list of shrubs species ####
# Approach 1
shrub.DBH.sp <- c("beth", "chvi", "coam", "crpr", "elum", "eual", "ilve", "libe", "saca") # using DBH in AGB allometric equation
# Approach 2
shrub.BD.sp <- c("havi", "loma", "romu","rual", "rupe", "ruph", "viac", "vipr", "vire") # using basal diameter in AGB allometric equation


# Case 1: Calculate Biomass for shrubs using a DBH allometry equation ####

## subset shrub species for which the biomass allometry requires DBH

x.shrub.DBH <- x[x$sp %in% shrub.DBH.sp,]

## first calculate basal area contribution of each stem within a tree
BA <- (pi/4) * x.shrub.DBH$dbh^2 # basal area (at 1.3 m) in mm
tree.sum.BA <- tapply(BA, x.shrub.DBH$tag, sum, na.rm = T) #sum of basal areas per tree
tree.sum.BA <- tree.sum.BA[match(x.shrub.DBH$tag, names(tree.sum.BA))] # same but same length as BA
BA.contribution <- BA / tree.sum.BA #contribution of each stem to sum of basal area of tree

## identify main stem
tree.main.stem.DBH <- do.call(rbind, lapply(split(x.shrub.DBH, x.shrub.DBH$tag), function(x) return(data.frame(sp = unique(x$sp), dbh = ifelse(any(!is.na(x$dbh)), max(x$dbh, na.rm = T), NA))))) #DBH of main stem of tree

## calculate AGB on main stem

tree.main.stem.DBH$agb <- NA

#multiple dbh in mm by 0.1 to obtain dbh in cm
#some species will multiply by 0.36, the bias correction factor reported in the original publication 

tree.main.stem.DBH$agb <- ifelse(tree.main.stem.DBH$sp == "beth", exp(-2.48 + 2.4835 * log(tree.main.stem.DBH$dbh * 0.1)) * 0.36, tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "chvi", exp(-2.48 + 2.4835 * log(tree.main.stem.DBH$dbh * 0.1)) * 0.36, tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "coam", exp(-2.48 + 2.4835 * log(tree.main.stem.DBH$dbh * 0.1)) * 0.36, tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "crpr", exp(-2.2118 + 2.4133 * log(tree.main.stem.DBH$dbh * 0.1)), tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "elum", exp(-2.48 + 2.4835 * log(tree.main.stem.DBH$dbh * 0.1)) * 0.36, tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "eual", exp(-2.48 + 2.4835 * log(tree.main.stem.DBH$dbh * 0.1)) * 0.36, tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "ilve", exp(-2.2118 + 2.4133 * log(tree.main.stem.DBH$dbh * 0.1)), tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "libe", exp(-2.2118 + 2.4133 * log(tree.main.stem.DBH$dbh * 0.1)), tree.main.stem.DBH$agb )

tree.main.stem.DBH$agb  <- ifelse(tree.main.stem.DBH$sp == "saca", exp(-2.48 + 2.4835 * log(tree.main.stem.DBH$dbh * 0.1)) * 0.36, tree.main.stem.DBH$agb )

## Redistribute the biomass of main stem to other stems, using the basal contribution
tree.main.stem.AGB <- tree.main.stem.DBH$agb[match(x.shrub.DBH$tag, rownames(tree.main.stem.DBH))] #get a vector as long as x.shrub.DBH with AGB of main stem repeated for each stem of tree

x.shrub.DBH$agb = tree.main.stem.AGB * BA.contribution


# Case 2: Calculate Biomass for shrubs using the Basal Diameter allometry equation ####

## subset shrub species for which the biomass allometry requires basal diameter

x.shrub.BD <- x[x$sp %in% shrub.BD.sp,]

## calculate basal area contribution of each stem within a tree
BA <- (pi/4) * x.shrub.BD$dbh^2 # basal area (at 1.3 m) in mm
tree.sum.BA.un <- tapply(BA, x.shrub.BD$tag, sum, na.rm = T) #sum of basal areas per tree
tree.sum.BA.rep <- tree.sum.BA.un[match(x.shrub.BD$tag, names(tree.sum.BA.un))] # same but same length as BA
BA.contribution <- BA / tree.sum.BA.rep #contribution of each stem to sum of basal area of tree

## calculate diameter at base of shrub, assuming area preserving
tree.BD <- data.frame(tag = names(tree.sum.BA.un), BD = sqrt(tree.sum.BA.un/pi) * 2)
tree.BD <- merge(tree.BD, x.shrub.BD[, c("tag", "sp")], by = "tag")

#multiple dbh in mm by 0.1 to obtain dbh in cm
#divide by 1000 to obtain biomass in kg (as original pub gives biomass in gr) 

## calculate AGB using basal diamter

tree.BD$agb <- NA

tree.BD$agb <- ifelse(tree.BD$sp == "havi", (38.111 * (tree.BD$BD * 0.1)^2.9) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "loma", (51.996 * (tree.BD$BD * 0.1)^2.77) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "romu", (37.637 * (tree.BD$BD * 0.1)^2.779) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "rual", (43.992 * (tree.BD$BD * 0.1)^2.86) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "rupe", (43.992 * (tree.BD$BD * 0.1)^2.86) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "ruph", (43.992 * (tree.BD$BD * 0.1)^2.86) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "viac", (29.615 * (tree.BD$BD * 0.1)^3.243) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "vipr", (29.615 * (tree.BD$BD * 0.1)^3.243) / 1000, tree.BD$agb) #basal diameter

tree.BD$agb <- ifelse(tree.BD$sp == "vire", (29.615 * (tree.BD$BD * 0.1)^3.243) / 1000, tree.BD$agb) #basal diameter


## Redistribute the biomass of main stem to other stem, using the basal contribution
tree.BD <- tree.BD[match(names(BA.contribution), tree.BD$tag),] # PUT BACK IN RIGHT ORDER

x.shrub.BD$agb = tree.BD$agb * BA.contribution



# Now calculate AGB for tree species, take into consideration the following:
# multiple dbh in mm by 0.1 to obtain dbh in cm
#some species will need to multiply by the bias correction factor reported in the original publication (ie. 0.36; 1.008)
#multiply by 0.03937 if original pub gived dbh in inch
#multiply by 0.45359 if original pub give AGB in lbs

x.trees <- x[!x$sp %in% c(shrub.DBH.sp, shrub.BD.sp),]

x.trees$agb <- NA

x.trees$agb <- ifelse(x.trees$sp == "acne", exp(-2.047 + 2.3852 * log(x.trees$dbh * 0.1)), NA)

x.trees$agb <- ifelse(x.trees$sp == "acpl", exp(-2.047 + 2.3852 * log(x.trees$dbh * 0.1)), x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "acru", exp(4.5835 + 2.43 * log(x.trees$dbh * 0.1)) / 1000, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "acsp", exp(4.5835 + 2.43 * log(x.trees$dbh * 0.1)) / 1000, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "aial", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)) * 0.36, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "amar", exp(7.217 + 1.514 * log(x.trees$dbh * 0.1)) / 1000
                      + 10^(2.5368 + 1.3197 * log10(x.trees$dbh * 0.03937)) / 1000
                      + 10^(2.0865 + 0.9449 * log10(x.trees$dbh * 0.03937)) /1000,
                      x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "astr", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)) * 0.36, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "caca", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)) * 0.36, x.trees$agb)

#x.trees$agb <- ifelse(x.trees$sp == "caco", (1.93378 * (x.trees$dbh * 0.03937)^2.6209) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "caco", 10^(-1.326 + 2.762 * log10(x.trees$dbh * 0.1)) *1.005, x.trees$agb)# new equation added by Erika 1/13/2020                                          
                                      
x.trees$agb <- ifelse(x.trees$sp == "cade", exp(-2.0705 + 2.441 * log(x.trees$dbh * 0.1)), x.trees$agb)

#x.trees$agb <- ifelse(x.trees$sp == "cagl", (1.93378 * (x.trees$dbh * 0.03937)^2.6209) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "cagl", 10^(-1.326 + 2.762 * log10(x.trees$dbh * 0.1)) *1.005, x.trees$agb)# new equation added by Erika 1/13/2020  

#x.trees$agb <- ifelse(x.trees$sp == "caovl", (1.93378 * (x.trees$dbh * 0.03937)^2.6209) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "caovl", 10^(-1.326 + 2.762 * log10(x.trees$dbh * 0.1)) *1.005, x.trees$agb)# new equation added by Erika 1/13/2020                                              

#x.trees$agb <- ifelse(x.trees$sp == "cato", (1.93378 * (x.trees$dbh * 0.03937)^2.6209) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "cato", 10^(-1.326 + 2.762 * log10(x.trees$dbh * 0.1)) *1.005, x.trees$agb)# new equation added by Erika 1/13/2020                                              

#x.trees$agb <- ifelse(x.trees$sp == "casp", (1.93378 * (x.trees$dbh * 0.03937)^2.6209) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "casp", 10^(-1.326 + 2.762 * log10(x.trees$dbh * 0.1)) *1.005, x.trees$agb)# new equation added by Erika 1/13/2020                                              

x.trees$agb <- ifelse(x.trees$sp == "ceca", exp(-2.5095 + 2.5437 * log(x.trees$dbh * 0.1)), x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "ceoc", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)) * 0.36, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "coal",  (3.08355 * ((x.trees$dbh * 0.03937)^2)^1.1492) * 0.45359,  x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "cofl",  (3.08355 * ((x.trees$dbh * 0.03937)^2)^1.1492) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "crpr", exp(-2.2118 + 2.4133 * log(x.trees$dbh * 0.1)), x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "crsp", exp(-2.2118 + 2.4133 * log(x.trees$dbh * 0.1)), x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "divi", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)) * 0.36, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "elum", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)), x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "eual", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)), x.trees$agb)
                                            
#x.trees$agb <- ifelse(x.trees$sp == "fagr", (2.0394 * (x.trees$dbh * 0.03937)^2.5715) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "fagr", 10^(2.1112 + 2.462 * log10(x.trees$dbh * 0.1)) / 1000, x.trees$agb)# new equation added by Erika 1/13/2020

x.trees$agb <- ifelse(x.trees$sp == "fram", (2.3626 * (x.trees$dbh * 0.03937)^2.4798) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "frni", 0.1634 * (x.trees$dbh * 0.1)^2.348, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "frpe", 0.1634 * (x.trees$dbh * 0.1)^2.348, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "frsp",  0.1634 * (x.trees$dbh * 0.1)^2.348, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "juci", exp(-2.5095 + 2.5437 * log(x.trees$dbh * 0.1)), x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "juni", exp(-2.5095 + 2.5437 * log(x.trees$dbh * 0.1)), x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "juvi", 0.1632 * (x.trees$dbh * 0.1)^2.2454, x.trees$agb)

# x.trees$agb <- ifelse(x.trees$sp == "litu", (1.0259 * (x.trees$dbh * 0.03937)^2.7324) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "litu", (10^(-1.236 + 2.635 * (log10(x.trees$dbh * 0.1)))) * 1.008, x.trees$agb) # new equation given by Erika on Tue 4/2/2019 11:57

# x.trees$agb <- ifelse(x.trees$sp == "nysy", (1.5416 * ((x.trees$dbh * 0.03937)^2)^1.2759) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "nysy", exp(-2.2118 + 2.4133 * log(x.trees$dbh * 0.1)) , x.trees$agb)# new equation given by Erika on Tue 4/2/2019 11:57

x.trees$agb <- ifelse(x.trees$sp == "pato", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)) * 0.36, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "pipu", (exp(5.2831 + 2.0369 * log(x.trees$dbh * 0.1))) / 1000, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "pist", (exp(5.2831 + 2.0369 * log(x.trees$dbh * 0.1))) / 1000, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "pivi", 10^(1.83 + 2.464 * log10(x.trees$dbh * 0.1)) / 1000, x.trees$agb)

# x.trees$agb <- ifelse(x.trees$sp == "ploc", (2.4919 * ((x.trees$dbh * 0.03937)^2)^1.1888) *  0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "ploc" & (x.trees$dbh * 0.1) < 24, (1.57573 * ((x.trees$dbh * 0.03937)^2) ^ 1.29005) * 0.45359, x.trees$agb) # new equation given by Erika on Tue 4/2/2019 11:57
x.trees$agb <- ifelse(x.trees$sp == "ploc" & (x.trees$dbh * 0.1) >= 24, (2.51502 * ((x.trees$dbh * 0.03937)^2) ^ 1.19256) * 0.45359, x.trees$agb) # new equation given by Erika on Tue 4/2/2019 11:57


#x.trees$agb <- ifelse(x.trees$sp == "prav", (1.8082 * (x.trees$dbh * 0.03937)^2.6174) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "prav", 10^(1.1981 + 1.5876 * (log10((x.trees$dbh*0.1)^2))) /1000 *1.017, x.trees$agb)# new equation added by Erika 1/13/2020
                                            
#x.trees$agb <- ifelse(x.trees$sp == "prse", (1.8082 * (x.trees$dbh * 0.03937)^2.6174) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "prse", 10^(1.1981 + 1.5876 * (log10((x.trees$dbh*0.1)^2))) /1000 *1.017, x.trees$agb)# new equation added by Erika 1/13/2020                                            

#x.trees$agb <- ifelse(x.trees$sp == "prsp", (1.8082 * (x.trees$dbh * 0.03937)^2.6174) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "prsp", 10^(1.1981 + 1.5876 * (log10((x.trees$dbh*0.1)^2))) /1000 *1.017, x.trees$agb)# new equation added by Erika 1/13/2020                                          

x.trees$agb <- ifelse(x.trees$sp == "qual", (1.5647 * (x.trees$dbh * 0.03937)^2.6887) * 0.45359, x.trees$agb)

#x.trees$agb <- ifelse(x.trees$sp == "quco", (2.6574 * (x.trees$dbh * 0.03937)^2.4395) * 0.45359, x.trees$agb)                                            
x.trees$agb <- ifelse(x.trees$sp == "quco", 10^((1.283 + 2.685 * log10(x.trees$dbh * 0.1)) / 1000) *1.003, x.trees$agb)# new equation added by Erika 1/13/2020

x.trees$agb <- ifelse(x.trees$sp == "qufa" & x.trees$dbh <= 26 * 25.4, (2.3025 * ((x.trees$dbh * 0.03937)^2)^1.2580) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "qufa" & x.trees$dbh > 26 * 25.4,  (2.2373 * ((x.trees$dbh * 0.03937)^2)^1.2639) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "qumi", (1.5509 * (x.trees$dbh * 0.03937)^2.7276) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "qumu", (1.5509 * (x.trees$dbh * 0.03937)^2.7276) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "qupr", (1.5509 * (x.trees$dbh * 0.03937)^2.7276) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "quru", (2.4601 * (x.trees$dbh * 0.03937)^2.4572) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "qusp", (1.5509 * (x.trees$dbh * 0.03937)^2.7276) * 0.45359, x.trees$agb)

# x.trees$agb <- ifelse(x.trees$sp == "quve", (2.1457 * (x.trees$dbh * 0.03937)^2.5030) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "quve" & (x.trees$dbh * 0.1) < 30, exp(-0.34052 + 2.65803 * log(x.trees$dbh * 0.03937)), x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "quve" & (x.trees$dbh * 0.1) >= 30, (10^(1.00005 + 2.10621 * (log10(x.trees$dbh * 0.03937)))) * 0.45359, x.trees$agb)

# x.trees$agb <- ifelse(x.trees$sp == "rops", (1.04649 * ((x.trees$dbh * 0.03937)^2)^1.37539) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "rops", exp(-2.5095 + 2.5437 * log(x.trees$dbh * 0.1)), x.trees$agb)

# x.trees$agb <- ifelse(x.trees$sp == "saal", (10^(1.3539  + 1.3412 * log10(x.trees$dbh * 0.1)^2)) / 1000 * 1.004, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "saal", exp(-2.2118 + 2.4133 * log(x.trees$dbh * 0.1)) , x.trees$agb) # new equation given by Erika on Tue 4/2/2019 11:57 (Chojnacky)


# x.trees$agb <- ifelse(x.trees$sp == "tiam", (1.4416 * (x.trees$dbh * 0.03937)^2.7324) * 0.45359, x.trees$agb)
x.trees$agb <- ifelse(x.trees$sp == "tiam" & (x.trees$dbh * 0.1) <= 10, exp(4.29 + 2.29 * log(x.trees$dbh * 0.1)) * 0.001, x.trees$agb)# new equation given by Erika on Wed 4/3/2019 15:13
x.trees$agb <- ifelse(x.trees$sp == "tiam" & (x.trees$dbh * 0.1) > 10 & (x.trees$dbh * 0.1) <= 27, 1.74995 * ((x.trees$dbh * 0.03937)^2)^1.19103 * 0.45359, x.trees$agb)# new equation given by Erika on Wed 4/3/2019 15:13
x.trees$agb <- ifelse(x.trees$sp == "tiam" & (x.trees$dbh * 0.1) > 27, 1.49368 * ((x.trees$dbh * 0.03937)^2)^1.22405 * 0.45359, x.trees$agb)# new equation given by Erika on Wed 4/3/2019 15:13

x.trees$agb <- ifelse(x.trees$sp == "ulam", (2.17565 * ((x.trees$dbh * 0.03937)^2)^1.2481) * 0.45359, x.trees$agb)

# x.trees$agb <- ifelse(x.trees$sp == "ulru", (2.04282 * ((x.trees$dbh * 0.03937)^2)^1.2546) * 0.45359, x.trees$agb)
# x.trees$agb <- ifelse(x.trees$sp == "ulru", (0.08248 * (x.trees$dbh * 0.03937)^2.468) * 0.45359, x.trees$agb)# new equation given by Erika on Wed 4/3/2019 15:13
x.trees$agb <- ifelse(x.trees$sp == "ulru", exp(-2.2118 + 2.4133*log(x.trees$dbh * 0.1)), x.trees$agb)# Chojnacky eq in allodb for ulmaceae, equation_id f08fff

x.trees$agb <- ifelse(x.trees$sp == "ulsp", (2.04282 * ((x.trees$dbh * 0.03937)^2)^1.2546) * 0.45359, x.trees$agb)

x.trees$agb <- ifelse(x.trees$sp == "unk", exp(-2.48 + 2.4835 * log(x.trees$dbh * 0.1)) * 0.36, x.trees$agb) # mixed hardwood



# put back the subsets together ####
x.all <- rbind(x.trees, x.shrub.DBH, x.shrub.BD)
x.all <- x.all[order(x.all$order),]
x.all$order <- NULL

if(!identical(x.all$dbh, x$dbh)) stop("order is not the same as the begining")
x <- x.all

#Convert from kg to Mg
x$agb <- x$agb / 1000 

#remove object we don't need anymore
rm(list = ls()[!ls() %in% list.object.before])

