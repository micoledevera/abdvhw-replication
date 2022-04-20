# Robustness checks

## Notes on the codes
* The codes in this folder only compute the different income risk measures across the robustness checks. The codes to plot these results are in "part2_income_risk/main_analysis".
* neural_net:
  * The neural networks were estimated using the R package "H2O".
  * As the code to estimate the neural networks take advantage of parallel computing, we could not set a random seed and so results from running this code would differ slightly across runs.
* unobserved_heterogeneity:
  * To change the number of clusters, change the value of k in line 57 of "cluster_inc_poisson_kchosen_until2018.R" or "cluster_inc_poisson_kchosen_until2018_absdev.R".
