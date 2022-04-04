*File Name: GID Expectations - MU & SIGMA (Berkson estimator)
*Purpose: Sigma estimates
*This version: March 2021
*Author: Laura Hospido (laura.hospido@bde.es) 
*-------------------------------------------------------------------------
* Please notify and cite the author to distribute and/or modify this work.
*-------------------------------------------------------------------------

set more off
clear all

global add ".../subjective_expectations"
cd "$add"
do "myplots.do"	
// Define some common charactristics of the plots 
global folderfile = "${add}"
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

*****************
*** HISTOGRAM ***
*****************

* 5 imputed datasets 2014 HH head *

set more off
local i=1
while	`i'<=5 {

	use "$add/Males_EFF2014_`i'", clear
	
	keep if age>=25&age<=55
	
	local j=1
	while	`j'<=5 {
		gen prob`j'=(p6_60iz`j')/10
		local j = `j' + 1
	}
	gen c1=prob1
	gen c2=prob1+prob2
	gen c3=prob1+prob2+prob3
	gen c4=prob1+prob2+prob3+prob4
		
	local j=1
	while	`j'<=4 {
		gen c`j'tilda=(c`j'+(`j'/20))/(1+(5/20))
		gen arg`j'=1-c`j'tilda
		gen q`j'=invnorm(arg`j')
		local j = `j' + 1
	}
	
	gen mu=0.5*((q1+q4)+(q2+q3))/((5*(q1-q4))+(25*(q2-q3)))
	
	gen sigma=(2)/((5*(q1-q4))+(25*(q2-q3)))
	
	keep h_2014 sigma facine3
	rename sigma sigma`i'
	rename facine3 facine3_`i'
	qui compress
	sort h_2014
	save sigma_`i', replace

	local i = `i' + 1
}

use sigma_1, clear
local i=2
while	`i'<=5 {
	sort h_2014
	merge 1:1 h_2014 using sigma_`i'
	keep if _merge==3
	drop _merge
	erase sigma_`i'.dta
local i = `i' + 1
}
erase sigma_1.dta
gen sigma=(1/5)*(sigma1+sigma2+sigma3+sigma4+sigma5)
gen weight=(1000000/5)*(facine3_1+facine3_2+facine3_3+facine3_4+facine3_5)
label variable sigma "Standard deviation"
histogram sigma [fw=weight], fraction bin(32) 
graph export "sigma_histogram.pdf", as(pdf) replace

colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 ) // "0 114 178" "213 94 0"
tw (histogram sigma [fw=weight], fraction bin(32) lcolor("`r(p1)'") fcolor("0 114 178 *0.8")  ), ///				
			xtitle("Risk") ytitle("") ///
			graphregion(color(white)  ) ///				Graph region define
			plotregion(lcolor(black))  //				Plot regione define
			//title("Histogram of CV and rescaled Std(ln(Y{sub:it})|Y{sub:it-1})", color(black)) //	
cap noisily: graph export "sigma_histogram.${formatfile}", replace 	
	
**************
*** INCOME ***
**************

* 5 imputed datasets 2014 HH head *

set more off
local i=1
while	`i'<=5 {

	use "$add/Males_EFF2014_`i'", clear

	gen imputation=`i'
	
	keep if age>=25&age<=55
	
	local j=1
	while	`j'<=5 {
		gen prob`j'=(p6_60iz`j')/10
		local j = `j' + 1
	}
	gen c1=prob1
	gen c2=prob1+prob2
	gen c3=prob1+prob2+prob3
	gen c4=prob1+prob2+prob3+prob4
	
	
	
	local j=1
	while	`j'<=4 {
		gen c`j'tilda=(c`j'+(`j'/20))/(1+(5/20))
		gen arg`j'=1-c`j'tilda
		gen q`j'=invnorm(arg`j')
		local j = `j' + 1
	}
	
	gen mu=0.5*((q1+q4)+(q2+q3))/((5*(q1-q4))+(25*(q2-q3)))
	
	gen sigma=(2)/((5*(q1-q4))+(25*(q2-q3)))
	
	gen rescaled_sigma1=sqrt(2/3.14)*sigma
	gen rescaled_sigma2=sqrt(3.14/2)*sigma
	
	pctile pct = earning [aw=facine3], nq(100) genp(percent)
	gen pct1=pct if percent==1
	egen maxpct1=max(pct1)
	drop pct1
	gen pct5=pct if percent==5
	egen maxpct5=max(pct5)
	drop pct5
	local j=1
	while	`j'<=9 {
	gen pct`j'0=pct if percent==`j'0
	egen maxpct`j'0=max(pct`j'0)
	drop pct`j'0
	local j = `j' + 1
	}
	gen pct95=pct if percent==95
	egen maxpct95=max(pct95)
	drop pct95
	gen pct99=pct if percent==99
	egen maxpct99=max(pct99)
	drop pct99
	
	gen category=1 if earning<=maxpct10
	replace category=2 if earning>maxpct10&earning<=maxpct20
	replace category=3 if earning>maxpct20&earning<=maxpct30
	replace category=4 if earning>maxpct30&earning<=maxpct40
	replace category=5 if earning>maxpct40&earning<=maxpct50
	replace category=6 if earning>maxpct50&earning<=maxpct60
	replace category=7 if earning>maxpct60&earning<=maxpct70
	replace category=8 if earning>maxpct70&earning<=maxpct80
	replace category=9 if earning>maxpct80&earning<=maxpct90
	replace category=10 if earning>maxpct90
	tab category,gen(cat_inc)
	drop maxpct* pct percent
	rename category category_inc
	
	pctile pct = renthog [aw=facine3], nq(100) genp(percent)
	gen pct1=pct if percent==1
	egen maxpct1=max(pct1)
	drop pct1
	gen pct5=pct if percent==5
	egen maxpct5=max(pct5)
	drop pct5
	local j=1
	while	`j'<=9 {
	gen pct`j'0=pct if percent==`j'0
	egen maxpct`j'0=max(pct`j'0)
	drop pct`j'0
	local j = `j' + 1
	}
	gen pct95=pct if percent==95
	egen maxpct95=max(pct95)
	drop pct95
	gen pct99=pct if percent==99
	egen maxpct99=max(pct99)
	drop pct99
	
	gen category=1 if renthog<=maxpct10
	replace category=2 if renthog>maxpct10&renthog<=maxpct20
	replace category=3 if renthog>maxpct20&renthog<=maxpct30
	replace category=4 if renthog>maxpct30&renthog<=maxpct40
	replace category=5 if renthog>maxpct40&renthog<=maxpct50
	replace category=6 if renthog>maxpct50&renthog<=maxpct60
	replace category=7 if renthog>maxpct60&renthog<=maxpct70
	replace category=8 if renthog>maxpct70&renthog<=maxpct80
	replace category=9 if renthog>maxpct80&renthog<=maxpct90
	replace category=10 if renthog>maxpct90
	tab category,gen(cat)
	
	local j=1
	while	`j'<=10 {
	
	sum mu [aw=facine3] if category_inc==`j'
	gen wmean_mu_ind`j'=r(mean)
	
	sum mu [aw=facine3] if category==`j'
	gen wmean_mu_tot`j'=r(mean)
	
	sum sigma  [aw=facine3] if category_inc==`j'
	gen wmean_sigma_ind`j'=r(mean)
	
	sum sigma  [aw=facine3] if category==`j'
	gen wmean_sigma_tot`j'=r(mean)
	qui:sum sigma  [aw=facine3] if category==`j', de
	gen wp10_sigma_tot`j' = r(p10)
	gen wp25_sigma_tot`j' = r(p25)
	gen wp50_sigma_tot`j' = r(p50)
	gen wp75_sigma_tot`j' = r(p75)
	gen wp90_sigma_tot`j' = r(p90)
	
	
	
	
	sum rescaled_sigma1  [aw=facine3] if category_inc==`j'
	gen wmean_r1sigma_ind`j'=r(mean)
	
	sum rescaled_sigma1  [aw=facine3] if category==`j'
	gen wmean_r1sigma_tot`j'=r(mean)
	
	sum rescaled_sigma2  [aw=facine3] if category_inc==`j'
	gen wmean_r2sigma_ind`j'=r(mean)
	
	sum rescaled_sigma2  [aw=facine3] if category==`j'
	gen wmean_r2sigma_tot`j'=r(mean)

		local j = `j' + 1
	}

	keep if _n==1
	keep imputation wmean* wp*_sigma_tot*
	qui compress
	save means_`i', replace

	local i = `i' + 1
}

use means_1, clear
local i=2
while	`i'<=5 {
	append using means_`i'
	erase means_`i'.dta
local i = `i' + 1
}
sum
gen wave=2014
save means_2014, replace
erase means_1.dta


use means_2014, clear
/*
gr bar  wmean_sigma_tot*, ylabel(0(.02).08) title("By income") b1title("Quantile of lag total income of the household") legend(rows(3) label(1 "<10") label(2 "10-20") label(3 "20-30") label(4 "30-40") /*
*/ label(5 "40-50") label(6 "50-60") label(7 "60-70") label(8 "70-80") label(9 "80-90") label(10 ">90") ) bar(1,color(black)) bar(2,color(gray)) bar(3,color(olive))/*
*/ bar(4,color(purple)) bar(5,color(blue)) bar(6,color(green)) bar(7,color(pink)) bar(8,color(red)) bar(9,color(orange))  bar(10,color(yellow)) 
graph save Graph "1.gph", replace
*/

keep wp*_sigma_tot* 
collapse (mean) _all
gen temp = 1
reshape long wp10_sigma_tot wp25_sigma_tot wp50_sigma_tot wp75_sigma_tot wp90_sigma_tot,i(temp) j(inc)
replace inc = inc*10 - 5


tspltAREALimPA2 "wp90_sigma_tot wp75_sigma_tot  wp50_sigma_tot wp25_sigma_tot  wp10_sigma_tot" /// Which variables?
	   "inc" ///
	   5 95 20 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Percentiles of lag total income of the household" /// x axis title
	   "Percentiles of standard deviations" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "sigma_income"	/// Figure name
	   "0" "0.24" "0.06"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" 

***********
*** AGE ***
***********


* 5 imputed datasets 2014 HH head *

set more off
local i=1
while	`i'<=5 {

	use "$add/Males_EFF2014_`i'", clear

	gen imputation=`i'
		
	keep if age>=25&age<=55
	
	local j=1
	while	`j'<=5 {
		gen prob`j'=(p6_60iz`j')/10
		local j = `j' + 1
	}
	gen c1=prob1
	gen c2=prob1+prob2
	gen c3=prob1+prob2+prob3
	gen c4=prob1+prob2+prob3+prob4
	
	local j=1
	while	`j'<=4 {
		gen c`j'tilda=(c`j'+(`j'/20))/(1+(5/20))
		gen arg`j'=1-c`j'tilda
		gen q`j'=invnorm(arg`j')
		local j = `j' + 1
	}
	
	gen mu=0.5*((q1+q4)+(q2+q3))/((5*(q1-q4))+(25*(q2-q3)))
	
	gen sigma=(2)/((5*(q1-q4))+(25*(q2-q3)))
	
	gen rescaled_sigma1=sqrt(2/3.14)*sigma
	gen rescaled_sigma2=sqrt(3.14/2)*sigma

	gen category=1 if age>=25&age<30
	replace category=2 if age>=30&age<35
	replace category=3 if age>=35&age<40
	replace category=4 if age>=40&age<45
	replace category=5 if age>=45&age<50
	replace category=6 if age>=50&age<=55	
	tab category,gen(cat)
	
	local j=1
	while	`j'<=6 {
	
	sum mu [aw=facine3] if category==`j'
	gen wmean_mu_age`j'=r(mean)
	
	sum sigma  [aw=facine3] if category==`j'
	gen wmean_sigma_age`j'=r(mean)
	qui:sum sigma  [aw=facine3] if category==`j', de
	gen wp10_sigma_tot`j' = r(p10)
	gen wp25_sigma_tot`j' = r(p25)
	gen wp50_sigma_tot`j' = r(p50)
	gen wp75_sigma_tot`j' = r(p75)
	gen wp90_sigma_tot`j' = r(p90)
	
	
	sum rescaled_sigma1  [aw=facine3] if category==`j'
	gen wmean_r1sigma_age`j'=r(mean)
	
	sum rescaled_sigma2  [aw=facine3] if category==`j'
	gen wmean_r2sigma_age`j'=r(mean)

		local j = `j' + 1
	}

	keep if _n==1
	keep imputation wmean* wp*_sigma_tot*
	qui compress
	save means_`i', replace

	local i = `i' + 1
}

use means_1, clear
local i=2
while	`i'<=5 {
	append using means_`i'
	erase means_`i'.dta
local i = `i' + 1
}
sum
gen wave=2014
save means_age_2014, replace
erase means_1.dta

use means_age_2014, clear
/*
gr bar wmean_sigma*, ylabel(0(.02).08) title("By age") b1title("Age") legend(rows(3) /*
*/ label(1 "25-29") label(2 "30-34") label(3 "35-39") label(4 "40-44") /*
*/ label(5 "45-49") label(6 "50-55") ) bar(1,color(black)) bar(2,color(gray)) bar(3,color(olive))/*
*/ bar(4,color(purple)) bar(5,color(blue)) bar(6,color(green)) bar(7,color(pink)) bar(8,color(red)) bar(9,color(orange))  bar(10,color(yellow)) 
graph save Graph "2.gph", replace
*/
keep wp*_sigma_tot* 
collapse (mean) _all
gen temp = 1
reshape long wp10_sigma_tot wp25_sigma_tot wp50_sigma_tot wp75_sigma_tot wp90_sigma_tot,i(temp) j(age)


tspltAREALimPA3 "wp90_sigma_tot wp75_sigma_tot  wp50_sigma_tot wp25_sigma_tot  wp10_sigma_tot" /// Which variables?
	   "age" ///
	   1 6 1 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
	   "1" "1" ///
	   "Age" /// x axis title
	   "Percentiles of standard deviations" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "sigma_age"	/// Figure name
	   "0" "0.24" "0.06"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S T x D" ""  ///
	   "1" "2" "3" "4" "5" "6" ///
	   "25-29" "30-34" "35-39" "40-44" "45-49" "50-55"
	   
/*
gr combine "1.gph" "2.gph" , rows(1) iscale(.55)   
graph export "sigma_income_age.pdf", as(pdf) replace
erase "1.gph"
erase "2.gph"
*/
