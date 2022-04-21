# Codes for the main analysis of the inequality of income risk

## Recommended folder structure
The code was written with the following folder structure in mind:
* do
* dta
* figs
* log
* out

## Details on codes

### 1_Merge_gdp_unemp.do
Merge the national and provincial level unemployment rate and gdp with the main dataset 
Input: mcvl_annual_FinalData_pt2_*  
Output: mcvl_annual_FinalData_pt2_gdp_unemp_*

### 2_Disposable_income.do
Generate disposable income 
Input: mcvl_annual_FinalData_pt2_gdp_unemp_*
Output: mcvl_annual_FinalData_pt2_gdp_unemp_*

### 3_part2_poisson_main.do
Main file to compute 1) Baseline CV measure 2) CV measure with cluster 

~\CV\Part2_analysis_moment_TS_poisson2018.do: Using all sample, exponential specification, produce baseline CV results in the paper 
~\CV\Part2_analysis_moment_TS_poisson2018_bootstrap: bootstrap to compute the std for the 2nd step— absdev 

~\CV\Part2_analysis_moment_TS_poisson2018_alt2nd.do: Using all sample, exponential specification, but in 2nd step, instead of estimating absolute deviation, estimate CV (absolute deviation divided by predicted conditional mean)

~\CV\Part2_analysis_moment_TS_poisson.do: Using sample up to year 2017, exponential specification, check prediction performance (results for Table 1)
~\CV\Part2_analysis_moment_inconly_poisson.do: Using sample up to year 2017, only use (functions of) lag income as predictors, compare prediction performance (results for Table 1)
~\CV\Part2_analysis_moment_inc_wkdays_poisson.do: Using sample up to year 2017, only use (functions of)  lag income and lag working days as predictors, compare prediction performance (results for Table 1)
~\CV\Part2_analysis_moment_inc_wkdays_age_poisson.do: Using sample up to year 2017, only use (functions of) lag income, lag working days, and age as predictors, compare prediction performance (results for Table 1)

~\CV\Part2_analysis_moment_dum_poisson_update_new.do: Using sample up to year 2017, exponential specification with updated cluster (likelihood as criteria)
~\CV\Part2_analysis_moment_dum_poisson_update_new2018.do: Using all sample, exponential specification with updated cluster (likelihood as criteria)

### 4_part2_all_tab_figs.do
Produce figures and tables in part 2

tftaxthres: produce effective tax rates table in .tex  (Table S-G1) <br/>
tftabsum:  produce summary statistics tables of (nonnegative )annual income for CS, LS, H, and B samples (Table S-A1 - Table S-A6) <br/>
tfperf: produce prediction performance table (Table 1) <br/>
tfpart: produce  partial R2 table (Table 2) <br/>
tfclust: education distribution of individuals by cluster (table S-D1), predicted age income profiles for the estimated mean groups (Figure S-D1), Ave. CV over age, by mean cluster and absolute deviation cluster (Figure S-D2) <br/>
tfcvden: comparison between two measures of risk (Figure C1) , Comparing CV and standard deviation (Figure 12) <br/>
tfcvden_quantile: comparing CV and quantile-based dispersion (Figure S-G6) <br/>
tfcvcomp: compare exponential CV with other specifications (Figure S-G3, Figure S-G4) <br/>
tfcvt: distribution of CV by year and age (Figure 9-10, Figure 11(a), Figure 13, Figure B1(a-b), Figure B2(a-b), Figure B3(a-b), Figure B4(a-b), Figure S-G5(a-b), Figure B5(a-b) ) <br/>
tfcvt_quantile: distribution of quantile based dispersion and skewness by year and age (Figure B6(a-b), Figure B7, Figure S-G7(a)) <br/>
tfcvdyn: distribution of cv by lag income, lag working days, and lag CV, respectively (Figure 11(b-d), Figure C2, Figure B1(c-d), Figure B2(c-d), Figure B3(c-d), Figure B4(c-d), Figure S-G5(c-d), Figure B5(c-d)) <br/>
tfcvdyn_quantile: distribution of quantile based dispersion and skewness by lag income, lag working days, and lag skewness (dispersion), respectively (Figure B6(c-d), Figure S-G7(b-c)) <br/>
tftab1_3: distribution table of cv by age and year (Table 3-4, Table S-G2, Table S-G3, Table S-G4, Table S-G5, Table C1) <br/>
tfcvtax: before-tax and after-tax income comparison (Figure S-G1), Quantile-quantile plot of before-tax and after-tax CV (Figure S-G2)


### 5_bootstrap.do
Bootstrap the baseline model to compute std of second stage (absolute deviation)
