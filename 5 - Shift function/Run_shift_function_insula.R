# Run the shift function for the insula subregions (AI short, AI long, AI pole, MI short, PI short, PI long)
# For each subregion, the group-level FC density distributions of HCP and MDD are compared
# decile-wise with the Harrell-Davis quantile estimator and percentile bootstrap confidence
# intervals (rogme::shifthd_pbci, 1000 bootstrap samples). Results are saved as out_*.RData
# in the current working directory (provided in 'output/insula').
# Input: hc_Bilateral_*.csv and mdd_Bilateral_*.csv (output of shift_prep_insula.m,
#        provided in 'shift_prep')
# See 'Shift function' in the Methods.

# USER SETTINGS: adjust the path below to your local system
input.folder <- '/path/to/5 - Shift function/shift_prep'   # folder containing the hc_/mdd_Bilateral_*.csv files

library(readr)
hc_Bilateral_AI_long <- read_csv(file.path(input.folder, "hc_Bilateral_AI_long.csv"), 
                                 col_names = FALSE)
hc_Bilateral_AI_short <- read_csv(file.path(input.folder, "hc_Bilateral_AI_short.csv"), 
                                  col_names = FALSE)
hc_Bilateral_AI_pole <- read_csv(file.path(input.folder, "hc_Bilateral_AI_pole.csv"), 
                                 col_names = FALSE)
hc_Bilateral_PI_long <- read_csv(file.path(input.folder, "hc_Bilateral_PI_long.csv"), 
                                 col_names = FALSE)
hc_Bilateral_PI_short <- read_csv(file.path(input.folder, "hc_Bilateral_PI_short.csv"), 
                                  col_names = FALSE)
hc_Bilateral_MI_short <- read_csv(file.path(input.folder, "hc_Bilateral_MI_short.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_AI_long <- read_csv(file.path(input.folder, "mdd_Bilateral_AI_long.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_AI_short <- read_csv(file.path(input.folder, "mdd_Bilateral_AI_short.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_AI_pole <- read_csv(file.path(input.folder, "mdd_Bilateral_AI_pole.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_PI_long <- read_csv(file.path(input.folder, "mdd_Bilateral_PI_long.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_PI_short <- read_csv(file.path(input.folder, "mdd_Bilateral_PI_short.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_MI_short <- read_csv(file.path(input.folder, "mdd_Bilateral_MI_short.csv"), 
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


#AI_long

hc_AI_long <-as.numeric(hc_Bilateral_AI_long$X1) #extract only numeric values for shifthd function to work
mdd_AI_long <-as.numeric(mdd_Bilateral_AI_long$X1)

combined_AI_long <- mkt2(hc_AI_long, mdd_AI_long) #make dataframe
rm(hc_AI_long, mdd_AI_long, hc_Bilateral_AI_long, mdd_Bilateral_AI_long)

out_AI_long <- shifthd_pbci( data = combined_AI_long,obs ~ gr, nboot=1000) #run shift function

save(out_AI_long, file = "out_AI_long.RData")

##########################################


#AI_short
hc_AI_short <-as.numeric(hc_Bilateral_AI_short$X1) #extract only numeric values for shifthd function to work
mdd_AI_short <-as.numeric(mdd_Bilateral_AI_short$X1)

combined_AI_short <- mkt2(hc_AI_short, mdd_AI_short)#make dataframe
rm(hc_AI_short, mdd_AI_short, hc_Bilateral_AI_short, mdd_Bilateral_AI_short) #clear environment

out_AI_short <- shifthd_pbci( data = combined_AI_short,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_AI_short, file = "out_AI_short.RData")

###################################################


#AI_pole
hc_AI_pole <-as.numeric(hc_Bilateral_AI_pole$X1) #extract only numeric values for shifthd function to work
mdd_AI_pole <-as.numeric(mdd_Bilateral_AI_pole$X1)

combined_AI_pole <- mkt2(hc_AI_pole , mdd_AI_pole)#make dataframe
rm(hc_AI_pole, mdd_AI_pole, hc_Bilateral_AI_pole, mdd_Bilateral_AI_pole)

out_AI_pole  <- shifthd_pbci( data = combined_AI_pole,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_AI_pole, file = "out_AI_pole.RData")

############################################################


#PI_short
hc_PI_short <-as.numeric(hc_Bilateral_PI_short$X1) #extract only numeric values for shifthd function to work
mdd_PI_short <-as.numeric(mdd_Bilateral_PI_short$X1)

combined_PI_short <- mkt2(hc_PI_short, mdd_PI_short)#make dataframe
rm(hc_PI_short, mdd_PI_short, hc_Bilateral_PI_short, mdd_Bilateral_PI_short)

out_PI_short <- shifthd_pbci( data = combined_PI_short,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_PI_short, file = "out_PI_short.RData")

################################################################################################


#PI_long
hc_PI_long <-as.numeric(hc_Bilateral_PI_long$X1) #extract only numeric values for shifthd function to work
mdd_PI_long <-as.numeric(mdd_Bilateral_PI_long$X1)

combined_PI_long <- mkt2(hc_PI_long, mdd_PI_long)#make dataframe
rm(hc_PI_long, mdd_PI_long, hc_Bilateral_PI_long, mdd_Bilateral_PI_long)

out_PI_long<- shifthd_pbci( data = combined_PI_long,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_PI_long, file = "out_PI_long.RData")

##################################################################


#MI_short
hc_MI_short <-as.numeric(hc_Bilateral_MI_short$X1) #extract only numeric values for shifthd function to work
mdd_MI_short <-as.numeric(mdd_Bilateral_MI_short$X1)

combined_MI_short <- mkt2(hc_MI_short, mdd_MI_short)#make dataframe
rm(hc_MI_short, mdd_MI_short, hc_Bilateral_MI_short, mdd_Bilateral_MI_short)

out_MI_short <- shifthd_pbci( data = combined_MI_short,obs ~ gr, nboot=1000) #run shift function (sf) based on dataframe (obs+gr)

save(out_MI_short, file = "out_MI_short.RData")

#####################################



