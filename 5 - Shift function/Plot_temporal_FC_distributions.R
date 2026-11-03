# Plot the FC density distributions of HCP and MDD for each temporal cortex subregion
# (Figure 3C (top) and Figure S5)
# Input: hc_Bilateral_*.csv and mdd_Bilateral_*.csv (output of shift_prep_temporal.m,
#        provided in 'shift_prep/temporal')

install.packages("devtools")
devtools::install_github("GRousselet/rogme")
library(readr)
library(cowplot)
library(rogme)
library(tibble)
library(gridExtra)
library(ggpubr)
library(tidyverse)

# USER SETTINGS: adjust the paths below to your local system
read.file.path <- '/path/to/5 - Shift function/shift_prep/temporal'   # folder containing the hc_/mdd_Bilateral_*.csv files
save.path <- '/path/to/results/folder'   # output folder for the figures

hc_Bilateral_AT_medial <- read_csv(paste0(read.file.path,"/hc_Bilateral_AT_medial.csv"), 
                                 col_names = FALSE)
hc_Bilateral_AT_lateral <- read_csv(paste0(read.file.path,"/hc_Bilateral_AT_lateral.csv"), 
                                  col_names = FALSE)
hc_Bilateral_MIT <- read_csv(paste0(read.file.path,"/hc_Bilateral_MIT.csv"), 
                                 col_names = FALSE)
hc_Bilateral_PT <- read_csv(paste0(read.file.path,"/hc_Bilateral_PT.csv"), 
                                 col_names = FALSE)
hc_Bilateral_ST_middle <- read_csv(paste0(read.file.path,"/hc_Bilateral_ST_middle.csv"), 
                                  col_names = FALSE)
hc_Bilateral_aSTG <- read_csv(paste0(read.file.path,"/hc_Bilateral_aSTG.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_AT_medial <- read_csv(paste0(read.file.path,"/mdd_Bilateral_AT_medial.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_AT_lateral <- read_csv(paste0(read.file.path,"/mdd_Bilateral_AT_lateral.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_MIT <- read_csv(paste0(read.file.path,"/mdd_Bilateral_MIT.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_PT <- read_csv(paste0(read.file.path,"/mdd_Bilateral_PT.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_ST_middle <- read_csv(paste0(read.file.path,"/mdd_Bilateral_ST_middle.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_aSTG <- read_csv(paste0(read.file.path,"/mdd_Bilateral_aSTG.csv"), 
                                   col_names = FALSE)


## AT_medial
hc_Bilateral_AT_medial$Group <- "HCP"
mdd_Bilateral_AT_medial$Group <- "MDD"

# Combine
AT.medial <- rbind(hc_Bilateral_AT_medial, mdd_Bilateral_AT_medial)
AT.medial$Group <- factor(AT.medial$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

AT.medial %>% ggplot(., aes(x = X1, fill = Group)) +
  geom_density(alpha = 0.6, colour = NA) +
  #facet_wrap(~Group, ncol = 1) +
  scale_fill_manual(values=c("#2B64C5", "#F09235")) +
  scale_y_continuous(expand = c(0,0)) +
  xlab("ROI-to-voxel FC [z-transformed r]") +
  ylab("Density") +
  theme_minimal() +
  theme(text = element_text(size=22),
        legend.position = "bottom",
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        panel.grid.minor = element_blank(),panel.grid.major.y = element_blank(), axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines"),
        plot.margin=unit(c(0.5,1,0.5,0.5),"cm")) 

ggsave(file = paste0(save.path, "/AT_medial_FC_distributions.png"), width=6, height=4, dpi=300)


##########################################


## AT_lateral
hc_Bilateral_AT_lateral$Group <- "HCP"
mdd_Bilateral_AT_lateral$Group <- "MDD"

# Combine
AT.lateral <- rbind(hc_Bilateral_AT_lateral, mdd_Bilateral_AT_lateral)
AT.lateral$Group <- factor(AT.lateral$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

AT.lateral %>% ggplot(., aes(x = X1, fill = Group)) +
  geom_density(alpha = 0.6, colour = NA) +
  scale_fill_manual(values=c("#2B64C5", "#F09235")) +
  scale_y_continuous(expand = c(0,0)) +
  xlab("ROI-to-voxel FC [z-transformed r]") +
  ylab("Density") +
  theme_minimal() +
  theme(text = element_text(size=22),
        legend.position = "bottom",
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        panel.grid.minor = element_blank(),panel.grid.major.y = element_blank(), axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines"),
        plot.margin=unit(c(0.5,1,0.5,0.5),"cm")) 

ggsave(file = paste0(save.path, "/AT_lateral_FC_distributions.png"), width=6, height=4, dpi=300)

###################################################

## MIT
hc_Bilateral_MIT$Group <- "HCP"
mdd_Bilateral_MIT$Group <- "MDD"

# Combine
MIT <- rbind(hc_Bilateral_MIT, mdd_Bilateral_MIT)
MIT$Group <- factor(MIT$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

MIT %>% ggplot(., aes(x = X1, fill = Group)) +
  geom_density(alpha = 0.6, colour = NA) +
  scale_fill_manual(values=c("#2B64C5", "#F09235")) +
  scale_y_continuous(expand = c(0,0)) +
  xlab("ROI-to-voxel FC [z-transformed r]") +
  ylab("Density") +
  theme_minimal() +
  theme(text = element_text(size=22),
        legend.position = "bottom",
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        panel.grid.minor = element_blank(),panel.grid.major.y = element_blank(), axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines"),
        plot.margin=unit(c(0.5,1,0.5,0.5),"cm")) 

ggsave(file = paste0(save.path, "/MIT_FC_distributions.png"), width=6, height=4, dpi=300)


############################################################


## PT
hc_Bilateral_PT$Group <- "HCP"
mdd_Bilateral_PT$Group <- "MDD"

# Combine
PT <- rbind(hc_Bilateral_PT, mdd_Bilateral_PT)
PT$Group <- factor(PT$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

PT %>% ggplot(., aes(x = X1, fill = Group)) +
  geom_density(alpha = 0.6, colour = NA) +
  scale_fill_manual(values=c("#2B64C5", "#F09235")) +
  scale_y_continuous(expand = c(0,0)) +
  xlab("ROI-to-voxel FC [z-transformed r]") +
  ylab("Density") +
  theme_minimal() +
  theme(text = element_text(size=22),
        legend.position = "bottom",
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        panel.grid.minor = element_blank(),panel.grid.major.y = element_blank(), axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines"),
        plot.margin=unit(c(0.5,1,0.5,0.5),"cm")) 

ggsave(file = paste0(save.path, "/PT_FC_distributions.png"), width=6, height=4, dpi=300)


################################################################################################


## ST middle
hc_Bilateral_ST_middle$Group <- "HCP"
mdd_Bilateral_ST_middle$Group <- "MDD"

# Combine
ST.middle <- rbind(hc_Bilateral_ST_middle, mdd_Bilateral_ST_middle)
ST.middle$Group <- factor(ST.middle$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

ST.middle %>% ggplot(., aes(x = X1, fill = Group)) +
  geom_density(alpha = 0.6, colour = NA) +
  scale_fill_manual(values=c("#2B64C5", "#F09235")) +
  scale_y_continuous(expand = c(0,0)) +
  xlab("ROI-to-voxel FC [z-transformed r]") +
  ylab("Density") +
  theme_minimal() +
  theme(text = element_text(size=22),
        legend.position = "bottom",
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        panel.grid.minor = element_blank(),panel.grid.major.y = element_blank(), axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines"),
        plot.margin=unit(c(0.5,1,0.5,0.5),"cm")) 

ggsave(file = paste0(save.path, "/ST_middle_FC_distributions.png"), width=6, height=4, dpi=300)


##################################################################


## aSTG
hc_Bilateral_aSTG$Group <- "HCP"
mdd_Bilateral_aSTG$Group <- "MDD"

# Combine
aSTG <- rbind(hc_Bilateral_aSTG, mdd_Bilateral_aSTG)
aSTG$Group <- factor(aSTG$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

aSTG %>% ggplot(., aes(x = X1, fill = Group)) +
  geom_density(alpha = 0.6, colour = NA) +
  scale_fill_manual(values=c("#2B64C5", "#F09235")) +
  scale_y_continuous(expand = c(0,0)) +
  xlab("ROI-to-voxel FC [z-transformed r]") +
  ylab("Density") +
  theme_minimal() +
  theme(text = element_text(size=22),
        legend.position = "bottom",
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        panel.grid.minor = element_blank(),panel.grid.major.y = element_blank(), axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines"),
        plot.margin=unit(c(0.5,1,0.5,0.5),"cm")) 

ggsave(file = paste0(save.path, "/aSTG_FC_distributions.png"), width=6, height=4, dpi=300)


#####################################



