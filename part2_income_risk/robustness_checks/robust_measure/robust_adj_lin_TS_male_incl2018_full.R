library("tidyverse") # for data cleaning
library("h2o") # for fitting neural net
library("haven") # for read_dta
library("tictoc") # for timing
library("quantreg") # for quantile regressions

rm(list = ls())

# Set working directory
setwd(".../part2_income_risk")

# Save filename
filename <- paste0("./main_analysis/dta/robust_adj_lin_TS_male_incl2018.dta")

# Set seed
set.seed(1995)

# Import dataset
data <- read_dta("./main_analysis/dta/mcvl_annual_FinalData_pt2_RemoveAllAfter2_NotClustering.dta")

# Clean and filter
data <- data %>% 
  filter(sex == 1) %>% 
  dplyr::select(person_id, tot_inc, year, education, log_tot_inc_lag, 
                log_tot_inc_lag_h2, log_tot_inc_lag_h3, tot_inc_lag_dum, oow_inc_lag_dum,
                log_oow_inc_lag, age, age_sq, days_lag1, fullyear_lag1, fullyear_lag12,
                fullyear_lag123, permanent_main_prev, fulltime_main_prev,
                gdp_lag1, gdp_lag2, gdp_lag3,
                gdppr_lag1, gdppr_lag2, gdppr_lag3,
                unemployment_lag1, unemployment_lag2, unemployment_lag3,
                unemploymentpr_lag1, unemploymentpr_lag2, unemploymentpr_lag3,
                est_sample) %>%
  mutate(zero_tot_inc = (tot_inc == 0))

# Declare as factor variables
data$year <- as.factor(data$year)
data$education <- as.factor(data$education)
data$fullyear_lag1 <- as.factor(data$fullyear_lag1)
data$fullyear_lag12 <- as.factor(data$fullyear_lag12)
data$fullyear_lag123 <- as.factor(data$fullyear_lag123)
data$permanent_main_prev <- as.factor(data$permanent_main_prev)
data$fulltime_main_prev <- as.factor(data$fulltime_main_prev)
data$tot_inc_lag_dum <- as.factor(data$tot_inc_lag_dum)
data$oow_inc_lag_dum <- as.factor(data$oow_inc_lag_dum)
data$zero_tot_inc <- as.factor(data$zero_tot_inc)

# Generate contrasts for factor variables
contrasts_list <- list()
contrasts_list[["education"]] <- contrasts(data$education)
contrasts_list[["fullyear_lag1"]] <- contrasts(data$fullyear_lag1)
contrasts_list[["fullyear_lag12"]] <- contrasts(data$fullyear_lag12)
contrasts_list[["fullyear_lag123"]] <- contrasts(data$fullyear_lag123)
contrasts_list[["permanent_main_prev"]] <- contrasts(data$permanent_main_prev)
contrasts_list[["fulltime_main_prev"]] <- contrasts(data$fulltime_main_prev)
contrasts_list[["tot_inc_lag_dum"]] <- contrasts(data$tot_inc_lag_dum)
contrasts_list[["oow_inc_lag_dum"]] <- contrasts(data$oow_inc_lag_dum)

# Define grid of tau's for quantile regressions
Ntau <- 11
Vectau <- seq(from = 1/(Ntau+1), to = Ntau/(Ntau+1), length.out = Ntau)

#######################
#### MEDIAN INCOME ####
#######################
# Estimate logit on zero_tot_inc
logit_inc <- glm(zero_tot_inc ~ (log_tot_inc_lag + log_tot_inc_lag_h2 + log_tot_inc_lag_h3 + tot_inc_lag_dum + 
                                   log_oow_inc_lag + oow_inc_lag_dum + education + days_lag1 + 
                                   fullyear_lag1 + fullyear_lag12 + fullyear_lag123 + 
                                   permanent_main_prev + fulltime_main_prev) * (age + age_sq) +
                   (gdp_lag1 + gdp_lag2 + gdp_lag3 +
                      gdppr_lag1 + gdppr_lag2 + gdppr_lag3 +
                      unemployment_lag1 + unemployment_lag2 + unemployment_lag3 +
                      unemploymentpr_lag1 + unemploymentpr_lag2 + unemploymentpr_lag3) * age,
                 data = data,
                 family = binomial)

rm(data_est)

# Predict probabilities
data$prob_zeroinc <- predict(logit_inc, data, type = "response")
rm(logit_inc)

# Get adjusted quantiles based on median
data$adj_tau <- (0.5 <= data$prob_zeroinc) * 99 +
  (0.5 > data$prob_zeroinc) * (0.5 - data$prob_zeroinc) / (1 - data$prob_zeroinc)

# Estimation sample for quantile regressions
data_est <- data %>% 
  filter(tot_inc > 0) %>% 
  mutate(log_totinc = log(tot_inc))

# Matrix to store quantile predictions
q_preds <- data.frame(matrix(rep(0, nrow(data) * Ntau), ncol = Ntau))
names(q_preds) <- paste0("p", 1:Ntau)

# Quantile regressions
for (tau_ind in 1:Ntau) {
  # Print
  message <- paste0("QR for tau = ", tau_ind)
  
  # QR
  tic(message)
  q_reg <- rq(log_totinc ~ (log_tot_inc_lag + log_tot_inc_lag_h2 + log_tot_inc_lag_h3 + tot_inc_lag_dum + 
                              log_oow_inc_lag + oow_inc_lag_dum + education + days_lag1 + 
                              fullyear_lag1 + fullyear_lag12 + fullyear_lag123 + 
                              permanent_main_prev + fulltime_main_prev) * (age + age_sq) +
                (gdp_lag1 + gdp_lag2 + gdp_lag3 +
                   gdppr_lag1 + gdppr_lag2 + gdppr_lag3 +
                   unemployment_lag1 + unemployment_lag2 + unemployment_lag3 +
                   unemploymentpr_lag1 + unemploymentpr_lag2 + unemploymentpr_lag3) * age, 
              tau = Vectau[tau_ind], data = data_est,
              contrasts = contrasts_list, method = "sfn", control = list(tmpmax = 10e6))
  
  # Predict
  q_preds[ , tau_ind] <- predict.rq(q_reg, newdata = data)
  rm(q_reg)
  toc()
}

rm(data_est)

# Compute Laplace Tails
data_est <- data %>% 
  cbind(q_preds) %>% 
  filter(tot_inc > 0) %>% 
  mutate(log_totinc = log(tot_inc))

temp_Vect <- data_est$log_totinc - data_est$p1
b1_loginc <- -sum(temp_Vect <= 0) / sum(temp_Vect * (temp_Vect <= 0))
rm(temp_Vect)

temp_Vect <- data_est$log_totinc - data_est$p11
bL_loginc <- sum(temp_Vect >= 0) / sum(temp_Vect * (temp_Vect >= 0))
rm(temp_Vect)

rm(data_est)

# Save temp
to_save <- cbind(data, q_preds)
write_dta(to_save, filename, version = 14)
rm(to_save)

# Predict p50
data$p50_inc <- 0
data$p50_inc <- q_preds[, 1] * (data$adj_tau <= Vectau[1])
for (jtau in 2:Ntau) {
  data$p50_inc <- data$p50_inc + 
    (q_preds[, jtau-1] + (data$adj_tau - Vectau[jtau-1]) * (q_preds[, jtau] - q_preds[, jtau-1]) / (Vectau[jtau] - Vectau[jtau-1])) *
    (data$adj_tau > Vectau[jtau-1]) * (data$adj_tau <= Vectau[jtau])
}
data$p50_inc <- data$p50_inc + q_preds[, Ntau] * (data$adj_tau > Vectau[Ntau]) * (data$adj_tau < 99)

data$p50_inc <- data$p50_inc +
  ((1 / b1_loginc) * log(data$adj_tau / Vectau[1])) * (data$adj_tau <= Vectau[1]) -
  ifelse((data$adj_tau < 99), ((1 / bL_loginc) * log((1 - data$adj_tau) / (1 - Vectau[Ntau]))) * (data$adj_tau > Vectau[Ntau]), 0) 

# Save temp
write_dta(data, filename, version = 14)

#######################
#### MEDIAN ABSDEV ####
#######################
# Compute absolute deviations wrt median
data$p50_inc <- ifelse((data$p50_inc > 0), exp(data$p50_inc), 0)
data$absdev <- abs(data$tot_inc - data$p50_inc)

data$zero_absdev <- (data$absdev == 0)

# Estimate logit on zero_tot_inc
logit_absdev <- glm(zero_absdev ~ (log_tot_inc_lag + log_tot_inc_lag_h2 + log_tot_inc_lag_h3 + tot_inc_lag_dum + 
                                     log_oow_inc_lag + oow_inc_lag_dum + education + days_lag1 + 
                                     fullyear_lag1 + fullyear_lag12 + fullyear_lag123 + 
                                     permanent_main_prev + fulltime_main_prev) * (age + age_sq) +
                      (gdp_lag1 + gdp_lag2 + gdp_lag3 +
                         gdppr_lag1 + gdppr_lag2 + gdppr_lag3 +
                         unemployment_lag1 + unemployment_lag2 + unemployment_lag3 +
                         unemploymentpr_lag1 + unemploymentpr_lag2 + unemploymentpr_lag3) * age,
                    data = data,
                    family = binomial)

rm(data_est)

# Predict probabilities
data$prob_zeroabsdev <- predict(logit_absdev, data, type = "response")
rm(logit_absdev)

# Get adjusted quantiles based on median
data$adj_tau_absdev <- (0.5 <= data$prob_zeroabsdev) * 99 +
  (0.5 > data$prob_zeroabsdev) * (0.5 - data$prob_zeroabsdev) / (1 - data$prob_zeroabsdev)

# Estimation sample for quantile regressions
data_est <- data %>%
  filter(absdev > 0) %>% filter(absdev != Inf) %>% 
  mutate(log_absdev = log(absdev))

# Matrix to store quantile predictions
q_preds <- data.frame(matrix(rep(0, nrow(data) * Ntau), ncol = Ntau))
names(q_preds) <- paste0("p", 1:Ntau)

# Quantile regressions
for (tau_ind in 1:Ntau) {
  # Print
  message <- paste0("QR for tau = ", tau_ind)
  
  # QR
  tic(message)
  q_reg <- rq(log_absdev ~ (log_tot_inc_lag + log_tot_inc_lag_h2 + log_tot_inc_lag_h3 + tot_inc_lag_dum + 
                              log_oow_inc_lag + oow_inc_lag_dum + education + days_lag1 + 
                              fullyear_lag1 + fullyear_lag12 + fullyear_lag123 + 
                              permanent_main_prev + fulltime_main_prev) * (age + age_sq) +
                (gdp_lag1 + gdp_lag2 + gdp_lag3 +
                   gdppr_lag1 + gdppr_lag2 + gdppr_lag3 +
                   unemployment_lag1 + unemployment_lag2 + unemployment_lag3 +
                   unemploymentpr_lag1 + unemploymentpr_lag2 + unemploymentpr_lag3) * age, 
              tau = Vectau[tau_ind], data = data_est,
              contrasts = contrasts_list, method = "sfn", control = list(tmpmax = 10e6))
  
  # Predict
  q_preds[ , tau_ind] <- predict.rq(q_reg, newdata = data)
  rm(q_reg)
  toc()
  
}

rm(data_est)

# Compute Laplace Tails
data_est <- data %>% 
  cbind(q_preds) %>% 
  filter(absdev > 0) %>%  filter(absdev != Inf) %>% 
  mutate(log_absdev = log(absdev))

temp_Vect <- data_est$log_absdev - data_est$p1
b1_logabsdev <- -sum(temp_Vect <= 0) / sum(temp_Vect * (temp_Vect <= 0))
rm(temp_Vect)

temp_Vect <- data_est$log_absdev - data_est$p11
bL_logabsdev <- sum(temp_Vect >= 0) / sum(temp_Vect * (temp_Vect >= 0))
rm(temp_Vect)

rm(data_est)

# Save temp
to_save <- cbind(data, q_preds)
write_dta(to_save, filename, version = 14)
rm(to_save)

# Predict p50
data$p50_absdev <- 0
data$p50_absdev <- q_preds[, 1] * (data$adj_tau_absdev <= Vectau[1])
for (jtau in 2:Ntau) {
  data$p50_absdev <- data$p50_absdev + 
    (q_preds[, jtau-1] + (data$adj_tau_absdev - Vectau[jtau-1]) * (q_preds[, jtau] - q_preds[, jtau-1]) / (Vectau[jtau] - Vectau[jtau-1])) *
    (data$adj_tau_absdev > Vectau[jtau-1]) * (data$adj_tau_absdev <= Vectau[jtau])
}
data$p50_absdev <- data$p50_absdev + q_preds[, Ntau] * (data$adj_tau_absdev > Vectau[Ntau]) * (data$adj_tau_absdev < 99)

if (!is.nan(b1_logabsdev)) {
  data$p50_absdev <- data$p50_absdev +
    ((1 / b1_logabsdev) * log(data$adj_tau_absdev / Vectau[1])) * (data$adj_tau_absdev <= Vectau[1]) 
}

if (!is.nan(bL_logabsdev)) {
  data$p50_absdev <- data$p50_absdev -
    ifelse((data$adj_tau_absdev < 99), ((1 / bL_logabsdev) * log((1 - data$adj_tau_absdev) / (1 - Vectau[Ntau]))) * (data$adj_tau_absdev > Vectau[Ntau]), 0) 
}

# Compute robust cvar measure
data$p50_absdev <- ifelse((data$p50_absdev > 0), exp(data$p50_absdev), 0)
data$cvar_m <- data$p50_absdev / data$p50_inc

# Save temp
write_dta(data, filename, version = 14)

