// FORMING SAMPLE

clear all

** Merge SS files to tax files
local end = $latest - 16
local start = $latest - 99

** Matrix to store number of observations
matrix observations = J(`end'-`start'+1, 9, 0)

* Remove past files
foreach j of numlist `start'/`end' {
	capture erase "$temp\annual_cohort`j'_pt2.dta"
}

* Loop over cohorts
local rowcounter = 1
foreach i of numlist `start'/`end' {
	* Use data
	use "$temp\cohorts\mcvl${latest}_YearMonth_`i'", clear
	
	**** Make education consistent
	gen negyear = -year
	gen miss_educ = missing(education)
	bysort person_id (miss_educ negyear): gen educ_aux = education[1]
	drop education negyear
	rename educ_aux education
	
	**** Make birth_year consistent
	bysort person_id: egen aux_byear = mean(birth_year)
	drop birth_year
	rename aux_byear birth_year
	
	replace birth_year = `i' if missing(birth_year)
	
	**** Get entry into MCVL (SS)
	gen aux1 = year if !missing(firm_cc2)
	bysort person_id: egen min_year = min(aux1)
	drop aux1
	
	* Minimum of MCVL_entry and min_year
	gen aux = cond(MCVL_entry <= min_year, MCVL_entry, min_year)
	drop min_year
	rename aux min_year
	
	* Drop observations before entry
	drop if year < min_year
	
	* Drop observations after last entry to MCVL
	bysort person_id: egen last_temp = max(MCVL_last)
	drop MCVL_last
	rename last_temp MCVL_last
	
	drop if year > MCVL_last
	
	**** Generate max_year as last contract
	gen aux1 = year if !missing(firm_cc2)
	bysort person_id: egen max_year = max(aux1)
	drop aux1
	
	**** Make MCVL_last consistent
	bysort person_id: egen last_temp = max(MCVL_last)
	drop MCVL_last
	rename last_temp MCVL_last
	
	**** Get year of death
	gen death_year = int(death_year_month / 100)
	replace death_year = . if death_year == 0
	drop death_year_month
	
	* Keep observations only before death year
	drop if year > death_year
	
	**** Merge to correct some firm_id == 0
	merge m:1 firm_cc using "$temp\firm_id_correction.dta", keep(match master)
	drop _merge
	
	replace firm_id = firm_id_correction if firm_id == 0 & !missing(firm_id_correction)
	drop firm_id_correction
	
	**** Merge with fiscal data on labor earnings only
	merge m:1 person_id firm_id year using "$temp\Fiscal${latest}_work", keep(match master)
	rename _merge merge_tax
	
	**** Family size variable (16-64)
	gen famsize_16_64 = familysize - famsize_06 - famsize_715 - famsize_a65
	
	**** Keep variables needed
	keep person_id firm_id firm_cc2 year month alta baja sex birth_year death_year education wage inkind ///
		age entryage MCVL_entry min_year max_year MCVL_last firm_muni contribution_regime merge_tax job_relationship contribution_group ///
		contribution contract_type ptcoef person_muni_latest firm_jur_status famsize_16_64 sector_cnae93 sector_cnae09 firm_workers
	
	**** Construct indicators for different types of contracts
	* Indicator for work contracts (need merged to tax)
	gen rel_contract = 0
	replace rel_contract = 1 if ((contribution_regime >= 111 & contribution_regime <= 137) | ///
								(contribution_regime >= 140 & contribution_regime <= 180) | ///
								(contribution_regime >= 611 & contribution_regime <= 650) | ///
								(contribution_regime >= 811 & contribution_regime <= 823) | ///
								(contribution_regime >= 840 & contribution_regime <= 850) | ///
								(contribution_regime >= 911 & contribution_regime <= 950)) & ///
								(job_relationship < 751 | job_relationship > 756)
	
	* Indicator for self-employment
	gen self_emp = 0
	replace self_emp = 1 if (contribution_regime >= 521 & contribution_regime <= 540) | ///
							(contribution_regime >= 721 & contribution_regime <= 740) | ///
							(contribution_regime >= 825 & contribution_regime <= 831)
																	
	bysort person_id year: egen self_emp_year = sum(self_emp)
	
	* Indicator for empleados hogar contract
	gen emp_hogar = 0
	replace emp_hogar = 1 if (contribution_regime == 138 | ///
							(contribution_regime >= 1200 & contribution_regime <= 1250)) & ///
							(job_relationship < 751 | job_relationship > 756)
							
	bysort person_id year: egen emp_hogar_year = sum(emp_hogar)	
	
	* Indicator for unemployment
	gen unemp = 0
	replace unemp = 1 if job_relationship >= 751 & job_relationship <= 756
	
	bysort person_id year: egen unemp_year = sum(unemp)
	
	**** Indicator whether "work" contracts are matched to tax data
	gen matched = 0 if rel_contract == 1
	replace matched = 1 if merge_tax == 3 & rel_contract == 1
	
	bysort person_id year: egen sum_matched = sum(matched)
	bysort person_id year: egen sum_relcon = sum(rel_contract)
	
	gen match_tax = (sum_relcon == sum_matched)
	drop matched sum_matched sum_relcon
	
	**** Make variables for permanent and fulltime (main job)
	qui do "$do\mainjob_vars.do"
	
	**** Firm and occ variables
	gen main_sector93 = sector_cnae93 if recent_main_contract == 1
	gen main_sector09 = sector_cnae09 if recent_main_contract == 1
	gen main_fsize = firm_workers if recent_main_contract == 1
	gen main_occ = contribution_group if recent_main_contract == 1
	
	**** FOR TESTING ****
	*gen public_all = inlist(job_relationship, 901, 902, 910) if rel_contract == 1
	*gen funcionario_all = inlist(job_relationship, 901, 902, 932, 937) if rel_contract == 1
	*********************
	
	**** Get the firm municipality of main contract
	gen firm_muni_main = firm_muni if recent_main_contract == 1
	drop recent_main_contract
	
	**** Make wage == . for non-relevant SS regimes
	replace wage = . if rel_contract == 0 | self_emp == 1 | unemp == 1 | emp_hogar == 1
	drop self_emp emp_hogar unemp
	rename self_emp_year self_emp
	rename emp_hogar_year emp_hogar
	rename unemp_year unemp
	
	**** Indicators for Basque Country and Navarra for any contract
	gen basque_navarra = 0
	replace basque_navarra = 1 if (firm_muni >=  1000 & firm_muni <  2000) | ///
									(firm_muni >= 20000 & firm_muni < 21000) | ///
									(firm_muni >= 31000 & firm_muni < 32000) | ///
									(firm_muni >= 48000 & firm_muni < 49000)
									
	**** Keep variables to make into panel
	keep person_id firm_id sex birth_year death_year education wage inkind year ///
		MCVL_entry min_year MCVL_last basque_navarra self_emp emp_hogar max_year match_tax unemp ///
		person_muni_latest permanent_main fulltime_main continuing_main govt_main firm_muni_main ///
		public funcionario main_sector93 main_sector09 main_fsize main_occ famsize_16_64
		
	**** Panelize
	qui count
	if `r(N)' > 0 {
		**** First, as a person_id-firm_id-year panel
		gen negyear = -year
		sort person_id negyear
		collapse (mean) wage inkind sex birth_year death_year MCVL_entry min_year MCVL_last max_year ///
				(sum) basque_navarra ///
				(max) famsize_16_64 main_sector93 main_sector09 main_fsize main_occ ///
				(firstnm) education self_emp emp_hogar match_tax unemp person_muni_latest public funcionario ///
							permanent_main fulltime_main continuing_main govt_main firm_muni_main, ///
							by(person_id firm_id year)
		compress
		
		**** Next, as a person_id-year panel
		gen negyear = -year
		sort person_id negyear
		collapse (sum) wage inkind basque_navarra ///
				(max) famsize_16_64 ///
				(firstnm) education self_emp emp_hogar match_tax unemp sex ///
				birth_year death_year MCVL_entry min_year MCVL_last max_year public funcionario main_occ ///
				person_muni_latest permanent_main fulltime_main continuing_main govt_main firm_muni_main main_sector93 main_sector09 main_fsize, ///
				by(person_id year)
		compress
		
		**** Fill-in
		fillin person_id year
		
		* Remove before entry
		bysort person_id: egen minyr_mode = mean(min_year)
		drop min_year
		rename minyr_mode min_year
		
		drop if year < min_year
		
		* Remove after death
		bysort person_id: egen death_year_aux = mean(death_year)
		drop death_year
		rename death_year_aux death_year
		
		drop if year > death_year
		
		* Make consistent fixed variables
		bysort person_id: egen sex_aux = mean(sex)
		drop sex
		rename sex_aux sex
		
		bysort person_id: egen byear_aux = mean(birth_year)
		drop birth_year
		rename byear_aux birth_year
		
		bysort person_id: egen dyear_aux = mean(death_year)
		drop death_year
		rename dyear_aux death_year
		
		bysort person_id: egen educ_aux = mean(education)
		drop education
		rename educ_aux education
		
		bysort person_id: egen maxyr_aux = mean(max_year)
		drop max_year
		rename maxyr_aux max_year
		
		bysort person_id: egen entry_aux = mean(MCVL_entry)
		drop MCVL_entry
		rename entry_aux MCVL_entry
		
		**** Merge with unemployment tax files
		merge 1:1 person_id year using "$temp\Fiscal${latest}_unemp_det", keep(match master)
		drop _merge
		
		**** Merge with professional income tax files
		merge 1:1 person_id year using "$temp\Fiscal${latest}_prof_det", keep(match master)
		drop _merge
		
		**** Merge with retirementyear from pensions file
		merge m:1 person_id using "$temp\all_pensiones.dta", keep(master matched)
		drop _merge
		
		**** Merge to get days
		merge 1:1 person_id year using "$temp\mcvl_annual_panel_days.dta", keep(match master)
		drop _merge
			
		compress
		
		* Adjust days
		gen aux = 1 if missing(days)
		replace days = 0 if missing(days)
		replace days_lag1 = 0 if missing(days_lag1) & min_year <= year - 1 & aux == 1
		replace days_lag2 = 0 if missing(days_lag2) & min_year <= year - 2 & aux == 1
		replace days_lag3 = 0 if missing(days_lag3) & min_year <= year - 3 & aux == 1
		
		**** Extend self-employment spells
		bysort person_id (year): replace self_emp = 1 if self_emp[_n-1] > 0 & !missing(self_emp[_n-1]) & ///
														(self_emp == 0 | missing(self_emp)) & ///
														(days == 0 | missing(days)) & ///
														(inc_unemp == 0 | missing(inc_unemp)) & ///
														_n > 1
		
		* Variable indicating previous year self_emp
		xtset person_id year
		gen selfemp_prev = (l.self_emp > 0 & !missing(l.self_emp))
		
		**** Determine province and comunidad autonoma
		gen province = .
		gen comunidad = .
		
		* Use firm province of main job
		replace province = trunc(firm_muni_main / 1000) if !missing(firm_muni_main) & firm_muni_main != 0
		gen tag1 = (!missing(province))
		
		* Main job: Copy forward
		bysort person_id (year): replace province = province[_n-1] if _n > 1 & missing(province) & !missing(province[_n-1])
		gen tag2 = (!missing(province) & tag1 == 0)
		
		* Main job: Copy backward
		gen neg_year = -year
		bysort person_id (neg_year): replace province = province[_n-1] if _n > 1 & missing(province) & !missing(province[_n-1])
		gen tag3 = (!missing(province) & tag1 == 0 & tag2 == 0)
		
		* Use firm province in padron
		replace province = trunc(person_muni_latest / 1000) if !missing(person_muni_latest) & person_muni_latest != 0 & ///
																missing(province)
		gen tag4 = (!missing(province) & tag1 == 0 & tag2 == 0 & tag3 == 0)
		
		* Padron: Copy forward
		bysort person_id (year): replace province = province[_n-1] if _n > 1 & missing(province) & !missing(province[_n-1])
		gen tag5 = (!missing(province) & tag1 == 0 & tag2 == 0 & tag3 == 0 & tag4 == 0)
		
		* Padron: Copy backward
		bysort person_id (neg_year): replace province = province[_n-1] if _n > 1 & missing(province) & !missing(province[_n-1])
		gen tag6 = (!missing(province) & tag1 == 0 & tag2 == 0 & tag3 == 0 & tag4 == 0 & tag5 == 0)
		
		drop neg_year
		
		* Comunidad autonoma
		replace comunidad = 1 if inlist(province, 4, 11, 14, 18, 21, 23, 29, 41)
		replace comunidad = 2 if inlist(province, 22, 44, 50)
		replace comunidad = 3 if inlist(province, 33)
		replace comunidad = 4 if inlist(province, 7)
		replace comunidad = 5 if inlist(province, 35, 38)
		replace comunidad = 6 if inlist(province, 39)
		replace comunidad = 7 if inlist(province, 5, 9, 24, 34, 37, 40, 42, 47, 49)
		replace comunidad = 8 if inlist(province, 2, 13, 16, 19, 45)
		replace comunidad = 9 if inlist(province, 8, 17, 25, 43)
		replace comunidad = 10 if inlist(province, 3, 12, 46)
		replace comunidad = 11 if inlist(province, 6, 10)
		replace comunidad = 12 if inlist(province, 15, 27, 32, 36)
		replace comunidad = 13 if inlist(province, 28)
		replace comunidad = 14 if inlist(province, 30)
		replace comunidad = 15 if inlist(province, 31)
		replace comunidad = 16 if inlist(province, 1, 48, 20)
		replace comunidad = 17 if inlist(province, 26)
		replace comunidad = 18 if inlist(province, 51)
		replace comunidad = 19 if inlist(province, 52)
		
		**** Family size
		bysort person_id (year): replace famsize_16_64 = famsize_16_64[_n-1] if missing(famsize_16_64) & _n > 1
		
		gen negyear = -year
		bysort person_id (negyear): replace famsize_16_64 = famsize_16_64[_n-1] if missing(famsize_16_64) & _n > 1
		
		drop negyear
		
		**** Firm size
		replace main_fsize = -99 if missing(main_fsize) & wage == 0
		replace main_fsize = -89 if missing(main_fsize) & wage > 0
		
		**** "OCCUPATION" (contribution group)
		replace main_occ = . if (main_occ < 1 | main_occ > 10) & !missing(main_occ)
		replace main_occ = -99 if missing(main_occ)
		
		**** SECTOR
		gen sector = .
		
		*** Work with CNAE93
		* Agriculture and food
		replace sector = 1 if (main_sector93 == 1 | main_sector93 == 10 | main_sector93 == 16)
		replace sector = 1 if (main_sector93 >= 11 & main_sector93 <= 15)
		replace sector = 1 if (main_sector93 == 20 | main_sector93 == 50)
		replace sector = 1 if (main_sector93 >= 101 & main_sector93 <= 145)
		replace sector = 1 if (main_sector93 >= 151 & main_sector93 <= 162)
		
		* Clothing industry
		replace sector = 2 if (main_sector93 >= 171 & main_sector93 <= 193)
		
		* Chemical and machinery
		replace sector = 2 if (main_sector93 == 24 | main_sector93 == 31)
		replace sector = 2 if (main_sector93 >= 201 & main_sector93 <= 223)
		replace sector = 2 if (main_sector93 >= 231 & main_sector93 <= 239)
		replace sector = 2 if (main_sector93 >= 241 & main_sector93 <= 268)
		replace sector = 2 if (main_sector93 >= 271 & main_sector93 <= 297)
		
		* Car industry and others
		replace sector = 2 if (main_sector93 >= 341 & main_sector93 <= 355)
		replace sector = 2 if (main_sector93 >= 300 & main_sector93 <= 335)
		replace sector = 2 if (main_sector93 >= 360 & main_sector93 <= 366)
		
		* Construction
		replace sector = 4 if (main_sector93 >= 451 & main_sector93 < 500)
		
		* Sales
		replace sector = 3 if (main_sector93 >= 501 & main_sector93 <= 532)
		
		* Hotels
		replace sector = 5 if (main_sector93 >= 551 & main_sector93 <= 591)
		
		* Transportation
		replace sector = 3 if (main_sector93 >= 601 & main_sector93 <= 634)
		
		* Energy and telecommunications
		replace sector = 3 if (main_sector93 >= 371 & main_sector93 <= 439)
		replace sector = 3 if (main_sector93 >= 641 & main_sector93 <= 649)
		replace sector = 3 if (main_sector93 >= 721 & main_sector93 <= 726)
		
		* Finance
		replace sector = 6 if (main_sector93 >= 651 & main_sector93 <= 672)
		
		* Corporate services
		replace sector = 6 if (main_sector93 >= 701 & main_sector93 <= 714)
		replace sector = 6 if (main_sector93 >= 741 & main_sector93 <= 749)
		replace sector = 6 if (main_sector93 >= 930 & main_sector93 <= 970)
		
		* Public Administration
		replace sector = 7 if (main_sector93 >= 750 & main_sector93 <= 753)
		
		* Education
		replace sector = 8 if (main_sector93 >= 801 & main_sector93 <= 843)
		replace sector = 8 if (main_sector93 >= 731 & main_sector93 <= 732)
		
		* Health
		replace sector = 8 if (main_sector93 >= 851 & main_sector93 <= 852)
		
		* Social Services
		replace sector = 9 if (main_sector93 >= 853 & main_sector93 <= 927)
		
		*** IF CNAE93 not available, use CNAE09
		* Agriculture and food
		replace sector = 1 if inrange(main_sector09, 01, 99) & missing(sector)
		
		* Manufacturing
		replace sector = 2 if inrange(main_sector09, 100, 349) & missing(sector)
		
		* Utilities, Trade and Transportation
		replace sector = 3 if inrange(main_sector09, 350, 399) & missing(sector)
		replace sector = 3 if inrange(main_sector09, 450, 539) & missing(sector)
		
		* Construction
		replace sector = 4 if inrange(main_sector09, 410, 439) & missing(sector)
		
		* Hotel industry
		replace sector = 5 if inrange(main_sector09, 550, 569) & missing(sector)
		
		* Business services
		replace sector = 6 if inrange(main_sector09, 580, 829) & missing(sector)
		
		* Public sector
		replace sector = 7 if inrange(main_sector09, 840, 849) & missing(sector)
		
		* Health & education
		replace sector = 8 if inrange(main_sector09, 850, 889) & missing(sector)
		
		* Other services
		replace sector = 9 if inrange(main_sector09, 900, 999) & missing(sector)
		
		*** Missing values
		replace sector = -99 if missing(main_sector09) & missing(main_sector93)
		replace sector = -89 if (!missing(main_sector09) | !missing(main_sector93)) & missing(sector)
		
		*** Previous variables
		* Variable for previous province and comunidad autonoma
		sort person_id year
		xtset person_id year
		gen prov_prev = l.province
		gen CA_prev = l.comunidad
		
		**** Get previous main job characteristics
		replace permanent_main = 0 if missing(permanent_main)
		replace fulltime_main = 0 if missing(fulltime_main)
		replace continuing_main = 0 if missing(continuing_main)
		replace govt_main = 0 if missing(govt_main)
		replace public = 0 if missing(public)
		replace funcionario = 0 if missing(funcionario)
		
		gen permanent_main_prev = l.permanent_main
		gen fulltime_main_prev = l.fulltime_main
		gen continuing_main_prev = l.continuing_main
		gen govt_main_prev = l.govt_main
		gen public_main_prev = l.public
		gen funcionario_main_prev = l.funcionario
		
		gen sector_main_prev = l.sector
		gen fsize_main_prev = l.main_fsize
		
		gen famsize_lag = l.famsize_16_64
		
		**** Count added zeros
		gen added_zero = ((days == 0 | missing(days)) & self_emp == 0 & unemp == 0 & emp_hogar == 0)
		replace added_zero = 1 if _fillin == 1 & missing(inc_unemp) & missing(inc_prof)
		replace added_zero = 1 if wage == 0 & missing(inc_unemp) & missing(inc_prof) & (days == 0 | missing(days))
		replace added_zero = 0 if (!missing(wage) & wage != 0) | !missing(inc_unemp) | !missing(inc_prof)
		
		* Count sequence of zeros
		bysort person_id added_zero (year): gen added_zero_seq = 1 if _n == 1 & added_zero == 1
		bysort person_id added_zero (year): replace added_zero_seq = 1 if _n > 1 & year != year[_n-1]+1 & added_zero == 1
		bysort person_id added_zero (year): replace added_zero_seq = added_zero_seq[_n-1] + 1 if _n > 1 & ///
																						year == year[_n-1]+1 & ///
																						added_zero == 1
		replace added_zero_seq = 0 if missing(added_zero_seq)
		
		* Identify end_fill
		gen end_fill = 1 if added_zero == 1 & year > max_year
		gen end_fill_counter = 0
		bysort person_id (year): replace end_fill_counter = end_fill_counter[_n-1] + end_fill if !missing(end_fill)
		
		**** Sample selection
		* Keep only after MCVL_entry
		keep if year >= MCVL_entry
		
		* Count total observations
		matrix observations[`rowcounter', 1] = `i'
		qui count
		matrix observations[`rowcounter', 2] = `r(N)'
		
		* Remove self-employed
		qui count if self_emp > 0 & !missing(self_emp)
		matrix observations[`rowcounter', 3] = `r(N)'
		drop if self_emp > 0 & !missing(self_emp)
		
		* Remove other contracts
		qui count if emp_hogar > 0 & !missing(emp_hogar)
		matrix observations[`rowcounter', 4] = `r(N)'
		drop if emp_hogar > 0 & !missing(emp_hogar)
		
		* Remove Basque country and Navarra
		qui count if (basque_navarra > 0 & !missing(basque_navarra)) | comunidad == 15 | comunidad == 16
		matrix observations[`rowcounter', 5] = `r(N)'
		drop if (basque_navarra > 0 & !missing(basque_navarra)) | comunidad == 15 | comunidad == 16
		
		* Remove if there are unmatched relevant contracts to tax files
		qui count if match_tax == 0
		matrix observations[`rowcounter', 6] = `r(N)'
		drop if match_tax == 0
		
		* Remove observations after receiving first pension payment
		qui count if year >= retirementyear & !missing(retirementyear)
		matrix observations[`rowcounter', 7] = `r(N)'
		drop if year >= retirementyear & !missing(retirementyear)
		
		** Remove after two years at end of observation in MCVL
		*qui count if end_fill_counter > 2 & end_fill == 1
		*matrix observations[`rowcounter', 8] = `r(N)'
		*drop if end_fill_counter > 2 & end_fill == 1
		
		* Remove observations if all observations remaining are added zeros
		bysort person_id: egen added_zero_counter = sum(added_zero)
		bysort person_id: gen nobs = _N
		qui count if added_zero_counter == nobs
		matrix observations[`rowcounter', 8] = `r(N)'
		drop if added_zero_counter == nobs
		drop added_zero_counter nobs
		
		* Final count of observations
		qui count
		matrix observations[`rowcounter', 9] = `r(N)'
		
		**** Final adjustments for missings and fill-ins
		qui count
		if `r(N)' > 0 {
			* Fill-in income values for other variables
			replace wage = 0 if missing(wage) & year >= MCVL_entry
			replace inkind = 0 if missing(inkind) & year >= MCVL_entry
			replace inc_unemp = 0 if missing(inc_unemp) & year >= MCVL_entry
			replace inc_prof = 0 if missing(inc_prof) & year >= MCVL_entry
			
			* Correct label for sex
			label var sex "Male: sex == 1"
		
			* Save in temp folder
			drop basque_navarra self_emp _fillin unemp match_tax emp_hogar tag* MCVL_entry MCVL_last aux
			compress
			sort person_id year
			save "$temp\annual_cohort`i'_pt2", replace
		}	
	}
	
	local rowcounter = `rowcounter' + 1
}

**** Save results of observation count
drop _all

svmat observations

save "$temp\observation_count_morevars.dta", replace

**** APPEND ALL FILES
local last = $yrlast - 16
local end = `last' - 1
local start = $yrlast - 99

use "$temp\annual_cohort`last'_pt2", clear
foreach j of numlist `start'/`end' {
	capture append using "$temp\annual_cohort`j'_pt2"
	erase "$temp\annual_cohort`j'_pt2.dta"
}
save "$temp\mcvl_annual_panel_pt2", replace
erase "$temp\annual_cohort`last'_pt2.dta"

**** MAKE EDUCATION CONSISTENT (TAKE LATEST NON-MISSING OBSERVATION)
gen missing_ed = (education == .)
gen negyear = -year
bysort person_id (missing_ed negyear): replace education = education[1] if _n > 1
drop missing_ed negyear

* Relabel education
rename education education_7cats
gen education = .
replace education = 1 if education_7cats == 10 | education_7cats == 20
replace education = 2 if education_7cats == 30
replace education = 3 if education_7cats == 40
replace education = 4 if education_7cats == 50 | education_7cats == 60 | education_7cats == 70

sort person_id year
compress
save "$temp\mcvl_annual_panel_pt2_morevars", replace

**** DEALING WITH ZEROS ****
use "$temp\mcvl_annual_panel_pt2_morevars", clear

gen remove = (added_zero_seq > 2 & !missing(added_zero_seq))
bysort person_id (year): replace remove = remove[_n-1] if _n > 1 & remove[_n-1] == 1

drop if remove == 1
drop remove

**** PREPARE FOR PART I
** Age
* Compute age
gen age = year - birth_year
gen age_sq = age ^ 2

* Sample selection
drop if age < 24 | age > 55

* Deal with missings
keep if !missing(sex)
keep if !missing(education)

* Drop if all observations are added zeros
bysort person_id: egen added_zero_counter = sum(added_zero)
bysort person_id: gen nobs = _N
drop if added_zero_counter == nobs
drop added_zero_counter nobs

** SAVE
compress
sort person_id year
save "$out\mcvl_annual_FinalData_pt1_RemoveAllAfter2_morevars.dta", replace

**** DEALING WITH INCOME VARIABLES
* Sum up income components
gen tot_inc = wage + inc_unemp + inc_prof
gen oow_inc = inc_unemp + inc_prof

* Put income in real terms
global cpi2018 = 103.664

gen cpi = .
replace cpi = 103.664 if year == 2018
replace cpi = 101.956 if year == 2017
replace cpi = 100.000 if year == 2016
replace cpi = 100.203 if year == 2015
replace cpi = 100.707 if year == 2014
replace cpi = 100.859 if year == 2013
replace cpi = 99.458 if year == 2012
replace cpi = 97.084 if year == 2011
replace cpi = 94.077 if year == 2010
replace cpi = 92.414 if year == 2009
replace cpi = 92.680 if year == 2008
replace cpi = 89.051 if year == 2007
replace cpi = 86.637 if year == 2006
replace cpi = 83.694 if year == 2005

replace cpi = cpi / $cpi2018

replace wage = wage / cpi
replace inc_unemp = inc_unemp / cpi
replace inc_prof = inc_prof / cpi
replace tot_inc = tot_inc / cpi

drop cpi

* Remove if all contributions are zeros
gen zero_inc = (tot_inc == 0)
bysort person_id: egen tot_zero_inc = sum(zero_inc)
bysort person_id: gen nobs_indiv = _N

drop if tot_zero_inc == nobs_indiv
drop zero_inc tot_zero_inc nobs_indiv

* Generate lagged income
xtset person_id year
gen tot_inc_lag = l.tot_inc
gen oow_inc_lag = l.oow_inc

**** FINAL VARIABLE CONSTRUCTION
* Generate fullyear_lag variables
gen fullyear_lag1 = (days_lag1 >= 360)
gen fullyear_lag12 = (days_lag1 >= 360 & days_lag2 >= 360)
gen fullyear_lag123 = (days_lag1 >= 360 & days_lag2 >= 360 & days_lag3 >= 360)

* Positive lag income dummy
gen tot_inc_lag_dum = (tot_inc_lag == 0) if !missing(tot_inc_lag)

* Hermite polynomials of income
gen log_tot_inc_lag = log(tot_inc_lag)
replace log_tot_inc_lag = 0 if missing(log_tot_inc_lag) & !missing(tot_inc_lag)
qui sum log_tot_inc_lag
replace log_tot_inc_lag = (log_tot_inc_lag - r(mean)) / r(sd)

gen log_tot_inc_lag_h2 = (log_tot_inc_lag^2 - 1) 

gen log_tot_inc_lag_h3 = (log_tot_inc_lag^3 - 3*log_tot_inc_lag) 

* OOW income
gen oow_inc_lag_dum = (oow_inc_lag == 0) if !missing(oow_inc_lag)

gen log_oow_inc_lag = log(oow_inc_lag)
replace log_oow_inc_lag = 0 if oow_inc_lag == 0

qui sum log_oow_inc_lag
replace log_oow_inc_lag = (log_oow_inc_lag - r(mean)) / r(sd)

**** DEALING WITH MISSING
** Remove missing education and missing lag
keep if education != . & tot_inc_lag != .

** Remove missing days
keep if days_lag1 != . & days_lag2 != . & days_lag3 != .

** Remove missing province
by person_id: gen count_miss = 1 if missing(prov_prev)
by person_id: egen sum_miss = sum(count_miss)
drop if sum_miss > 0
drop count_miss sum_miss

** Remove observations with any Basque/Navarra or Ceuta/Melilla
gen remove_prov = 1 if CA == 15 | CA ==  16 
replace remove_prov = 1 if CA == 18 | CA == 19
by person_id: egen sum_remove_prov = sum(remove_prov)
drop if sum_remove_prov > 0
drop remove_prov sum_remove_prov

* Count number of observations that will be kept and keep final_obs >= 4 (excluding 2018)
by person_id: gen final_obs = _N
gen avail2018 = (year == 2018)
by person_id: egen avail2018_indiv = sum(avail2018)
replace final_obs = final_obs - avail2018_indiv

drop avail2018*

* Estimation sample conditions
gen est_sample = 0
replace est_sample = 1 if final_obs >= 4 & year != 2018

by person_id: egen any_est = sum(est_sample)
drop if any_est == 0

* Cluster estimation sample: final_obs >=4 (excluding 2017/2018)
gen avail2017 = (year == 2017)
by person_id: egen avail2017_indiv = sum(avail2017)
gen final_obs_cluster = final_obs - avail2017_indiv

drop avail2017*

gen est_sample_clust = 0
replace est_sample_clust = 1 if final_obs_cluster >= 4 & year != 2017 & year != 2018

by person_id: egen any_est_clust = sum(est_sample_clust)
replace est_sample_clust = 2 if est_sample_clust == 0 & any_est_clust > 0 & year == 2017

** Winsorize
*winsor2 tot_inc tot_inc_lag, suffix(_w) cuts(0 99.9) by(year sex)

** Save
compress
sort person_id year
save "$out\mcvl_annual_FinalData_pt2_RemoveAllAfter2_morevars.dta", replace


