# Replication files for "Income Risk Inequality: Evidence from Spanish Administrative Records" by Arellano, Bonhomme, De Vera, Hospido, and Wei

This repository includes the codes to process the raw social security data and replicate the results in "Income Risk Inequality: Evidence from Spanish Administrative Records". In the first part of the paper, we compute various statistics on income dynamics common across all the countries in the [Global Repository of Income Dynamics (GRID)](https://mebdi.org/global-repository-income-dynamics). In the second part of the paper, we construct individual measures of income risk and document inequality in income risk. 

## Muestra Continua de Vidas Laborales

This paper uses the 2005-2018 versions of the Muestra Continua de Vidas Laborales con Datos Fiscales (MCVL with fiscal data). Due to data security reasons, we cannot share the data files. However, researchers can apply to access the data for scientific purposes. Details for this application process can be found using [this link (in Spanish)](https://www.seg-social.es/wps/portal/wss/internet/EstadisticasPresupuestosEstudios/Estadisticas/EST211).

## Overview of Replication Package

There are three main parts to the replication package:
- mcvl_data_processing
  - do
    - **00_Main.do**: Runs all steps 
    - **01_Past_Info.do**: Combines raw files to get base panels of individuals and firms
    - **02_MergeMCVL_05_12.do** and **02_MergeMCVL_13_latest.do**: Merge various components of MCVL
    - **03_MonthlyVars.do**: Compute some monthly data
    - **04_ReshapeData.do**: Reshape contribution data from wide to long
    - **05_OtherVars.do**: Create additional variables pertaining to the census, job types and contract types
    - **06_01_FixIDs.do**, **06_02_DatosFiscales_Unemp.do**, **06_03_Pensions.do**, and **06_04_Count_Days.do**: Generate variables (correct for firm ID changes, sum total income and unemployment benefits from fiscal data, identify individuals receiving a pension, count days worked)
    - **07_01_Prep_Data_RemoveAllAfter2_NotClustering.do**, …, **07_05_Prep_Data_NoConstraint.do**: Generate the final data sets that are inputs to part1_statistics and part2_income_risk
    - **mainjob_vars.do**: Identify the main job of an individual in the year and create variables pertaining to that main job
    - **mcvl_reading_2005.do**, …, **mcvl_reading_2018.do**: Read in raw data and name variables, called by 00_Main.do
  - raw 
    - **bounds.dta**: Information needed to identify top-coded and bottom-coded data, collected from annual Boletín Oficial del Estado
- part1_statistics
  - **0_Initialize.do**: Define variable names, time span, and vectors used throughout the codes 
  - **1_Gen_Base_Sample.do**: Rename the variables, select basic sample, create new variables, generate and save the dataset master_sample.dta used in the rest of the do files 
  - **2_DescriptiveStats.do**: Generate descriptive statistics 
  - **3_Inequality.do**: Generate statistics for different income measures (e.g., log income, residualized log income, etc.) 
  - **4_Volatility.do**: Generate statistics for different income growth measures 
  - **5_Mobility.do**: Generate statistics for income ranking
  - **6_Insheeting_dataset.do**: Generate CSV files 
  - **7_Paper_Figs.do**: Generate figures 
  - **8_Part1_paper_table.do**: Generate summary statistics tables (F2-F12)
- part2_income_risk
  - main_analysis
    - do
	  - **1_Merge_gdp_unemp.do**: Merge the national and provincial level unemployment rate and gdp with the main dataset
	  - **2_Disposable_income.do**: Generate disposable income
	  - **3_part2_poisson_main.do**: Main file to compute (1) baseline CV measure and (2) CV measure with cluster
	  - **4_part2_all_tab_figs.do**: Produce figures and tables in part 2
	  - **5_bootstrap.do**: Bootstrap baseline model to compute standard errors of the second stage regression (absolute deviation)
	  - CV: folder containing other complementary codes
	- dta
	  - **effective_tax_rate.csv**: Effective tax rates collected from annual editions of Manual Práctico Renta y Patrimonio
	  - **National.dta** and **Province.dta**: National and provincial macroeconomic variables collected from Instituto Nacional de Estadística (INE)
  - robustness_checks
    - neural_net
	  - **01_neuralnet_poisson_modelselect_quantiles_noclust_catcherror.R** and **02_neuralnet_poisson_modelselect_quantiles_noclust_catcherror_absdev.R**: Estimate multiple models for grid search to select hyperparameters of neural net
	  - **03_estimation_fit_NN_modelselect_average.do** and **04_estimation_fit_NN_modelselect_average_absdev.do**: Assess in-sample and out-of-sample performance of different models estimated above
	  - **05_neuralnet_male_poisson_average_incl2018.R**: Estimate neural net model with chosen hyperparameters
	- quantile_measure
	  - **TS_quantile2018.do**: Estimate quantile measures of income risk
	- robust_measure
	  - **robust_adj_lin_TS_male_incl2018_full.R**: Estimate robust measures of income risk
	- unobserved_heterogeneity
	  - **cluster_inc_poisson_kchosen_until2018.R** and **cluster_inc_poisson_kchosen_until2018_absdev.R**: Obtain initial cluster estimates before updating using the full model (chosen number of clusters)
	  - **unobs_het_functions.R**: Support functions for estimating clusters 
  - subjective_expectations
    - **GID_sigma.do**: Compute household-level income risk and plot figures
	- **myplots.do**: Additional functions for plotting
