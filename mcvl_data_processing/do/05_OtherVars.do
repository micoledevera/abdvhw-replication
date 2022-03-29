clear all
set more off

foreach j of numlist 2005/$latest {
	local end = `j' - 16
	local start = `j' - 99
	
	foreach i of numlist `start'/`end' {
		use "$temp\cohorts\BasesYearMonth`j'_`i'", clear
		
		** ADD DATA ON CONVIVIENTES
		merge m:1 person_id year using "$temp\individuals_full", update replace ///
		keep(match master match_update match_conflict)
		drop _merge expan_num* duplicate* _fillin
		
		* Age
		gen age = (time - ym(birth_year, month(birth_date)))/12
		label var age "Age of individual in years (not full)"
		
		bysort person_id (time): egen entryage_tmp = min(age) if alta != . & baja != .
		/* We put this condition so that we do not put things in the extra month-year observations we created */
		bysort person_id (time): egen entryage = max(entryage_tmp)
		drop entryage_tmp
		label variable entryage "Age of entry into labor market"
		order entryage, after(age)
		
		* Age of convivientes
		foreach x of numlist 2/10 {
			gen birthdate`x' = date(birth_date`x', "YM")
			format birthdate`x' %tdMon.CCYY
			label var birthdate`x' "Birthdate: Year-Month, conviviente `x'"
			gen yearbirth`x' =  year(birthdate`x')
			gen age`x' = (time - ym(yearbirth`x', month(birthdate`x')))/12
			label var age`x' "Age (in years), conviviente `x'"
		}
		drop birth_date? birth_date10 birthdate? birthdate10 yearbirth? yearbirth10
		
		* Remove negative ages
		foreach x of numlist 2/10 {
			replace age`x' = . if age`x' < 0
		}
		
		* Ages (rounded to nearest year)
		foreach x of numlist 2/10 {
			gen age`x'_b = round(age`x', 1)
		}
		
		* "Family size" based on the number of convivientes
		egen famsize = rownonmiss(age*)
		label var famsize "Number of people conviviendo"
		
		* Size with 0 to 6 years old, 7 to 15, and above 65
		gen famsize_06 = inrange(age2_b, 0, 6) + inrange(age3_b, 0, 6) + inrange(age4_b, 0, 6) ///
		+ inrange(age5_b, 0, 6) + inrange(age6_b, 0, 6) + inrange(age7_b, 0, 6) + inrange(age8_b, 0, 6) ///
		+ inrange(age9_b, 0, 6) + inrange(age10_b, 0, 6)
		label var famsize_06 "Number of people conviviendo between 0 and 6 years old"
		
		gen famsize_715 = inrange(age2_b, 7, 15) + inrange(age3_b, 7, 15) + inrange(age4_b, 7, 15) ///
		+ inrange(age5_b, 7, 15) + inrange(age6_b, 7, 15) + inrange(age7_b, 7, 15) + inrange(age8_b, 7, 15) ///
		+ inrange(age9_b, 7, 15) + inrange(age10_b, 7, 15)
		label var famsize_715 "Number of people conviviendo between 7 and 15 years old"
		
		gen famsize_a65 = inrange(age2_b, 65, 120) + inrange(age3_b, 65, 120) + inrange(age4_b, 65, 120) ///
		+ inrange(age5_b, 65, 120) + inrange(age6_b, 65, 120) + inrange(age7_b, 65, 120) ///
		+ inrange(age8_b, 65, 120) + inrange(age9_b, 65, 120) + inrange(age10_b, 65, 120)
		label var famsize_a65 "Number of people conviviendo above 65 years old"
		
		* Sex of convivientes
		foreach x of numlist 2/10{
			capture destring sex`x', replace
			replace sex`x' = . if age`x' == .
		}
		
		egen n_male = anycount(sex sex? sex10), values(1)
		label var n_male "Number of male conviviendo"
		
		egen n_female = anycount(sex sex? sex10), values(2)
		label var n_female "Number of female conviviendo"
		
		drop age*b age? age10 sex? sex10
		
		* More than one affiliation in the month
		bysort person_id time: gen multiple_month = (_N > 1)
		label var multiple_month "More than one episode of affiliation for month"
		order multiple_month, after(month)
		
		* Type of contract
		gen contractb = contract_type
		replace contractb = 100 if inlist(contract_type,1,17,22,49,69,70,71,32,33)
		replace contractb = 109 if inlist(contract_type,11,35,101,109)
		replace contractb = 130 if inlist(contract_type,9,29,59)
		replace contractb = 150 if inlist(contract_type,8,20,28,40,41,42,43,44,45,46,47,48,50,60,61,62,80,86,88,91,150,151,152,153,154,155,156,157)
		replace contractb = 200 if inlist(contract_type,3)
		replace contractb = 209 if inlist(contract_type,38,102,209)
		*replace contractb = 230 if inlist(contracttype,9,29,59)
		replace contractb = 250 if inlist(contract_type,63,81,89,98,250,251,252,253,254,255,256,257)
		replace contractb = 300 if inlist(contract_type,18)
		replace contractb = 309 if inlist(contract_type,185,186,309)
		replace contractb = 350 if inlist(contract_type,181,182,183,184,350,351,352,353,354,355,356,357)
		replace contractb = 401 if inlist(contract_type,14)
		replace contractb = 402 if inlist(contract_type,15)
		replace contractb = 410 if inlist(contract_type,16,72,82,92,75)
		replace contractb = 420 if inlist(contract_type,58,96)
		replace contractb = 421 if inlist(contract_type,85,87,97)
		replace contractb = 430 if inlist(contract_type,30,31)
		replace contractb = 441 if inlist(contract_type,5)
		replace contractb = 450 if inlist(contract_type,457)
		replace contractb = 500 if inlist(contract_type,4)
		*replace contractb = 501 if inlist(contracttype,14)
		*replace contractb = 502 if inlist(contracttype,15)
		replace contractb = 510 if inlist(contract_type,73,83,93,76)
		replace contractb = 520 if inlist(contract_type,6)
		replace contractb = 540 if inlist(contract_type,34)
		*replace contractb = 541 if inlist(contracttype,5)
		replace contractb = 550 if inlist(contract_type,557)
		label var contractb "Type of work contract (coherent)"
		label values contractb contract_type
		
		* Permanent and temporary contracts
		gen permanent = 1 if inlist(contractb,23,65,100,109,130,131,139,141,150,189,200, ///
		209,230,231,239,250,289,300,309,330,331,339,350,389)
		
		replace permanent = 0 if inlist(contractb,7,10,12,13,24,26,27,36,37,53,54,55,56, ///
		57,64,66,67,68,74,77,78,79,84,94,401,402,403,408,410,418,420,421,430,431,441,450, ///
		451,452,500,501,502,503,508,510,518,520,530,531,541,550,551,552)
		
		replace permanent = . if inlist(contractb,25,19,39,51,52,90,95,540,990)
		
		label var permanent "=1 if the contract is indefinido"
		
		* Part-time vs full-time contracts
		gen parttime = 1 if inlist(contractb,23,24,25,26,27,64,65,84,95,200,209,230,231, ///
		239,241,250,289,500,501,502,503,508,510,518,520,530,531,540,541,550,551,552)
		replace parttime = 0 if ptcoef == 0
		replace parttime = 1 if ptcoef !=0 & ptcoef != .
		label var parttime "=1 if contract if part-time"
		
		* Identify the top-coded observations
		merge m:1 contribution_group year month using "$raw\bounds.dta", generate(_mergebounds) keep(match master)
		drop _mergebounds
		label var min_base "Min base of cotizacion according to group and year"
		label var max_base "Max base of cotizacion according to group and year"
		
		/* Bounds are missing for:
		1. contribution_group is missing or zero
		2. year-month outside 01/1980-12/2018 */
		
		gen topcoded = (contribution >= 0.995*max_base) if contribution != . & max_base != .
		label var topcoded "Base cotizacion > max legal"
		
		/* Adjust for those whose contributions are missing:
		1. no data for affiliation available
		2. autonomo
		3. no base de cotizacion associated to the month-year-cc2-pid (_mergeBases != 3)
		4. no base de cotizacion 1980 */
		replace topcoded = . if contribution == .
		
		** Exclusions:
		* Unemployed
		replace topcoded = . if job_relationship == 751 | job_relationship == 752 | job_relationship == 753 | ///
		job_relationship == 755 | job_relationship == 756
		* Part-time workers
		replace topcoded = . if ptcoef != 0 & ptcoef != .
		* Workers who did not work entire month (30 days)
		replace topcoded = . if days != 30
		* Bases which are below the min_base
		replace topcoded = . if contribution <= 0.995 * min_base & min_base != .
		
		** FIRM-LEVEL VARIABLES
		* Employer type (firm_jur_type)
		qui destring firm_jur_type, replace force
		qui replace firm_jur_type = 0 if firm_jur_type == .
		
		* Firm type (firm_jur_status)
		qui replace firm_jur_status = "" if firm_jur_status != "A" & firm_jur_status != "B" & ///
		firm_jur_status != "C" & firm_jur_status != "D" & firm_jur_status != "E" & ///
		firm_jur_status != "F" & firm_jur_status != "G" & firm_jur_status != "H" & ///
		firm_jur_status != "J" & firm_jur_status != "N" & firm_jur_status != "P" & ///
		firm_jur_status != "Q" & firm_jur_status != "R" & firm_jur_status != "S" & ///
		firm_jur_status != "U" & firm_jur_status != "V" & firm_jur_status != "W"
		/* firm type only makes sense if employer type is 9 */
		
		* Update firm info
		merge m:1 firm_cc2 year using "$temp\firms_all", update replace keep(match master match_update match_conflict) ///
		keepusing(firm_muni sector_cnae93 firm_workers firm_age firm_ett firm_jur_type firm_jur_status firm_main_prov sector_cnae09)
		drop _merge
		
		* Firm tenure
		rename firm_age firm_age_aux
		tostring firm_age_aux, replace
		gen entry_firm = date(firm_age_aux, "YMD")
		format entry_firm %tdDD.Mon.CCYY
		label var entry_firm "Real date of entry of first worker in CCC"
		order entry_firm, after(firm_age_aux)
		drop firm_age_aux
		
		gen firm_age = (time - ym(year(entry_firm), month(entry_firm)))/12
		replace firm_age = . if firm_age < 0
		label var firm_age "Age of firm (in years)"
		order firm_age, after(entry_firm)
		
		if (`j' == ${latest}) {
			local last = $latest - 1
		
			foreach t of numlist 2005/`last' {
				capture append using "$temp\cohorts\mcvl`t'_YearMonth_`i'"
			}
		}
		
		* Make MCVL_last consistent
		bysort person_id: egen last_temp = max(MCVL_last)
		drop MCVL_last
		rename last_temp MCVL_last
		
		* Save
		compress
		save "$temp\cohorts\mcvl`j'_YearMonth_`i'", replace
		erase "$temp\cohorts\BasesYearMonth`j'_`i'.dta"
	}
}

*** COMBINE DATA
/* Combine to the last file of the recent cohort the information of individuals that
were observed last in previous versions of MCVL. i.e. they are part of the sample but were
born before the earliest cohort of the lastest MCVL */
local z = $latest - 99 /*First cohort of the most recent MCVL */
use "$temp\cohorts\mcvl${latest}_YearMonth_`z'", clear

local last = $latest - 1
local end_b = $latest - 99 - 1
local start_b = 2005 - 99

foreach t of numlist 2005/`last' {
	foreach s of numlist `start_b'/`end_b' {
		capture append using "$temp\cohorts\mcvl`t'_YearMonth_`s'"
	}
}

save "$temp\cohorts\mcvl${latest}_YearMonth_`z'", replace


































