# Comorbidity and medication sensitivity analyses for the insular similarity models
# 1. Counts comorbid diagnoses (DSM-IV codes) in the MDD group (Table 1)
# 2. Sensitivity analysis comparing HCP, MDD without and MDD with comorbid anxiety disorder
#    in the Group x Similarity type model, including emmeans contrasts
# 3. Adds medication information to the similarity tables (T_insula_medication.csv,
#    T_temporal_medication.csv) and extends the Group x Similarity type models by
#    Similarity type x antidepressant (SNRI, SSRI, NaSSA, tricyclic) interactions
#    (see 'Sensitivity analysis on medication effects' in the Supplementary Information)

library(tidyverse)
library(lme4)
library(lmerTest)

# Disable scientific notation
options(scipen = 999)

# USER SETTINGS: adjust the paths below to your local system
covariates.file <- '/path/to/Covariates_14-05-2018.csv'   # covariate table of the FOR2107 sample (diagnoses, medication)
IDs.file <- '/path/to/EPIC_SubjectIDs.csv'                # subject IDs of the participants included in the study
similarity.folder <- '/path/to/2 - Similarity/output'     # folder containing T_insula.csv and T_temporal.csv
output.folder <- '/path/to/2 - Similarity/output'         # output folder for T_insula_medication.csv and T_temporal_medication.csv

# Load covariates table
covariates <- read.csv(covariates.file)
IDs.used <- read.csv(IDs.file, header = F)

# Load insula similarity data
T_insula = read.csv(file.path(similarity.folder, 'T_insula.csv'))
# Load temporal similarity data
T_temporal = read.csv(file.path(similarity.folder, 'T_temporal.csv'))


# Select participants included in the study
covariates <- covariates %>% filter(SubjectID %in% IDs.used$V1)
mdd <- covariates %>% filter(Group == 2)

# How many individuals have comorbidities?
sum(mdd$Comorbid) # 194

# Separate comorbidities
comorbidities <- mdd %>% select(SubjectID, Group, Comorbid, starts_with("DSMIV"), )

First.diagnosis <- unique(comorbidities$DSMIV_Diagnosis1)
Second.diagnosis <- unique(comorbidities$DSMIV_Diagnosis2)
Third.diagnosis <- unique(comorbidities$DSMIV_Diagnosis3)
Fourth.diagnosis <- unique(comorbidities$DSMIV_Diagnosis4)
Fifth.diagnosis <- unique(comorbidities$DSMIV_Diagnosis5)

All <- c(First.diagnosis, Second.diagnosis, Third.diagnosis, Fourth.diagnosis, Fifth.diagnosis) %>% unique()

# Set lists with codes for disorders
anxiety <- c("300.01","300.22","300.29","300.21","300.23","300.02","300.23[2]","300","309.81")
dysthymia <- c("300.4","300.04")
ocd <- c("300.3")
substance.use.disorder <- c("305.7","305","305.9","305.2","305.9","305.00/3")
somatoform.disorder <- c("300.81","307.8","307.89","300.82","300.11","300.7")
eating.disorders <- c("307.1","307.5","307.51")
personality.disorder <- c("301.83","301.81","301.9")
adjustment.disorder <- c("309.29")
psychotic.disorder <- c("298.8")

# Select cases
anxiety.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% anxiety | DSMIV_Diagnosis2 %in% anxiety | DSMIV_Diagnosis3 %in% anxiety | DSMIV_Diagnosis4 %in% anxiety | DSMIV_Diagnosis5 %in% anxiety)
dysthymia.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% dysthymia | DSMIV_Diagnosis2 %in% dysthymia | DSMIV_Diagnosis3 %in% dysthymia | DSMIV_Diagnosis4 %in% dysthymia | DSMIV_Diagnosis5 %in% dysthymia)
ocd.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% ocd | DSMIV_Diagnosis2 %in% ocd | DSMIV_Diagnosis3 %in% ocd | DSMIV_Diagnosis4 %in% ocd | DSMIV_Diagnosis5 %in% ocd)
substance.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% substance.use.disorder | DSMIV_Diagnosis2 %in% substance.use.disorder | DSMIV_Diagnosis3 %in% substance.use.disorder | DSMIV_Diagnosis4 %in% substance.use.disorder | DSMIV_Diagnosis5 %in% substance.use.disorder)
somatoform.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% somatoform.disorder | DSMIV_Diagnosis2 %in% somatoform.disorder | DSMIV_Diagnosis3 %in% somatoform.disorder | DSMIV_Diagnosis4 %in% somatoform.disorder | DSMIV_Diagnosis5 %in% somatoform.disorder)
eating.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% eating.disorders | DSMIV_Diagnosis2 %in% eating.disorders | DSMIV_Diagnosis3 %in% eating.disorders | DSMIV_Diagnosis4 %in% eating.disorders | DSMIV_Diagnosis5 %in% eating.disorders)
personality.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% personality.disorder | DSMIV_Diagnosis2 %in% personality.disorder | DSMIV_Diagnosis3 %in% personality.disorder | DSMIV_Diagnosis4 %in% personality.disorder | DSMIV_Diagnosis5 %in% personality.disorder)
adjustment.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% adjustment.disorder | DSMIV_Diagnosis2 %in% adjustment.disorder | DSMIV_Diagnosis3 %in% adjustment.disorder | DSMIV_Diagnosis4 %in% adjustment.disorder | DSMIV_Diagnosis5 %in% adjustment.disorder)
psychotic.cases <- mdd %>% filter(DSMIV_Diagnosis1 %in% psychotic.disorder | DSMIV_Diagnosis2 %in% psychotic.disorder | DSMIV_Diagnosis3 %in% psychotic.disorder | DSMIV_Diagnosis4 %in% psychotic.disorder | DSMIV_Diagnosis5 %in% psychotic.disorder)



# Sensitivity analysis comparing MDD with anxiety and MDD without anxiety
T_insula_comorbidity_sensitivity <- T_insula
T_insula_comorbidity_sensitivity[T_insula_comorbidity_sensitivity$Subj_ID %in% anxiety.cases$SubjectID,"Group"] <- 2

T_insula_model_comorbidity <- T_insula_comorbidity_sensitivity
T_insula_model_comorbidity$Subj_ID <- factor(T_insula_model_comorbidity$Subj_ID)
T_insula_model_comorbidity$Group <- factor(T_insula_model_comorbidity$Group, labels = c("HCP", "MDD","MDD with Anxiety"), levels = c(0,1,2))
T_insula_model_comorbidity$region <- factor(T_insula_model_comorbidity$region, labels = c("between", "within AIC", "within PIC"), levels = c(0,1,2))

# Set up the same model used in Matlab previously but compare MDD with anxiety and without
lm_insula_comorbidity <- lmer(scale(atanh) ~ Group * region +
                               (1 + Group + region | Subj_ID), 
                             data = T_insula_model_comorbidity, 
                             control = lmerControl(optimizer = "bobyqa", optCtrl=list(maxfun=2e5)))


summary(lm_insula_comorbidity)

emm <- emmeans(lm_insula_comorbidity, ~ Group * region, pbkrtest.limit = 30600)

# Run first contrast testing (HCP - MDD) for AIC within - between & PIC within - between
simple.con <- contrast(emm, interaction = c("trt.vs.ctrl", "trt.vs.ctrl"))

# Run contrast of contrasts: (HCP - MDD within AIC - between) - (HCP - MDD within PIC - between)
contrast(simple.con, method = "pairwise")



#### Add medication columns to data file for main similarity analysis
medication <- covariates %>% select(SubjectID,Medication,Antidepressants,SNRI,Antipsychotic,SSRI,NaSSA,TZA,Lithium)

T_insula_medication <- merge(T_insula,medication,by.x = "Subj_ID",by.y = "SubjectID")

write.csv(T_insula_medication, file.path(output.folder, 'T_insula_medication.csv'))

# Set factor variables
T_insula_model <- T_insula_medication
T_insula_model$Subj_ID <- factor(T_insula_model$Subj_ID)
T_insula_model$Group <- factor(T_insula_model$Group, labels = c("HCP", "MDD"), levels = c(0,1))
T_insula_model$region <- factor(T_insula_model$region, labels = c("between", "within AIC", "within PIC"), levels = c(0,1,2))
T_insula_model$Antidepressants <- factor(T_insula_model$Antidepressants, labels = c("No", "Yes"), levels = c(0,1))
T_insula_model$SNRI <- factor(T_insula_model$SNRI, labels = c("No", "Yes"), levels = c(0,1))
T_insula_model$SSRI <- factor(T_insula_model$SSRI, labels = c("No", "Yes"), levels = c(0,1))
T_insula_model$NaSSA <- factor(T_insula_model$NaSSA, labels = c("No", "Yes"), levels = c(0,1))
T_insula_model$TZA <- factor(T_insula_model$TZA, labels = c("No", "Yes"), levels = c(0,1))

# Set up the same model used in Matlab previously but include the different antidepressant medications
lm_insula_medication <- lmer(scale(atanh) ~ (Group * region) +
                    region * (SNRI + SSRI + NaSSA + TZA) +
                    (1 + Group + region + SNRI + SSRI + NaSSA + TZA| Subj_ID), 
                  data = T_insula_model, 
                  control = lmerControl(optimizer = "bobyqa", optCtrl=list(maxfun=2e5)))


summary(lm_insula_medication)
confint(lm_insula_medication, method = "Wald")


## Temporal
T_temporal_medication <- merge(T_temporal,medication,by.x = "Subj_ID",by.y = "SubjectID")

write.csv(T_temporal_medication, file.path(output.folder, 'T_temporal_medication.csv'))

# Set factor variables
T_temporal_model <- T_temporal_medication
T_temporal_model$Subj_ID <- factor(T_temporal_model$Subj_ID)
T_temporal_model$Group <- factor(T_temporal_model$Group, labels = c("HCP", "MDD"), levels = c(0,1))
T_temporal_model$region <- factor(T_temporal_model$region, labels = c("between", "within anterior", "within posterior"), levels = c(0,1,2))
T_temporal_model$Antidepressants <- factor(T_temporal_model$Antidepressants, labels = c("No", "Yes"), levels = c(0,1))
T_temporal_model$SNRI <- factor(T_temporal_model$SNRI, labels = c("No", "Yes"), levels = c(0,1))
T_temporal_model$SSRI <- factor(T_temporal_model$SSRI, labels = c("No", "Yes"), levels = c(0,1))
T_temporal_model$NaSSA <- factor(T_temporal_model$NaSSA, labels = c("No", "Yes"), levels = c(0,1))
T_temporal_model$TZA <- factor(T_temporal_model$TZA, labels = c("No", "Yes"), levels = c(0,1))

# Set up the same model used in Matlab previously but include the different antidepressant medications
lm_temporal_medication <- lmer(scale(atanh) ~ Group * region +  
                               region * (SNRI + SSRI + NaSSA + TZA) +
                               (1 + Group + region | Subj_ID), 
                             data = T_temporal_model, 
                             control = lmerControl(optimizer = "bobyqa", optCtrl=list(maxfun=2e5)))


summary(lm_temporal_medication)
confint(lm_temporal_medication, method = "Wald")


