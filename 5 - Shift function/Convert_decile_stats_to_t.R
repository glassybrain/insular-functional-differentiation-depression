### Convert group differences and CIs from shift function (bootstrapped decile differences) to t values
### Add Cohen's d based on t value and standard error
### Format output table and save as csv
### Input: out_*.RData files (output of Run_shift_function_insula.R / _temporal.R, provided in
### 'output/insula' and 'output/temporal'); the csv tables (cf. Table S2) are written into the
### same folders
options(scipen=999)

# USER SETTINGS: adjust the paths below to your local system
insula.folder <- '/path/to/5 - Shift function/output/insula'       # folder containing the out_*.RData files of the insula
temporal.folder <- '/path/to/5 - Shift function/output/temporal'   # folder containing the out_*.RData files of the temporal cortex

## Insula
filenames <- list.files(insula.folder, pattern="*.RData", full.names=TRUE)
ldf <- lapply(filenames, load,.GlobalEnv)

Stats_Insula_t <- matrix(, nrow = 9, ncol = 6)
Stats_Insula_d <- matrix(, nrow = 9, ncol = 6)
Stats_Insula_p <- matrix(, nrow = 9, ncol = 6)

for(i in 1:length(ldf)){
  region <- ldf[[i]][1]
  results.table <- eval(as.name(region))
  # run through deciles
  for(deciles in 1:length(results.table$`Group1 - Group2`)){
    # first convert CI to SE
    SE<- (results.table[["Group1 - Group2"]][["ci_upper"]][deciles] - results.table[["Group1 - Group2"]][["ci_lower"]][deciles])/3.92 # divide width of confidence interval by critical value (for 95% CI: 1.96x2=3.92)
    # next calculate t value based on group difference and SE
    t <- results.table[["Group1 - Group2"]][["difference"]][deciles]/SE # divide mean difference by standard error to get t value
    # switch sign of t as groups were switched for more intuitive visualization
    t <- -t
    # calculate Cohen's d
    d <- t/(sqrt((417 * 433)/(417 + 433))) # use formula for independent samples with unequal group sizes
    
    # save output
    Stats_Insula_t[deciles,i] <- t
    Stats_Insula_d[deciles,i] <- d
    Stats_Insula_p[deciles,i] <- results.table[["Group1 - Group2"]][["p_value"]][deciles]
  }
}

colnames(Stats_Insula_t) <- c(ldf[[1]][1],ldf[[2]][1],ldf[[3]][1],ldf[[4]][1],ldf[[5]][1],ldf[[6]][1])
Stats_Insula_t <- as.data.frame(Stats_Insula_t)

colnames(Stats_Insula_d) <- c(ldf[[1]][1],ldf[[2]][1],ldf[[3]][1],ldf[[4]][1],ldf[[5]][1],ldf[[6]][1])
Stats_Insula_d <- as.data.frame(Stats_Insula_d)

colnames(Stats_Insula_p) <- c(ldf[[1]][1],ldf[[2]][1],ldf[[3]][1],ldf[[4]][1],ldf[[5]][1],ldf[[6]][1])
Stats_Insula_p <- as.data.frame(Stats_Insula_p)

# AI pole
AI.pole <- -(as.data.frame(matrix(out_AI_pole[["Group1 - Group2"]][["difference"]])))
AI.pole$CI.lower <- -(matrix(out_AI_pole[["Group1 - Group2"]][["ci_upper"]]))
AI.pole$CI.upper <- -(matrix(out_AI_pole[["Group1 - Group2"]][["ci_lower"]]))
AI.pole$T.value <- Stats_Insula_t$out_AI_pole
AI.pole$Cohens.d <- Stats_Insula_d$out_AI_pole
AI.pole$p.value <- Stats_Insula_p$out_AI_pole
colnames(AI.pole) <- c("Difference","CI lower","CI upper","T","d","p")
AI.pole <- format(AI.pole, digits = 3)
write.csv(AI.pole, file.path(insula.folder, 'AI_pole.csv'))

# AI long
AI.long <- -(as.data.frame(matrix(out_AI_long[["Group1 - Group2"]][["difference"]])))
AI.long$CI.lower <- -(matrix(out_AI_long[["Group1 - Group2"]][["ci_upper"]]))
AI.long$CI.upper <- -(matrix(out_AI_long[["Group1 - Group2"]][["ci_lower"]]))
AI.long$T.value <- Stats_Insula_t$out_AI_long
AI.long$Cohens.d <- Stats_Insula_d$out_AI_long
AI.long$p.value <- Stats_Insula_p$out_AI_long
colnames(AI.long) <- c("Difference","CI lower","CI upper","T","d","p")
AI.long <- format(AI.long, digits = 3)
write.csv(AI.long, file.path(insula.folder, 'AI_long.csv'))


# AI short
AI.short <- -(as.data.frame(matrix(out_AI_short[["Group1 - Group2"]][["difference"]])))
AI.short$CI.lower <- -(matrix(out_AI_short[["Group1 - Group2"]][["ci_upper"]]))
AI.short$CI.upper <- -(matrix(out_AI_short[["Group1 - Group2"]][["ci_lower"]]))
AI.short$T.value <- Stats_Insula_t$out_AI_short
AI.short$Cohens.d <- Stats_Insula_d$out_AI_short
AI.short$p.value <- Stats_Insula_p$out_AI_short
colnames(AI.short) <- c("Difference","CI lower","CI upper","T","d","p")
AI.short <- format(AI.short, digits = 3)
write.csv(AI.short, file.path(insula.folder, 'AI_short.csv'))


# MI short
MI.short <- -(as.data.frame(matrix(out_MI_short[["Group1 - Group2"]][["difference"]])))
MI.short$CI.lower <- -(matrix(out_MI_short[["Group1 - Group2"]][["ci_upper"]]))
MI.short$CI.upper <- -(matrix(out_MI_short[["Group1 - Group2"]][["ci_lower"]]))
MI.short$T.value <- Stats_Insula_t$out_MI_short
MI.short$Cohens.d <- Stats_Insula_d$out_MI_short
MI.short$p.value <- Stats_Insula_p$out_MI_short
colnames(MI.short) <- c("Difference","CI lower","CI upper","T","d","p")
MI.short <- format(MI.short, digits = 3)
write.csv(MI.short, file.path(insula.folder, 'MI_short.csv'))


# PI long
PI.long <- -(as.data.frame(matrix(out_PI_long[["Group1 - Group2"]][["difference"]])))
PI.long$CI.lower <- -(matrix(out_PI_long[["Group1 - Group2"]][["ci_upper"]]))
PI.long$CI.upper <- -(matrix(out_PI_long[["Group1 - Group2"]][["ci_lower"]]))
PI.long$T.value <- Stats_Insula_t$out_PI_long
PI.long$Cohens.d <- Stats_Insula_d$out_PI_long
PI.long$p.value <- Stats_Insula_p$out_PI_long
colnames(PI.long) <- c("Difference","CI lower","CI upper","T","d","p")
PI.long <- format(PI.long, digits = 3)
write.csv(PI.long, file.path(insula.folder, 'PI_long.csv'))


# PI short
PI.short <- -(as.data.frame(matrix(out_PI_short[["Group1 - Group2"]][["difference"]])))
PI.short$CI.lower <- -(matrix(out_PI_short[["Group1 - Group2"]][["ci_upper"]]))
PI.short$CI.upper <- -(matrix(out_PI_short[["Group1 - Group2"]][["ci_lower"]]))
PI.short$T.value <- Stats_Insula_t$out_PI_short
PI.short$Cohens.d <- Stats_Insula_d$out_PI_short
PI.short$p.value <- Stats_Insula_p$out_PI_short
colnames(PI.short) <- c("Difference","CI lower","CI upper","T","d","p")
PI.short <- format(PI.short, digits = 3)
write.csv(PI.short, file.path(insula.folder, 'PI_short.csv'))




## Temporal
filenames <- list.files(temporal.folder, pattern="*.RData", full.names=TRUE)
ldf <- lapply(filenames, load,.GlobalEnv)

Stats_Temporal_t <- matrix(, nrow = 9, ncol = 6)
Stats_Temporal_d <- matrix(, nrow = 9, ncol = 6)
Stats_Temporal_p <- matrix(, nrow = 9, ncol = 6)

for(i in 1:length(ldf)){
  region <- ldf[[i]][1]
  results.table <- eval(as.name(region))
  # run through deciles
  for(deciles in 1:length(results.table$`Group1 - Group2`)){
    # first convert CI to SE
    SE<- (results.table[["Group1 - Group2"]][["ci_upper"]][deciles] - results.table[["Group1 - Group2"]][["ci_lower"]][deciles])/3.92
    # next calculate t value based on group difference and SE
    t <- results.table[["Group1 - Group2"]][["difference"]][deciles]/SE
    # switch sign of t as groups were switched for more intuitive visualization
    t <- -t
    # calculate Cohen's d
    d <- t/(sqrt((417 * 433)/(417 + 433))) # use formula for independent samples with unequal group sizes
    # save output
    Stats_Temporal_t[deciles,i] <- t
    Stats_Temporal_d[deciles,i] <- d
    Stats_Temporal_p[deciles,i] <- results.table[["Group1 - Group2"]][["p_value"]][deciles]
  }
}

colnames(Stats_Temporal_t) <- c(ldf[[1]][1],ldf[[2]][1],ldf[[3]][1],ldf[[4]][1],ldf[[5]][1],ldf[[6]][1])
Stats_Temporal_t <- as.data.frame(Stats_Temporal_t)

colnames(Stats_Temporal_d) <- c(ldf[[1]][1],ldf[[2]][1],ldf[[3]][1],ldf[[4]][1],ldf[[5]][1],ldf[[6]][1])
Stats_Temporal_d <- as.data.frame(Stats_Temporal_d)

colnames(Stats_Temporal_p) <- c(ldf[[1]][1],ldf[[2]][1],ldf[[3]][1],ldf[[4]][1],ldf[[5]][1],ldf[[6]][1])
Stats_Temporal_p <- as.data.frame(Stats_Temporal_p)


# aSTG
aSTG <- -(as.data.frame(matrix(out_aSTG[["Group1 - Group2"]][["difference"]])))
aSTG$CI.lower <- -(matrix(out_aSTG[["Group1 - Group2"]][["ci_upper"]]))
aSTG$CI.upper <- -(matrix(out_aSTG[["Group1 - Group2"]][["ci_lower"]]))
aSTG$T.value <- Stats_Temporal_t$out_aSTG
aSTG$Cohens.d <- Stats_Temporal_d$out_aSTG
aSTG$p.value <- Stats_Temporal_p$out_aSTG
colnames(aSTG) <- c("Difference","CI lower","CI upper","T","d","p")
aSTG <- format(aSTG, digits = 3)
write.csv(aSTG, file.path(temporal.folder, 'aSTG.csv'))

# AT lateral
AT.lateral <- -(as.data.frame(matrix(out_AT_lateral[["Group1 - Group2"]][["difference"]])))
AT.lateral$CI.lower <- -(matrix(out_AT_lateral[["Group1 - Group2"]][["ci_upper"]]))
AT.lateral$CI.upper <- -(matrix(out_AT_lateral[["Group1 - Group2"]][["ci_lower"]]))
AT.lateral$T.value <- Stats_Temporal_t$out_AT_lateral
AT.lateral$Cohens.d <- Stats_Temporal_d$out_AT_lateral
AT.lateral$p.value <- Stats_Temporal_p$out_AT_lateral
colnames(AT.lateral) <- c("Difference","CI lower","CI upper","T","d","p")
AT.lateral <- format(AT.lateral, digits = 3)
write.csv(AT.lateral, file.path(temporal.folder, 'AT_lateral.csv'))


# AT medial
AT.medial <- -(as.data.frame(matrix(out_AT_medial[["Group1 - Group2"]][["difference"]])))
AT.medial$CI.lower <- -(matrix(out_AT_medial[["Group1 - Group2"]][["ci_upper"]]))
AT.medial$CI.upper <- -(matrix(out_AT_medial[["Group1 - Group2"]][["ci_lower"]]))
AT.medial$T.value <- Stats_Temporal_t$out_AT_medial
AT.medial$Cohens.d <- Stats_Temporal_d$out_AT_medial
AT.medial$p.value <- Stats_Temporal_p$out_AT_medial
colnames(AT.medial) <- c("Difference","CI lower","CI upper","T","d","p")
AT.medial <- format(AT.medial, digits = 3)
write.csv(AT.medial, file.path(temporal.folder, 'AT_medial.csv'))


# MIT
MIT <- -(as.data.frame(matrix(out_MIT[["Group1 - Group2"]][["difference"]])))
MIT$CI.lower <- -(matrix(out_MIT[["Group1 - Group2"]][["ci_upper"]]))
MIT$CI.upper <- -(matrix(out_MIT[["Group1 - Group2"]][["ci_lower"]]))
MIT$T.value <- Stats_Temporal_t$out_MIT
MIT$Cohens.d <- Stats_Temporal_d$out_MIT
MIT$p.value <- Stats_Temporal_p$out_MIT
colnames(MIT) <- c("Difference","CI lower","CI upper","T","d","p")
MIT <- format(MIT, digits = 3)
write.csv(MIT, file.path(temporal.folder, 'MIT.csv'))


# PT
PT <- -(as.data.frame(matrix(out_PT[["Group1 - Group2"]][["difference"]])))
PT$CI.lower <- -(matrix(out_PT[["Group1 - Group2"]][["ci_upper"]]))
PT$CI.upper <- -(matrix(out_PT[["Group1 - Group2"]][["ci_lower"]]))
PT$T.value <- Stats_Temporal_t$out_PT
PT$Cohens.d <- Stats_Temporal_d$out_PT
PT$p.value <- Stats_Temporal_p$out_PT
colnames(PT) <- c("Difference","CI lower","CI upper","T","d","p")
PT <- format(PT, digits = 3)
write.csv(PT, file.path(temporal.folder, 'PT.csv'))


# ST middle
ST.middle <- -(as.data.frame(matrix(out_ST_middle[["Group1 - Group2"]][["difference"]])))
ST.middle$CI.lower <- -(matrix(out_ST_middle[["Group1 - Group2"]][["ci_upper"]]))
ST.middle$CI.upper <- -(matrix(out_ST_middle[["Group1 - Group2"]][["ci_lower"]]))
ST.middle$T.value <- Stats_Temporal_t$out_ST_middle
ST.middle$Cohens.d <- Stats_Temporal_d$out_ST_middle
ST.middle$p.value <- Stats_Temporal_p$out_ST_middle
colnames(ST.middle) <- c("Difference","CI lower","CI upper","T","d","p")
ST.middle <- format(ST.middle, digits = 3)
write.csv(ST.middle, file.path(temporal.folder, 'ST_middle.csv'))



