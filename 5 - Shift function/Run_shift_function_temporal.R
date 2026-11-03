# Run the shift function for the temporal cortex subregions (aSTG, AT lateral, AT medial, MIT, PT, ST middle)
# For each subregion, the group-level FC density distributions of HCP and MDD are compared
# decile-wise with the Harrell-Davis quantile estimator and percentile bootstrap confidence
# intervals (rogme::shifthd_pbci, 1000 bootstrap samples). Results are saved as out_*.RData
# in the current working directory (provided in 'output/temporal').
# Input: hc_Bilateral_*.csv and mdd_Bilateral_*.csv (output of shift_prep_temporal.m,
#        provided in 'shift_prep/temporal')
# See 'Shift function' in the Methods.

# USER SETTINGS: adjust the path below to your local system
input.folder <- '/path/to/5 - Shift function/shift_prep/temporal'   # folder containing the hc_/mdd_Bilateral_*.csv files

library(readr)
hc_Bilateral_aSTG <- read_csv(file.path(input.folder, "hc_Bilateral_aSTG.csv"), 
                                 col_names = FALSE)
hc_Bilateral_AT_lateral <- read_csv(file.path(input.folder, "hc_Bilateral_AT_lateral.csv"), 
                                  col_names = FALSE)
hc_Bilateral_AT_medial <- read_csv(file.path(input.folder, "hc_Bilateral_AT_medial.csv"), 
                                 col_names = FALSE)
hc_Bilateral_MIT <- read_csv(file.path(input.folder, "hc_Bilateral_MIT.csv"), 
                                 col_names = FALSE)
hc_Bilateral_PT <- read_csv(file.path(input.folder, "hc_Bilateral_PT.csv"), 
                                  col_names = FALSE)
hc_Bilateral_ST_middle <- read_csv(file.path(input.folder, "hc_Bilateral_ST_middle.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_aSTG <- read_csv(file.path(input.folder, "mdd_Bilateral_aSTG.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_AT_lateral <- read_csv(file.path(input.folder, "mdd_Bilateral_AT_lateral.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_AT_medial <- read_csv(file.path(input.folder, "mdd_Bilateral_AT_medial.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_MIT <- read_csv(file.path(input.folder, "mdd_Bilateral_MIT.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_PT <- read_csv(file.path(input.folder, "mdd_Bilateral_PT.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_ST_middle <- read_csv(file.path(input.folder, "mdd_Bilateral_ST_middle.csv"), 
                                   col_names = FALSE)


library(ggplot2)
library(cowplot)

install.packages("devtools")
devtools::install_github("GRousselet/rogme")

library(rogme)
library(tibble)
library(gridExtra)
library(ggpubr)
library(tidyr)


#aSTG
hc_aSTG <-as.numeric(hc_Bilateral_aSTG$X1) #extract only numeric values for shifthd function to work
mdd_aSTG <-as.numeric(mdd_Bilateral_aSTG$X1)

combined_aSTG <- mkt2(hc_aSTG, mdd_aSTG) #make dataframe
rm(hc_aSTG, mdd_aSTG, hc_Bilateral_aSTG, mdd_Bilateral_aSTG)

out_aSTG <- shifthd_pbci( data = combined_aSTG,obs ~ gr, nboot=1000) #run shift function

save(out_aSTG, file = "out_aSTG.RData")

##########################################


#AT_lateral
hc_AT_lateral <-as.numeric(hc_Bilateral_AT_lateral$X1) #extract only numeric values for shifthd function to work
mdd_AT_lateral <-as.numeric(mdd_Bilateral_AT_lateral$X1)

combined_AT_lateral <- mkt2(hc_AT_lateral, mdd_AT_lateral)#make dataframe
rm(hc_AT_lateral, mdd_AT_lateral, hc_Bilateral_AT_lateral, mdd_Bilateral_AT_lateral) #clear environment

out_AT_lateral <- shifthd_pbci( data = combined_AT_lateral,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_AT_lateral, file = "out_AT_lateral.RData")

###################################################


#AT_medial
hc_AT_medial <-as.numeric(hc_Bilateral_AT_medial$X1) #extract only numeric values for shifthd function to work
mdd_AT_medial <-as.numeric(mdd_Bilateral_AT_medial$X1)

combined_AT_medial <- mkt2(hc_AT_medial , mdd_AT_medial)#make dataframe
rm(hc_AT_medial, mdd_AT_medial, hc_Bilateral_AT_medial, mdd_Bilateral_AT_medial)

out_AT_medial  <- shifthd_pbci( data = combined_AT_medial,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_AT_medial, file = "out_AT_medial.RData")

############################################################


#MIT
hc_MIT <-as.numeric(hc_Bilateral_MIT$X1) #extract only numeric values for shifthd function to work
mdd_MIT <-as.numeric(mdd_Bilateral_MIT$X1)

combined_MIT <- mkt2(hc_MIT, mdd_MIT)#make dataframe
rm(hc_MIT, mdd_MIT, hc_Bilateral_MIT, mdd_Bilateral_MIT)

out_MIT <- shifthd_pbci( data = combined_MIT,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_MIT, file = "out_MIT.RData")

################################################################################################


#PT
hc_PT <-as.numeric(hc_Bilateral_PT$X1) #extract only numeric values for shifthd function to work
mdd_PT <-as.numeric(mdd_Bilateral_PT$X1)

combined_PT <- mkt2(hc_PT, mdd_PT)#make dataframe
rm(hc_PT, mdd_PT, hc_Bilateral_PT, mdd_Bilateral_PT)

out_PT<- shifthd_pbci( data = combined_PT,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_PT, file = "out_PT.RData")

##################################################################


#ST_middle
hc_ST_middle <-as.numeric(hc_Bilateral_ST_middle$X1) #extract only numeric values for shifthd function to work
mdd_ST_middle <-as.numeric(mdd_Bilateral_ST_middle$X1)

combined_ST_middle <- mkt2(hc_ST_middle, mdd_ST_middle)#make dataframe
rm(hc_ST_middle, mdd_ST_middle, hc_Bilateral_ST_middle, mdd_Bilateral_ST_middle)

out_ST_middle <- shifthd_pbci( data = combined_ST_middle,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_ST_middle, file = "out_ST_middle.RData")

#####################################



