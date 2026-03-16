#!/usr/bin/env Rscript

# Analyze ROI condition values extracted from first-level con images
# Expected input: roi_condition_values_long.csv
# Tests per ROI:
# 1) HC vs MDD (group main effect)
# 2) group x target emotion
# 3) group x primer emotion
# 4) group x congruency

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(lme4)
  library(lmerTest)
})

# ----------------------------- Paths ---------------------------------------
input_csv  <- "scripts/mri/ROI/results/roi_condition_values_long.csv"
out_dir    <- "scripts/mri/ROI/results"

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

if (!file.exists(input_csv)) {
  stop(paste0("Input file not found: ", input_csv,
              "\nRun extract_roi_condition_values_for_r.m first or adjust input_csv path."))
}

# ----------------------------- Load ----------------------------------------
df <- read_csv(input_csv, show_col_types = FALSE) %>%
  mutate(
    subject = factor(subject),
    group = factor(group, levels = c("HC", "MDD")),
    roi = factor(roi),
    hemisphere = factor(hemisphere),
    primer = factor(primer, levels = c("happy", "sad")),
    target = factor(target, levels = c("happy", "sad")),
    congruency = factor(congruency, levels = c("congruent", "incongruent")),
    mean_contrast = as.numeric(mean_contrast)
  ) %>%
  filter(!is.na(mean_contrast))

# ------------------- Per-ROI model (group * primer * target) --------------
get_type3_row <- function(model, effect_name, roi_name, model_name) {
  a <- suppressWarnings(anova(model, type = 3))
  rn <- rownames(a)
  idx <- which(rn == effect_name)

  if (length(idx) == 0) {
    return(tibble(
      roi = roi_name,
      model = model_name,
      effect = effect_name,
      sum_sq = NA_real_,
      mean_sq = NA_real_,
      numdf = NA_real_,
      dendf = NA_real_,
      f_value = NA_real_,
      p_value = NA_real_
    ))
  }

  tibble(
    roi = roi_name,
    model = model_name,
    effect = effect_name,
    sum_sq = as.numeric(a[idx, "Sum Sq"]),
    mean_sq = as.numeric(a[idx, "Mean Sq"]),
    numdf = as.numeric(a[idx, "NumDF"]),
    dendf = as.numeric(a[idx, "DenDF"]),
    f_value = as.numeric(a[idx, "F value"]),
    p_value = as.numeric(a[idx, "Pr(>F)"])
  )
}

results_primary <- list()
results_congruency <- list()

for (roi_i in levels(df$roi)) {
  dat_roi <- df %>% filter(roi == roi_i)

  # Main model for group, group:target, group:primer
  m_primary <- lmer(mean_contrast ~ group * primer * target + (1 | subject),
                    data = dat_roi, REML = TRUE)

  results_primary[[length(results_primary) + 1]] <- bind_rows(
    get_type3_row(m_primary, "group", roi_i, "group*primer*target"),
    get_type3_row(m_primary, "group:target", roi_i, "group*primer*target"),
    get_type3_row(m_primary, "group:primer", roi_i, "group*primer*target")
  )

  # Congruency model for group difference in congruent vs incongruent
  dat_cong <- dat_roi %>%
    group_by(subject, group, roi, congruency) %>%
    summarise(mean_contrast = mean(mean_contrast, na.rm = TRUE), .groups = "drop")

  m_cong <- lmer(mean_contrast ~ group * congruency + (1 | subject),
                 data = dat_cong, REML = TRUE)

  results_congruency[[length(results_congruency) + 1]] <-
    get_type3_row(m_cong, "group:congruency", roi_i, "group*congruency")
}

primary_tbl <- bind_rows(results_primary) %>%
  mutate(p_fdr_within_effect = p.adjust(p_value, method = "fdr"))

congruency_tbl <- bind_rows(results_congruency) %>%
  mutate(p_fdr_within_effect = p.adjust(p_value, method = "fdr"))

all_tbl <- bind_rows(primary_tbl, congruency_tbl) %>%
  mutate(
    across(ends_with("value"), ~ round(., 6)),
    across(c(sum_sq, mean_sq, numdf, dendf, f_value, p_value, p_fdr_within_effect), ~ round(., 6))
  )

# --------------------------- Save outputs ----------------------------------
write_csv(primary_tbl, file.path(out_dir, "roi_primary_effects_type3.csv"))
write_csv(congruency_tbl, file.path(out_dir, "roi_group_by_congruency_type3.csv"))
write_csv(all_tbl, file.path(out_dir, "roi_all_requested_effects_type3.csv"))

cat("Saved:\n")
cat("-", file.path(out_dir, "roi_primary_effects_type3.csv"), "\n")
cat("-", file.path(out_dir, "roi_group_by_congruency_type3.csv"), "\n")
cat("-", file.path(out_dir, "roi_all_requested_effects_type3.csv"), "\n")
