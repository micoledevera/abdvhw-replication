## CHOOSING NUMBER OF CLUSTERS: OBJECTIVE IS INCOME (LIKELIHOOD FORM)

library("tidyverse") # for data cleaning
library("haven") # for read_dta
library("tictoc") # for timing
library("collapse") # for faster group_by (fgroup_by) and mean (fmean)
library("RcppArmadillo")
library("Rfast")
library("MASS") # for multivariate normal

# Set working directory
setwd(".../part2_income_risk")

# Set seed
set.seed(1995)

# Import functions
source('./robustness_checks/unobserved_heterogeneity/unobs_het_functions.R')

# Import dataset
data_raw <- read_dta("./main_analysis/dta/mcvl_annual_FinalData_pt2_RemoveAllAfter2_NotClustering.dta")

# Keep estimation sample
data <- data_raw %>% filter(sex == 1) 
rm(data_raw)

# Define controls
person_id <- c("person_id")
outcome <- c("tot_inc")
controls <- c("age", "age_sq")
clust_formula <- as.formula(paste(outcome, " ~ ", paste(controls, collapse = "+")))

# Reference for coefficients ordering
ref_coef <- c(1, 25, 25^2)

# Way to end filenames related to this run
fname_end <- "_inc_poisson"

# Data for clustering
data_clustering <- data %>% dplyr::select(person_id, outcome, controls)

# Data without the response
data0 <- data_clustering %>% dplyr::select(controls)

# Total number of observations and number of coefficients (incl constant)
totobs <- dim(data_clustering)[1]
ncoefs <- length(controls) + 1

# Get unique person_ids
indivs <- unique(data_clustering[[person_id]])
n_indivs <- length(indivs)

################
## CLUSTERING ##
################
# Possible values for k
k <- 4

# Other parameters
starts <- 20 # Number of starting clusters
tol <- 1e-10 # Tolerance for cluster-wise regression
max_iter <- 1200 # Maximum iterations for cluster-wise regression

# All results
clustering_results <- list()

# Initial Regression to get a good guess of the magnitude of the coefficients
init_reg <- glm(clust_formula, data = data_clustering, family = "poisson")
init_mean_coefs <- init_reg$coefficients
init_var_coefs <- diag(as.vector(1000 * (summary(init_reg)$coefficients[, 2])^2))
init_conds <- list(init_mean_coefs = init_mean_coefs, init_var_coefs = init_var_coefs)

# Save R lines like log file
log_fname <- paste0("./main_analysis/log/unobserved_heterogeneity_2018_logfile_k", k, fname_end, ".txt")
sink(log_fname)

# Compute over different starting points
for (j in 1:starts) {
  tic()
  # Draw initial cluster
  init_clust <- draw_init_clus_pois(k, init_conds, data0, 
                                   data_clustering, indivs, outcome, person_id)
  c <- init_clust$init_c
  prev_ave_sre <- init_clust$ave_sre
  
  # Do updating
  iter_counter <- 1
  stopping_crit <- 1
  while (abs(stopping_crit) > tol && iter_counter <= max_iter) {
    # Display update
    if (iter_counter %% 5 == 0) {
      message <- paste0("No Clust: ", k, "; Initial: ", j, "; Iteration: ", iter_counter, "; Change: ", stopping_crit)
      print(message)
    }
    
    # Cluster-wise regressions and update 
    update_j <- update_clust_pois(c, k, clust_formula, data_clustering, person_id, outcome, controls)
    
    # Prepare for next iteration
    c <- update_j$c
    stopping_crit <- (update_j$ave_sre - prev_ave_sre) / abs(prev_ave_sre)
    prev_ave_sre <- update_j$ave_sre
    iter_counter <- iter_counter + 1
  }
  
  # Relabel clusters
  c <- relabel_clusters_pois(c, data_clustering, clust_formula, ref_coef, person_id, outcome, controls)
  
  # Save Results
  clustering_results[[j]] <- list(cluster = c, final_sre = prev_ave_sre)
  
  # Done message
  message <- paste0("DONE: ", j, "; k: ", k, "; Iteration: ", iter_counter, "; Change: ", stopping_crit)
  print(message)
  
  toc()
  
}

# Close log file
for(i in seq_len(sink.number())){
  sink(NULL)
}

# Save clustering_results_k
filename <- paste0("./main_analysis/out/clustering_results_k", k, fname_end, "_until2018.rds")
saveRDS(clustering_results, filename)

# Get best cluster
final_sre <- c()
for (i in 1:starts) {
  final_sre[i] <- clustering_results[[i]]$final_sre
}

best <- nth(final_sre, 1, descending = FALSE, index.return = TRUE)
best_cluster <- clustering_results[[best]]$cluster

second_best <- nth(final_sre, 2, descending = FALSE, index.return = TRUE)
secondbest_cluster <- clustering_results[[second_best]]$cluster

# Get fits
best_fit <- list()
for (i in 1:length(best_cluster)) {
  data_k <- data_clustering[which(data_clustering[[person_id]] %in% best_cluster[[i]]), ]
  best_fit_coefs_aux <- glm(clust_formula, data = data_k, family = "poisson")

  best_fit[[i]] <- list(coefs = best_fit_coefs_aux)
}

# Compare coefficients
best_fit_coefs <- matrix(rep(0, (ncoefs+1) * length(best_cluster)), nrow = length(best_cluster))
for (i in 1:length(best_cluster)) {
  best_fit_coefs[i, 1:ncoefs] <- best_fit[[i]]$coefs$coefficients
}

# Compare the two clusters
compare_1_2 <- rand_ind(best_cluster, secondbest_cluster)

# Correlation of clustering to education
educ <- data %>% dplyr::select(c(person_id, education)) %>% unique()
educ_levels <- sort(unique(educ$education))

cluster_educ <- matrix(rep(0, length(best_cluster)*length(educ_levels)), nrow = length(best_cluster))

for (i in 1:length(educ_levels)) {
  data_temp <- educ %>% filter(education == educ_levels[i])
  for (j in 1:length(best_cluster)) {
    cluster_educ[j, i] <- length(intersect(best_cluster[[j]], data_temp$person_id))
  }
}

# Save Summary
summary_cluster_k <- list(best_cluster = best_cluster,
                          best_fit_coefs = best_fit_coefs,
                          compare_1_2 = compare_1_2,
                          cluster_educ = cluster_educ)
filename <- paste0("./main_analysis/out/clustering_summary_k", k, fname_end, "_until2018.rds")
saveRDS(summary_cluster_k, filename)

# Save Clusters
result_k <- list(k = k, c = best_cluster, final_sre = clustering_results[[best]]$final_sre)

# Export clusters
aux <- cbind(best_cluster[[1]], rep(1, length(best_cluster[[1]])))

for (i in 2:k) {
  aux_1 <- cbind(best_cluster[[i]], rep(i, length(best_cluster[[i]])))
  aux <- rbind(aux, aux_1)
}

aux <- data.frame(aux)
colnames(aux) <- c("person_id", "cluster")

filename <- paste0("./main_analysis/dta/clustering_k", k, fname_end, "_until2018.dta")
write_dta(aux, filename, version=14)










