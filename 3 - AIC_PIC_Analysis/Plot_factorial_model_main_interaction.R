# Plot voxel-wise T values of the main effect of Subregion (AIC, PIC) against T values of the
# interaction effect Group x Subregion from the full factorial model (Figure 2C)
# Input: factorial_model_FC_main_effect_vectorized.csv and
#        factorial_model_FC_interaction_effect_vectorized.csv (one T value per voxel, taken
#        from spmT_main_effect_subregion.nii.gz and spmT_interaction_group_subregion.nii.gz)

library(tidyverse)
library(cowplot)

# USER SETTINGS: adjust the paths below to your local system
data.folder <- '/path/to/3 - AIC_PIC_Analysis'   # folder containing the vectorized T maps
results.folder <- '/path/to/results/folder'      # output folder for the figure

# Load vectorized t maps
main.effect <- read.csv(file.path(data.folder, 'factorial_model_FC_main_effect_vectorized.csv'), header = F)
interaction.effect <- read.csv(file.path(data.folder, 'factorial_model_FC_interaction_effect_vectorized.csv'), header = F)

# Combine
colnames(main.effect) <- "main"
main.effect$main <- -main.effect$main # switch main effect to have AIC on the left of the plot
colnames(interaction.effect) <- "interaction"
main.effect$subregion <- "AIC"
main.effect[main.effect$main > 0,"subregion"] <- "PIC"

factorial <- cbind(interaction.effect,main.effect)

# Plot
factorial %>% ggplot(aes(x=main, y=interaction, colour = subregion)) +
  geom_point(shape = ".") +
  scale_color_manual(values = c("#6FB151","#8188B0")) +
  #geom_line(data = data.frame(x = c(-Inf, Inf), y = c(Inf, -Inf)), aes(x, y), color = "black") +
  geom_smooth(method = "lm", color = "black", linewidth = 0.5) +
  #geom_abline(slope = -1, color = "black",  size = 1) +
  xlab("Main effect: Subregion [T]") +
  ylab("Interaction effect:\nGroup × Subregion [T]") +
  theme_cowplot() +
  theme(text = element_text(size=22),
        legend.position = "none",
        axis.text = element_text(colour = "black", size =20),
        axis.title = element_text(colour = "black", face = "bold"),
        strip.text = element_text(colour = "black", face = "bold"),
        #panel.grid.minor = element_blank(),panel.grid.major.y = element_blank(), axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = 'white'),
        panel.spacing = unit(2, "lines"),
        plot.margin=unit(c(0.5,1,0.5,0.5),"cm")) 

ggsave(file = file.path(results.folder, 'Factorial_model_main_interaction.png'), width=5.5, height=4, dpi=300)




