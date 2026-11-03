# Generate Figure 4
# A: median AUC of the SVM models trained on true group labels (red) and on permuted group
#    labels (blue) per BDI inclusion threshold, with linear fit
# B: distribution of the slope coefficients of the permuted models compared with the slope
#    of the true model (dark red line)
# Input: average_auc_perm_median.csv and slope_perm_median.csv (output of
#        Run_SVM_BDI_with_permutation.m, provided in the 'output' folder)

library(ggplot2)
library(tidyr)
library(ggpubr)
library(cowplot)

theme_set(theme_cowplot())

# USER SETTINGS: set paths to your local system
results.folder = "/path/to/6 - SVM/plots/"   # output folder for the figures (keep the trailing slash)
data.folder = "/path/to/6 - SVM/output"      # folder containing average_auc_perm_median.csv and slope_perm_median.csv

auc_median = read.csv(file.path(data.folder, "average_auc_perm_median.csv"))
slope_perm_median = read.csv(file.path(data.folder, "slope_perm_median.csv"), header = FALSE)


# plot classification outcome for true and permuted labels
permutation_median <- ggplot(auc_median, aes(bdi, AUC, color = "AUC")) +
  ggtitle("Predicting group\nusing insular FC profiles") +
  geom_point(size = 3) +
  geom_point(data = auc_median, aes(x = bdi, y = prct_AUC_perm, color = "mean_AUC_perm"), size = 3) +
  scale_color_manual(labels = c("True", "Permuted (mean)"), values = c("red", "blue")) +
  labs(color = " ") +
  geom_smooth(method = "lm", color = "firebrick4") +
  theme(legend.position = c(0.05, 0.85), legend.text = element_text(size = 24.0), plot.title = element_text(size = 34.0, hjust = 0.5), axis.title = element_text(size = 32.0,face = "bold"),axis.text.x = element_text(size = 30.0),axis.text.y = element_text(size = 30.0)) +
  xlab("BDI inclusion threshold") +
  ylab("Median AUC") 

ggsave(paste0(results.folder, "Permutation_prediction_median.png"), plot = permutation_median, scale = 1, width = 8, height = 8, units = "in",  dpi = 300)



# plot coefficients for slope
names(slope_perm_median)[1] <- "perm_auc"

slope_perm <- ggplot(slope_perm_median, aes(x=perm_auc))+
  ggtitle("Higher accuracy with\nhigher symptom severity") +
  geom_density(color = "blue", fill = "blue", alpha=0.5) +
  theme(plot.margin = unit(c(0.25,1,0.25,0.25), "cm"), legend.position = c(0.05, 0.85), legend.text = element_text(size = 20.0), plot.title = element_text(size = 34.0, hjust = 0.5), axis.title = element_text(size = 32.0,face = "bold"),axis.text.x = element_text(size = 30.0),axis.text.y = element_text(size = 30.0)) +
  xlab("Coefficient of fitted slopes") +
  xlim(-0.025, 0.025) +
  #scale_x_continuous(breaks = c(-0.02,0, 0.02), labels=c("-0.005","0", "0.005")) +
  coord_cartesian(clip = "off") +
  ylab("Density") +
  geom_vline(xintercept = 0.0205742940415878, color = "firebrick4", size=1.5) +
  geom_rect(xmin = 0.02, xmax = 0.05, ymin = 100, ymax = 120, fill = "white") +
  geom_text(x=0.0205742940415878, y=100,label="***", color = "firebrick4",size=14)

ggsave(paste0(results.folder, "Slope_perm_median.png"), plot = slope_perm, scale = 1, width = 8.5, height = 8, units = "in",  dpi = 300)


# combine panels into one figure
pAll <- plot_grid(permutation_median, slope_perm, labels = c("A","B"), label_size = 34, ncol=2, rel_widths = c(1, 1.2))

ggsave(paste0(results.folder, "EPIC_Classification_SVM.png"), plot = pAll, scale = 1, width = 16, height = 9, units = "in",  dpi = 300)


