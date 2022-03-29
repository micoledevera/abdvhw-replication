clear all
set more off


foreach j of numlist 2005/$latest {
	local end = `j' - 16
	local start = `j' - 99
	
	foreach i of numlist `start'/`end' {
		use "$temp\cohorts\IndividualsDaysM`j'_`i'", clear
		
		* Create id that identifies each observation for reshape
		sort person_id year firm_cc2 alta baja
		gen count = _n
		
		reshape long days contribution_ contribution_aut_, i(count)
		
		rename _j month
		rename contribution_ contribution
		rename contribution_aut_ contribution_aut
		label var month "Month"
		label var days "Dias cotizados (trabajo o prestacion)"
		replace contribution = contribution / 100
		label var contribution "Base de cotizacion por continhencias comunes en Euros"
		replace contribution_aut = contribution_aut / 100
		label var contribution_aut "Base de cotizacion autonomos y otros en Euros"
		
		order person_id year month alta baja firm_cc2, first
		sort person_id year month alta baja firm_cc2
		drop if days == .
		drop count
		
		* RECTANGULARIZE THE BASE
		gen time = ym(year, month)
		label var time "Year-month of contribution"
		order time, after(month)
		format time %tmMon.CCYY
		
		* Make variables for start of when we observe worker, end, and 16th bday
		bysort person_id (time alta baja firm_cc2): egen start = min(time)
		label var start "Year-month of entry into market"
		bysort person_id (time alta baja firm_cc2): egen end = max(time)
		label var end "Year-month of exit of market"
		format start end %tmMon.CCYY
		by person_id: gen d16 = ym(birth_year, month(birth_date)) + 16 * 12
		
		/* This is needed for individuals who appear last in previous waves. The problem is that fillin will
		not be able to fill in all the years that we need. This is most important for individuals who are 
		foreigners and change their identification. Thus, they are dropped from the Muestra */
		foreach AAAA of numlist 2006/$latest {
			foreach MM of numlist 1/12 {
				qui set obs `=_N+1'
				qui replace time = ym(`AAAA', `MM') in `=_N'
			}
		}
		
		* Fill in the missing years
		fillin person_id time
		drop _fillin
		drop if person_id == .
		
		* We will make a panel +/-4 years from the start or end of observing the individual.
		* This needs CARRYFORWARD
		bysort person_id (time): carryforward start end d16, replace
		gen negtime = -time
		bysort person_id (negtime): carryforward start end d16, replace
		drop negtime
		
		by person_id: gen d1 = (time < (max((start - 4*12), d16)))
		drop if d1 == 1
		
		by person_id: gen d2 = (time > min((end + 4*12), ym(${latest}, 12)))
		drop if d2 == 1
		
		drop d16 d1 d2
		
		* Fill in the holes
		replace year = year(dofm(time)) if year == .
		replace month = month(dofm(time)) if month == .
		sort person_id time alta baja firm_cc2
		
		**** Changes in contract
		gen newcdate1 = mofd(date(new_date_contract1, "YMD") + 2) /* Add 2 days to make sure it starts in a new month */
		gen newcdate2 = mofd(date(new_date_contract2, "YMD") + 2)
		gen newgdate = mofd(date(new_date_contribution_group, "YMD") + 2)
		format newcdate1 newcdate2 newgdate %tmMon.CCYY
		
		* Type of contract
		destring prev_contract1 prev_contract2, replace
		replace contract_type = prev_contract1 if time <= newcdate1 & prev_contract1 != .
		replace contract_type = prev_contract2 if time > newcdate1 & time <= newcdate2 & prev_contract2 != .
		drop prev_contract1 prev_contract2
		
		* Coeficiente de parcialidad
		destring prev_ptcoef1 prev_ptcoef2, replace
		gen parttime_coef = .
		replace ptcoef = prev_ptcoef1 if time <= newcdate1 & prev_ptcoef1 != .
		replace ptcoef = prev_ptcoef2 if time > newcdate1 & time <= newcdate2 & prev_ptcoef2 != .
		drop prev_ptcoef1 prev_ptcoef2 newcdate1 newcdate2
		
		* Grupo de cotizacion
		destring prev_contribution_group, replace
		replace contribution_group = prev_contribution_group if time <= newgdate & prev_contribution_group != .
		drop prev_contribution_group newgdate
		
		* SAVE
		order person_id time year month alta baja firm_cc2, first
		sort person_id time alta baja
		
		compress
		save "$temp\cohorts\BasesYearMonth`j'_`i'", replace
		erase "$temp\cohorts\IndividualsDaysM`j'_`i'.dta"
	}
}






















