# Plot the FC density distributions of HCP and MDD for each insula subregion
# (Figure 3B/C (top) and Figure S4)
# Input: hc_Bilateral_*.csv and mdd_Bilateral_*.csv (output of shift_prep_insula.m,
#        provided in 'shift_prep')

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
read.file.path <- '/path/to/5 - Shift function/shift_prep'   # folder containing the hc_/mdd_Bilateral_*.csv files
save.path <- '/path/to/results/folder'   # output folder for the figures

hc_Bilateral_AI_long <- read_csv(paste0(read.file.path,"/hc_Bilateral_AI_long.csv"), 
                                 col_names = FALSE)
hc_Bilateral_AI_short <- read_csv(paste0(read.file.path,"/hc_Bilateral_AI_short.csv"), 
                                  col_names = FALSE)
hc_Bilateral_AI_pole <- read_csv(paste0(read.file.path,"/hc_Bilateral_AI_pole.csv"), 
                                 col_names = FALSE)
hc_Bilateral_PI_long <- read_csv(paste0(read.file.path,"/hc_Bilateral_PI_long.csv"), 
                                 col_names = FALSE)
hc_Bilateral_PI_short <- read_csv(paste0(read.file.path,"/hc_Bilateral_PI_short.csv"), 
                                  col_names = FALSE)
hc_Bilateral_MI_short <- read_csv(paste0(read.file.path,"/hc_Bilateral_MI_short.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_AI_long <- read_csv(paste0(read.file.path,"/mdd_Bilateral_AI_long.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_AI_short <- read_csv(paste0(read.file.path,"/mdd_Bilateral_AI_short.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_AI_pole <- read_csv(paste0(read.file.path,"/mdd_Bilateral_AI_pole.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_PI_long <- read_csv(paste0(read.file.path,"/mdd_Bilateral_PI_long.csv"), 
                                  col_names = FALSE)
mdd_Bilateral_PI_short <- read_csv(paste0(read.file.path,"/mdd_Bilateral_PI_short.csv"), 
                                   col_names = FALSE)
mdd_Bilateral_MI_short <- read_csv(paste0(read.file.path,"/mdd_Bilateral_MI_short.csv"), 
                                   col_names = FALSE)


## AI_long
hc_Bilateral_AI_long$Group <- "HCP"
mdd_Bilateral_AI_long$Group <- "MDD"

# Combine
AI.long <- rbind(hc_Bilateral_AI_long, mdd_Bilateral_AI_long)
AI.long$Group <- factor(AI.long$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

AI.long %>% ggplot(., aes(x = X1, fill = Group)) +
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

ggsave(file = paste0(save.path, "/AI_long_FC_distributions.png"), width=6, height=4, dpi=300)


##########################################


## AI_short
hc_Bilateral_AI_short$Group <- "HCP"
mdd_Bilateral_AI_short$Group <- "MDD"

# Combine
AI.short <- rbind(hc_Bilateral_AI_short, mdd_Bilateral_AI_short)
AI.short$Group <- factor(AI.short$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

AI.short %>% ggplot(., aes(x = X1, fill = Group)) +
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

ggsave(file = paste0(save.path, "/AI_short_FC_distributions.png"), width=6, height=4, dpi=300)

###################################################

## AI_pole
hc_Bilateral_AI_pole$Group <- "HCP"
mdd_Bilateral_AI_pole$Group <- "MDD"

# Combine
AI.pole <- rbind(hc_Bilateral_AI_pole, mdd_Bilateral_AI_pole)
AI.pole$Group <- factor(AI.pole$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

AI.pole %>% ggplot(., aes(x = X1, fill = Group)) +
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

ggsave(file = paste0(save.path, "/AI_pole_FC_distributions.png"), width=6, height=4, dpi=300)


############################################################


## PI_short
hc_Bilateral_PI_short$Group <- "HCP"
mdd_Bilateral_PI_short$Group <- "MDD"

# Combine
PI.short <- rbind(hc_Bilateral_PI_short, mdd_Bilateral_PI_short)
PI.short$Group <- factor(PI.short$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

PI.short %>% ggplot(., aes(x = X1, fill = Group)) +
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

ggsave(file = paste0(save.path, "/PI_short_FC_distributions.png"), width=6, height=4, dpi=300)


################################################################################################


## PI_long
hc_Bilateral_PI_long$Group <- "HCP"
mdd_Bilateral_PI_long$Group <- "MDD"

# Combine
PI.long <- rbind(hc_Bilateral_PI_long, mdd_Bilateral_PI_long)
PI.long$Group <- factor(PI.long$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

PI.long %>% ggplot(., aes(x = X1, fill = Group)) +
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

ggsave(file = paste0(save.path, "/PI_long_FC_distributions.png"), width=6, height=4, dpi=300)


##################################################################


## MI_short
hc_Bilateral_MI_short$Group <- "HCP"
mdd_Bilateral_MI_short$Group <- "MDD"

# Combine
MI.short <- rbind(hc_Bilateral_MI_short, mdd_Bilateral_MI_short)
MI.short$Group <- factor(MI.short$Group, labels = c("MDD","HCP"), levels = c("MDD","HCP"))

MI.short %>% ggplot(., aes(x = X1, fill = Group)) +
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

ggsave(file = paste0(save.path, "/MI_short_FC_distributions.png"), width=6, height=4, dpi=300)


#####################################



