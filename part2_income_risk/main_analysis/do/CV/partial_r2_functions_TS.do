cap program drop partial_r2_TS

* Compute partial r-squared
program partial_r2_TS

	args main_var inc_var description
	
	** Matrix to store results
	matrix results = J(4, 3, .)
	matrix colnames results = "M, 26-30" "M, 36-40" ///
								"M, 46-50" //"F, 26-30" ///
								//"F, 36-40" "F, 46-50"
	matrix rownames results = "Business Cycle" "Contract Features (t-1)" ///
								"Days Worked (t-1)" "Income (t-1)" 
	
	** Matrix to store results with more detailed contract features
	matrix results_det = J(5, 3, .)
	matrix colnames results_det = "M, 26-30" "M, 36-40" ///
								"M, 46-50" //"F, 26-30" ///
								//"F, 36-40" "F, 46-50"
	matrix rownames results_det = "Business Cycle" "Permanent (t-1)" "Fulltime (t-1)" ///
								"Days Worked (t-1)" "Income (t-1)" 
								
	** LOOP OVER SEX AND AGE GROUP
	local col_ind = 1
	foreach s_ind of numlist 1 {
		forvalues a_ind = 1/3 {
			preserve
			
			* Keep condition
			keep if sex == `s_ind' & age_group == `a_ind'
			keep `main_var' `inc_var'_lag days_lag1 permanent_main ///
					fulltime_main gdp_lag* gdppr_lag* unemployment_lag* ///
					unemploymentpr_lag* 
			
			** Business cycle
			qui reg `main_var' `inc_var'_lag days_lag1 permanent_main fulltime_main 
			predict main_resid, resid
			
			local counter = 1
			foreach v of varlist gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* {
				qui reg `v' `inc_var'_lag days_lag1 permanent_main fulltime_main 
				predict e_`counter', resid
				
				local counter = `counter' + 1
			}
			
			qui reg main_resid e_*
			matrix results[1, `col_ind'] = e(r2)
			matrix results_det[1, `col_ind'] = e(r2)
			
			drop main_resid e_*
			
			** Contract features
			qui reg `main_var' `inc_var'_lag days_lag1 ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
			predict main_resid, resid
			
			local counter = 1
			foreach v of varlist permanent_main fulltime_main {
				qui reg `v' `inc_var'_lag days_lag1 ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
				predict e_`counter', resid
				
				local counter = `counter' + 1
			}
			
			qui reg main_resid e_*
			matrix results[2, `col_ind'] = e(r2)
			
			drop main_resid e_*
			
			** Permanent 
			qui reg `main_var' `inc_var'_lag days_lag1 fulltime_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
			predict main_resid, resid
			
			local counter = 1
			foreach v of varlist permanent_main {
				qui reg `v' `inc_var'_lag days_lag1 fulltime_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
				predict e_`counter', resid
				
				local counter = `counter' + 1
			}
			
			qui reg main_resid e_*
			matrix results_det[2, `col_ind'] = e(r2)
			
			drop main_resid e_*
			
			** Fulltime
			qui reg `main_var' `inc_var'_lag days_lag1 permanent_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
			predict main_resid, resid
			
			local counter = 1
			foreach v of varlist fulltime_main {
				qui reg `v' `inc_var'_lag days_lag1 permanent_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
				predict e_`counter', resid
				
				local counter = `counter' + 1
			}
			
			qui reg main_resid e_*
			matrix results_det[3, `col_ind'] = e(r2)
			
			drop main_resid e_*
			
			** Days worked
			qui reg `main_var' `inc_var'_lag permanent_main fulltime_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
			predict main_resid, resid
			
			local counter = 1
			foreach v of varlist days_lag1 {
				qui reg `v' `inc_var'_lag permanent_main fulltime_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
				predict e_`counter', resid
				
				local counter = `counter' + 1
			}
			
			qui reg main_resid e_*
			matrix results[3, `col_ind'] = e(r2)
			matrix results_det[4, `col_ind'] = e(r2)
			
			drop main_resid e_*
			
			** Lagged income
			qui reg `main_var' days_lag1 permanent_main fulltime_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
			predict main_resid, resid
			
			local counter = 1
			foreach v of varlist `inc_var'_lag {
				qui reg `v' days_lag1 permanent_main fulltime_main ///
					gdp_lag* gdppr_lag* unemployment_lag* unemploymentpr_lag* 
				predict e_`counter', resid
				
				local counter = `counter' + 1
			}
			
			qui reg main_resid e_*
			matrix results[4, `col_ind'] = e(r2)
			matrix results_det[5, `col_ind'] = e(r2)
			
			drop main_resid e_*
			
			
			
			restore
			
			* Update col_indicator
			local col_ind = `col_ind' + 1
		}
	}
	
	* Save matrices
	esttab matrix(results, fmt(4)) using "${outfolder}/`description'_partialr2.tex", ///
		noobs nonumber nomtitles replace
	esttab matrix(results, fmt(4)) using "${outfolder}/`description'_partialr2.csv", ///
		noobs nonumber nomtitles replace
		
	esttab matrix(results_det, fmt(4)) using "${outfolder}/`description'_partialr2_contractdetailed.tex", ///
		noobs nonumber nomtitles replace
	esttab matrix(results_det, fmt(4)) using "${outfolder}/`description'_partialr2_contractdetailed.csv", ///
		noobs nonumber nomtitles replace

end
