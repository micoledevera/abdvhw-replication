clear all
set more off

foreach j of numlist 2005/$latest {
	local end = `j' - 16
	local start = `j' - 99
	
	foreach i of numlist `start'/`end' {
		use "$temp\cohorts\IndividualsBasesM`j'_`i'", clear
		
		/* Note: for every combination of pid+year+cc2, the base de cotizacion is the same
		even if there are several episodes of affiliation (different dates of registration/
		cancellation. */
		
		** NUMBER OF DAYS WORKED **
		sort person_id year alta baja firm_cc2
		
		foreach x of numlist 1/12 {
			gen days`x' = .
		
			* Months that are worked full-time
			replace days`x' = 30 if ( (year > year(alta) & year < year(baja)) | ///
			(year == year(alta) & year == year(baja) & `x' < month(baja) & `x' > month(alta)) | ///
			(year == year(alta) & year != year(baja) & `x' > month(alta)) | ///
			(year == year(baja) & year != year(alta) & `x' < month(baja)) )
			
			* Month of entry, not fully worked
			/* [mdy(month(alta)+1, 1, year(alta)) - 1] should be the last day of the month of entry */
			replace days`x' = cond(month(alta) != 12, ///
									mdy(month(alta) + 1, 1, year(alta)) - 1 - alta + 1, ///
									mdy(month(alta) - 11, 1, year(alta) + 1) - 1 - alta + 1) ///
			if year == year(alta) & month(alta) == `x'
			
			* Month of exit, not fully worked
			replace days`x' = day(baja) if year == year(baja) & month(baja) == `x'
			
			* Episodes that start and end the same month
			replace days`x' = day(baja) - day(alta) + 1 if year == year(baja) & month(baja) == `x' & year == year(alta) & month(alta) == `x'
			
			* Adjust months to 30 days
			replace days`x' = 30 if days`x' == 31
			
			* If alta == baja, then 1 day
			replace days`x' = 1 if baja == alta & month(baja) == `x' & month(alta) == `x'
			
			* Label variable
			label var days`x' "Days worked in month `x'"
		}
		
		/* For contracts that start 01Feb and end in another month, adjust days worked in Feb to 30 */
		replace days2 = 30 if alta == mdy(2, 1, year) & (year != year(baja) | month(baja) != 2)
		
		/* For contracts that end 28Feb or 29Feb and started a different month, adjust days worked in Feb to 30 */
		replace days2 = 30 if baja == mdy(2, 28, year) & (year != year(alta) | month(alta) != 2)
		replace days2 = 30 if baja == mdy(2, 29, year) & (year != year(alta) | month(alta) != 2)
		
		/* For contracts that start 01Feb and end 28Feb/29Feb, adjust days worked in Feb to 30 */
		replace days2 = 30 if alta == mdy(2, 1, year) & baja == mdy(2, 28, year)
		replace days2 = 30 if alta == mdy(2, 1, year) & baja == mdy(2, 29, year)
		
		* SAVE
		order days* contribution_? contribution_?? contribution_aut_? contribution_aut_??, after(baja)
		save "$temp\cohorts\IndividualsDaysM`j'_`i'", replace
		erase "$temp\cohorts\IndividualsBasesM`j'_`i'.dta"
	}
}









































