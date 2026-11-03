##Create plots for two way interaction model Münster
# Fits linear mixed-effects models (lme4) of similarity by Group x Similarity type for the
# insula and the temporal cortex and plots
#   - p1: similarity within vs. between subregions per group (Figure S2A)
#   - p2: delta similarity (within - between) per group (Figure S2B)
#   - p3: delta similarity (anterior-within - between, posterior-within - between) per group
#         for insula and temporal cortex (Figure 3A)
# Input: T_insula.csv and T_temporal.csv (output of '2 - Similarity', provided in
#        '2 - Similarity/output')
# Note: scale_fill_viridis() requires the R package 'viridis' and revalue() the package 'plyr'.

# USER SETTINGS: adjust the paths below to your local system
data.folder <- '/path/to/2 - Similarity/output'   # folder containing T_insula.csv and T_temporal.csv (used as working directory; x.RData and x_temporal.RData are saved here)
results.folder <- '/path/to/results/folder'       # output folder for the figures

setwd(data.folder)
T_insula <- read.csv('T_insula.csv')
T_temporal <- read.csv('T_temporal.csv')

T_practice_insula = T_insula
colnames(T_practice_insula)[colnames(T_practice_insula)=="within"] <- "Similarity_type"
T_practice_insula$Similarity_type = gsub("1", "2", T_practice_insula$Similarity_type) #change 1 to 2 in table
T_practice_insula$Similarity_type= gsub("0", "1", T_practice_insula$Similarity_type) #change 0 to 1 in table -> to avoid it being seen as logical
T_practice_insula$Similarity_type = gsub("2", "within", T_practice_insula$Similarity_type) #change 1 to 2 in table
T_practice_insula$Similarity_type = gsub("1", "between", T_practice_insula$Similarity_type) 

T_practice_insula$Group = gsub("1", "MDD", T_practice_insula$Group) #change 1 to 2 in table
T_practice_insula$Group= gsub("0", "HC", T_practice_insula$Group)


T_practice_insula$region= gsub("1", "anterior_within", T_practice_insula$region) #change 1 to 2 in table
T_practice_insula$region= gsub("0", "between", T_practice_insula$region)
T_practice_insula$region= gsub("2", "posterior_within", T_practice_insula$region)

T_practice_insula$Similarity_type <- as.factor(T_practice_insula$Similarity_type)
T_practice_insula$Group <- as.factor(T_practice_insula$Group)
T_practice_insula$region <- as.factor(T_practice_insula$region)


library(lme4)
library(sjstats)
library(merTools)

lme_insula = lmer(atanh~ region*Group + (1+Group| Subj_ID), data = T_practice_insula); #create model to look at the interaction effect
#of Group and within on atanh, taking the Subject ID as a random effect into account
lme_insula
coef(summary(lme_insula))

#is_singular(lme) chacks if model is singular

#use function to create error bars that take random effects into account

library(carData)
library(effects)

ef_insula <- effect(term = "region*Group",lme_insula) #effect() takes term from model and model object
summary(ef_insula)

x_insula <- as.data.frame(ef_insula) #convert to data frame
x_insula
save(x_insula, file = "x.RData")

area <- c("Insula", "Insula", "Insula", "Insula", "Insula", "Insula")
x_insula$area <- area

library(dplyr)
library(ggplot2)
library(cowplot)


insula <- ggplot(x_insula, aes(Group, fit,  fill=region)) + #plot
  geom_bar(stat="identity", position= "dodge") + 
  scale_fill_viridis(option = "cividis", discrete= TRUE, begin = 0.15, end = 0.95, name = "Similarity type/region" ) +
  scale_color_viridis( option = "cividis", discrete= TRUE, begin = 0.15, end = 0.95, name = "Similarity type"  ) +
  geom_errorbar(aes(ymin=fit-se, ymax=fit+se), width=0.2, color="black", position=position_dodge(width=0.9)) +
  theme_bw(base_size=12)
insula

T_practice_temporal = T_temporal
colnames(T_practice_temporal)[colnames(T_practice_temporal)=="within"] <- "Similarity_type"
T_practice_temporal$Similarity_type = gsub("1", "2", T_practice_temporal$Similarity_type) #change 1 to 2 in table
T_practice_temporal$Similarity_type= gsub("0", "1", T_practice_temporal$Similarity_type) #change 0 to 1 in table -> to avoid it being seen as logical
T_practice_temporal$Similarity_type = gsub("2", "within", T_practice_temporal$Similarity_type) #change 1 to 2 in table
T_practice_temporal$Similarity_type = gsub("1", "between", T_practice_temporal$Similarity_type) 
T_practice_temporal$Group = gsub("1", "MDD", T_practice_temporal$Group) #change 1 to 2 in table
T_practice_temporal$Group= gsub("0", "HC", T_practice_temporal$Group)


T_practice_temporal$region= gsub("1", "anterior_within", T_practice_temporal$region) #change 1 to 2 in table
T_practice_temporal$region= gsub("0", "between", T_practice_temporal$region)
T_practice_temporal$region= gsub("2", "posterior_within", T_practice_temporal$region)


T_practice_temporal$Similarity_type <- as.factor(T_practice_temporal$Similarity_type)
T_practice_temporal$Group <- as.factor(T_practice_temporal$Group)
T_practice_temporal$region <- as.factor(T_practice_temporal$region)

library(lme4)
library(sjstats)
library(merTools)

lme_temporal = lmer(atanh~ region*Group + (1+region+Group| Subj_ID), data = T_practice_temporal); #create model to look at the interaction effect
#of Group and within on atanh, taking the Subject ID as a random effect into account
lme_temporal
coef(summary(lme_temporal))

#is_singular(lme) chacks if model is singular

#use function to create error bars that take random effects into account

library(carData)
library(effects)

ef_temporal <- effect(term = "region*Group",lme_temporal) #effect() takes term from model and model object
summary(ef_temporal)

x_temporal <- as.data.frame(ef_temporal) #convert to data frame
x_temporal
save(x_temporal, file = "x_temporal.RData")

area <- c("Temporal", "Temporal", "Temporal", "Temporal", "Temporal", "Temporal")
x_temporal$area <- area

library(dplyr)
library(ggplot2)
library(cowplot)

temporal <- ggplot(x_temporal, aes(Group, fit, color = Similarity_type, fill=Similarity_type)) + #plot
  geom_bar(stat="identity", position= "dodge") + 
  scale_fill_brewer(palette = "Set1") +
  geom_errorbar(aes(ymin=fit-se, ymax=fit+se), width=0.2, color="black", position=position_dodge(width=0.9)) +
  theme_bw(base_size=12)

temporal


## make plots based on subject-wise data
T_both = rbind(T_practice_insula,T_practice_temporal)
T_both$ROI = t(cbind(t(rep("Insula",30600)),t(rep("Temporal",30600))))
T_both$ROI <- as.factor(T_both$ROI)


p1 <- ggplot(T_both, aes(Group, atanh,  fill=Similarity_type)) + #plot
  geom_bar(stat="summary",  position= "dodge") + 
  facet_wrap(~ ROI, ncol =2) +
  labs(y = "Similarity \n (z-transformed r)")+
  scale_fill_viridis(option = "cividis", discrete= TRUE, begin = 0.15, end = 0.95, name = "Similarity type" ) +
  scale_color_viridis( option = "cividis", discrete= TRUE, begin = 0.15, end = 0.95, name = "Similarity type"  ) +
  geom_errorbar(aes(y = atanh,x = Group),data=T_both,size = 0.8,width = 0.2,fun.data = mean_cl_normal,fun.args = list(conf.int = 0.95),stat = 'summary',position = position_dodge(width = 0.9)) +
  theme(strip.text.x = element_text(size = 28.0, margin = margin(0.2,0.2,0.2,0.2, "cm")), text = element_text(face = 'bold',size = 26.0),axis.text = element_text(face = 'plain',size = 24.0),axis.text.x = element_text(size = 24.0), legend.title=element_text(size = 22), legend.text=element_text(size = 20))

ggsave(file.path(results.folder, "Model_similarity_within_only_insula_temporal.png"), plot = p1, height = 6.5, width = 9, units = "in",  dpi = 600)


# mean entries for between
T_both_mean <- T_both %>%
  group_by(Subj_ID,ROI,Similarity_type, Group) %>%
  summarize(Similarity = mean(atanh))

T_both_mean_within = T_both_mean[T_both_mean$Similarity_type == "within",]
T_both_mean_between = T_both_mean[T_both_mean$Similarity_type == "between",]

T_both_mean_delta = as.data.frame(cbind(T_both_mean_within$Subj_ID, T_both_mean_within$ROI,T_both_mean_within$Group, T_both_mean_within$Similarity - T_both_mean_between$Similarity))
colnames(T_both_mean_delta) <- c("Subj_ID","ROI","Group","Delta_Similarity")
T_both_mean_delta$ROI <- factor(T_both_mean_delta$ROI, labels = c("Insula","Temporal"))
T_both_mean_delta$Group <- factor(T_both_mean_delta$Group, labels = c("HC","MDD"))

p2 <- ggplot(T_both_mean_delta, aes(Group, Delta_Similarity, fill=Group)) + #plot
  geom_bar(stat="summary",  position= "dodge") + 
  facet_wrap(~ ROI, ncol =2) +
  labs(y = "?? Similarity (within-between) \n (z-transformed r)")+
  scale_color_manual(values = c("deeppink4","deeppink4")) +
  scale_fill_manual(values = c("deeppink4","deeppink4")) +
  geom_errorbar(aes(y = Delta_Similarity,x = Group),data=T_both_mean_delta,size = 0.8,width = 0.3,fun.data = mean_cl_normal,fun.args = list(conf.int = 0.95),stat = 'summary',position = position_dodge(width = 0.9)) +
  theme(legend.position="none",strip.text.x = element_text(size = 28.0, margin = margin(0.2,0.2,0.2,0.2, "cm")), text = element_text(face = 'bold',size = 26.0),axis.text = element_text(face = 'plain',size = 24.0),axis.text.x = element_text(size = 24.0))

ggsave(file.path(results.folder, "Model_delta_similarity_within_only_insula_temporal.png"), plot = p2, height = 6.5, width = 7, units = "in",  dpi = 600)


T_both_mean_EPIC <- T_both %>%
  group_by(Subj_ID,ROI,region, Group) %>%
  summarize(Similarity = mean(atanh))

T_both_mean_EPIC_anteriorwithin = T_both_mean_EPIC[T_both_mean_EPIC$region == "anterior_within",]
T_both_mean_EPIC_posteriorwithin = T_both_mean_EPIC[T_both_mean_EPIC$region == "posterior_within",]
T_both_mean_EPIC_between = T_both_mean_EPIC[T_both_mean_EPIC$region == "between",]

delta_similarity_anterior_between = T_both_mean_EPIC_anteriorwithin$Similarity - T_both_mean_EPIC_between$Similarity
delta_similarity_posterior_between = T_both_mean_EPIC_posteriorwithin$Similarity - T_both_mean_EPIC_between$Similarity

T_both_mean_EPIC_anterior_between = T_both_mean_EPIC_anteriorwithin
T_both_mean_EPIC_anterior_between$Similarity = delta_similarity_anterior_between

T_both_mean_EPIC_posterior_between = T_both_mean_EPIC_posteriorwithin
T_both_mean_EPIC_posterior_between$Similarity = delta_similarity_posterior_between

T_both_mean_EPIC_deltas = rbind(T_both_mean_EPIC_anterior_between,T_both_mean_EPIC_posterior_between)
T_both_mean_EPIC_deltas$region <- revalue(T_both_mean_EPIC_deltas$region, c("anterior_within"="anterior", "posterior_within"="posterior"))


p3 <- ggplot(T_both_mean_EPIC_deltas, aes(Group, Similarity,  fill=region)) + #plot
  geom_bar(stat="summary",  position= "dodge") + 
  facet_wrap(~ ROI, ncol =2) +
  labs(y = "?? Similarity (within-between) \n (z-transformed r)")+
  labs(fill = "Gradient") +
  scale_color_manual(values = c("#9ACE81","#8B94C4")) +
  scale_fill_manual(values = c("#9ACE81","#8B94C4")) +
  coord_cartesian(ylim = c(0, 0.29)) +
  #scale_fill_viridis(option = "cividis", discrete= TRUE, begin = 0.15, end = 0.95, name = "Similarity type" ) +
  #scale_color_viridis( option = "cividis", discrete= TRUE, begin = 0.15, end = 0.95, name = "Similarity type"  ) +
  geom_errorbar(aes(y = Similarity,x = Group),data=T_both_mean_EPIC_deltas,size = 0.8,width = 0.3,fun.data = mean_cl_normal,fun.args = list(conf.int = 0.95),stat = 'summary',position = position_dodge(width = 0.9)) +
  theme(strip.text.x = element_text(size = 28.0, margin = margin(0.2,0.2,0.2,0.2, "cm")), text = element_text(face = 'bold',size = 26.0),axis.text = element_text(face = 'plain',size = 24.0),axis.text.x = element_text(size = 24.0), legend.title=element_text(size = 22), legend.text=element_text(size = 20))

ggsave(file.path(results.folder, "Model_delta_similarity_insula_temporal.png"), plot = p3, height = 6.5, width = 9, units = "in",  dpi = 600)



