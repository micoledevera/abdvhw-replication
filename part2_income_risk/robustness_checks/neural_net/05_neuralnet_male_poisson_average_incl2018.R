# ESTIMATE NEURAL NET ON FULL DATA

library("tidyverse") # for data cleaning
library("h2o") # for fitting neural net
library("haven") # for read_dta
library("tictoc") # for timing

rm(list = ls())

# Set working directory
setwd(".../part2_income_risk")

# Set seed
set.seed(1995)

# Import dataset
data <- read_dta("./main_analysis/dta/mcvl_annual_FinalData_pt2_RemoveAllAfter2_NotClustering.dta")
data <- data %>% filter(sex == 1)
sex <- "male"

# Declare data as factor
data_factor <- data.frame(data[, c("fullyear_lag1", "fullyear_lag12", 
                                   "fullyear_lag123", "permanent_main_prev", 
                                   "fulltime_main_prev", "tot_inc_lag_dum", 
                                   "oow_inc_lag_dum", "education")])

for (i in 1:ncol(data_factor)) {
  data_factor[, i] <- as.factor(data_factor[, i])
}

# Scale continuous data
data_cont <- data.frame(data[, c("log_tot_inc_lag", "log_tot_inc_lag_h2", "log_tot_inc_lag_h3",
                                 "log_oow_inc_lag", "age", "age_sq", "days_lag1", 
                                 "gdp_lag1", "gdp_lag2", "gdp_lag3",
                                 "gdppr_lag1", "gdppr_lag2", "gdppr_lag3",
                                 "unemployment_lag1", "unemployment_lag2",
                                 "unemployment_lag3", "unemploymentpr_lag1",
                                 "unemploymentpr_lag2", "unemploymentpr_lag3")])
mean_col <- sapply(data_cont, mean, na.rm = TRUE)
std_col <- sapply(data_cont, sd, na.rm = TRUE)

for (i in 1:ncol(data_cont)) {
  data_cont[, i] <- (data_cont[, i] - mean_col[i]) / std_col[i]
}

# Scale tot_inc
std_inc <- sd(data$tot_inc, na.rm = TRUE)
max_inc <- max(data$tot_inc)

# Combine back data
data <- data.frame(person_id = data$person_id, year = data$year,
                   est_sample = data$est_sample, tot_inc = data$tot_inc / std_inc, 
                   data_cont, data_factor)
rm(data_cont, data_factor)

## REPS
nrep <- 15
max_iter <- 30

## FIXED HYPERPARAMETERS
nepochs <- 10 # epochs
nsample <- -2 # train_samples_per_iteration

nnodes_mean <- 8
nnodes_absdev <- 7

l2_mean <- 0
l2_absdev <- 0

# Save R lines like log file
log_fname <- paste0("./main_analysis/log/logfile_neuralnet_est_mean_k", nnodes_mean, 
                    "_absdev_k", nnodes_absdev, "_incl2018.txt")

sink(log_fname)

# Initialize h2o
h2o.init(nthreads = -1, max_mem_size = "16g")

# Data for estimation
data_est <- data %>% dplyr::select(-c("person_id", "year", "est_sample"))

### ESTIMATE COND_MEAN
# To store results
node_results <- data.frame(person_id = data$person_id, year = data$year)

# Inside loop run NN multiple times
rep_counter <- 1
iter <- 1
while (rep_counter <= nrep & iter <= max_iter) {
  # Estimate mean NN
  message <- paste0("Conditional Mean -- Nodes: ", nnodes_mean, "; Rep: ", rep_counter)
  tic(message)
  tryCatch({
    model_mean <- h2o.deeplearning(y = "tot_inc",
                                   training_frame = as.h2o(data_est),
                                   activation = "Rectifier",
                                   hidden = nnodes_mean,
                                   epochs = nepochs,
                                   train_samples_per_iteration = nsample,
                                   l2 = l2_mean,
                                   standardize = TRUE,
                                   shuffle_training_data = TRUE,
                                   distribution = "poisson")
    
    # Prediction
    data_temp <- data %>% dplyr::select(-c("person_id", "year", "est_sample", "tot_inc"))
    data_temp <- as.h2o(data_temp)
    predict_mean <- h2o.predict(model_mean, newdata = data_temp)
    predict_mean <- as.vector(predict_mean)
    h2o.rm(data_temp)
    h2o.rm(model_mean)
    
    # Save prediction
    predict_mean <- predict_mean * std_inc
    predict_mean <- (predict_mean <= max_inc) * predict_mean + (predict_mean > max_inc) * max_inc # predictions bounded above
    node_results[[paste0('cond_mean_rep', rep_counter)]] <- predict_mean
    rm(predict_mean)
    
    # Update
    rep_counter <- rep_counter + 1
  }, error = function(e){})
  
  
  toc()
  
  iter <- iter + 1
}
rm(data_est)

# Average to get predictions
average_temp <- node_results %>% dplyr::select(starts_with("cond_mean_rep"))
data$cond_mean <- rowMeans(average_temp)
rm(average_temp)

# To save results
save_data <- data %>% dplyr::select(person_id, year, cond_mean)
filename <- paste0("./main_analysis/dta/neuralnet_", sex, "_tot_inc_noclust_mean_k", nnodes_mean, 
                   "_absdev_k", nnodes_absdev, "_incl2018.dta")
write_dta(save_data, filename, version=14)
rm(save_data)

filename <- paste0("./main_analysis/dta/neuralnet_", sex, "_tot_inc_noclust_mean_k", nnodes_mean, "_incl2018.dta")
write_dta(node_results, filename, version = 14)
rm(node_results)

## ESTIMATE COND_ABSDEV
data$absdev <- abs(data$tot_inc * std_inc - data$cond_mean)

std_absdev <- sd(data$absdev, na.rm = TRUE)
data$absdev <- data$absdev / std_absdev

data_est <- data %>% 
  dplyr::select(-c("person_id", "year", "est_sample", "tot_inc", "cond_mean"))

# To store results
node_results <- data.frame(person_id = data$person_id, year = data$year)

# Inside loop run NN multiple times
rep_counter <- 1
iter <- 1
while (rep_counter <= nrep & iter <= max_iter) {
  # Estimate mean NN
  message <- paste0("Conditional Absdev -- Nodes: ", nnodes_absdev, "; Rep: ", rep_counter)
  tic(message)
  tryCatch({
    model_absdev <- h2o.deeplearning(y = "absdev",
                                   training_frame = as.h2o(data_est),
                                   activation = "Rectifier",
                                   hidden = nnodes_absdev,
                                   epochs = nepochs,
                                   train_samples_per_iteration = nsample,
                                   l2 = l2_absdev,
                                   standardize = TRUE,
                                   shuffle_training_data = TRUE,
                                   distribution = "poisson")
    
    # Prediction
    data_temp <- data %>% dplyr::select(-c("person_id", "year", "est_sample", "tot_inc", "cond_mean", "absdev"))
    data_temp <- as.h2o(data_temp)
    predict_absdev <- h2o.predict(model_absdev, newdata = data_temp)
    predict_absdev <- as.vector(predict_absdev)
    h2o.rm(data_temp)
    h2o.rm(model_absdev)
    
    # Save prediction
    predict_absdev <- predict_absdev * std_absdev
    node_results[[paste0('cond_absdev_rep', rep_counter)]] <- predict_absdev
    rm(predict_absdev)
    
    # Update
    rep_counter <- rep_counter + 1
  }, error = function(e){})
  
  
  toc()
  
  iter <- iter + 1
  
}
rm(data_est)

# Average to get predictions
average_temp <- node_results %>% dplyr::select(starts_with("cond_absdev_rep"))
data$cond_absdev <- rowMeans(average_temp)
rm(average_temp)

## CVAR
data$cvar_m <- data$cond_absdev / data$cond_mean

# To save results
save_data <- data %>% dplyr::select(person_id, year, cond_mean, cond_absdev, cvar_m)
filename <- paste0("./main_analysis/dta/neuralnet_", sex, "_tot_inc_noclust_mean_k", nnodes_mean, 
                   "_absdev_k", nnodes_absdev, "_incl2018.dta")
write_dta(save_data, filename, version=14)


filename <- paste0("./main_analysis/dta/neuralnet_", sex, "_tot_inc_noclust_absdev_k", nnodes_absdev, "_incl2018.dta")
write_dta(node_results, filename, version = 14)
rm(node_results)

# Close log file
for(i in seq_len(sink.number())){
  sink(NULL)
}

# Shutdown h2o instance
h2o.shutdown()


