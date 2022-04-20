# MODEL SELECTION FOR NEURAL NETWORK (ABSDEV)

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
data <- read_dta("./main_analysis/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018.dta")
data <- data %>% filter(sex == 1 & year != 2018) %>% mutate(absdev = abs(tot_inc - cond_mean))
sex <- "male"

# Create folders for results
res_foldername <- format(Sys.Date(), format = "%Y%m%d")
res_foldername <- paste0("./main_analysis/out/model_select_", res_foldername, 
                         "_quantile_noclust_loglaginc_absdev")
dir.create(res_foldername)

# Declare data as factor
data_factor <- data.frame(data[, c("fullyear_lag1", "fullyear_lag12", 
                                   "fullyear_lag123", "permanent_main_prev", 
                                   "fulltime_main_prev", "tot_inc_lag_dum", "oow_inc_lag_dum", "education")])

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
std_absdev <- sd(data$absdev, na.rm = TRUE)

# Combine back data
data <- data.frame(person_id = data$person_id, year = data$year,
                   est_sample = data$est_sample, absdev = data$absdev / std_absdev, 
                   data_cont, data_factor)
rm(data_cont, data_factor)

## REPS
nrep <- 15
max_iter <- 30

## FIXED HYPERPARAMETERS
nepochs <- 10 # epochs
nsample <- -2 # train_samples_per_iteration

## HYPERPARAMETERS FOR SELECTION
nnodes <- 5:19
l2_pen <- c(0)

# Save R lines like log file
log_fname <- paste0("./main_analysis/out/logfile_modelsel_NN_poisson_", sex, "_quantile_noclust_log.txt")

sink(log_fname)

# Initialize h2o
h2o.init(nthreads = -1, max_mem_size = "16g")

# Data for estimation
data_est <- data %>% filter(year != 2017) %>% 
  select(-c("person_id", "year", "est_sample"))

# Big loop over number of nodes and l2-penalization parameters
spec_counter <- 5
for (n in nnodes) {
  # Number of nodes
  hidden_mean <- c(n)
  
  for (p in l2_pen) {
    # L2-penalization
    l2_val <- p
    
    # To store results
    node_results <- data.frame(person_id = data$person_id, year = data$year)
    
    # Inside loop run NN multiple times
    rep_counter <- 1
    iter <- 1
    while (rep_counter <= nrep & iter <= max_iter) {
      # Estimate mean NN
      message <- paste0("Conditional Absdev -- Nodes: ", n, "; Rep: ", rep_counter)
      tic(message)
      tryCatch({
        model_MAD <- h2o.deeplearning(y = "absdev",
                                       training_frame = as.h2o(data_est),
                                       activation = "Rectifier",
                                       hidden = hidden_mean,
                                       epochs = nepochs,
                                       train_samples_per_iteration = nsample,
                                       l2 = l2_val,
                                       standardize = TRUE,
                                       shuffle_training_data = TRUE,
                                       distribution = "poisson")
        
        # Prediction
        data_temp <- data %>% select(-c("person_id", "year", "est_sample", "absdev"))
        data_temp <- as.h2o(data_temp)
        predict_MAD <- h2o.predict(model_MAD, newdata = data_temp)
        predict_MAD <- as.vector(predict_MAD)
        h2o.rm(data_temp)
        h2o.rm(model_MAD)
        
        # Save prediction
        predict_MAD <- predict_MAD * std_absdev
        node_results[[paste0('cond_absdev_rep', rep_counter)]] <- predict_MAD
        rm(predict_MAD)
        
        # Update
        rep_counter <- rep_counter + 1
      }, error = function(e){})
      
      
      toc()
      
      iter <- iter + 1
    }
    
    # To save results
    filename <- paste0(res_foldername, "/neuralnet_", sex, "_modelsel_poisson_spec", 
                       spec_counter, "_noclust_absdev.dta")
    write_dta(node_results, filename, version=14)
    rm(node_results)
    
    # Prep for next
    spec_counter <- spec_counter + 1
    
  }
}

# Close log file
for(i in seq_len(sink.number())){
  sink(NULL)
}

# Shutdown h2o instance
h2o.shutdown()


