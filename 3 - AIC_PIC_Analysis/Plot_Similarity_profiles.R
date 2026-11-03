# Compare and plot the similarity of AIC and PIC FC profiles between HCP and MDD (Figure 2D)
# Within-participant AIC-PIC similarity (z-transformed r) is compared between groups with a
# standard two-sample t-test and a robust Yuen-Welch test (10% trimmed means, winsorized
# variances) including the robust effect size of Algina, Keselman & Penfield (akp.effect).
# Input: Similarity_AIC_PIC_Groups.csv
#        (output of Full_factorial_model_group_subregions_sample_850_with_regress_SPM25.m)

library(tidyverse)
library(gghalves)
library(cowplot)
library(WRS2)
library(effectsize)

# USER SETTINGS: adjust the paths below to your local system
input.file <- '/path/to/Similarity_AIC_PIC_Groups.csv'   # AIC-PIC similarity per participant
results.folder <- '/path/to/results/folder'              # output folder for the figure

# Load vectorized t maps
similarity <- read.csv(input.file, header = T)

# Rename Group column
similarity[similarity$Group == 0,"Group"] <- 'HCP'
similarity[similarity$Group == 1,"Group"] <- 'MDD'
similarity$Group <- as.factor(similarity$Group)

# Get stats
# Generic t-test
similarity.ttest.group.comparison <- t.test(Similarity ~ Group, data = similarity, var.equal = TRUE)
similarity.d.group.comparison <- (2*similarity.ttest.group.comparison$statistic)/(sqrt(similarity.ttest.group.comparison$parameter))

# Robust t-test: Yuen-Welch (trimmed means (10%), winsorized variances)
similarity.yuen.group.comparison <- yuen(Similarity ~ Group, data = similarity, tr = 0.1)
similarity.akp.group.comparison <- akp.effect(Similarity ~ Group, data = similarity, tr = 0.1)

# Plot
similarity %>% ggplot(aes(x=Group, y=Similarity, fill = Group)) +
  geom_half_violin(side = "r", colour = NA, alpha = 0.4, scale = 'count') +
  geom_dotplot(binaxis = "y", colour = NA, dotsize = 1, binwidth = 0.028) +
  scale_fill_manual(values = c("#E9AA69","#6B9AD8")) +
  geom_half_boxplot(errorbar.draw = F, outlier.shape = NA, width = 0.1) +
  xlab("Group") +
  ylab("Similarity of AIC and PIC FC\nprofiles [z-transformed r]") +
  theme_cowplot() +
  theme(text = element_text(size=20),
        legend.position = "none",
        axis.text = element_text(colour = "black", size =18),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines")) 

ggsave(file = file.path(results.folder, 'Comparison_similarity_profiles_HCP_MDD.png'), width=4.5, height=4.5, dpi=300)

