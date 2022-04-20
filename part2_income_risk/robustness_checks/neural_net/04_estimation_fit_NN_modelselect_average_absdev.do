** COMBINE NN MODEL SELECTION FILES (ABSDEV)
clear
set more off

global maindir ".../part2_income_risk"

global c_date = subinstr(c(current_date), " ", "", .) 

capture noisily mkdir "${maindir}/main_analysis/out/${c_date}"
global outfolder "${maindir}/main_analysis/out/${c_date}"

* Assign specifications
global table1 5 6 7 8 9
global table2 10 11 12 13 14
global table3 15 16 17 18 19

********
** TS **
********
use "${maindir}/main_analysis/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2016.dta", clear

rename (cond_mean absdev cond_absdev) ///
		(cond_mean_TS absdev_TS cond_absdev_TS)
		
* Make results folder
cap noisily mkdir "${maindir}/main_analysis/out/${c_date}/abs_pred_error"

**********************
** CONDITIONAL MEAN **
**********************
global resultdir "${maindir}/main_analysis/out/model_select_20210314_quantile_noclust_loglaginc_absdev"

* Make results folder
cap noisily mkdir "${maindir}/main_analysis/out/${c_date}/abs_pred_error/TS_absdev"
global outfolder "${maindir}/main_analysis/out/${c_date}/abs_pred_error/TS_absdev"

* Parameters

global nrep 15

global tab1_col = `""Pois+noclust" "5" "6" "7" "8" "9""'
global tab2_col = `""Pois+noclust" "10" "11" "12" "13" "14""'
global tab3_col = `""Pois+noclust" "15" "16" "17" "18" "19""'


global ncol = 6

global row_names = `""p1" "p5" "p10" "p25" "p50" "p75" "p90" "p95" "p99" "MSE" "Trimmed MSE" "MAE" "Trimmed MAE" "Poisson""'

* Define abs_pred_mean_TS
gen abs_pred_mean_TS = abs(absdev_TS - cond_absdev_TS)

* Gen likelihood of TS
gen llik_TS = absdev_TS * log(cond_absdev_TS) - cond_absdev_TS

* Loop over different tables
forvalues tabn = 1/3 {
	* Matrix to store results
	matrix define abs_pred_mean_in = J(14, $ncol, .)
	matrix rownames abs_pred_mean_in = $row_names
	matrix colnames abs_pred_mean_in = ${tab`tabn'_col}
	
	matrix define abs_pred_mean_out = J(14, $ncol, .)
	matrix rownames abs_pred_mean_out = $row_names
	matrix colnames abs_pred_mean_out = ${tab`tabn'_col}
	
	* First column is TS specification
	_pctile abs_pred_mean_TS if year <= 2016, p(1 5 10 25 50 75 90 95 99) // In-sample
	forvalues i = 1/9 {
		matrix abs_pred_mean_in[`i', 1] = r(r`i')
	}
	gen mse_temp = abs_pred_mean_TS^2
	qui sum mse_temp if year <= 2016, d
	matrix abs_pred_mean_in[10, 1] = r(mean)
	qui sum mse_temp if mse_temp <= r(p99) & year <= 2016, d
	matrix abs_pred_mean_in[11, 1] = r(mean)
	drop mse_temp
	qui sum abs_pred_mean_TS if year <= 2016, d
	matrix abs_pred_mean_in[12, 1] = r(mean)
	qui sum abs_pred_mean_TS if abs_pred_mean_TS <= r(p99) & year <= 2016, d
	matrix abs_pred_mean_in[13, 1] = r(mean)
	qui sum llik_TS if year <= 2016
	matrix abs_pred_mean_in[14, 1] = r(mean)

	_pctile abs_pred_mean_TS if year == 2017, p(1 5 10 25 50 75 90 95 99) // Out-of-sample
	forvalues i = 1/9 {
		matrix abs_pred_mean_out[`i', 1] = r(r`i')
	}
	gen mse_temp = abs_pred_mean_TS^2
	qui sum mse_temp if year == 2017, d
	matrix abs_pred_mean_out[10, 1] = r(mean)
	qui sum mse_temp if mse_temp <= r(p99) & year == 2017, d
	matrix abs_pred_mean_out[11, 1] = r(mean)
	drop mse_temp
	qui sum abs_pred_mean_TS if year == 2017, d
	matrix abs_pred_mean_out[12, 1] = r(mean)
	qui sum abs_pred_mean_TS if abs_pred_mean_TS <= r(p99) & year == 2017, d
	matrix abs_pred_mean_out[13, 1] = r(mean)
	qui sum llik_TS if year == 2017
	matrix abs_pred_mean_out[14, 1] = r(mean)
	
	* Loop over different specifications of NN
	local col_cnt = 2
	foreach specn in ${table`tabn'} {
		merge 1:1 person_id year using "${resultdir}/neuralnet_male_modelsel_poisson_spec`specn'_noclust_absdev.dta"
		drop _merge
		
		* To store average
		gen cond_mean_ave = 0
		
		* Loop over replications
		forvalues rep = 1/$nrep {
			replace cond_mean_ave = cond_mean_ave + (cond_absdev_rep`rep' / $nrep)
		}
		
		* Compute abs_pred_mean and llik
		gen abs_pred_mean_ave = abs(absdev_TS - cond_mean_ave)
		gen llik_ave = absdev_TS * log(cond_mean_ave) - cond_mean_ave
		
		* Compute rows of matrix
		_pctile abs_pred_mean_ave if year <= 2016, p(1 5 10 25 50 75 90 95 99) // In-sample
		forvalues i = 1/9 {
			matrix abs_pred_mean_in[`i', `col_cnt'] = r(r`i')
		}
		gen mse_temp = abs_pred_mean_ave^2
		qui sum mse_temp if year <= 2016, d
		matrix abs_pred_mean_in[10, `col_cnt'] = r(mean)
		qui sum mse_temp if mse_temp <= r(p99) & year <= 2016, d
		matrix abs_pred_mean_in[11, `col_cnt'] = r(mean)
		drop mse_temp
		qui sum abs_pred_mean_ave if year <= 2016, d
		matrix abs_pred_mean_in[12, `col_cnt'] = r(mean)
		qui sum abs_pred_mean_ave if abs_pred_mean_ave <= r(p99) & year <= 2016, d
		matrix abs_pred_mean_in[13, `col_cnt'] = r(mean)
		qui sum llik_ave if year <= 2016
		matrix abs_pred_mean_in[14, `col_cnt'] = r(mean)
		
		_pctile abs_pred_mean_ave if year == 2017, p(1 5 10 25 50 75 90 95 99) // Out-sample
		forvalues i = 1/9 {
			matrix abs_pred_mean_out[`i', `col_cnt'] = r(r`i')
		}
		gen mse_temp = abs_pred_mean_ave^2
		qui sum mse_temp if year == 2017, d
		matrix abs_pred_mean_out[10, `col_cnt'] = r(mean)
		qui sum mse_temp if mse_temp <= r(p99) & year == 2017, d
		matrix abs_pred_mean_out[11, `col_cnt'] = r(mean)
		drop mse_temp
		qui sum abs_pred_mean_ave if year == 2017, d
		matrix abs_pred_mean_out[12, `col_cnt'] = r(mean)
		qui sum abs_pred_mean_ave if abs_pred_mean_ave <= r(p99) & year == 2017, d
		matrix abs_pred_mean_out[13, `col_cnt'] = r(mean)
		qui sum llik_ave if year == 2017
		matrix abs_pred_mean_out[14, `col_cnt'] = r(mean)
		
		* Prep for next iteration
		local col_cnt = `col_cnt' + 1
		drop cond_absdev_rep* cond_mean_ave abs_pred_mean_ave llik_ave
	}
	
	* Save tables
	esttab matrix(abs_pred_mean_in, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_in_tab`tabn'_average.tex", ///
		noobs nonumber nomtitles replace
	esttab matrix(abs_pred_mean_in, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_in_tab`tabn'_average.csv", ///
		noobs nonumber nomtitles replace
		
	esttab matrix(abs_pred_mean_out, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_out_tab`tabn'_average.tex", ///
		noobs nonumber nomtitles replace
	esttab matrix(abs_pred_mean_out, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_out_tab`tabn'_average.csv", ///
		noobs nonumber nomtitles replace
		
	* Scaled Matrices
	matrix define abs_pred_mean_in_scaled = J(14, $ncol, .)
	matrix rownames abs_pred_mean_in_scaled = $row_names
	matrix colnames abs_pred_mean_in_scaled = ${tab`tabn'_col}
	
	matrix define abs_pred_mean_out_scaled = J(14, $ncol, .)
	matrix rownames abs_pred_mean_out_scaled = $row_names
	matrix colnames abs_pred_mean_out_scaled = ${tab`tabn'_col}
	
	forvalues i = 1/14 {
		matrix abs_pred_mean_in_scaled[`i', 1] = abs_pred_mean_in[`i', 1]
		matrix abs_pred_mean_out_scaled[`i', 1] = abs_pred_mean_out[`i', 1] / abs_pred_mean_in[`i', 1]
	}
	
	forvalues j = 2/$ncol {
		forvalues i = 1/14 {
			matrix abs_pred_mean_in_scaled[`i', `j'] = abs_pred_mean_in[`i', `j'] / abs_pred_mean_in[`i', 1]
			matrix abs_pred_mean_out_scaled[`i', `j'] = abs_pred_mean_out[`i', `j'] / abs_pred_mean_in[`i', 1]
		}
	}
	
	* Save tables
	esttab matrix(abs_pred_mean_in_scaled, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_in_scaled_tab`tabn'_average.tex", ///
		noobs nonumber nomtitles replace
	esttab matrix(abs_pred_mean_in_scaled, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_in_scaled_tab`tabn'_average.csv", ///
		noobs nonumber nomtitles replace
		
	esttab matrix(abs_pred_mean_out_scaled, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_out_scaled_tab`tabn'_average.tex", ///
		noobs nonumber nomtitles replace
	esttab matrix(abs_pred_mean_out_scaled, fmt(2)) ///
		using "${outfolder}/abs_pred_error_absdev_out_scaled_tab`tabn'_average.csv", ///
		noobs nonumber nomtitles replace
}










