###############################################
## FUNCTIONS FOR UNOBSERVED HETEROGENEITY V2 ##
###############################################

################################################################
# Draw Initial Coefficients to Initialize Clustering Algorithm #
################################################################

## POISSON

draw_init_clus_pois_nocheck <- function(k, init_conds, data0, data_clustering, indivs, outcome, person_id) {
  # Initial coefficient estimates
  init_coefs <- mvrnorm(k, mu = init_conds$init_mean_coefs, Sigma = init_conds$init_var_coefs)

  # Get initial clustering
  # 1. Compute Poisson Obj based on initial clustering
  init_sre <- matrix(data = NA, totobs, k)
  for (i in 1:k) {
    init_sre[, i] <- as.matrix(cbind(rep(1, totobs), data0)) %*% as.vector(init_coefs[i, ])
    init_sre[, i] <- data_clustering[[outcome]] * init_sre[, i] - exp(init_sre[, i])
  }
  
  # 2. Get initial clusters
  init_sre_indiv <- data.frame(person_id = data_clustering[[person_id]], init_sre)
  init_sre_indiv <- init_sre_indiv %>% fgroup_by(person_id) %>% fsum
  init_clusters <- max.col(init_sre_indiv[, 2:(k+1)])
  
  init_c <- list()
  for (i in 1:k) {
    init_c[[i]] <- indivs[which(init_clusters == i)]
  }
  
  # Average log-likelihood
  boundindices <- cbind(1:length(indivs), init_clusters+1)
  ave_sre <- sum(data.matrix(init_sre_indiv)[boundindices])
  
  # Count number of non-empty clusters
  init_clus_sum <- table(init_clusters) # to check if all in one cluster
  n_init_clus <- dim(init_clus_sum)[1]
  
  # Out
  out <- list(init_c = init_c, n_init_clus = n_init_clus, ave_sre = ave_sre)
  return(out)
}


draw_init_clus_pois <- function(k, init_conds, data0, data_clustering, indivs, outcome, person_id) {
  # Make sure that no cluster is empty
  check <- 0
  while (check == 0) {
    init_clus <- draw_init_clus_pois_nocheck(k, init_conds, data0, 
                                            data_clustering, indivs, outcome, person_id)
    if (init_clus$n_init_clus == k) {
      check <- 1
    }
  }
  
  # Return
  return(init_clus)
}

###########################################
## RUN ONE ITERATION OF UPDATING CLUSTER ##
###########################################

## POISSON

update_clust_pois <- function(c, k, clust_formula, data_clustering, person_id, outcome, controls) {
  # Initialize objects
  clustering_results <- list()
  fit <- list()
  pred <- matrix(data = NA, nrow(data_clustering), k)
  sre <- matrix(data = NA, nrow(data_clustering), k)
  
  # Cluster-specific regression
  for (i in 1:k) {
    data_k <- data_clustering[which(data_clustering[[person_id]] %in% c[[i]]), ]
    fit[[i]] <- glm(clust_formula, data = data_k, family = "poisson")
  }
  
  # Calculating SRE for all observations
  for(i in 1:k) {
    pred[, i] <- as.matrix(cbind(rep(1, totobs), data0)) %*% as.vector(fit[[i]]$coefficients)
    pred[, i] <- exp(pred[, i])
    sre[, i] <- data_clustering[[outcome]] * log(pred[, i]) - pred[, i]
  }
  
  # Calculating average squared residual errors for each individual
  sre_indiv <- data.frame(person_id = data_clustering[[person_id]], sre)
  sre_indiv <- sre_indiv %>% group_by(person_id) %>% summarise_all(sum)
  
  # Reclassify individuals
  new_clus <- max.col(sre_indiv[,2:(k+1)])
  boundindices <- cbind(1:n_indivs, new_clus+1)
  ave_sre <-  sum(data.matrix(sre_indiv)[boundindices])
  
  for (i in 1:k) {
    c[[i]] <- indivs[which(new_clus == i)]
  }
  
  # Out
  out <- list(c = c, ave_sre = ave_sre)
  return(out)
}


#####################################################
# Relabeling the Partition based on the predictions #
#####################################################

relabel_clusters_pois <- function(c, data_clustering, clust_formula, ref_coef, person_id, outcome, controls) {
  # Store the value of outcome at the ref_age
  ref_age_vals <- rep(NA, length(c))
  
  # Cluster-wise regression and get the value at ref_age
  for (k in 1:length(c)) {
    # Get data
    data_k <- data_clustering[which(data_clustering[[person_id]] %in% c[[k]]), ]
    
    # Regression
    reg_k <- glm(clust_formula, data = data_k, family = "poisson")
    
    # Value at reference age
    ref_age_vals[k] <- exp(reg_k$coefficients %*% ref_coef)
  }
  
  # Get the relabeling
  c_new <- list()
  for (k in 1:length(c)) {
    # Get index of nth best
    index_n <- Rfast::nth(ref_age_vals, k, descending = TRUE, index.return = TRUE)
    
    # Assign new cluster
    c_new[[k]] <- c[[index_n]]
  }
  
  # Return new cluster
  return(c_new)
}

######################################################################
# Comparing Partitions (Corrected Rand Index based on Hubert (1985)) #
######################################################################
rand_ind <- function(cluster_1, cluster_2) {
  # Input: 2 lists of partitions
  # Number of partitions
  n_part_1 <- length(cluster_1)
  n_part_2 <- length(cluster_2)
  
  # Initialize contingency matrix
  contingency <- matrix(rep(0,n_part_1*n_part_2), nrow = n_part_1)
  
  # Fill in contingency matrix
  n <- 0
  for (ind_1 in 1:n_part_1) {
    n <- n + length(cluster_1[[ind_1]])
    for (ind_2 in 1:n_part_2) {
      contingency[ind_1, ind_2] <- length(intersect(cluster_1[[ind_1]], cluster_2[[ind_2]]))
    }
  }
  
  # Get row and column sums of contingency matrix
  cont_row <- apply(contingency, 1, sum)
  cont_col <- apply(contingency, 2, sum)
  
  # Compute Rand index
  num <- sum(choose(contingency, 2)) - sum(choose(cont_row, 2)) * sum(choose(cont_col, 2)) / choose(n, 2)
  den <- 0.5 * (sum(choose(cont_row, 2)) + sum(choose(cont_col, 2))) - sum(choose(cont_row, 2)) * sum(choose(cont_col, 2)) / choose(n, 2)
  r_ind <- num/den
  
  # Return objects
  returnObject <- list(contingency, r_ind)
  names(returnObject) <- c("contingency", "r_ind")
  return(returnObject)
  #return(r_ind)
}
