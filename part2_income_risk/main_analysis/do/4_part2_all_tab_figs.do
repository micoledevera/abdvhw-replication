clear all
set more off
global sep="/"
global maindir ="C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part2\main_analysis"
global maindir_part1 ="C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part1" 
*global maindir ="/Users/siqiwei/Dropbox/Global_Income_Dynamics/Part2/main_analysis"
*global maindir_part1 ="/Users/siqiwei/Dropbox/Global_Income_Dynamics/Part1" 
cd "$maindir/out"
// Where the firgures are going to be saved 
global outfolder="paper_tab_figs_05Mar2021"			
capture noisily mkdir "$maindir${sep}out${sep}${outfolder}"
global outfolder="$maindir${sep}out${sep}${outfolder}"	

// Where the data is stored
** tot_inc 
global Tot_sample = "${maindir}/dta/mcvl_annual_FinalData_pt2_RemoveAllAfter2_NotClustering"
* Main TS tot_inc results   
global TS2018 = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018"	
global TS2018_funcion = "${TS2018}"
global TS2018_permnt = "${TS2018}"
global TS2018_npermnt = "${TS2018}"
global TS_fem2018 = "${maindir}/dta/IR_moment_cvar_TS_ppml_0_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018"	
* TS tot_inc to 2017 
global TS = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml"			
* Main TS disp_inc results   
global TS_disp2018 = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_disp_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018"	
* TS disp_inc to 2017 
global TS_disp = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_disp_inc_RemoveAllAfter2_NotClustering_poisson_ppml"			
* Based model income only to 2017
global TS_inconly = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml_inconly"			
* Based model income + wkdays to 2017
global TS_inc_wkdays = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml_inc_wkdays"			
* Based model income + wkdays + age to 2017
global TS_inc_wkdays_age = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml_inc_wkdays_age"			
* quantile 
global TS_quantile = "${maindir}/dta/IR_moment_cvar_TS_quantile_1_tot_inc_RemoveAllAfter2_NotClustering_quantile2018"			
* robust  
global TS_robust = "${maindir}/dta/robust_adj_lin_TS_male_incl2018" 
* alternative 2nd step
global TS_alt2nd = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018_alt2nd"
* TS 2018 for 3ZEROS samples
global TS_3zeros = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter3_NotClustering_poisson_ppml2018"
* TS 2018 morevars: firm sector family
global TS_morevars = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_morevars_poisson_ppml2018"

* Cluster
*DUM K4 RemoveAllAfter2, k4 cluster to 2018
global TS_k4DUM_2018 = "${maindir}/dta/IR_moment_cvar_dum_k4_inc_poisson_until2018_1_tot_inc_poisson_ppml_update2018.dta"		  // TS+ Cluster result
global TS_k6DUM_2018 = "${maindir}/dta/IR_moment_cvar_dum_k6_inc_poisson_until2018_1_tot_inc_poisson_ppml_update2018.dta"		  // TS+ Cluster result

* NN
* Mean K8 absdev K7
global NN_k8k7_2018 = "${maindir}/dta/neuralnet_male_tot_inc_noclust_mean_k8_absdev_k7_incl2018.dta" 

* Time varying coefficient 
global TS2018_timevary = "${maindir}/dta/IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018_timevary.dta"



	
// Read initialize and plotting code. Do not change myplots.do
do "$maindir${sep}do${sep}CV${sep}myplots.do"	
do "$maindir${sep}do${sep}CV${sep}partial_r2_functions.do"		
do "$maindir${sep}do${sep}CV${sep}partial_r2_functions_TS.do"		
do "$maindir_part1${sep}do${sep}myprogs.do"	
*do "$maindir_part1${sep}do${sep}myplots_extra.do"		
// Define these variables for your dataset
global yrfirst = 2005 		// First year in the dataset 
global yrlast =  2018 		// Last year in the dataset

// Define some common charactristics of the plots 
global folderfile = "${outfolder}"
global xtitlesize =   "large" 
global ytitlesize =   "large" 
global xlabsize =     "large" 
global ylabsize =     "large" 
global titlesize  =   "large" 
global subtitlesize = "medium" 
global formatfile  =  "pdf"
global fontface   =   "Times New Roman"
global marksize =     "medium"	
global legesize =     "large"	

global receyears = "2008,2009,2011,2012,2013"
global exrate2018 = 0.846  //take from 0_Initialize, part 1 #euro/1dollar	   
// Cd to folder with out 
cd "${outfolder}${sep}" // Cd to the folder containing the files
	
// Which section are we ploting 
global tftaxthres = "no"   // tax for computing disposable income
global tftabsum = "no"   // summary statistics tab
global tfperf =  "no"			// Performance: meanonly, + days, + days+age, and TS 
global tfpart =  "no"			// Partial R2 
global tfclust =  "yes"			// Age income profiles by cluster (need to adjust labels for each category)
global tfcvden =   "no"			// CV density 
global tfcvden_quantile =   "no"			// CV density 
global tfcvcomp = "no"  // figures for comparing cv: marginal distribution and by individual (general tfcvden)
global tfcvt =   "no"			// CV percentiles over time and over lifecycle and CV inequality
global tfcvt_quantile = "no"   // 
global tfcvdyn =  "no"			// CV dynmaics
global tfcvdyn_quantile = "no"
global tftab1_3 = "no"         // CV table 1-3
global tfcvtax = "no" // figures for comparing cv(tot_inc) and cv(disp)

* Performance 
if "${tftaxthres}" == "yes"{
	use "$maindir\dta\effective_tax_rate.dta",clear
	*format base* tau* %10.2f
	dataout, save(effective_tax_rate) tex replace noauto
	
}

if "${tftabsum}" == "yes"{
foreach mdname in "Tot_sample"{

foreach subspl in "all" "positive"{    
    *local mdname "Tot_sample"
	local fsrtyr = 2006
	local lastyr = 2018
	
	foreach curr in "usd" "euro"{
	forvalues yr = `fsrtyr'/`lastyr'{
		
		*local yr = 2006
		*local mdname = "TS2018"
		use "${`mdname'}",clear	
		rename (sex education tot_inc) (male educ labor)	

		keep male age educ labor year 
		keep if labor~=. & year == `yr'
		
		if "`subspl'" == "positive"{
		    drop if labor == 0
		}
		
		if "`curr'" == "usd"{
			// Transform to 2018 US dollars		
			replace labor = labor/${exrate2018}  // already in 2018 euro
		}	

		
		bymysum "labor" "L_" "_`yr'" "year"
		bymysum "labor" "L_" "_male`yr'" "year male"
	
		bymyPCT "labor" "L_" "_`yr'" "year"
		bymyPCT "labor" "L_" "_male`yr'" "year male"
		
		collapse (count) numobs = labor (sum) sum_labor = labor, by(year male educ age)
		order year male educ age numobs sum_labor
		qui: save "numobs`yr'.dta", replace
	
	} // END of loop over years

	* Collects number of observations data across years (for what did we need this?)
	clear
	*local fsrtyr = 2005
	*local lastyr = 2018
	*local spl = "CS"
	forvalues yr = `fsrtyr'/`lastyr'{
		append using "numobs`yr'.dta"
		erase "numobs`yr'.dta"	
	}
    save "temp.dta" ,replace

	sort year male
	by year: gen temp = sum(numobs)
	by year: egen obs = max(temp)
	drop temp
	gen prop = numobs/obs

	* Obs.
	preserve 
	collapse (mean) Obs = obs, by(year)
	save year_obs.dta,replace
	restore

	* Women Share
	preserve 
	collapse (sum) fem_prop = prop, by(year male)
	keep if male == 0
	drop male

	save year_femprop.dta, replace 
	restore 

	*Age Shares
	preserve
	gen ageid = 1 if age>=25 & age<=35
	replace ageid = 2 if age>=36 & age<=45
	replace ageid = 3 if age>=46 & age<=55
	collapse (sum) age_prop = prop, by(year ageid)
	reshape wide age_pro,i(year) j(ageid)
	save year_ageprop.dta, replace 
	restore

	*edu shares
	preserve
	collapse (sum) edu_prop = prop, by(year educ)
	reshape wide edu_prop,i(year) j(educ)
	save year_educprop.dta, replace 
	restore 


	*mean income 
	preserve
	collapse (sum) male_numobs = numobs ///
               male_sumlabor = sum_labor, by(year male)
	gen mean_labor = male_sumlabor/male_numobs
	keep year male mean_labor
	reshape wide mean_labor,i(year) j(male)
	save year_meanlabor.dta, replace 
	restore

	use year_obs,clear
	merge 1:1 year using "year_meanlabor.dta"
	drop _merge
	merge 1:1 year using "year_femprop.dta"
	drop _merge
	merge 1:1 year using "year_ageprop.dta"
	drop _merge
	merge 1:1 year using "year_educprop.dta"
	drop _merge


	replace Obs = Obs/1000
	label var Obs "Obs. (*1000)"
	format Obs %10.2f

	label var mean_labor0 "Mean Income Women"
	label var mean_labor1 "Mean Income Men"
	format mean_labor0 mean_labor1 %10.0f

	label var fem_prop "Women % Share"
	label var age_prop1 "Age Shares % [25,35]"
	label var age_prop2 "Age Shares % [36,45]"
	label var age_prop3 "Age Shares % [46,55]"
	label var edu_prop1 "Education Shares % <= Primary"
	label var edu_prop2 "Education Shares % Lower secondary"
	label var edu_prop3 "Education Shares % Upper secondary"
	label var edu_prop4 "Education Shares % >=College"

	replace fem_prop = fem_prop*100
	replace age_prop1 = age_prop1*100
	replace age_prop2 = age_prop2*100
	replace age_prop3 = age_prop3*100
	replace edu_prop1 = edu_prop1*100
	replace edu_prop2 = edu_prop2*100
	replace edu_prop3 = edu_prop3*100
	replace edu_prop4 = edu_prop4*100
	format *prop*  %10.1f

	mkmat Obs mean_labor1 mean_labor0 fem_prop age_prop1 age_prop2 ///
		age_prop3 edu_prop1 edu_prop2 edu_prop3 edu_prop4, mat(table1)
   
   
	matrix colnames table1 =  "Obs (*1000)" "Mean Inc Men" "Mean Inc Women" ///
		"Women Share" "[25,35]" "[36,45]" "[46,55]" ///
			"Primary"	"Lower secondary" ///
			"Upper secondary" "College"

	
	matrix rownames table1 = "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" ///
								"2014" "2015" "2016" "2017" ///
								"2018" 

	esttab matrix(table1, fmt(3 0 0 1 1 1 1 1 1 1 1)) ///
		using "part2sum_table1_`mdname'_`subspl'_`curr'.tex", ///
		noobs nonumber no nomtitles align(`=colsof(table1)*"c"') replace								
								
    * same table for male only
    use  "temp.dta" ,clear
	
	keep if male == 1
	sort year male
	by year: gen temp = sum(numobs)
	by year: egen obs = max(temp)
	drop temp
	gen prop = numobs/obs

	* Obs.
	preserve 
	collapse (mean) Obs = obs, by(year)
	save year_obs.dta,replace
	restore

	* Women Share
	/*preserve 
	collapse (sum) fem_prop = prop, by(year male)
	keep if male == 0
	drop male

	save year_femprop.dta, replace 
	restore 
*/
	*Age Shares
	preserve
	gen ageid = 1 if age>=25 & age<=35
	replace ageid = 2 if age>=36 & age<=45
	replace ageid = 3 if age>=46 & age<=55
	collapse (sum) age_prop = prop, by(year ageid)
	reshape wide age_pro,i(year) j(ageid)
	save year_ageprop.dta, replace 
	restore

	*edu shares
	preserve
	collapse (sum) edu_prop = prop, by(year educ)
	reshape wide edu_prop,i(year) j(educ)
	save year_educprop.dta, replace 
	restore 


	*mean income 
	preserve
	collapse (sum) male_numobs = numobs ///
               male_sumlabor = sum_labor, by(year male)
	gen mean_labor = male_sumlabor/male_numobs
	keep year male mean_labor
	reshape wide mean_labor,i(year) j(male)
	save year_meanlabor.dta, replace 
	restore

	use year_obs,clear
	merge 1:1 year using "year_meanlabor.dta"
	drop _merge
	*merge 1:1 year using "year_femprop.dta"
	*drop _merge
	merge 1:1 year using "year_ageprop.dta"
	drop _merge
	merge 1:1 year using "year_educprop.dta"
	drop _merge


	replace Obs = Obs/1000
	label var Obs "Obs. (*1000)"
	format Obs %10.2f

	*label var mean_labor0 "Mean Income Women"
	label var mean_labor1 "Mean Income Men"
	format  mean_labor1 %10.0f

	*label var fem_prop "Women % Share"
	label var age_prop1 "Age Shares % [25,35]"
	label var age_prop2 "Age Shares % [36,45]"
	label var age_prop3 "Age Shares % [46,55]"
	label var edu_prop1 "Education Shares % <= Primary"
	label var edu_prop2 "Education Shares % Lower secondary"
	label var edu_prop3 "Education Shares % Upper secondary"
	label var edu_prop4 "Education Shares % >=College"

	*replace fem_prop = fem_prop*100
	replace age_prop1 = age_prop1*100
	replace age_prop2 = age_prop2*100
	replace age_prop3 = age_prop3*100
	replace edu_prop1 = edu_prop1*100
	replace edu_prop2 = edu_prop2*100
	replace edu_prop3 = edu_prop3*100
	replace edu_prop4 = edu_prop4*100
	format *prop*  %10.1f

	mkmat Obs mean_labor1 age_prop1 age_prop2 ///
		age_prop3 edu_prop1 edu_prop2 edu_prop3 edu_prop4, mat(table0)
   
   
	matrix colnames table0 =  "Obs (*1000)" "Mean Inc Men" ///
		 "[25,35]" "[36,45]" "[46,55]" ///
			"Primary"	"Lower secondary" ///
			"Upper secondary" "College"

	
	matrix rownames table0 = "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" ///
								"2014" "2015" "2016" "2017" ///
								"2018" 

	esttab matrix(table0, fmt(3 0 1 1 1 1 1 1 1)) ///
		using "part2sum_table1_male_`mdname'_`subspl'_`curr'.tex", ///
		noobs nonumber no nomtitles align(`=colsof(table1)*"c"') replace								
							
							
							
	
	* percentile 
	use "PC_L_labor_`fsrtyr'",clear
	local yp1 = `fsrtyr' + 1
	forval yr = `yp1'(1)`lastyr'{
		append using "PC_L_Labor_`yr'.dta"
	}
	keep year p1labor p5labor p10labor p25labor p50labor p75labor p90labor p95labor p99labor p99_5labor

	mkmat p1labor p5labor p10labor p25labor p50labor p75labor p90labor p95labor p99labor p99_5labor, ///
		mat(table2)
      
	matrix colnames table2 = "P1" "P5" "P10" "P25" "P50" ///
								"P75" "P90" "P95" "P99" "P99.5"

	matrix rownames table2 = "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" ///
								"2014" "2015" "2016" "2017" ///
								"2018" 
								
	esttab matrix(table2, fmt(0)) ///
		using "part2SUM_table2_`mdname'_`subspl'_`curr'.tex", ///
		noobs nonumber no nomtitles align(`=colsof(table2)*"c"') replace	
		
	* percentile male 
	*local fsrtyr = 2006
	*local lastyr = 2018
	use "PC_L_labor_male`fsrtyr'",clear	
	local yp1 = `fsrtyr' + 1
	forval yr = `yp1'(1)`lastyr'{
		append using "PC_L_Labor_male`yr'.dta"
	}
	keep if male == 1 
	drop male
	
	keep year p1labor p5labor p10labor p25labor p50labor p75labor p90labor p95labor p99labor p99_5labor

	mkmat p1labor p5labor p10labor p25labor p50labor p75labor p90labor p95labor p99labor p99_5labor, ///
		mat(table3)
      
	matrix colnames table3 = "P1" "P5" "P10" "P25" "P50" ///
								"P75" "P90" "P95" "P99" "P99.5"

	matrix rownames table3 = "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" ///
								"2014" "2015" "2016" "2017" ///
								"2018" 
								
	esttab matrix(table3, fmt(0)) ///
		using "part2SUM_table2_male_`mdname'_`subspl'_`curr'.tex", ///
		noobs nonumber no nomtitles align(`=colsof(table3)*"c"') replace		
}								
}
}

}



if "${tfperf}" == "yes"{ 

    use "${TS}", clear
	rename (cond_mean absdev cond_absdev L L_abs) ///
		   (cond_mean_TS absdev_TS cond_absdev_TS L_TS L_abs_TS)    

    merge 1:1 person_id year using "${TS_inconly}", ///	    
		update keepusing(cond_mean absdev cond_absdev L L_abs)
	drop _merge	
 	rename (cond_mean absdev cond_absdev L L_abs) ///
		   (cond_mean_inconly absdev_inconly cond_absdev_inconly L_inconly L_abs_inconly)
		   
    merge 1:1 person_id year using "${TS_inc_wkdays}", ///	    
		update keepusing(cond_mean absdev cond_absdev L L_abs)
	drop _merge	
 	rename (cond_mean absdev cond_absdev L L_abs) ///
		   (cond_mean_inc_wkdays absdev_inc_wkdays cond_absdev_inc_wkdays L_inc_wkdays L_abs_inc_wkdays)
		   
	merge 1:1 person_id year using "${TS_inc_wkdays_age}", ///	    
		update keepusing(cond_mean absdev cond_absdev L L_abs)
	drop _merge	
 	rename (cond_mean absdev cond_absdev L L_abs) ///
		   (cond_mean_inc_wkdays_age absdev_inc_wkdays_age cond_absdev_inc_wkdays_age L_inc_wkdays_age L_abs_inc_wkdays_age)
		   
		   
	gen abs_mean_TS = abs(tot_inc - cond_mean_TS)
	gen mse_mean_TS = abs_mean_TS^2
	
	gen abs_mean_inconly = abs(tot_inc - cond_mean_inconly) //for mean part is diff from absdev_inconly
	gen mse_mean_inconly = abs_mean_inconly^2
	
	gen abs_mean_inc_wkdays = abs(tot_inc - cond_mean_inc_wkdays) //for mean part is diff from absdev_inconly
	gen mse_mean_inc_wkdays = abs_mean_inc_wkdays^2
	
	gen abs_mean_inc_wkdays_age = abs(tot_inc - cond_mean_inc_wkdays_age) //for mean part is diff from absdev_inconly
	gen mse_mean_inc_wkdays_age = abs_mean_inc_wkdays_age^2
	
	
	gen abs_absdev_TS = abs(absdev_TS - cond_absdev_TS)
	gen mse_absdev_TS = abs_absdev_TS^2
	
	gen abs_absdev_inconly = abs(absdev_inconly - cond_absdev_inconly)
	gen mse_absdev_inconly = abs_absdev_inconly^2
	
	gen abs_absdev_inc_wkdays = abs(absdev_inc_wkdays - cond_absdev_inc_wkdays)
	gen mse_absdev_inc_wkdays = abs_absdev_inc_wkdays^2
	
	gen abs_absdev_inc_wkdays_age = abs(absdev_inc_wkdays_age - cond_absdev_inc_wkdays_age)
	gen mse_absdev_inc_wkdays_age = abs_absdev_inc_wkdays_age^2
	
	
	

	local endings `""inconly" "inc_wkdays" "inc_wkdays_age" "TS""' 
	local numclst : word count `endings'
	local numclst = `numclst'*2*2
	di "`numclst'"
	
	matrix define abs_pred = J(3, `numclst', .)
	matrix colnames abs_pred = "Income only, Mean, In" "Inc and wkdays, Mean, In"	"Inc wkdays age, Mean, In" "Homogenous, Mean, In" ///
							   "Income only, Mean, Out" "Inc and wkdays, Mean, Out"	"Inc wkdays age, Mean, Out" "Homogenous, Mean, Out" ///
							   "Income only, Absdev, In" "Inc and wkdays, Absdev, In"	"Inc wkdays age, Absdev, In" "Homogenous, Absdev, In" ///
							   "Income only, Absdev, Out" "Inc and wkdays, Absdev, Out"	"Inc wkdays  age, Absdev, Out" "Homogenous, Absdev, Out" //								 
	matrix rownames abs_pred =  "MSE" "MAE"  "Ave logliklihood"
	//"p1" "p5" "p10" "p25" "p50" "p75" "p90" "p95" "p99"
	local col_cnt = 1
	forval est_ind = 1(-1)0{
		foreach ends in `endings' {
					
		qui:sum mse_mean_`ends' if est_sample == `est_ind' & sex == 1, detail		
		qui:sum mse_mean_`ends' if est_sample == `est_ind' & sex == 1 & mse_mean_`ends'<=r(p99) , detail	
		matrix abs_pred[1, `col_cnt'] = r(mean)
				
		qui:sum absdev_`ends' if est_sample == `est_ind' & sex == 1, detail		
		qui:sum abs_mean_`ends' if est_sample == `est_ind' & sex == 1 & abs_mean_`ends'<=r(p99) , detail	
		matrix abs_pred[2, `col_cnt'] = r(mean)
		
		qui: sum L_`ends' if est_sample == `est_ind' & sex == 1, detail	
		matrix abs_pred[3, `col_cnt'] = r(mean)
													 
			local col_cnt = `col_cnt' + 1
		}
}


	
local col_cnt = `numclst'/2+1
forval est_ind = 1(-1)0{
	foreach ends in `endings' {
		
		qui:sum mse_absdev_`ends' if est_sample == `est_ind' & sex == 1, detail		
		qui:sum mse_absdev_`ends' if est_sample == `est_ind' & sex == 1 & mse_absdev_`ends'<=r(p99) , detail	
		matrix abs_pred[1, `col_cnt'] = r(mean)
		
		qui:sum abs_absdev_`ends' if est_sample == `est_ind' & sex == 1, detail		
		qui:sum abs_absdev_`ends' if est_sample == `est_ind' & sex == 1 & abs_absdev_`ends'<=r(p99) , detail	
		matrix abs_pred[2, `col_cnt'] = r(mean)
		
		qui: sum L_abs_`ends' if est_sample == `est_ind' & sex == 1, detail	
		matrix abs_pred[3, `col_cnt'] = r(mean)
											  
		local col_cnt = `col_cnt' + 1
		}
}


esttab matrix(abs_pred, fmt(2)) ///
		using "abs_pred_error.tex", ///
		noobs nonumber nomtitles align(`=colsof(abs_pred)*"c"') replace
							
		
}

* Partial R2 ?

if "${tfpart}" == "yes"{ 

	foreach mdname in  "TS" { // "TS_DUM" "NN"
	if "`mdname'" == "NN"{
		u "${TS_DUM2018}", clear 
		replace year = year - 2005
		drop cond_mean absdev cond_absdev cvar_m
		merge 1:1 person_id year using "${NN2018}"
		replace year = year + 2005
		
		gen age_group = .
		replace age_group = 1 if age >= 26 & age <= 30
		replace age_group = 2 if age >= 36 & age <= 40
		replace age_group = 3 if age >= 46 & age <= 50
		
		partial_r2 "cvar_m" "cvar_m_`mdname'_CV"
	}
	if "`mdname'" == "TS"{
	    u "${TS2018}", clear		
		gen age_group = .
		replace age_group = 1 if age >= 26 & age <= 30
		replace age_group = 2 if age >= 36 & age <= 40
		replace age_group = 3 if age >= 46 & age <= 50

		partial_r2_TS "cvar_m" "tot_inc" "cvar_m_tot_inc_`mdname'_CV"
		
	    u "${TS_disp2018}", clear		
		gen age_group = .
		replace age_group = 1 if age >= 26 & age <= 30
		replace age_group = 2 if age >= 36 & age <= 40
		replace age_group = 3 if age >= 46 & age <= 50

		partial_r2_TS "cvar_m" "disp_inc" "cvar_m_disp_inc_`mdname'_CV"
		
	}
	if "`mdname'" == "TS_DUM"{
	    u "${TS_DUM2018}", clear	
		
		gen age_group = .
		replace age_group = 1 if age >= 26 & age <= 30
		replace age_group = 2 if age >= 36 & age <= 40
		replace age_group = 3 if age >= 46 & age <= 50
		
		partial_r2 "cvar_m" "cvar_m_`mdname'_CV"
		
	
	}	  
		
	}
	
}
* Age Income profiles for the CLUSTER 
if "${tfclust}" == "yes"{ 

*foreach mdname in "TS_k6DUM_2018" "TS_k4DUM_2018"{   //"TS_k6DUM_2018"
     
	local mdname = "TS_k4DUM_2018"
    use "${`mdname'}",clear
	keep person_id year tot_inc absdev cvar_m age new_cluster_mean new_cluster_abs educ1-educ4
	*heatplot new_cluster_abs new_cluster_mean,color(hue) discrete
			
	* Education by cluster 
	preserve 
	bysort person_id: gen temp = _n
	keep if temp == 1
	drop temp
	
	qui:sum new_cluster_mean,de
	local nclust = r(max)
	collapse (sum) educ* (count) cvar_m_abs, by(new_cluster_mean)
	forval i = 1(1)4{
		replace educ`i' = educ`i'/cvar_m_abs
	}
	rename cvar_m_abs N	
	sort new_cluster_mean	
	order new_cluster_mean N educ*
	mkmat N educ*, mat(clust_edu)
	if "`mdname'" == "TS_k4DUM_2018"{
		matrix rownames clust_edu = "Mean Cluster 1" "Mean Cluster 2" "Mean Cluster 3" "Mean Cluster 4"
		*matrix colnames frac = "Abs Cluster 1" "Abs Cluster 2" "Abs Cluster 3" "Abs Cluster 4"
	}
	if "`mdname'" == "TS_k6DUM_2018"{
		matrix rownames clust_edu = "Mean Cluster 1" "Mean Cluster 2" "Mean Cluster 3" "Mean Cluster 4" "Mean Cluster 5" "Mean Cluster 6"
		*matrix colnames frac = "Abs Cluster 1" "Abs Cluster 2" "Abs Cluster 3" "Abs Cluster 4" "Abs Cluster 5" "Abs Cluster 6"
	}
	esttab matrix(clust_edu, fmt(2)) ///
		using "Mean_cluster_edu_`mdname'_frac.tex", ///
		noobs nonumber nomtitles  align(`=colsof(frac)*"c"') replace
	restore
	
	preserve
	bysort person_id: gen temp = _n
	keep if temp == 1
	drop temp
	qui:sum new_cluster_abs,de
	local nclust = r(max)
	collapse (sum) educ* (count) cvar_m_abs, by(new_cluster_abs)
	forval i = 1(1)4{
		replace educ`i' = educ`i'/cvar_m_abs
	}
	rename cvar_m_abs N	
	sort new_cluster_abs	
	order new_cluster_abs N educ*
	mkmat N educ*, mat(clust_edu)
	if "`mdname'" == "TS_k4DUM_2018"{
		*matrix rownames clust_edu = "Mean Cluster 1" "Mean Cluster 2" "Mean Cluster 3" "Mean Cluster 4"
		matrix rownames clust_edu = "Abs Cluster 1" "Abs Cluster 2" "Abs Cluster 3" "Abs Cluster 4"
	}
	if "`mdname'" == "TS_k6DUM_2018"{
		*matrix rownames clust_edu = "Mean Cluster 1" "Mean Cluster 2" "Mean Cluster 3" "Mean Cluster 4" "Mean Cluster 5" "Mean Cluster 6"
		matrix rownames clust_edu = "Abs Cluster 1" "Abs Cluster 2" "Abs Cluster 3" "Abs Cluster 4" "Abs Cluster 5" "Abs Cluster 6"
	}
	esttab matrix(clust_edu, fmt(2)) ///
		using "Absdev_cluster_edu_`mdname'_frac.tex", ///
		noobs nonumber nomtitles  align(`=colsof(frac)*"c"') replace
	restore 
	
	* over age 
	preserve 	
	qui:sum new_cluster_mean,de
	local nclust = r(max)
	collapse (mean) cvar_m, by(new_cluster_mean new_cluster_abs age)
	gen cluster = .
	local ct = 1
	forval j = 1(1)`nclust'{
	    forval i = 1(1)`nclust'{
		    replace cluster = `ct' if new_cluster_mean==`i' & new_cluster_abs==`j'
			local ct = `ct'+1
		}
	}
	reshape wide cvar_m_abs new_cluster_mean new_cluster_abs,i(age) j(cluster)
	drop new* 
	
	
	forval i = 1(1)`nclust'{	
	
	local lb = (`i'-1)*`nclust'+1
	local ub = (`i')*`nclust'
	
	local varl cvar_m_abs`lb'-cvar_m_abs`ub'
    tspltAREALimPA2 "`varl'" /// Which variables?
	   "age" ///
	   25 55 10 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "Mean Cluster 1" "Mean Cluster 2" "Mean Cluster 3" "Mean Cluster 4" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Age" /// x axis title
	   "CV" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "`mdname'_male_cv_profile_abs_cluster`i'_overage"	/// Figure name
	   "0" "2.5" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S x D T" 
	}
	restore
	
	
	
	* cv over time
	preserve 	
	qui:sum new_cluster_mean,de
	local nclust = r(max)
	collapse (mean) cvar_m, by(new_cluster_mean new_cluster_abs year)
	gen cluster = .
	local ct = 1
	forval j = 1(1)`nclust'{
	    forval i = 1(1)`nclust'{
		    replace cluster = `ct' if new_cluster_mean==`i' & new_cluster_abs==`j'
			local ct = `ct'+1
		}
	}
	reshape wide cvar_m_abs new_cluster_mean new_cluster_abs,i(year) j(cluster)
	drop new* 
		
	forval i = 1(1)`nclust'{	
	
	local lb = (`i'-1)*`nclust'+1
	local ub = (`i')*`nclust'
	
	local varl cvar_m_abs`lb'-cvar_m_abs`ub'
    tspltAREALimPA2 "`varl'" /// Which variables?
	   "year" ///
	   2006 2018 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "Mean Cluster 1" "Mean Cluster 2" "Mean Cluster 3" "Mean Cluster 4" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Year" /// x axis title
	   "CV" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "`mdname'_male_cv_profile_abs_cluster`i'_overtime"	/// Figure name
	   "0" "2.0" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S x D T" 
	}
	restore
	
	
	
	* predicted age income profiles 
	preserve 
	gen cluster = new_cluster_mean
	sum cluster 
	local nclust = r(max)
	
	gen tot_inc_age = .
	forval i = 1/`nclust'{
	    reg tot_inc c.age##c.age if cluster == `i'
		predict fit`i' if cluster == `i'
		replace tot_inc_age = fit`i' if tot_inc_age == .
	}
	drop fit*	
	collapse (mean) tot_inc_age, by(cluster age)
	
	replace tot_inc_age = tot_inc_age/1000
	reshape wide tot_inc_age, i(age) j(cluster)
		
	local varl tot_inc_age*		
	tspltAREALimPA2 "`varl'" /// Which variables?
	   "age" ///
	   25 55 10 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "Cluster 1" "Cluster 2" "Cluster 3" "Cluster 4" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Age" /// x axis title
	   "Income (in thousands) " /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "male_income_profile_`mdname'"	/// Figure name
	   "0" "180" "60"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S x D T" 
	restore   
	 
	
	 
	 
*}

}




* CV density  (originally in part1/6_1_extra_figs)
if "${tfcvden}" == "yes"{ 

	foreach spl in "RemoveAllAfter2" "RemoveAllAfter2_NotClustering"{
	foreach inc_var in "tot_inc" "disp_inc"{
    //( compute Delta epsilon 1F for part 2 all non zero income)
	use "${maindir}\dta\mcvl_annual_FinalData_pt2_`spl'.dta",clear
	gen yob = birth_year
	*drop age* same age using in part2 1 year less than part 1
	rename `inc_var' labor
	rename sex male
	rename education educ
	drop if year == 2005 | year == 2019 // missing
	keep person_id year labor male yob educ `inc_var'_lag
	reshape wide labor `inc_var'_lag, i(person_id) j(year)
	gen labor2005 = `inc_var'_lag2006
	gen `inc_var'_lag2005 = .

	forvalues yr = 2005/2018{	
		*local yr 2008
		*use personid male yob educ labor`yr' using ///
		*"$maindir${sep}dta${sep}base_sample.dta" if labor`yr'~=. , clear   
		preserve
		// Create year
		gen year=`yr'
		
		// Create age 
		gen age = `yr'-yob
		drop if age<25 | age>55
		
		// Create log earn if earnings above the min treshold
		// Criteria c (Trimming) in CS Sample
		// Notice we do not drop the observations but log-earnings are generated for those with
		// income below 1/3*min threshold. Variable logearn`yr'c is used for growth rates conditional
		// on permanent income only
		
		gen logearn`yr' = log(labor`yr') if  labor`yr'!=. 	
		
		// Create dummies for age and education groups
		tab age, gen(agedum)
		drop agedum1
		tab educ, gen(educdum)
		drop educdum1
	
		// Regression for residuals earnigs
		statsby _b,  by(year) saving(age_yr`yr'_m,replace):  ///
		regress logearn`yr' agedum* if male==1
	
		predict temp_m if e(sample)==1, resid
		
		statsby _b,  by(year) saving(age_yr`yr'_f,replace):  ///
		regress logearn`yr' agedum* if male==0
	
		predict temp_f if e(sample)==1, resid
		
		// Generate the residuals by year and save a database for later append.
		gen researn`yr'= temp_m
		replace researn`yr'= temp_f if male==0	

		keep person_id researn`yr' `inc_var'_lag`yr'
		sort person_id
	
		// Save data set for later append
		label var researn`yr' "Residual of real log-labor earnings of year `yr'"	
		save "researn`yr'.dta", replace
	
		erase age_yr`yr'_f.dta
		erase age_yr`yr'_m.dta
		restore	
	}

	* Merge data
	clear	
	forvalues yr = 2005/2018{
	
		if (`yr' == 2005){
			use researn`yr'.dta, clear
			erase researn`yr'.dta
		}
		else{
			merge 1:1 person_id using researn`yr'.dta, nogen
			erase researn`yr'.dta
		}
		sort person_id
	}
	reshape long researn `inc_var'_lag, i(person_id) j(year)
	xtset person_id year 
	gen researn1F = researn - l.researn
	compress 
	save "researn_part2_`inc_var'_`spl'.dta", replace 
	}
	}
	
	
	foreach mdname in "TS2018" {    //"TS_disp2018" "TS_disp2018"
	
	*local mdname = "TS2018"
	use "${`mdname'}",clear
	
	if ("`mdname'" == "TS2018"){	    
	    local labname = "TS"
		merge 1:1 person_id year using "researn_part2_tot_inc_RemoveAllAfter2_NotClustering.dta"
		drop if _merge ==2
		local inc_var = "tot_inc"
	}
	
	if ("`mdname'" == "TS_disp2018"){	    
	    local labname = "TS"
		merge 1:1 person_id year using "researn_part2_disp_inc_RemoveAllAfter2_NotClustering.dta"
		drop if _merge ==2
		local inc_var = "disp_inc"
	}
	
				
	
	* construct change of residual for all nonzero income     
	preserve 	
	drop if researn1F ==. | cvar_m ==.
	* By inc_tot_lag ranks, compute p50(cvar) and std(researn)
	xtile rank = `inc_var'_lag,n(100)
		
	collapse (p10) cvar_m_p10 = cvar_m ///
			(p50) cvar_m_p50 = cvar_m ///
			(p90) cvar_m_p90 = cvar_m ///
			(sd) sdres1F = researn1F, by(rank)

	gen rescal = sqrt(2/c(pi))*sdres1F //(4*normal(sdres1F/2) - 2)
		
	colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 )
	tw (line cvar_m_p10 rank  if rank>1 & rank<100, lcolor("213 94 0")   lwidth(medthick) lpattern(longdash)  ) ///
		(line cvar_m_p50 rank  if rank>1 & rank<100, lcolor("213 94 0")  lwidth(medthick) lpattern(shortdash)  ) ///
		(line cvar_m_p90 rank  if rank>1 & rank<100, lcolor("213 94 0")  lwidth(medthick) lpattern(dash_dot) ) ///
		(line rescal rank  if rank>1 & rank<100, lcolor("`r(p1)'")  lwidth(medthick) lpattern(solid)  ), ///
		legend(order(1 "CV, p10" 2 "CV, p50" 3 "CV, p90" 4 "Std(log(Y{sub:it})|Y{sub:it-1})") ///
		symxsize(9.0) ring(0) position(1) col(1) ///
		region(color(none) lcolor(white))) ///
		xtitle("Percentiles of Y{sub:it-1}", size(medium)) ///
		ytitle("Percentiles of CV and Std(log(Y{sub:it})|Y{sub:it-1})") ///
		graphregion(color(white)  ) ///				Graph region define
		plotregion(lcolor(black))  ///				Plot regione define
		title("", color(black)) //
	cap noisily: graph export "`labname'_`inc_var'_male_res_cvarp1590_rescal.${formatfile}", replace 
	
	restore
    

	
	preserve 	
	keep person_id year researn1F cvar_m `inc_var'_lag
	drop if researn1F ==. | cvar_m ==.
	
	xtile rank = `inc_var'_lag,n(100)
	sort rank
	by rank: egen sdres1F = sd(researn1F)
	gen rescal = sqrt(2/c(pi))*sdres1F //(4*normal(sdres1F/2) - 2)
	
	*count
	*local temp = `r(N)'+1
	*set obs `temp'
	*replace rescal = 0 if rescal == .
	*replace cvar_m = 0 if cvar_m == .
	*qui:sum cvar_m,d	 bwidth(0.025)
	*replace cvar_m = . if cvar_m > r(p99)
	qui:sum rescal,de
	local rescalp99 = r(p99)
	qui:sum cvar_m,de
	local cvar_mp99 = r(p99)
	
	corr rescal cvar_m if rescal<`rescalp99' & cvar_m< `cvar_mp99'
	global corrnum  = r(rho)
	global corrnum: di %4.2f  ${corrnum}

			
	colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 ) // "0 114 178" "213 94 0"
	tw (histogram cvar_m if cvar_m < 1.5,lcolor("`r(p1)'") fcolor(none) ylabel(0(5)20) ) ///
			(histogram rescal if rescal < 1.5, lcolor("`r(p2)'")  fcolor(none) ylabel(0(5)20)), ///				
			legend(order(1 "CV" 2 "Std(ln(Y{sub:it})|Y{sub:it-1})") ///
			symxsize(7.0) ring(0) position(1) col(1) ///
			region(color(none) lcolor(white))) ///
			xtitle("Risk") ytitle("Histogram") ///
			graphregion(color(white)  ) ///				Graph region define
			plotregion(lcolor(black))  ///				Plot regione define
			text(19.5 .03  "Correlation: ${corrnum}", place(e) size(median)) //
			//title("Histogram of CV and rescaled Std(ln(Y{sub:it})|Y{sub:it-1})", color(black)) //	
	cap noisily: graph export "`labname'_`inc_var'_cv_sdres_den_all.${formatfile}", replace 	
	restore 
	

	}
	}
	
	
	
if "${tfcvden_quantile}" == "yes"{ 

	
	foreach mdname in "TS_quantile" {    
	
	*local mdname = "TS_quantile"
	use "${`mdname'}",clear
	
	if ("`mdname'" == "TS_quantile"){	    
	    local labname = "TS_quantile"
		merge 1:1 person_id year using "${TS2018}"
		drop if _merge ==2
		local inc_var = "tot_inc"
	}
	
	
	preserve 	
	keep person_id year tot_inc_disp cvar_m `inc_var'_lag
	replace tot_inc_disp = . if tot_inc_disp<0								
		
	gen rescal = tot_inc_disp/(1.2815515655446004*2)
	replace rescal =  sqrt(2/c(pi))*rescal   //(4*normal(rescal/2) - 2)
	

	qui: sum cvar_m_abs,de
	local cvar_m_absp99 = r(p99)
	qui: sum rescal,de
	local rescalp99 = r(p99)
	qui: sum tot_inc_disp,de
	local tot_inc_dispp99 = r(p99)
	
	corr cvar_m_abs rescal if cvar_m_abs<`cvar_m_absp99' & rescal<`rescalp99'
	global corrnum1  = r(rho)
	global corrnum1: di %4.2f  ${corrnum1}
	
	corr cvar_m_abs tot_inc_disp if cvar_m_abs<`cvar_m_absp99' & tot_inc_disp<`tot_inc_dispp99'
	global corrnum2  = r(rho)

			
	colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 ) // "0 114 178" "213 94 0"
	tw (histogram cvar_m if cvar_m < 1.5,lcolor("`r(p1)'") fcolor(none) ylabel(0(5)20) ) ///
			(histogram rescal if rescal < 1.5, lcolor("`r(p2)'")  fcolor(none) ylabel(0(5)20)), ///				
			legend(order(1 "CV" 2 "Rescaled quantile-based dispersion") ///
			symxsize(7.0) ring(0) position(1) col(1) ///
			region(color(none) lcolor(white))) ///
			xtitle("Risk") ytitle("Histogram") ///
			graphregion(color(white)  ) ///				Graph region define
			plotregion(lcolor(black))  ///    //				Plot regione define
			text(19.5 .03  "Correlation: ${corrnum1}", place(e) size(median)) //
			//title("Histogram of CV and rescaled Quantile-based dispersion", color(black)) //	
	cap noisily: graph export "`labname'_`inc_var'_cv_resqt_den_all.${formatfile}", replace 		
	
	restore 
			

	}
	}	

	
if "${tfcvcomp}" == "yes"{
    ******************************************
	local mdname_x = "TS2018" 
	local inc_var = "tot_inc"	
	local labname_x = "TS"
	
	foreach mdname_y in "NN_k8k7_2018" "TS_k4DUM_2018" "TS_k6DUM_2018" { // "TS2018_wage" "TS2018_timevary"
	
	if "`mdname_y'" == "NN_k8k7_2018"{
	    local labname_y = "NN" 
		local yaxisname = "CV, NN" 
	}
	if "`mdname_y'" == "TS_k4DUM_2018"{
		local labname_y = "TS_k4" //TS_k4 TS_k6 NN
		local yaxisname = "CV, Heterogeneous" // "CV, NN" "CV, Heterogeneous"
	}
	if "`mdname_y'" == "TS_k6DUM_2018"{
		local labname_y = "TS_k6" //TS_k4 TS_k6 NN
		local yaxisname = "CV, Heterogeneous" // "CV, NN" "CV, Heterogeneous"
	}
	if "`mdname_y'" == "TS2018_wage"{
		local labname_y = "TS_wage" //TS_k4 TS_k6 NN
		local yaxisname = "CV, wage" // "CV, NN" "CV, Heterogeneous"
	}
	if "`mdname_y'" == "TS2018_timevary"{
		local labname_y = "TS_timevary" //TS_k4 TS_k6 NN
		local yaxisname = "CV, time-varying coef." // "CV, NN" "CV, Heterogeneous"
	}	
	
	use "${`mdname_x'}",clear
	
	rename cvar_m_abs cvar_m_x
	
	merge 1:1 person_id year using "${`mdname_y'}", keepusing(cvar_m_abs)
	drop if _merge ==2
	rename cvar_m_abs cvar_m_y	
	
    keep person_id year cvar_m_x cvar_m_y
	
	preserve 	
	qui:sum cvar_m_x,de
	local xp99 = r(p99)
	qui:sum cvar_m_y,de
	local yp99 = r(p99)
	
	corr cvar_m_x cvar_m_y if cvar_m_x < `xp99' & cvar_m_y < `yp99'
	global corrnum  = r(rho)
	global corrnum: di %4.2f  ${corrnum}
	
	colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 ) // "0 114 178" "213 94 0"
	tw (histogram cvar_m_x if cvar_m_x < 1.5,lcolor("`r(p1)'") fcolor(none) ylabel(0(5)20) ) ///
			(histogram cvar_m_y if cvar_m_y < 1.5, lcolor("`r(p2)'")  fcolor(none) ylabel(0(5)20)), ///				
			legend(order(1 "CV, Exponential" 2 "`yaxisname'") ///
			symxsize(7.0) ring(0) position(1) col(1) ///
			region(color(none) lcolor(white))) ///
			xtitle("Risk") ytitle("Histogram") ///
			graphregion(color(white)  ) ///				Graph region define
			plotregion(lcolor(black))  ///				Plot regione define
			text(19.5 .03  "Correlation: ${corrnum}", place(e) size(median)) //
			//title("Histogram of CV and rescaled Std(ln(Y{sub:it})|Y{sub:it-1})", color(black)) //	
	cap noisily: graph export "`labname_x'_`inc_var'_cv_`labname_y'_den_all.${formatfile}", replace 	
	restore 
	
	
}
}

* Income risk inequality in Spain over time and lifecycle
if "${tfcvt}" == "yes"{ 

	foreach mdname in "TS_robust"  "TS_k4DUM_2018" "NN_k8k7_2018" { // "TS2018" "TS2018_wage" "TS2018_timevary"  "TS2018_permnt" "TS2018_npermnt"  "TS_disp2018" "TS_robust"  "TS_k4DUM_2018" "TS_k6DUM_2018" "NN_k8k7_2018" "TS_alt2nd" "TS_3zeros" "TS2018_funcion"  "TS_morevars" "TS_fem2018"
		
	use "${`mdname'}",clear
	
	if "`mdname'" == "TS2018_funcion"{
	   keep if funcionario_main_prev == 1 & permanent_main_prev == 1
	}
	
	if "`mdname'" == "TS2018_permnt"{
	   keep if permanent_main_prev == 1
	}
	if "`mdname'" == "TS2018_npermnt"{
	   keep if permanent_main_prev == 0
	}
	
	if "`mdname'" == "NN_k8k7_2018"{
	    merge 1:1 person_id year using "${Tot_sample}"
		keep if _merge ==3
		drop _merge	
	}
	
	qui:sum year 
	if "`r(min)'"=="1"{
	    replace year = year + 2005
	}
	   
	* Over time 
	preserve 
	collapse (p10) cvp10 = cvar_m ///
			 (p25) cvp25 = cvar_m ///
			 (p50) cvp50 = cvar_m ///
			 (p75) cvp75 = cvar_m ///
			 (p90) cvp90 = cvar_m, by(year) //
	gen cvp9010 = cvp90/cvp10
	gen cvp9050 = cvp90/cvp50
	gen cvp5010 = cvp50/cvp10
	
	save "cvar_m_`mdname'_distovertime.dta",replace
	
	gen rece = inlist(year,${receyears})
	
	tspltAREALimPA "cvp90 cvp75  cvp50 cvp25  cvp10" /// Which variables?
	   "year" ///
	   2006 2018 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Year" /// x axis title
	   "Percentiles of CV" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "cvar_m_`mdname'_distovertime"	/// Figure name
	   "0" "2.0" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
	
 	  * CV inequality	
  	replace rece = rece*20  
	tsplt2sc "cvp9010" "cvp50" /// variables plotted
		   "year" ///
		    2006 2018 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
		   "P90/P10" "P50"  /// Labels 
		   "Year" /// x axis title
		   "P90/P10 of CV" /// y axis title (left)
		   "P50 of CV" /// y axis title  (right)
		   "" ///  Plot title
		   ""  /// 	 Plot subtitle  (left blank in this example)
		   "cvar_m_`mdname'_p9010"	// Figure name 
	 replace rece = rece/20	     
	     * CV inequality
	 tspltAREALimPA "cvp9050 cvp5010" /// Which variables?
	   "year" ///
	   2006 2018 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90/P50" "P50/P10" "" "" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Year" /// x axis title
	   "Dispersion of CV" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "cvar_m_`mdname'_p9050_p5010"	/// Figure name
	   "0" "9" "3"				/// ylimits
	   "" 						/// If legend is active or nor	
	   "blue red navy blue maroon forest_green purple gray orange"			/// Colors
	   "O S" 	  
	   
	restore
			 
	
	preserve 
	collapse (p10) cvp10 = cvar_m ///
			 (p25) cvp25 = cvar_m ///
			 (p50) cvp50 = cvar_m ///
			 (p75) cvp75 = cvar_m ///
			 (p90) cvp90 = cvar_m, by(age) //
	
	save "cvar_m_`mdname'_distoverage.dta",replace

	tspltAREALimPA2 "cvp90 cvp75  cvp50 cvp25  cvp10" /// Which variables?
	   "age" ///
	   25 55 10 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Age" /// x axis title
	   "Percentiles of CV" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "cvar_m_`mdname'_distoverage"	/// Figure name
	   "0" "2.0" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
	 restore
	 	
	 }
	 
}

if "${tfcvt_quantile}" == "yes"{ 

	foreach mdname in "TS_quantile" { 
		
	use "${`mdname'}",clear	
	
	* Over time 
	preserve 
	collapse (p10) kellyp10 = tot_inc_skew qtdispp10 = tot_inc_disp ///
			 (p25) kellyp25 = tot_inc_skew qtdispp25 = tot_inc_disp ///
			 (p50) kellyp50 = tot_inc_skew qtdispp50 = tot_inc_disp ///
			 (p75) kellyp75 = tot_inc_skew qtdispp75 = tot_inc_disp ///
			 (p90) kellyp90 = tot_inc_skew qtdispp90 = tot_inc_disp, by(year) //

	
	save "cvar_m_`mdname'_distovertime.dta",replace
	gen rece = inlist(year,${receyears})
	
	tspltAREALimPA "kellyp90 kellyp75  kellyp50 kellyp25  kellyp10" /// Which variables?
	   "year" ///
	   2006 2018 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Year" /// x axis title
	   "Percentiles of Skewness" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "kelly_`mdname'_distovertime"	/// Figure name
	   "-0.5" "1.0" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 

	tspltAREALimPA "qtdispp90 qtdispp75  qtdispp50 qtdispp25  qtdispp10" /// Which variables?
	   "year" ///
	   2006 2018 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Year" /// x axis title
	   "Percentiles of Dispersion" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "quantile_disp_`mdname'_distovertime"	/// Figure name
	   "0" "2" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 	   
	   	
	restore
			 
	
	preserve 
	collapse (p10) kellyp10 = tot_inc_skew qtdispp10 = tot_inc_disp ///
			 (p25) kellyp25 = tot_inc_skew qtdispp25 = tot_inc_disp ///
			 (p50) kellyp50 = tot_inc_skew qtdispp50 = tot_inc_disp ///
			 (p75) kellyp75 = tot_inc_skew qtdispp75 = tot_inc_disp ///
			 (p90) kellyp90 = tot_inc_skew qtdispp90 = tot_inc_disp, by(age) //
	
	save "cvar_m_`mdname'_distoverage.dta",replace
	
	tspltAREALimPA2 "kellyp90 kellyp75  kellyp50 kellyp25  kellyp10" /// Which variables?
	   "age" ///
	   25 55 10 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Age" /// x axis title
	   "Percentiles of Skewness" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "kelly_`mdname'_distoverage"	/// Figure name
	   "-0.4" "0.6" "0.2"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
	
	tspltAREALimPA2 "qtdispp90 qtdispp75  qtdispp50 qtdispp25  qtdispp10" /// Which variables?
	   "age" ///
	   25 55 10 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Age" /// x axis title
	   "Percentiles of Dispersion" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "quantile_disp_`mdname'_distoverage"	/// Figure name
	   "0" "3" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
	 	 
	 restore
	 	
	 }
	 
}





* Income risk: dynamics 
if "${tfcvdyn}" == "yes"{ 
	foreach mdname in  "TS_robust"  "TS_k4DUM_2018" "NN_k8k7_2018"  { //"TS2018"  "TS2018_wage" "TS2018_timevary" "TS_disp2018" "TS_robust" "TS_k4DUM_2018" "TS_k6DUM_2018" "NN_k8k7_2018" "TS_alt2nd" "TS_3zeros" "TS2018_funcion" "TS_morevars" "TS_fem2018"  "TS2018_permnt" "TS2018_npermnt" 	
	
	use "${`mdname'}",clear
	
	if "`mdname'" == "TS2018_funcion"{
	   keep if funcionario_main_prev == 1 & permanent_main_prev == 1
	}
	
	if "`mdname'" == "TS2018_permnt"{
	   keep if permanent_main_prev == 1
	}
	if "`mdname'" == "TS2018_npermnt"{
	   keep if permanent_main_prev == 0
	}
	
	if "`mdname'" == "NN_k8k7_2018"{
	    merge 1:1 person_id year using "${Tot_sample}"
		keep if _merge ==3	
		drop _merge	
	}
	
	qui:sum year 
	if "`r(min)'"=="1"{
	    replace year = year + 2005
	}
	capture rename cvar_m cvar_m_abs
	
	if "`mdname'"  == "TS2018" | "`mdname'"  == "TS_disp2018" | "`mdname'"  == "TS2018_timevary"{
	    local ymin = 0.0
		local ymax = 2.0
		local ygp = 0.5
	}
	if "`mdname'"  == "TS_robust"{
	    local ymin = 0.0
		local ymax = 4.5
		local ygp = 1.0
	}
	if "`mdname'"  == "TS2018_funcion"{
	    local ymin = 0.0
		local ymax = 0.6
		local ygp = 0.2
	}
	
	if "`mdname'"  == "TS2018_wage"{
	    local ymin = 0.0
		local ymax = 3.0
		local ygp = 0.5
	}
	
	
	* conditional on days worked in t-1	
	preserve
	* Generate ranks
	sum days_lag1
	gen rank =  round(days_lag1/r(max)*12)
		
	* Collapse by rank
	collapse	(p10) cvp10= cvar_m ///
				(p25) cvp25= cvar_m ///
				(p50) cvp50= cvar_m ///
				(p75) cvp75= cvar_m ///
				(p90) cvp90= cvar_m, by(rank)
	replace rank = rank /12*100				
	drop if missing(rank)	
	save "cvar_m_`mdname'_dist_cond_wkdaylag_ageall.dta",replace
	
	*drop if rank == 100
	tspltAREALimPA2 "cvp90 cvp75  cvp50 cvp25  cvp10" /// Which variables?
	   "rank" ///
	   0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Days worked at t-1 (% of year)" /// x axis title
	   "Percentiles of CV" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "cvar_m_`mdname'_dist_cond_wkdaylag_ageall"	/// Figure name
	   "`ymin'" "`ymax'" "`ygp'"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
	restore 
	
	* conditional on y_t_1	
	preserve
	* Generate ranks
	xtile rank = tot_inc, n(50)
		
	* Collapse by rank
	collapse	(p10) cvp10= cvar_m ///
				(p25) cvp25= cvar_m ///
				(p50) cvp50= cvar_m ///
				(p75) cvp75= cvar_m ///
				(p90) cvp90= cvar_m, by(rank)
	replace rank = rank * 2				
	drop if missing(rank)	
	save "cvar_m_`mdname'_dist_cond_inclag_ageall.dta",replace
	
	drop if rank == 100
	tspltAREALimPA2 "cvp90 cvp75  cvp50 cvp25  cvp10" /// Which variables?
	   "rank" ///
	   0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Percentiles of Y{sub:it-1}" /// x axis title
	   "Percentiles of CV" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "cvar_m_`mdname'_dist_cond_inclag_ageall"	/// Figure name
	   "`ymin'" "`ymax'" "`ygp'"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
	restore 	
	
	* conditional on cvar_t_1
	preserve 
		xtset person_id year 
		gen cvar_m_lag = l.cvar_m
		xtile rank = cvar_m_lag, n(50)
		replace rank = rank * 2	
		*drop if rank == 100
		* Collapse by rank
		collapse	(p10) cvp10= cvar_m_abs ///
					(p25) cvp25= cvar_m_abs ///
					(p50) cvp50= cvar_m_abs ///
					(p75) cvp75= cvar_m_abs ///
					(p90) cvp90= cvar_m_abs, by(rank)
					
		drop if missing(rank)
		save "cvar_m_`mdname'_dist_cond_cvarlag_ageall.dta",replace
		
		tspltAREALimPA2 "cvp90 cvp75  cvp50 cvp25  cvp10" /// Which variables?
			"rank" ///
			0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
			"P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
			"1" "11" ///
			"Percentiles CV{sub:it-1}" /// x axis title
			"Percentiles of CV" /// y axis title 
			"" ///  Plot title
			"" ///
			"cvar_m_`mdname'_dist_cond_cvarlag_ageall"	/// Figure name
			"`ymin'" "`ymax'" "`ygp'"		/// ylimits
			"" 						/// Set to off to have inactive legend
			"blue green red navy black maroon forest_green purple gray orange"			/// Colors
			"O + S T x D" 
	restore	
		
	
	forval i = 1/6{
	    preserve		
		keep if (age <= (`i')*5+25) & (age > (`i'-1)*5+25 - 1*(`i'==1))
		*tab age
	    * conditional on cvar_t_1
		xtset person_id year 
		gen cvar_m_lag = l.cvar_m
		xtile rank = cvar_m_lag, n(50)
		replace rank = rank * 2	
		*drop if rank == 100
		* Collapse by rank
		collapse	(p10) cvp10= cvar_m_abs ///
					(p25) cvp25= cvar_m_abs ///
					(p50) cvp50= cvar_m_abs ///
					(p75) cvp75= cvar_m_abs ///
					(p90) cvp90= cvar_m_abs, by(rank)
					
		drop if missing(rank)
		save "cvar_m_`mdname'_dist_cond_cvarlag_age`i'.dta",replace
	
		tspltAREALimPA2 "cvp90 cvp75  cvp50 cvp25  cvp10" /// Which variables?
			"rank" ///
			0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
			"P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
			"1" "11" ///
			"Percentiles CV{sub:it-1}" /// x axis title
			"Percentiles of CV" /// y axis title 
			"" ///  Plot title
			"" ///
			"cvar_m_`mdname'_dist_cond_cvarlag_age`i'"	/// Figure name
			"0" "2" "0.5"		/// ylimits
			"" 						/// Set to off to have inactive legend
			"blue green red navy black maroon forest_green purple gray orange"			/// Colors
			"O + S T x D" 
		restore	
     }
	}	
			
}


		
if "${tfcvdyn_quantile}" == "yes"{ 
	foreach mdname in "TS_quantile" {
	
	use "${`mdname'}",clear
		
	* conditional on y_t_1	
	preserve
	* Generate ranks
	xtile rank = tot_inc, n(50)
		
	* Collapse by rank
	collapse (p10) kellyp10 = tot_inc_skew qtdispp10 = tot_inc_disp ///
			 (p25) kellyp25 = tot_inc_skew qtdispp25 = tot_inc_disp ///
			 (p50) kellyp50 = tot_inc_skew qtdispp50 = tot_inc_disp ///
			 (p75) kellyp75 = tot_inc_skew qtdispp75 = tot_inc_disp ///
			 (p90) kellyp90 = tot_inc_skew qtdispp90 = tot_inc_disp, by(rank) //
			 	
	replace rank = rank * 2				
	drop if missing(rank)
	
	save "cvar_m_`mdname'_dist_cond_inclag_ageall.dta",replace
	
	drop if rank == 100
	tspltAREALimPA2 "kellyp90 kellyp75  kellyp50 kellyp25  kellyp10" /// Which variables?
	   "rank" ///
	   0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Percentiles of Y{sub:it-1}" /// x axis title
	   "Percentiles of Skewness" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "kelly_`mdname'_dist_cond_inclag_ageall"	/// Figure name
	   "-1" "1" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
	
	tspltAREALimPA2 "qtdispp90 qtdispp75  qtdispp50 qtdispp25  qtdispp10" /// Which variables?
	   "rank" ///
	   0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Percentiles of Y{sub:it-1}" /// x axis title
	   "Percentiles of Dispersion" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "quantile_disp_`mdname'_dist_cond_inclag_ageall"	/// Figure name
	   "0" "4" "1"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 	  	
	   
	restore 	
	
	preserve
	* conditional on cvar_t_1
	xtset person_id year 
	gen skew_lag = l.tot_inc_skew
	xtile rank = skew_lag, n(50)
	replace rank = rank * 2	
	* Collapse by rank
	collapse (p10) kellyp10 = tot_inc_skew ///
			 (p25) kellyp25 = tot_inc_skew ///
			 (p50) kellyp50 = tot_inc_skew ///
			 (p75) kellyp75 = tot_inc_skew ///
			 (p90) kellyp90 = tot_inc_skew , by(rank) //
					
	drop if missing(rank)
	save "kelly_`mdname'_dist_cond_cvarlag_ageall.dta",replace
	
	tspltAREALimPA2 "kellyp90 kellyp75  kellyp50 kellyp25  kellyp10" /// Which variables?
	   "rank" ///
	   0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Percentiles Skewness{sub:it-1}" /// x axis title
	   "Percentiles of Skewness" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "kelly_`mdname'_dist_cond_kellylag_ageall"	/// Figure name
	   "-1" "1" "0.5"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
     restore 
	 
	preserve
	* conditional on cvar_t_1
	xtset person_id year 
	gen disp_lag = l.tot_inc_disp
	xtile rank = disp_lag, n(50)
	replace rank = rank * 2	
	* Collapse by rank
	collapse (p10) dispp10 = tot_inc_disp ///
			 (p25) dispp25 = tot_inc_disp ///
			 (p50) dispp50 = tot_inc_disp ///
			 (p75) dispp75 = tot_inc_disp ///
			 (p90) dispp90 = tot_inc_disp , by(rank) //
					
	drop if missing(rank)
	save "quantile_`mdname'_dist_cond_cvarlag_ageall.dta",replace
	
	tspltAREALimPA2 "dispp90 dispp75  dispp50 dispp25 dispp10" /// Which variables?
	   "rank" ///
	   0 100 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "Percentiles Dispersion{sub:it-1}" /// x axis title
	   "Percentiles of Dispersion" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "quantile_disp_`mdname'_dist_cond_displag_ageall"	/// Figure name
	   "0" "4" "1"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 
     restore 
	 		 
	 
	}	
			
}

		
		
if "${tftab1_3}" == "yes"{
    
	foreach mdname in  "TS_robust"  "TS_k4DUM_2018" "NN_k8k7_2018"  { // "TS_fem2018" "TS2018" "TS_disp2018"  "TS_robust"  "TS_k4DUM_2018" "TS_k6DUM_2018" "NN_k8k7_2018"  "TS2018_funcion" "TS_morevars"  "TS2018_permnt" "TS2018_npermnt"	
	*local mdname = "TS2018"
	use "${`mdname'}",clear	
	
	if "`mdname'" == "TS2018_funcion"{
	   keep if funcionario_main_prev == 1 & permanent_main_prev == 1
	}
	
	if "`mdname'" == "TS2018_permnt"{
	   keep if permanent_main_prev == 1
	}
	if "`mdname'" == "TS2018_npermnt"{
	   keep if permanent_main_prev == 0
	}
	
	if "`mdname'" == "NN_k8k7_2018"{
	    merge 1:1 person_id year using "${Tot_sample}"
		keep if _merge == 3
		drop _merge	
	}
	
	keep person_id year age cvar_m //unemployment*_lag* age*unemployment*_lag* ///
			//gdp*_lag* age*gdp*_lag* //cvar_u cvar_l
	qui:sum year 
	if "`r(min)'"=="1"{
	    replace year = year + 2005
	}
	save "IR_prediction_`mdname'.dta", replace
     	
********************************************************************************
* make tables
********************************************************************************
	
	local spl = "male"
	if "`mdname'" == "TS_fem2018"{
	   local spl = "fem"
	}
	* iterate over file and measures 
	foreach cvar in "cvar_m"{
		u person_id year age `cvar' using "IR_prediction_`mdname'.dta", clear
		
		*local cvar "cvar_m"
		*u person_id year age `cvar' using "${maindir}/out/paper_tab_figs_05Mar2021/IR_prediction_TS2018_male.dta",clear 
		
		*drop if year == 2017  // exclude 2017
		rename `cvar' IR 
		* tab 1 
		local hname1 "Risk_"
		forval i = 2006/2018{
			gen IR`i' = IR if year == `i'
		}
		estpost tabstat IR*,  statistics(p10 p25 p50 p75 p90)
		
		* store names 
		local namep: colnames e(IR)
		* compute p9010 p9050 p5010
		matrix define temp = e(IR)
		matrix define IR = (temp[1,5]/temp[1,1],temp[1,5]/temp[1,3],temp[1,3]/temp[1,1],e(IR) )
		matrix colnames IR = P9010 \;\;\;P9050 \;\;\;P5010 `namep'
	
		forval i = 2/14{
			local j = `i' + 2004
			matrix define temp = e(IR`j')
			matrix define IR`j' = (temp[1,5]/temp[1,1],temp[1,5]/temp[1,3],temp[1,3]/temp[1,1],e(IR`j') )
			matrix colnames IR`j' = P9010 \;\;\;P9050 \;\;\;P5010 `namep'
		}


		estadd matrix `hname1'all = IR,replace
		forval i = 2006/2018{
			estadd matrix `hname1'`i' = IR`i',replace
		}
		
		
		esttab using tab1_`mdname'_`spl'_`cvar'.tex, cells("`hname1'all(fmt(%3.2f)) `hname1'2006 `hname1'2007 `hname1'2008 `hname1'2009 `hname1'2010 `hname1'2011 `hname1'2012 `hname1'2013 `hname1'2014 `hname1'2015 `hname1'2016 `hname1'2017 `hname1'2018 " ) ///
			noobs nonumber nomtitles replace
		esttab using tab1_`mdname'_`spl'_`cvar'.csv, cells("`hname1'all(fmt(%3.2f)) `hname1'2006 `hname1'2007 `hname1'2008 `hname1'2009 `hname1'2010 `hname1'2011 `hname1'2012 `hname1'2013 `hname1'2014 `hname1'2015 `hname1'2016 `hname1'2017 `hname1'2018 " ) ///
			noobs nonumber nomtitles replace
		* tab 2
		local hname2 = "Risk_" 
		matrix define den = e(IR)   // denominator 
		forval i = 25(5)55{
			gen age`i' = IR if age == `i'
		}
		estpost tabstat age*,  statistics(p10 p25 p50 p75 p90)
		forval j = 25(5)55{
			matrix define temp = e(age`j')
			matrix define age`j' = (temp[1,1]/den[1,1],temp[1,2]/den[1,2],temp[1,3]/den[1,3],temp[1,4]/den[1,4],temp[1,5]/den[1,5] )
			matrix colnames age`j' = P1010 P2525 P5050 P7575 P9090
		}

		forval i = 25(5)55{
			estadd matrix `hname2'`i' = age`i',replace
		}
	*esttab, cells("`hname2'25(fmt(%3.2f)) `hname2'35 `hname2'45 `hname2'55" ) ///
	*noobs nonumber nomtitles replace
		esttab using tab2_`mdname'_`spl'_`cvar'.tex, cells("`hname2'25(fmt(%3.2f)) `hname2'30 `hname2'35 `hname2'40 `hname2'45 `hname2'50 `hname2'55" ) ///
			noobs nonumber nomtitles replace
		esttab using tab2_`mdname'_`spl'_`cvar'.csv, cells("`hname2'25(fmt(%3.2f)) `hname2'30 `hname2'35 `hname2'40 `hname2'45 `hname2'50 `hname2'55" ) ///
			noobs nonumber nomtitles replace

		
		}
	
	}

}
		

		

if "${tfcvtax}" == "yes"{

	use "${TS2018}",clear
	keep person_id year tot_inc tot_inc_lag cvar_m
	rename cvar_m_abs cv_tot
	merge 1:1 person_id year using "${TS_disp2018}",keepusing(cvar_m disp_inc)
	drop _merge
	rename cvar_m_abs cv_disp
	
	preserve 
	keep cv_tot
	sort cv_tot
	gen id = _n
	save "cv_tot.dta" ,replace	 
	restore 
	
	preserve 
	keep cv_disp
	sort cv_disp
	gen id = _n
	merge 1:1 id using "cv_tot.dta" 
	drop _merge
	
	sum id
	local temp = floor(r(max)/50)
	gen ptind = mod(id,`temp')
	qui:sum cv_tot,detail
	local cvub = r(p99)	
	colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 ) // "0 114 178" "213 94 0"
	twoway (scatter cv_disp cv_tot if cv_tot<`cvub' & ptind ==0, msymbol(circle_hollow) mlcolor("`r(p1)'")) ///
		(function y = x, range(0 `cvub') color("`r(p2)'") lpattern(dash) ), ///
		xtitle("CV, before tax") ytitle("CV, after tax") ///
		legend(off) graphregion(color(white)) //		
    drop ptind		
	graph export "qt_qt_cv_tot_disp.${formatfile}", as(pdf) replace	
	restore 
	
	
	
	preserve 
	keep tot_inc disp_inc 
	gen rk = tot_inc
	xtile rank = rk,n(100)
	collapse (mean) tot_inc disp_inc , by(rank)
	replace tot_inc = tot_inc/1000
	replace disp_inc = disp_inc/1000
	drop if rank == 100
	sum tot_inc
	local cvub = r(max)
	colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 )
	tw (line disp_inc tot_inc, lcolor("`r(p1)'") lpattern(solid)  ) ///
		(function y = x, range(0 `cvub') color("`r(p2)'") lpattern(dash) ), ///	
		xtitle("Before-tax income (in thousands)") ytitle("After-tax income (in thousands)") ///		
		legend(off) graphregion(color(white)) //
	cap noisily: graph export "tot_disp_thousands.${formatfile}", replace 
	
	
	restore 
	
	
	
}


