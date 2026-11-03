# Post-hoc comparison of the Group x Similarity type interactions between anterior and posterior
# subregions for the insula and the temporal cortex
# The Group x Similarity type linear mixed-effects model (same model as in
# LME_group_similarity_type_HC_MDD.m) is refitted with lme4/lmerTest. Based on the estimated
# marginal means (emmeans), the interaction contrasts (HCP - MDD) x (anterior-within - between)
# and (HCP - MDD) x (posterior-within - between) are calculated and compared with each other
# (contrast of contrasts). Results are printed to the console.
# Input: T_insula.csv and T_temporal.csv (output of '2 - Similarity', provided in
#        '2 - Similarity/output')
# See 'Linear mixed effects analysis of the similarity estimates' in the Methods.

library(tidyverse)
library(lmerTest)
library(emmeans)

# Disable scientific notation
options(scipen = 999)

### Run linear mixed-effects model to test for interaction between Group (HC, MDD) and
### Similarity type (anterior-within, posterior-within, between)

# USER SETTINGS: adjust the path below to your local system
result_folder = '/path/to/2 - Similarity/output/'   # folder containing T_insula.csv and T_temporal.csv (keep the trailing slash)

# Insula
T_insula = read.csv(paste0(result_folder, 'T_insula.csv'))

# Set factor variables
T_insula_model <- T_insula
T_insula_model$Subj_ID <- factor(T_insula_model$Subj_ID)
T_insula_model$Group <- factor(T_insula_model$Group, labels = c("HCP", "MDD"), levels = c(0,1))
T_insula_model$region <- factor(T_insula_model$region, labels = c("between", "within AIC", "within PIC"), levels = c(0,1,2))

# Set up the same model used in Matlab previously
lm_insula <- lmer(scale(atanh) ~ Group * region + (1 + Group + region | Subj_ID), 
                  data = T_insula_model, 
                  control = lmerControl(optimizer = "bobyqa"))

# Extract marginal means
emm <- emmeans(lm_insula, ~ Group * region, pbkrtest.limit = 30600)

# Run first contrast testing (HCP - MDD) for AIC within - between & PIC within - between
simple.con <- contrast(emm, interaction = c("pairwise", "trt.vs.ctrl"))

# Run contrast of contrasts: (HCP - MDD within AIC - between) - (HCP - MDD within PIC - between)
contrast(simple.con, method = "pairwise")




### Temporal
# Insula
T_temporal = read.csv(paste0(result_folder, 'T_temporal.csv'))

# Set factor variables
T_temporal_model <- T_temporal
T_temporal_model$Subj_ID <- factor(T_temporal_model$Subj_ID)
T_temporal_model$Group <- factor(T_temporal_model$Group, labels = c("HCP", "MDD"), levels = c(0,1))
T_temporal_model$region <- factor(T_temporal_model$region, labels = c("between", "within anterior", "within posterior"), levels = c(0,1,2))

# Set up the same model used in Matlab previously
lm_temporal <- lmer(scale(atanh) ~ Group * region + (1 + Group + region | Subj_ID), 
                  data = T_temporal_model, 
                  control = lmerControl(optimizer = "bobyqa"))

# Extract marginal means
emm_temporal <- emmeans(lm_temporal, ~ Group * region, pbkrtest.limit = 30600)

# Run first contrast testing (HCP - MDD) for AIC within - between & PIC within - between
simple.con.temporal <- contrast(emm_temporal, interaction = c("pairwise", "trt.vs.ctrl"))

# Run contrast of contrasts: (HCP - MDD within AIC - between) - (HCP - MDD within PIC - between)
contrast(simple.con.temporal, method = "pairwise")
