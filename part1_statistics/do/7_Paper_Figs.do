// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This program generates the core figures for the draft
// This version January 10, 2022
// Serdar Ozkan and Sergio Salgado
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

clear all
set more off

global maindir ="...\part1_statistics"

// Where the data is stored
global ineqdata = " 8 Mar 2022 Inequality"                      // Data on Inequality 
global voladata = " 8 Mar 2022 Volatility"                      // Data on Volatility
global mobidata = " 8 Mar 2022 Mobility"                        // Data on Mobility


// Where the firgures are going to be saved 
global outfolder="paper_figs_8Mar2022"   		
capture noisily mkdir "$maindir${sep}figs${sep}${outfolder}"

// Read initialize and plotting code. Do not change myplots.do
do "$maindir/do/0_Initialize.do"
do "$maindir${sep}do${sep}myplots.do"		

// Define these variables for your dataset
global yrfirst = 2005				// First year in the dataset 
global yrlast =  2018 					// Last year in the dataset	

/* Following the guidelines 
	Our suggestion is set  Tmax to the maximum length available (i.e., 24 years for Brazil, 34 years for Canada, etc.). As for Tcommon, we recommend  Tcommon=min{Tmax, 20}, going backward from the last year for which data are currently available (hence for Brazil is 1998-2017, for Canada 1997-2016, etc., while for Mexico would be 2005-2014).
	
	Notice this only affects the number of years used for th plots
*/
global Tcommon = ${yrlast} - 20 + 1	



// Define some common charactristics of the plots 
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
	
// Where the figs are going to be saved
	capture noisily mkdir "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"
	   
// Cd to folder with out 
	cd "$maindir${sep}" // Cd to the folder containing the files
	
// Which section are we ploting 
	global figineq =  "no"			// Inequality
	global figcoh =   "no"			// Cohorts and initial inequality
	global figvol =   "no"			// Volatility
	global figquan =  "no"			// Income growth heterogeneity 
	global figmob =   "no"			// Mobility
	global figtail =  "no"			// Tail 
	global figcon =   "no"			// Concentration 
	global figden =   "no"			// Density Plots

// Additional tables and figures (spainish team)
	global figquan2 =  "no"                 // Income growth heterogeneity 
	global figext =   "no"                  // Density Plots
	global figext2 = "no" // 8F conditional income 
    global tabext = "yes"
    global tabext2 = "yes" // tab occupation by income   




/*---------------------------------------------------	
    Inequality
 ---------------------------------------------------*/
if "${figineq}" == "yes"{ 	

// PLOTS OF LOG EARN: The limints need to change for each variable; Better seperate them
	*Define the saving folder 
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
	
	foreach subgp in fem male all{	
	
	*For residual-education earnings we are only ploting the aggregated results
	if 	"`subgp'" == "all"{
		local wlist = "logearn researne researn"			
	}	
	else {
		local wlist = "logearn researn"	
	}
	
	*Start main loop over variables
	foreach var of local wlist{
	
	*Which variable will be ploted
	global vari = "`var'"						 
	
	*What is the group under analysis? 
	*You can add more groups to this section 
	if "`subgp'" == "all"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_sumstat.csv", clear
		local labname = "All"
	}
	if "`subgp'" == "male"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_male_sumstat.csv", clear
		keep if male == 1	// Keep the group we want to plot 
		local labname = "Men"
	}
		
	if "`subgp'" == "fem"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_male_sumstat.csv", clear
		keep if male == 0	// Keep the group we want to plot 
		local labname = "Women"
	}
	
	*What is the label for title 
	if "${vari}" == "logearn"{
		local labtitle = "Log Earnings"
// 		local labtitle = "log y{sub:it}"
	}
	if "${vari}" == "researn" | "${vari}" == "researne"{
		local labtitle = "Residual Log Earnings"
// 		local labtitle = "{&epsilon}{sub:it}"
	}

	
	*What are the x-axis limits
	if "${vari}" == "logearn"{
		local lyear = ${yrfirst}
		local ryear = ${yrlast}
	}
	if "${vari}" == "researn" | "${vari}" == "researne" {
		local lyear = ${yrfirst}
		local ryear = ${yrlast}
	}

	
	*Normalize Percentiles 
	gen var${vari} = sd${vari}^2
	gen p9010${vari} = p90${vari} - p10${vari}
	gen p9901${vari} = p99${vari} - p1${vari}
	gen p99901${vari} = p99_9${vari} - p1${vari}
	gen p999901${vari} = p99_99${vari} - p1${vari}
	
	gen p9990${vari} = p99${vari} - p90${vari}
	gen p999_p99${vari} = p99_9${vari} - p99${vari}
	gen p9999_p999${vari} = p99_99${vari} - p99_9${vari}
	
	
	gen p9505${vari} = p95${vari} - p5${vari}
	gen p9050${vari} = p90${vari} - p50${vari}
	gen p5010${vari} = p50${vari} - p10${vari}
	gen ksk${vari} = (p9050${vari} - p5010${vari})/p9010${vari}

	*Rescale by first year 
	foreach vv in sd$vari  var$vari p1$vari p2_5$vari p5$vari p10$vari p12_5$vari p25$vari ///
		p37_5$vari p50$vari p62_5$vari p75$vari p87_5$vari p90$vari p95$vari ///
		p97_5$vari p99$vari  p99_5$vari  p99_9$vari p99_99$vari p9010$vari  p9901$vari  p9505$vari p9050${vari} p5010${vari} ksk${vari} ///
		p99901${vari} p999901${vari} p9990${vari} p999_p99${vari} p9999_p999${vari}{
		sum  `vv' if year == `lyear', meanonly
		gen n`vv' = `vv' - r(mean)
		}
	
	*Generate recession vars
	gen rece = inlist(year,${receyears})
	
	*Rescale standard deviation for plots
	replace sd$vari = 2.56*sd$vari

// Figure 1A (normalized percentiles)
	local y1 = ""
	local y2 = ""
	local y2 = ""
	
	if "${vari}" == "logearn"{
                local y1 = -0.7
                local y2 = 0.3
                local y3 = 0.2
                
                * for levels 
                local y4 = 8
                local y5 = 12.5
                local y6 = 1
                
        }
        if "${vari}" == "researn" | "${vari}" == "researne" {
                local y1 = -0.4
                local y2 =  0.4
                local y3 = .2
                
                * for level
                local y4 = -1.2
                local y5 =  1
                local y6 = .4
        }

	
	tspltAREALimPA "np90$vari np75$vari np50$vari np25$vari np10$vari" /// Which variables?
	   "year" ///
	   `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "p90" "p75" "p50" "p25" "p10" "" "" "" "" /// Labels 
	   "1" "7" ///
	   "" /// x axis title
	   "Percentiles Relative to `lyear'" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "fig1A_`subgp'_${vari}"	/// Figure name
	   "`y1'" "`y2'" "`y3'"		/// ylimits
	   "" 						/// Set to off to have inactive legend
	   "blue green red navy black maroon forest_green purple gray orange"			/// Colors
	   "O + S x D" 
	   
	 tspltAREALimPA "p90$vari p75$vari p50$vari p25$vari p10$vari" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "p90" "p75" "p50" "p25" "p10" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Percentiles" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig1A_`subgp'_${vari}_level"        /// Figure name
           "`y4'" "`y5'" "`y6'"         /// ylimits
           ""                                           /// Set to off to have inactive legend
           "blue green red navy black maroon forest_green purple gray orange"                   /// Colors
           "O + S x D" 
  
	   
// Figures 1B (normalized top percentiles)	 
	if "${vari}" == "logearn"{
		local y1 = -0.15
        local y2 = 0.15
        local y3 = 0.1
                
        * for levels
        local y4 = 10
        local y5 = 13
        local y6 = 1
		
	}
	if "${vari}" == "researn"{
		local y1 = -0.1
        local y2 = 0.3
        local y3 = 0.1
                
        * for levels
        local y4 = 0.8
        local y5 = 2.4
        local y6 = 0.4
	}
	if "${vari}" == "researne" {
		local y1 = -0.1
        local y2 = .2
        local y3 = 0.1
                
        * for levels
        local y4 = 0.8
        local y5 = 2.4
        local y6 = 0.4

	}
	
	 tspltAREALimPA "np99_5$vari np99$vari np95$vari np90$vari" /// Which variables? np99_99$vari np99_9$vari
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "p99.5" "p99" "p95" "p90" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Percentiles Relative to `lyear'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig1B_`subgp'_${vari}"      /// Figure name
           "`y1'" "`y2'" "`y3'"                         /// ylimits
           ""                                           /// If legend is active or nor  
           "blue green red navy black maroon forest_green purple gray orange"                   /// Colors
           "D + S x O" 
     
	 tspltAREALimPA "p99_5$vari p99$vari p95$vari p90$vari" /// Which variables? np99_99$vari np99_9$vari
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "p99.5" "p99" "p95" "p90" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Percentiles" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig1B_`subgp'_${vari}_level"        /// Figure name
           "`y4'" "`y5'" "`y6'"                         /// ylimits
           ""                                           /// If legend is active or nor  
           "blue green red navy black maroon forest_green purple gray orange"                   /// Colors
           "D + S x O" 



// Figure 2 (Inequality)	
	if "${vari}" == "logearn"{
		local y1 = 1.8
		local y2 = 2.4
		local y3 = 0.2
	}
	if "${vari}" == "researn"{
		local y1 = 1.6
		local y2 = 2.2
		local y3 = 0.2
	}
	if "${vari}" == "researne" {
		local y1 = 1.6
		local y2 = 2.2
		local y3 = 0.2
	}
		   		   
	tspltAREALimPA "sd$vari p9010$vari" /// Which variables?
	   "year" ///
	   `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	    "Rescaled standard deviation" "P90-P10" "" "" "" "" "" "" "" /// Labels   //2.56*{&sigma}
	   "1" "11" ///
	   "" /// x axis title
	   "Dispersion of `labtitle'" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "fig2A_`subgp'_${vari}"	/// Figure name
	   "`y1'" "`y2'" "`y3'"				/// ylimits
	   "" 						/// If legend is active or nor	
	   "blue red navy blue maroon forest_green purple gray orange"			/// Colors
	   "O S" 
	   
	if "${vari}" == "logearn"{
		local y1 = 0.4
		local y2 = 1.6
		local y3 = 0.2
	} 
	if "${vari}" == "researn"{
		local y1 = 0.4
		local y2 = 1.6
		local y3 = 0.2
	}
	if "${vari}" == "researne" {
		local y1 = 0.4
		local y2 = 1.6
		local y3 = 0.2
	}
	 tspltAREALimPA "p9050$vari  p5010$vari " /// Which variables?
	   "year" ///
	   `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90-P50" "P50-P10" "" "" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "" /// x axis title
	   "Dispersion of `labtitle'" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "fig2B_`subgp'_${vari}"	/// Figure name
	   "`y1'" "`y2'" "`y3'"				/// ylimits
	   "" 						/// If legend is active or nor	
	   "blue red navy blue maroon forest_green purple gray orange"			/// Colors
	   "O S" 	  		
	   
	   }	// END of loop over subgroups
	   
}		// END loop over variables
}	// END of inequality section
	
/*----------------------------------------
	Cohorts and Initial Inequality
------------------------------------------*/
if "${figcoh}" == "yes"{ 

	*What is the folder to save plot?
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
	

foreach var in logearn{	// Add here other variables 
	foreach subgp in male fem all{			// Add here other groups 
	
	// Generates plot for initial wealth inequality
													
	*The code generates for raw earnimgs and residuals earnigs
	global vari = "`var'"		
	
	*Label for plots
	local labtitle = "Log Earnings"
								
	*You can add more groups to this section 
	if "`subgp'" == "all"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_age_sumstat.csv", clear
		local tlocal = "All Sample"
	}
	if "`subgp'" == "male"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_maleage_sumstat.csv", clear
		keep if male == 1	// Keep the group we want to plot 
		local tlocal = "Men"
	}	
	if "`subgp'" == "fem"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_maleage_sumstat.csv", clear
		keep if male == 0	// Keep the group we want to plot 
		local tlocal = "Women"
	}	
			
	*Calculate additional moments 
	gen p99990${vari} = p99_9${vari} - p99${vari}
	gen p9990${vari} = p99${vari} - p90${vari}
	gen p9010${vari} = p90${vari} - p10${vari}	
	gen p9050${vari} = p90${vari} - p50${vari}
	gen p5010${vari} = p50${vari} - p10${vari}
	gen ksk${vari} = (p9050${vari} - p5010${vari})/p9010${vari}

	*Gen cohort that is the age at which cohort was 25 years old 
	gen cohort25 = year - age + 25
	order year age cohort25
		
			 			
// Plots at the age of entry

	foreach ageval in 25{
	preserve
		*Keep only the sub sample at the age of age val 
		keep if age == `ageval'
		
		*Rescale by first year 
		foreach vv in sd$vari p1$vari p2_5$vari p5$vari p10$vari p12_5$vari p25$vari ///
			p37_5$vari p50$vari p62_5$vari p75$vari p87_5$vari p90$vari p95$vari ///
			p97_5$vari p99$vari p99_9$vari p99_99$vari{
			
			sum  `vv' if year == ${yrfirst}, meanonly
			gen n`vv' = `vv' - r(mean)
			
			}
		*Recessions bars 
		gen rece = inlist(year,${receyears})

		*What is the last year in the x axis 
		local rlast = ${yrlast}

	// 	*Plots
		
	// Percentiles
		tspltAREALimPA "p9050${vari} p5010${vari}" /// Which variables?
	   "year" ///
	   ${yrfirst} `rlast' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "P90-P50" "P50-P10" "" "" "" "" "" "" "" /// Labels 
	   "1" "3" ///
	   "" /// x axis title
	   "Dispersion of `labtitle'" /// y axis title 
	   "" ///  Plot title
	   ""  /// 	 Plot subtitle  
	   "fig3_`subgp'_${vari}"	/// Figure name
	   "0.4" "1.6" "0.2"				/// ylimits
		"" 						/// If legend is active or nor	
		"blue red forest_green purple gray orange green"			/// Colors
		 "O S x D" 	
		 
		  tspltAREALimPA "p90$vari p75$vari p50$vari p25$vari p10$vari" /// Which variables?
           "year" ///
           ${yrfirst} `rlast' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "P90" "P75" "P50" "P25" "P10" "" "" "" "" /// Labels 
           "1" "7" ///
           "" /// x axis title
           "Percentiles of `labtitle'" /// y axis title 
           "" ///  Plot title
           ""  ///       Plot subtitle  
           "fig12_`subgp'_`ageval'_${vari}"     /// Figure name
           "6.5" "10.5" "1.0"                           /// ylimits
                ""                                              /// If legend is active or nor  
                "blue green red navy black maroon forest_green purple gray orange"                      /// Colors
                "O + S x D"
 
		 
	restore
	
	} // END of loop over age val		
	
	// Plots by cohorts 			
	*Which variable is under analysis? 
	*The code generates for raw earnimgs and residuals earnigs
	global vari = "`var'"		
	
	*Label for plots
	local labtitle = "log y{sub:it}"
								
	*You can add more groups to this section 
	if "`subgp'" == "all"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_age_sumstat.csv", clear
		local tlocal = "All Sample"
		
		          *Age 25
                local posi1= 2.0
                local posi2= 1.95
                local posi3= 2.05
                
                local yposi1= 2006
                local yposi2= 2008
                local yposi3= 2007
                
                *Age 30
                local posj1= 1.85
                local posj2= 2.0
                local posj3= 1.83
                
                local yposj1= 2010
                local yposj2= 2012
                local yposj3= 2010
                
                
            ** p50
        *Age 25
                local posi1_2= 9.3
                local posi2_2= 9.45
                local posi3_2= 9.3              
                local yposi1_2= 2006
                local yposi2_2= 2008
                local yposi3_2= 2007            
                *Age 27
                local posj1_2= 9.85
                local posj2_2= 9.65
                local posj3_2= 9.9              
                local yposj1_2= 2010
                local yposj2_2= 2011            
                local yposj3_2= 2010
                *Age 30
                local posk1_2= 9.85
                local posk2_2= 9.7
                local posk3_2= 9.9              
                local yposk1_2= 2015
                local yposk2_2= 2016.5          
                local yposk3_2= 2015

	}
	if "`subgp'" == "male"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_maleage_sumstat.csv", clear
		keep if male == 1	// Keep the group we want to plot 
		local tlocal = "Men"
		
		      *Age 25
                local posi1= 2.0
                local posi2= 1.95
                local posi3= 2.05
                
                local yposi1= 2006
                local yposi2= 2008
                local yposi3= 2007
                
                *Age 30
                local posj1= 2.0
                local posj2= 2.1
                local posj3= 1.97
                
                local yposj1= 2013
                local yposj2= 2014.7
                local yposj3= 2014
                
                
            ** p50
        *Age 25
                local posi1_2= 9.45
                local posi2_2= 9.55
                local posi3_2= 9.4              
                local yposi1_2= 2006
                local yposi2_2= 2008
                local yposi3_2= 2007            
                *Age 27
                local posj1_2= 9.85
                local posj2_2= 9.75
                local posj3_2= 9.9              
                local yposj1_2= 2010
                local yposj2_2= 2011            
                local yposj3_2= 2010
                *Age 30
                local posk1_2= 9.85
                local posk2_2= 9.8
                local posk3_2= 9.9              
                local yposk1_2= 2015
                local yposk2_2= 2016.5          
                local yposk3_2= 2015


		
	}	
	if "`subgp'" == "fem"{
		insheet using "out${sep}${ineqdata}${sep}L_`var'_maleage_sumstat.csv", clear
		keep if male == 0	// Keep the group we want to plot 
		local tlocal = "Women"
		
		 *Age 25
                local posi1= 2.0
                local posi2= 1.95
                local posi3= 2.05
                
                local yposi1= 2006
                local yposi2= 2008
                local yposi3= 2007
                
                *Age 30
                local posj1= 1.85
                local posj2= 1.97
                local posj3= 1.8
                
                local yposj1= 2010
                local yposj2= 2011              
                local yposj3= 2011
                
                ** p50
                *Age 25
        local posi1_2= 9.2
                local posi2_2= 9.3
                local posi3_2= 9.15             
                local yposi1_2= 2006
                local yposi2_2= 2008
                local yposi3_2= 2007            
                *Age 30
                local posj1_2= 9.65
                local posj2_2= 9.55
                local posj3_2= 9.7              
                local yposj1_2= 2010
                local yposj2_2= 2011    
                local yposj3_2= 2011
                *Age 35
                local posk1_2= 9.65
                local posk2_2= 9.58
                local posk3_2= 9.7              
                local yposk1_2= 2015
                local yposk2_2= 2016.5          
                local yposk3_2= 2015

	}
		
	*Calculate additional moments 
	gen p99990${vari} = p99_9${vari} - p99${vari}
	gen p9990${vari} = p99${vari} - p90${vari}
	gen p9010${vari} = p90${vari} - p10${vari}	
	gen p9050${vari} = p90${vari} - p50${vari}
	gen p5010${vari} = p50${vari} - p10${vari}
	gen ksk${vari} = (p9050${vari} - p5010${vari})/p9010${vari}

	*Gen cohort that is the age at which cohort was 25 years old 
	gen cohort25 = year - age + 25
	order year age cohort25
	
	gen rece = inlist(year,${receyears})

	/*gkswplot_co "p9010`var'" "year" ///
			 "1993 2000 2005 2010" /// what cohorts?
			 "25 30 35 45" /// What ages: code allows three
			 "1995" "2015" "5" /// x-axis
			 "on" "7" "2" "Cohort 1993" "Cohort 2000" "Cohort 2005" "Cohort 2010" /// Legends
			 "" "P90-P10 of Log Earnigs"  /// x and y titles 
			 "" "large" "" "" ///
			 "1" "2.5" "0.5" ///
			 "fig3B_`subgp'_${vari}" ///
			 "`posi1'" "`yposi1'" "`posi2'" "`yposi2'" "`posi3'" "`yposi3'" "25 yrs old" ///
			 "`posj1'" "`yposj1'" "`posj2'" "`yposj2'" "`posj3'" "`yposj3'" "35 yrs old" */
			 
	 gkswplot_co_adj "p9010`var'" "year" ///
                         "2005 2010 2015" /// what cohorts?
                         "25 30" /// What ages: code allows five
                         "2005" "2015" "5" /// x-axis
                         "on" "7" "2" "Cohort 2005" "Cohort 2010" "Cohort 2015" "" /// Legends
                         "" "P90-P10 of Log Earnigs"  /// x and y titles 
                         "" "large" "" "" ///
                         "1.5" "2.3" "0.4" ///
                         "fig3B_`subgp'_${vari}" ///
                         "`posi1'" "`yposi1'" "`posi2'" "`yposi2'" "`posi3'" "`yposi3'" "25 yrs old" ///
                         "`posj1'" "`yposj1'" "`posj2'" "`yposj2'" "`posj3'" "`yposj3'" "30 yrs old" 
                         
      gkswplot_co_adj2 "p50`var'" "year" ///
                         "2005 2007 2010 2013" /// what cohorts?
                         "25 30 35" /// What ages: code allows five
                         "2005" "2015" "5" /// x-axis
                         "on" "7" "2" "Cohort 2005" "Cohort 2007" "Cohort 2010" "Cohort 2013" /// Legends
                         "" "P50 of Log Earnigs"  /// x and y titles 
                         "" "large" "" "" ///
                         "8.5" "10" "0.5" ///
                         "fig3B_`subgp'_${vari}_ext_p50" ///
                         "`posi1_2'" "`yposi1_2'" "`posi2_2'" "`yposi2_2'" "`posi3_2'" "`yposi3_2'" "25 yrs old" ///
                         "`posj1_2'" "`yposj1_2'" "`posj2_2'" "`yposj2_2'" "`posj3_2'" "`yposj3_2'" "30 yrs old" ///
                         "`posk1_2'" "`yposk1_2'" "`posk2_2'" "`yposk2_2'" "`posk3_2'" "`yposk3_2'" "35 yrs old" //
                         *"`posl1_2'" "`yposl1_2'" "`posl2_2'" "`yposl2_2'" "`posl3_2'" "`yposl3_2'" "33 yrs old" 
                                
		 

	
}	// END loop subgroups
}	// END loop over variables 
}	// END section cohorts
 
/*---------------------------------------------------	
    Volatility
 ---------------------------------------------------*/
if "${figvol}" == "yes"{  


*Time series for slides 

	*Plot One-year changes
	foreach jj in 1 5{ 
		
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
	global vari = "researn`jj'F"
	
	*Figure 4
	foreach subgp in men women all{
		
		if "${vari}" == "researn1F"{
			local lyear = ${yrfirst}
			local ryear = ${yrlast}
			local labtitle = "g{sup:1}{sub:it}"
		}		
		if "${vari}" == "researn5F"{
			local lyear = ${yrfirst} //+ 2
			local ryear = ${yrlast} //- 3	
			local labtitle = "g{sup:5}{sub:it}" // ?? what labels here?
		}
		
		*Load data 				
		insheet using "out${sep}${voladata}${sep}L_${vari}_male_sumstat.csv", case clear
		
		if "`subgp'" == "men"{
			keep if male == 1
		}
		else{
			keep if male == 0
		}				
		gen rece = inlist(year,${receyears})
		
		gen p9050$vari = p90$vari - p50$vari
		gen p5010$vari = p50$vari - p10$vari
		gen p9010${vari} = p90${vari} - p10${vari}
		
		if "${vari}" == "researn1F"{
			local ylimlo = 0.2
			local ylimup = 0.75
			local ylimdf = 0.1			
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = 0.3
			local ylimup = 1.1
			local ylimdf = 0.2	
			replace year = year + 2		// This is to center the 5-year changes
		}
		
		   tspltAREALimPA "p9050$vari  p5010$vari" /// Which variables?
		   "year" ///
		   `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
		   "P90-P50" "P50-P10" "" "" "" "" "" "" "" /// Labels 
		   "1" "11" ///
		   "" /// x axis title
		   "Dispersion of `labtitle'" /// y axis title 
		   "" ///  Plot title
		   "" ///
		   "fig4_`subgp'_${vari}"	/// Figure name
		   "`ylimlo'" "`ylimup'" "`ylimdf'"				/// ylimits
		   "" 						/// If legend is active or nor	
		   "blue red navy blue maroon forest_green purple gray orange"			/// Colors
		   "O S" 
		    
			* make sure the labe shows  
            if "${vari}" == "researn5F"{ 
                                tspltAREALimPA5F "p9050$vari  p5010$vari" /// Which variables?
                                "year" ///
                                `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
                                "P90-P50" "P50-P10" "" "" "" "" "" "" "" /// Labels 
                                "1" "11" ///
                                "" /// x axis title
                                "Dispersion of `labtitle'" /// y axis title 
                                "" ///  Plot title
                                "" ///
                                "fig4_`subgp'_${vari}"  /// Figure name
                                "`ylimlo'" "`ylimup'" "`ylimdf'"                                /// ylimits
                                ""                                              /// If legend is active or nor  
                                "blue red navy blue maroon forest_green purple gray orange"                     /// Colors
                                "O S" 
                        }
           if "${vari}" == "researn1F"{
                        local y1 = 0.5
                        local y2 = 1.5
                        local y3 = 0.25
                }
                if "${vari}" == "researn5F"{
                        local y1 = 1.0
                        local y2 = 2.0
                        local y3 = 0.25
                }

                           
                tspltAREALimPA "sd$vari p9010$vari" /// Which variables?
                        "year" ///
                        `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
                        "Rescaled standard deviation" "P90-P10" "" "" "" "" "" "" "" /// Labels   //2.56*{&sigma}
                        "1" "11" ///
                        "" /// x axis title
                        "Dispersion of `labtitle'" /// y axis title 
                        "" ///  Plot title
                        "" ///
                        "fig4B_`subgp'_${vari}" /// Figure name
                        "`y1'" "`y2'" "`y3'"                            /// ylimits
                        ""                                              /// If legend is active or nor  
                        "blue red navy blue maroon forest_green purple gray orange"                     /// Colors
                        "O S" 
              tspltAREALimPA_nolegend "p9010$vari" /// Which variables?
                        "year" ///
                        `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
                        "Rescaled standard deviation" "P90-P10" "" "" "" "" "" "" "" /// Labels   //2.56*{&sigma}
                        "1" "11" ///
                        "" /// x axis title
                        "P90-P10 Dispersion of `labtitle'" /// y axis title 
                        "" ///  Plot title
                        "" ///
                        "fig4B_`subgp'_${vari}_p9010"   /// Figure name
                        "0" "1.25" "0.25"                               /// ylimits
                        ""                                              /// If legend is active or nor  
                        "blue red navy blue maroon forest_green purple gray orange"                     /// Colors
                        "O S"   
                        
                tspltAREALimPA_nolegend "sd$vari" /// Which variables?
                        "year" ///
                        `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
                        "Rescaled standard deviation" "P90-P10" "" "" "" "" "" "" "" /// Labels   //2.56*{&sigma}
                        "1" "11" ///
                        "" /// x axis title
                        "Dispersion of `labtitle'" /// y axis title 
                        "" ///  Plot title
                        "" ///
                        "fig4B_`subgp'_${vari}_sd"      /// Figure name
                        "`y1'" "`y2'" "`y3'"                            /// ylimits
                        ""                                              /// If legend is active or nor  
                        "blue red navy blue maroon forest_green purple gray orange"                     /// Colors
                        "O S"   

						
		   
	}
	
	*Figure 5
	insheet using "out${sep}${voladata}${sep}L_${vari}_male_sumstat.csv", case clear
	gen ksk${vari} = ((p90${vari} - p50${vari}) - (p50${vari} - p10${vari}) )/(p90$vari - p10${vari})
	gen cku${vari} = (p97_5${vari} - p2_5${vari})/(p75$vari - p25${vari}) - 2.91
	
	keep year male ksk${vari} cku${vari}  skew${vari} kurt${vari}
	reshape wide ksk${vari} cku${vari}  skew${vari} kurt${vari}, i(year) j(male)
	gen rece = inlist(year,${receyears})
	
	if "${vari}" == "researn1F"{
	    local ylimlo = -0.6
        local ylimup = 0.4
        local ylimdf = 0.2
                
        local ylimlo_m = -2
        local ylimup_m = 0
        local ylimdf_m = 0.5
		
	}		
	if "${vari}" == "researn5F"{
	    local ylimlo = -0.6
        local ylimup = 0.40
        local ylimdf = 0.2              
        replace year = year + 2         // This is to center the 5-year changes
                
        local ylimlo_m = -2
        local ylimup_m = 0.5
        local ylimdf_m = 0.5    

	}

	
	 tspltAREALimPA "ksk${vari}0 ksk${vari}1" /// Which variables?
	   "year" ///
	   `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "Women" "Men" "" "" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "" /// x axis title
	   "Skewness of `labtitle'" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "fig5A_${vari}"	/// Figure name
		"`ylimlo'" "`ylimup'" "`ylimdf'"				/// ylimits
	   "" 						/// If legend is active or nor	
	   "red blue navy blue maroon forest_green purple gray orange"			/// Colors
	   "O S" "yes"	
	   
	 tspltAREALimPA "skew${vari}0 skew${vari}1" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "Women" "Men" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Skewness of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5A_${vari}_moment"       /// Figure name
                "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                          /// ylimits
           ""                                           /// If legend is active or nor  
           "red blue navy blue maroon forest_green purple gray orange"                  /// Colors
           "O S" "yes"  
           
      tspltAREALimPA_nolegend "ksk${vari}1" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Kelley Skewness of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5A_${vari}_male" /// Figure name
                "`ylimlo'" "`ylimup'" "`ylimdf'"                                /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" "yes"             
           
      tspltAREALimPA_nolegend "skew${vari}1" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Skewness of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5A_${vari}_moment_male"  /// Figure name
                "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                          /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" "yes"  

	  tspltAREALimPA_nolegend "ksk${vari}0" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Kelley Skewness of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5A_${vari}_fem"  /// Figure name
                "`ylimlo'" "`ylimup'" "`ylimdf'"                                /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" "yes"             
           
       tspltAREALimPA_nolegend "skew${vari}0" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Skewness of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5A_${vari}_moment_fem"   /// Figure name
                "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                          /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" "yes"  
	   
		   
	   
	if "${vari}" == "researn1F"{
		local ylimlo = 9
        local ylimup = 21
        local ylimdf = 2        
                
        local ylimlo_m = 10
        local ylimup_m = 20
        local ylimdf_m = 2

	}		
	if "${vari}" == "researn5F"{
		local ylimlo = 4
        local ylimup = 8
        local ylimdf = 1        
                
        local ylimlo_m = 7
        local ylimup_m = 10
        local ylimdf_m = 1    
		
	}
 	 
	 tspltAREALimPA "cku${vari}0 cku${vari}1" /// Which variables?
	   "year" ///
	   `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "Women" "Men" "" "" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "" /// x axis title
	   "Excess Kurtosis of `labtitle'" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "fig5B_${vari}"	/// Figure name
	   "`ylimlo'" "`ylimup'" "`ylimdf'"				/// ylimits
	   "" 						/// If legend is active or nor	
	   "red blue navy blue maroon forest_green purple gray orange"			/// Colors
	   "O S" 
	   
	  tspltAREALimPA "kurt${vari}0 kurt${vari}1" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "Women" "Men" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Kurtosis of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5B_${vari}_moment"       /// Figure name
           "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                       /// ylimits
           ""                                           /// If legend is active or nor  
           "red blue navy blue maroon forest_green purple gray orange"                  /// Colors
           "O S"  
           
         
       tspltAREALimPA_nolegend "cku${vari}1" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Excess Kurtosis of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5B_${vari}_male" /// Figure name
           "`ylimlo'" "`ylimup'" "`ylimdf'"                             /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" 
       tspltAREALimPA_nolegend "kurt${vari}1" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Kurtosis of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5B_${vari}_moment_male"  /// Figure name
           "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                       /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S"  
		   
	    tspltAREALimPA_nolegend "cku${vari}0" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Excess Kurtosis of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5B_${vari}_fem"  /// Figure name
           "`ylimlo'" "`ylimup'" "`ylimdf'"                             /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" 
       
	   tspltAREALimPA_nolegend "kurt${vari}0" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Kurtosis of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5B_${vari}_moment_fem"   /// Figure name
           "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                       /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" 
	   
       // ALL *******************************
           insheet using "out${sep}${voladata}${sep}L_${vari}_sumstat.csv", case clear
           gen ksk${vari} = ((p90${vari} - p50${vari}) - (p50${vari} - p10${vari}) )/(p90$vari - p10${vari})
           gen cku${vari} = (p97_5${vari} - p2_5${vari})/(p75$vari - p25${vari}) - 2.91
        
           keep year ksk${vari} cku${vari}  skew${vari} kurt${vari}
           gen rece = inlist(year,${receyears})
        
        if "${vari}" == "researn1F"{
                local ylimlo = -0.6
                local ylimup = 0.4
                local ylimdf = 0.2
                
                local ylimlo_m = -2
                local ylimup_m = 0
                local ylimdf_m = 0.5
        }               
        if "${vari}" == "researn5F"{
                local ylimlo = -0.6
                local ylimup = 0.40
                local ylimdf = 0.2              
                replace year = year + 2         // This is to center the 5-year changes
                
                local ylimlo_m = -2
                local ylimup_m = 0.5
                local ylimdf_m = 0.5    
        }
       
	    tspltAREALimPA_nolegend "ksk${vari}" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Kelley Skewness of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5A_${vari}_all"  /// Figure name
                "`ylimlo'" "`ylimup'" "`ylimdf'"                                /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" "yes"             
           
       tspltAREALimPA_nolegend "skew${vari}" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Skewness of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5A_${vari}_moment_all"   /// Figure name
                "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                          /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" "yes"  
		   
        if "${vari}" == "researn1F"{
                local ylimlo = 9
                local ylimup = 21
                local ylimdf = 2        
                
                local ylimlo_m = 10
                local ylimup_m = 20
                local ylimdf_m = 2
        }               
        if "${vari}" == "researn5F"{
                local ylimlo = 4
                local ylimup = 8
                local ylimdf = 1        
                
                local ylimlo_m = 7
                local ylimup_m = 10
                local ylimdf_m = 1      
        }

		 tspltAREALimPA_nolegend "cku${vari}" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Excess Kurtosis of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5B_${vari}_all"  /// Figure name
           "`ylimlo'" "`ylimup'" "`ylimdf'"                             /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S" 
        
		tspltAREALimPA_nolegend "kurt${vari}" /// Which variables?
           "year" ///
           `lyear' `ryear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
           "" "" "" "" "" "" "" "" "" /// Labels 
           "1" "11" ///
           "" /// x axis title
           "Coef. of Kurtosis of `labtitle'" /// y axis title 
           "" ///  Plot title
           "" ///
           "fig5B_${vari}_moment_all"   /// Figure name
           "`ylimlo_m'" "`ylimup_m'" "`ylimdf_m'"                       /// ylimits
           ""                                           /// If legend is active or nor  
           " blue navy blue maroon forest_green purple gray orange"                     /// Colors
           "O S"  
           

		   
		
	   
	   }	// END loop jumps
}
***

/*---------------------------------------------------	
    Income growth heterogeneity 
 ---------------------------------------------------*/	
if "${figquan}" == "yes"{ 
	
		foreach mm in  0 1 2{		// 0: Women; 1: Men; 2: All		
		foreach jj in  1 5{
		local var = "researn`jj'F"
		global vari = "`var'"

		*What is the label for title 
		if "${vari}"== "researn1F"{
			local labtitle = "g{sub:it}"
			global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
		}
		if "${vari}" == "researn5F"{
			local labtitle = "g{sub:it}{sup:5}"
			global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
		}
	 
		 *Load the data for the last percentile
        if (`mm' == 1) | (`mm' == 0){
                insheet using "out${sep}${voladata}${sep}L_`var'_maleagerank.csv", clear case
        }
        if (`mm' == 2){
                insheet using "out${sep}${voladata}${sep}L_`var'_agerank.csv", clear case
        }

		
		*Calculate additional moments 
		gen p9010${vari} = p90${vari} - p10${vari}
		
		gen p9510${vari} = p95${vari} - p10${vari}
        gen p9910${vari} = p99${vari} - p10${vari}

		gen p9050${vari} = p90${vari} - p50${vari}
		gen p5010${vari} = p50${vari} - p10${vari}
		gen p7525${vari} = p75${vari} - p25${vari}
		gen ksk${vari} = (p9050${vari} - p5010${vari})/p9010${vari}
		gen cku${vari} = (p97_5${vari} - p2_5${vari})/p7525${vari} - 2.91		// Excess Kurtosis
		replace kurt${vari} = kurt${vari} - 3.0		// Excess Kurtosis
		
		if `mm' == 1{
			keep if male == `mm'
			local lname = "men"
			local mlabel = "Men"
		}
		else if `mm' == 0{
			keep if male == `mm'
			local lname = "women"
			local mlabel = "Women"
		}
		else if `mm' == 2{                      
            local lname = "all"
            //local mlabel = "Women"
        }

		
		drop if year < ${Tcommon} 	// we would like to compare countries over the same time period. This shorter sample period will be called Tcommon. Notice, Tcommon is defined in the start of this code. 
		
		collapse  p9010${vari}  p9510${vari} p9910${vari}  p9050${vari} p5010${vari} sd${vari} ksk${vari} skew${vari} cku${vari} kurt${vari}, by(agegp permrank)
		reshape wide p9010${vari}  p9510${vari} p9910${vari}  p9050${vari} p5010${vari} sd${vari} ksk${vari} skew${vari} cku${vari} kurt${vari}, i(permrank) j(agegp)
		
		*Idex for plot: the code calculates the top 0.1% in a seperated group (group 42). Since some countries might have 
		*top coded values, we do not plot the top 0.1%
		gen idex = _n
		order idex 
	
		*Figure A		
		if "${vari}" == "researn1F"{
			local ylimlo = 0.0
			local ylimup = 2.2
			local ylimdf = 0.5			
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = 0.5
			local ylimup = 3
			local ylimdf = 0.5		
		}
		
		  ** ALL FIG6, we change to idex<=41 from index<=42--- we plot up to quantile 99.5 instead of 100
        tw (connected p9010${vari}1 p9010${vari}2 p9010${vari}3 permrank if idex<=41, msymbol(none none o)  ///
            color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
            xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
            graphregion(color(white)) plotregion(lcolor(black)) ///
            legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
            xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
            ytitle("P90-P10 Difference of `labtitle'", size(${ytitlesize})) ///
            title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) //   
        graph export "${folderfile}/fig6A_${vari}_`lname'.${formatfile}", replace 
                                
                
         ** ALL FIG6, we change to idex<=41 from index<=42--- we plot up to quantile 99.5 instead of 100
        tw (connected p9510${vari}1 p9510${vari}2 p9510${vari}3 permrank if idex<=41, msymbol(none none o)  ///
           color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
           xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
           graphregion(color(white)) plotregion(lcolor(black)) ///
           legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
           xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
           ytitle("P95-P10 Difference of `labtitle'", size(${ytitlesize})) ///
           title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize}))              
        graph export "${folderfile}/fig6A_${vari}_`lname'_9510.${formatfile}", replace 
                
        ** ALL FIG6, we change to idex<=41 from index<=42--- we plot up to quantile 99.5 instead of 100
        tw (connected p9910${vari}1 p9910${vari}2 p9910${vari}3 permrank if idex<=41, msymbol(none none o)  ///
           color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
           xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
           graphregion(color(white)) plotregion(lcolor(black)) ///
           legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
           xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
           ytitle("P99-P10 Difference of `labtitle'", size(${ytitlesize})) ///
           title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize}))              
        graph export "${folderfile}/fig6A_${vari}_`lname'_9910.${formatfile}", replace 

			
		*Figure B	
		if "${vari}" == "researn1F"{
			local ylimlo = -0.4
			local ylimup = 0.25
			local ylimdf = 0.2			
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = -0.5
			local ylimup = 0.2
			local ylimdf = 0.2		
		}
		
		tw (connected ksk${vari}1 ksk${vari}2 ksk${vari}3 permrank if idex<=41, msymbol(none none o) ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
		graphregion(color(white)) plotregion(lcolor(black)) ///
		legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize}))  ///
		ytitle("Kelley Skewness of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) yline(0,lcolor(black) lpattern(dash))
		graph export "${folderfile}/fig6B_${vari}_`lname'.pdf", replace 
				
		*Figure C
		if "${vari}" == "researn1F"{
			local ylimlo = 1
			local ylimup = 28
			local ylimdf = 4
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = 1
			local ylimup = 11
			local ylimdf = 2	
		}
		
		tw (connected cku${vari}1 cku${vari}2 cku${vari}3 permrank if idex<=41, msymbol(none none o) ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
		graphregion(color(white)) plotregion(lcolor(black)) ///
		legend(ring(0) position(11) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize}))  ///
		ytitle("Excess Crow-Siddiqui Kurtosis of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(medium)) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize}))
		graph export "${folderfile}/fig6C_${vari}_`lname'.pdf", replace 	
		
		
		*For appendix
		*Figure AA
		
		if "${vari}" == "researn1F"{
			local ylimlo = 0.25
			local ylimup = 1
			local ylimdf = .25
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = 0.3
			local ylimup = 1.2
			local ylimdf = .3	
		}
		
		tw (connected sd${vari}1 sd${vari}2 sd${vari}3 permrank if idex<=41, msymbol(none none o)  ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
		graphregion(color(white)) plotregion(lcolor(black)) ///
		legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize}))  ///
		ytitle("Standard Deviation of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(medium)) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize}))
		graph export "${folderfile}/fig6A_${vari}_`lname'_ct.pdf", replace 		
		
			
		*Figure BB			
		if "${vari}" == "researn1F"{
			local ylimlo = -7
			local ylimup = 0
			local ylimdf = 1
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = -5
			local ylimup = 0
			local ylimdf = 1
		}
		
		tw (connected skew${vari}1 skew${vari}2 skew${vari}3 permrank if idex<=41, msymbol(none none o) ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
		graphregion(color(white)) plotregion(lcolor(black)) ///
		legend(ring(0) position(7) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize}))  ///
		ytitle("Skewness of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(medium)) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize}))  yline(0,lcolor(black) lpattern(dash))
		graph export "${folderfile}/fig6B_${vari}_`lname'_ct.pdf", replace 
		
		*Figure CC
		if "${vari}" == "researn1F"{
			local ylimlo = 0
			local ylimup = 100
			local ylimdf = 20
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = 0
			local ylimup = 50
			local ylimdf = 10
		}
		
		tw (connected kurt${vari}1 kurt${vari}2 kurt${vari}3 permrank if idex<=41, msymbol(none none o) ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100", labsize(${xlabsize}) grid) ///
		graphregion(color(white)) plotregion(lcolor(black)) ///
		legend(ring(0) position(11) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize}))  ///
		ytitle("Excess Kurtosis of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(medium)) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) yline(0,lcolor(black) lpattern(dash))
		graph export "${folderfile}/fig6C_${vari}_`lname'_ct.pdf", replace 	
		
		}	// END loop variables		
		}	// END loop men/women	
}
	
/*----------------------------------------------
	Mobility
------------------------------------------------*/
if "${figmob}" == "yes"{ 
	
	*What is the folder to save files 
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
		
		foreach mm in  0 1 2{			/*Gender: Men 1; Women 0*/		
		/*Load Data*/
		if (`mm' ==0) | (`mm' == 1){
                    insheet using "out${sep}${mobidata}${sep}L_male_agegp_permearnalt_mobstat.csv", clear                       
                        keep if male == `mm'
        }
        if (`mm' ==2){
                    insheet using "out${sep}${mobidata}${sep}L_agegp_permearnalt_mobstat.csv", clear                    
        }

			
		//insheet using "out${sep}${mobidata}${sep}L_male_agegp_permearnalt_mobstat.csv", clear			
		//keep if male == `mm'
		collapse meanpermearnaltranktp5 [aw=npermearnaltranktp5], by(permearnaltrankt year)
		keep meanpermearnaltranktp5 permearnaltrankt year
		reshape wide meanpermearnaltranktp5 , i(permearnaltrankt) j(year)
		gen idex = _n
		
		*T+5
		cap: drop  y1 x1 y2 x2
		if `mm' == 1{			
			gen y1 = 97 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 97 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 97
			local t2pos = 85 
		
		}
		else{
			gen y1 = 97 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 97 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 97
			local t2pos = 85 
		}
	    tw  (line meanpermearnaltranktp52007 meanpermearnaltranktp52012 permearnaltrankt permearnaltrankt if idex<= 41, ///
            color(red blue black) lpattern(solid dash dash) lwidth(thick thick )) ///
            (scatter meanpermearnaltranktp52007 meanpermearnaltranktp52012 permearnaltrankt if idex==42, ///
            color(red blue green) lpattern(dash dash dash) msymbol(D S O)  msize(large large large) ) ///
            (pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
            text(`t1pos' `t2pos' "Top 0.5% of P{sup:a}{sub:it}", place(w) size(large))  ///
            legend(ring(0) position(11) order(1 "2007" 2 "2012") size(large) cols(1) symxsize(7) region(color(none))) ///
            xtitle("Percentiles of Permanent Income, P{sup:a}{sub:it}", size(large)) title("", color(black) size(medlarge)) ///
            xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 99 "99.5", labsize(large) grid) ///
            graphregion(color(white)) plotregion(lcolor(black)) ///
            ytitle("Mean Percentiles of P{sup:a}{sub:it+5}", color(black) size(large)) ylabel(,labsize(large))                  
                                               
        graph export "${folderfile}/fig7_mobility_male`mm'_yrs_T5.${formatfile}", replace 

			
		*T+10
		 if (`mm' == 0) | (`mm' == 1){
                        insheet using "out${sep}${mobidata}${sep}L_male_agegp_permearnalt_mobstat.csv", clear                   
                        keep if male == `mm'
        }
                if (`mm' == 2){
                        insheet using "out${sep}${mobidata}${sep}L_agegp_permearnalt_mobstat.csv", clear                        
        }
		
		collapse meanpermearnaltranktp10 [aw=npermearnaltranktp10], by(permearnaltrankt year)
		keep meanpermearnaltranktp10 permearnaltrankt year
		reshape wide meanpermearnaltranktp10 , i(permearnaltrankt) j(year)
		gen idex = _n
		
		cap: drop  y1 x1 y2 x2
		if `mm' == 1{	
			gen y1 = 95 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 95 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 95
			local t2pos = 85 
				   			
		}
		else{			
			gen y1 = 98 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 98 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 98
			local t2pos = 85 

		}
			
		tw  (line meanpermearnaltranktp102007 meanpermearnaltranktp102008 permearnaltrankt permearnaltrankt if idex<= 41, ///
            color(red blue black) lpattern(solid dash dash) lwidth(thick thick)) ///
            (scatter meanpermearnaltranktp102007 meanpermearnaltranktp102008 permearnaltrankt if idex==42, ///
            color(red blue green) lpattern(dash dash dash) msymbol(D S O)  msize(large large large) ) ///
            (pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
            text(`t1pos' `t2pos' "Top 0.5% of P{sup:a}{sub:it}", place(w) size(large))  ///
            legend(ring(0) position(11) order(1 "2007" 2 "2008") size(large) cols(1) symxsize(7) region(color(none))) ///
            xtitle("Percentiles of Permanent Income, P{sup:a}{sub:it}", size(large)) title("", color(black) size(medlarge)) ///
            xlabel(0(10)90 99.5, labsize(large) grid) graphregion(color(white)) plotregion(lcolor(black)) ///
            ytitle("Mean Percentiles of P{sup:a}{sub:it+10}", color(black) size(large)) ylabel(,labsize(large))                 
			
       graph export "${folderfile}/fig7_mobility_male`mm'_yrs_T10.${formatfile}", replace 

		
	/*--- Mobility by age group---*/			
				
		/*Load Data*/
		if (`mm' ==0) | (`mm' == 1){
                        insheet using "out${sep}${mobidata}${sep}L_male_agegp_permearnalt_mobstat.csv", clear
                        keep if male == `mm'
        }
                if (`mm' ==2){
                        insheet using "out${sep}${mobidata}${sep}L_agegp_permearnalt_mobstat.csv", clear
        }

		collapse meanpermearnaltranktp5, by(permearnaltrankt agegp)
		keep meanpermearnaltranktp5 permearnaltrankt agegp
		reshape wide meanpermearnaltranktp5 , i(permearnaltrankt) j(agegp)
		gen idex = _n
		
		/*T+5 mobility*/
		cap: drop  y1 x1 y2 x2
		if `mm' == 1{			
			gen y1 = 95 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 95 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 95
			local t2pos = 85 
		
		}
		else{
			gen y1 = 95 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 95 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 95
			local t2pos = 85 
		}
						
		tw  (line meanpermearnaltranktp51 meanpermearnaltranktp52 meanpermearnaltranktp53 permearnaltrankt permearnaltrankt if idex<= 41, ///
			color(red blue green black) lpattern(solid dash dash_dot dash) lwidth(thick thick thick)) ///
			(scatter meanpermearnaltranktp51 meanpermearnaltranktp52 meanpermearnaltranktp53 permearnaltrankt if idex==42, ///
			color(red blue green) lpattern(dash dash dash) msymbol(D S O)  msize(large large large) ) ///
			(pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
			text(`t1pos' `t2pos' "Top 0.5% of P{sup:a}{sub:it}", place(w) size(large))  ///
			legend(ring(0) position(11) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(large) cols(1) symxsize(7) region(color(none))) ///
			xtitle("Percentiles of Permanent Income, P{sub:it}", size(large)) title("", color(black) size(medlarge)) ///
			xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 99 "99.5", labsize(large) grid) ///
			graphregion(color(white)) plotregion(lcolor(black)) ///
			ytitle("Mean Percentiles of P{sup:a}{sub:it+5}", color(black) size(large)) ylabel(,labsize(large))						
			graph export "${folderfile}/fig7_mobility_male`mm'_T5.pdf", replace 
		
			 
		/*T+10 mobility*/
		if (`mm' ==0) | (`mm' == 1){
                        insheet using "out${sep}${mobidata}${sep}L_male_agegp_permearnalt_mobstat.csv", clear
                        keep if male == `mm'
        }
        if (`mm' ==2){
                        insheet using "out${sep}${mobidata}${sep}L_agegp_permearnalt_mobstat.csv", clear                        
        }

		collapse meanpermearnaltranktp10, by(permearnaltrankt agegp)
		keep meanpermearnaltranktp10 permearnaltrankt agegp
		reshape wide meanpermearnaltranktp10 , i(permearnaltrankt) j(agegp)
		gen idex = _n
		
		cap: drop  y1 x1 y2 x2
		if `mm' == 1{	
			gen y1 = 95 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 95 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 95
			local t2pos = 85 
				   			
		}
		else{			
			gen y1 = 98 if _n == 1
			gen x1 = 85 if _n == 1
			gen y2 = 98 if _n == 1
			gen x2 = 97 if _n == 1
			local t1pos = 98
			local t2pos = 85 

		}	
		tw  (line meanpermearnaltranktp101 meanpermearnaltranktp102 permearnaltrankt permearnaltrankt if idex<= 41, ///
            color(red blue black) lpattern(solid dash dash) lwidth(thick thick)) ///
            (scatter meanpermearnaltranktp101 meanpermearnaltranktp102 permearnaltrankt if idex==42, ///
            color(red blue green) lpattern(dash dash dash) msymbol(D S O)  msize(large large large) ) ///
            (pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
            text(`t1pos' `t2pos' "Top 0.5% of P{sup:a}{sub:it}", place(w) size(large))  ///
            legend(ring(0) position(11) order(1 "[25-34]" 2 "[35-44]") size(large) cols(1) symxsize(7) region(color(none))) ///
            xtitle("Percentiles of Permanent Income, P{sup:a}{sub:it}", size(large)) title("", color(black) size(medlarge)) ///
            xlabel(0(10)90 99.5, labsize(large) grid) graphregion(color(white)) plotregion(lcolor(black)) ///
            ytitle("Mean Percentiles of P{sup:a}{sub:it+10}", color(black) size(large)) ylabel(,labsize(large))             
        graph export "${folderfile}/fig7_mobility_male`mm'_T10.${formatfile}", replace 

	}	// END loop over men and women	
}
****	

/*---------------------------------------------------	
    Tail For Appendix 
 ---------------------------------------------------*/
if "${figtail}" == "yes"{
	
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"
	
	*Load and reshape data 		
	forvalues mm = 0/2{			/*0: Women; 1: Men; 2: All*/
				
		if `mm' == 1{
			insheet using "out${sep}${ineqdata}${sep}RI_male_earn_idex.csv", clear comma 
			keep if male == `mm'
			local llabel = "Male"
		}
		else if `mm' == 0{
			insheet using "out${sep}${ineqdata}${sep}RI_male_earn_idex.csv", clear comma 
			keep if male == `mm'
			local llabel = "Women"		
		}
		else {
			insheet using "out${sep}${ineqdata}${sep}RI_earn_idex.csv", clear comma 			
		}
				
		reshape long t me ra ob, i(year) j(level) string
		split level, p(level) 
		drop level1
		rename level2 numlevel
		destring numlevel, replace 
		order numlevel level year 
		sort year numlevel
		
		*Re scale and share of pop
		by year: gen aux = 20*ob if numlevel == 0 
		by year: egen tob = max(aux)   // Because ob is number of observations in top 5%
		drop aux
		by year: gen  shob = ob/tob
				 gen  lshob = log(shob)		  	
		
		gen t1000s = (t/1000)/${exrate2018}				// Tranform to dollars of 2018
		gen lt1000s = log(t1000s)
		gen lt = log(t)
		gen l10t = log10(t)
		
		*Re-reshape 
		reshape wide t me ra ob tob shob lshob t1000s lt l10t lt1000s, i(numlevel) j(year)
		
		
		/*5% Tail*/
		regress lshob2005 lt2005
        predict lshob2005_hat, xb
        global slopep2005 : di %4.2f _b[lt2005]

		
		regress lshob2015 lt2015
		predict lshob2015_hat, xb
		global slopep2015 : di %4.2f _b[lt2015]
				
		tw (line lshob2005 lshob2005_hat lt2005, color(red red) lwidth(thick) lpattern(solid dash)) ///
           (line  lshob2015 lshob2015_hat lt2015 , color(blue blue)  lwidth(thick) lpattern(solid dash)) , ///
           legend(ring(0) position(2) ///
           order(1 "2005 Level (Slope: ${slopep2005})" 3 "2015 Level (Slope: ${slopep2015})") size(medium) cols(1) symxsize(7) region(color(none))) ///
           xtitle("log y{sub:it}", size(${xtitlesize})) title(, color(black) size(medlarge)) ///
           xlabel(, grid labsize(${xlabsize})) graphregion(color(white)) plotregion(lcolor(black)) ///
           ytitle("log(1-CDF)", color(black) size(${ytitlesize})) ylabel(,labsize(${ylabsize}))
        graph export "${folderfile}/logCDF_5pct_`llabel'.${formatfile}", replace 
        drop lshob2015_hat lshob2005_hat

		
		/*1% Tail*/		
		regress lshob2005 lt2005 if shob2005 < 0.01
		predict lshob2005_hat if e(sample), xb
		global slopep2005 : di %4.2f _b[lt2005]
		
		regress lshob2015 lt2015 if shob2015 < 0.01
		predict lshob2015_hat if e(sample), xb
		global slopep2015 : di %4.2f _b[lt2015]
				
		 tw (line lshob2005 lshob2005_hat lt2005    if shob2005 < 0.01, color(red red) lwidth(thick) lpattern(solid dash)) ///
            (line  lshob2015 lshob2015_hat lt2015  if shob2015 < 0.01, color(blue blue)  lwidth(thick) lpattern(solid dash)) , ///
            legend(ring(0) position(2) order(1 "2005 Level (Slope: ${slopep2005})" 3 "2015 Level (Slope: ${slopep2015})") ///
            size(medium) cols(1) symxsize(7) region(color(none))) ///
            xtitle("log y{sub:it}", size(${xtitlesize})) title(, color(black) size(medlarge)) ///
            xlabel(, grid labsize(${xlabsize})) graphregion(color(white)) plotregion(lcolor(black)) ///
            ytitle("log(1-CDF)", color(black) size(${ytitlesize})) ylabel(,labsize(${ylabsize}))
         graph export "${folderfile}/logCDF_1pct_`llabel'.${formatfile}", replace 
         drop lshob2015_hat lshob2005_hat

		
	}
}

/*---------------------------------------------------	
    This section generates the figures 3b in the
	Common Core section of the Guidelines
 ---------------------------------------------------*/	
if "${figcon}" == "yes"{ 
	*Folder to save figures 
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
	
	foreach subgp in male fem   all{
	*You can add more groups to this section 
	if "`subgp'" == "all"{
		insheet using  "out${sep}${ineqdata}${sep}L_earn_con.csv", clear
		local tlocal = "All Sample"
	}
	if "`subgp'" == "male"{
		insheet using "out${sep}${ineqdata}${sep}L_earn_con_male.csv", clear
		keep if male == 1	// Keep the group we want to plot 
		local tlocal = "Men"
	}	
	if "`subgp'" == "fem"{
		insheet using "out${sep}${ineqdata}${sep}L_earn_con_male.csv", clear
		keep if male == 0	// Keep the group we want to plot 
		local tlocal = "Women"
	}
	
	
	*Normalizing data to value in ${normyear}
	local lyear = ${normyear}	// Normalization year
	foreach vv in q1share q2share q3share q4share q5share ///
				  top10share top5share top1share top05share top01share top001share ///
				  bot50share{
		
		sum  `vv' if year == `lyear', meanonly
		gen n`vv' = (`vv' - r(mean))/100
		
		}
		
	*What years 
	local rlast = ${yrlast}
	
	*Recession bars 
	gen rece = inlist(year,${receyears})
	
	
	*Joint Quintiles Figures
	tspltAREALimZero "nq1share nq2share nq3share nq4share nq5share" /// Which variables?
		   "year" ///
		   ${yrfirst} `rlast' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
		   "Q1" "Q2" "Q3" "Q4" "Q5" "" "" "" "" /// Labels 
		    "1" "11" ///
		   "" /// x axis title
		   "Change in Income Shares Relative to `lyear'" /// y axis title 
		   "" ///  Plot title
		   ""  /// 	 Plot subtitle  (left blank in this example)
		   "fig11B_nquintile_more_`subgp'"	/// Figure name
		   "-0.03" "0.03" "0.02"				/// ylimits
		   "" 						/// If legend is active or nor	
	       "green black maroon red navy blue forest_green purple gray orange"	/// Colors
		   "solid solid solid solid solid solid solid solid" ///
		   "O T D S T dh sh th dh sh x none"
		   
		tspltAREALimZero "nbot50share ntop10share ntop5share ntop1share ntop05share" /// Which variables?
		   "year" ///
		   ${yrfirst} `rlast' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
		   "Bottom 50%" "Top 10%" "Top 5%" "Top 1%" "Top 0.5%" "" "" "" "" /// Labels 
		    "1" "11" ///
		   "" /// x axis title
		   "Change in Income Shares Relative to `lyear'" /// y axis title 
		   "" ///  Plot title
		   ""  /// 	 Plot subtitle  (left blank in this example)
		   "fig11B_bot50share_more_`subgp'"	/// Figure name
		   "-0.03" "0.03" "0.02"				/// ylimits
		   "" 						/// If legend is active or nor	
	       "green black maroon red navy blue forest_green purple gray orange"	/// Colors
		   "solid solid solid solid solid solid solid solid" ///
		   "O T D S T dh sh th dh sh x none"
		   
		   
	*Gini
	tspltAREALim2 "gini" /// Which variables?
		   "year" ///
		   ${yrfirst} `rlast' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
		   "Gini" "" "" "" "" "" "" "" "" /// Labels 
		   "1" "11" ///
		   "" /// x axis title
		   "Gini Coefficient" /// y axis title 
		   "" ///  Plot title
		   ""  /// 	 Plot subtitle  (left blank in this example)
		   "fig3b_gini_`subgp'"	/// Figure name
		   "0.38" "0.42" "0.01"				/// ylimits
		   "off" 						/// If legend is active or nor	
		   "blue red"			// Colors
		   
		   
}	// END of loop over variables
} // END of section 


/*---------------------------------------------------	
	Earnings growth Densities
---------------------------------------------------	*/

if "${figden}" == "yes"{ 
	
	*Folder to save figures 
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
	
	*Ploting
	foreach sam in women men all{
		foreach yy in 2005 2010{			// Which years are being plotted
			foreach vari in researn1F researn5F    {
			
				*Labels 
				if "`vari'" == "researn1F"{
// 					local labtitle = "{&Delta}{sup:1}{&epsilon}{sub:it}"
					local labtitle = "g{sup:1}{sub:it}"
				}
				if "`vari'" == "researn5F"{
// 					local labtitle = "{&Delta}{sup:5}{&epsilon}{sub:it}"
					local labtitle = "g{sup:5}{sub:it}"
				}
			
				*Data
				if "`sam'" == "all"{
					insheet using "out${sep}${voladata}${sep}L_`vari'_sumstat.csv", case clear
					
					sum sd`vari' if year == `yy'
					global sd = r(mean) 
					
					sum skew`vari' if year == `yy'
					global skew = r(mean) 
								
					sum kurt`vari' if year == `yy'
					global kurt = r(mean) 
					
					global sdplot: di %4.2f  ${sd}
					global skplot: di %4.2f  ${skew}
					global kuplot: di %4.2f  ${kurt}
					
					insheet using "out${sep}${voladata}${sep}L_`vari'_hist.csv", case clear
					local labtitle2 = "(All Sample)"
				}
				else if "`sam'" == "men"{
					insheet using "out${sep}${voladata}${sep}L_`vari'_male_sumstat.csv", case clear
					
					sum sd`vari' if year == `yy' & male == 1
					global sd = r(mean) 
					
					sum skew`vari' if year == `yy' & male == 1
					global skew = r(mean) 
								
					sum kurt`vari' if year == `yy' & male == 1
					global kurt = r(mean) 
					
					global sdplot: di %4.2f  ${sd}
					global skplot: di %4.2f  ${skew}
					global kuplot: di %4.2f  ${kurt}
					
					
					insheet using "out${sep}${voladata}${sep}L_`vari'_hist_male.csv", case clear
					keep if male == 1
					local labtitle2 = "(Men Only)"
				}
				else if "`sam'" == "women"{
					insheet using "out${sep}${voladata}${sep}L_`vari'_male_sumstat.csv", case clear
					
					sum sd`vari' if year == `yy' & male == 0
					global sd = r(mean) 
					
					sum skew`vari' if year == `yy' & male == 0
					global skew = r(mean) 
								
					sum kurt`vari' if year == `yy' & male == 0
					global kurt = r(mean) 
					
					global sdplot: di %4.2f  ${sd}
					global skplot: di %4.2f  ${skew}
					global kuplot: di %4.2f  ${kurt}
					
					insheet using "out${sep}${voladata}${sep}L_`vari'_hist_male.csv", case clear
					keep if male == 0
					local labtitle2 = "(Women Only)"
				}
				
				
				*Log densities 
				gen lden_`vari'`yy' = log(den_`vari'`yy')
				gen lnden_`vari'`yy' = log(normalden(val_`vari'`yy',0,${sd}))
				
				gen nden_`vari'`yy' = (normalden(val_`vari'`yy',0,${sd}))
				
				*Slopes
				reg lden_`vari'`yy' val_`vari'`yy' if val_`vari'`yy' < -1 & val_`vari'`yy' > -4
				global blefttail: di %4.2f _b[val_`vari'`yy']
				predict lefttail if e(sample), xb 
				
				reg lden_`vari'`yy' val_`vari'`yy' if val_`vari'`yy' > 1 & val_`vari'`yy' < 4
				global brighttail: di %4.2f _b[val_`vari'`yy']
				predict righttail if e(sample), xb 
				
				*Trimming for plots
				replace lnden_`vari'`yy' = . if val_`vari'`yy' < -2
				replace lnden_`vari'`yy' = . if val_`vari'`yy' > 2
				
				replace lden_`vari'`yy' = . if val_`vari'`yy' < -4
				replace lden_`vari'`yy' = . if val_`vari'`yy' > 4
				
				
				replace nden_`vari'`yy' = . if val_`vari'`yy' < -4
				replace nden_`vari'`yy' = . if val_`vari'`yy' > 4
				
				replace den_`vari'`yy' = . if val_`vari'`yy' < -4
				replace den_`vari'`yy' = . if val_`vari'`yy' > 4
				
				replace lefttail = . if val_`vari'`yy' < -4
				replace lden_`vari'`yy' = . if val_`vari'`yy' > 4
				
				replace righttail = . if val_`vari'`yy' > 4
				replace lden_`vari'`yy' = . if val_`vari'`yy' > 4
				
				
				logdnplot "lden_`vari'`yy' lnden_`vari'`yy' lefttail righttail" "val_`vari'`yy'" /// y and x variables 
						"One-Year Log Earnings Growth" "Log-Density" "medium" "medium" 		/// x and y axcis titles and sizes 
						 "" "" "large" ""  ///	Plot title
						 "Data Density" "N(0,${sdplot}{sup:2})" "Left   Slope: ${blefttail}" "Right Slope: ${brighttail}" "" ""						/// Legends
						 "on" "11"	"1"							/// Leave empty for active legend
						 "-4" "4" "1" "-10" "3" "2"				/// Set limits of x and y axis 
						 "lden_`vari'`yy'"					    /// Set what variable defines the y-axis
						"fig13_lden_`vari'_`sam'_`yy'"			/// Name of file
						"St. Dev.: ${sdplot}" "Skewness: ${skplot}"  "Kurtosis: ${kuplot}" ///
						 "2 1.8" "1 1.8" "0 1.8"				// Position of the right text
						 										
				logdnplot "den_`vari'`yy' nden_`vari'`yy'" "val_`vari'`yy'" /// y and x variables 
						"One-Year Log Earnings Growth" "Density" "medium" "medium" 		/// x and y axcis titles and sizes 
						 "" "" "large" ""  ///	Plot title
						 "Data Density" "N(0,${sdplot}{sup:2})" "" "" "" ""						/// Legends
						 "on" "11"	"1"							/// Leave empty for active legend
						 "-2.5" "2.5" "1" "0" "4" "1"				/// Set limits of x and y axis 
						 "den_`vari'`yy'"					/// Set what variable defines the y-axis
						"fig13_den_`vari'_`sam'_`yy'"		/// Name of file
						"St. Dev.: ${sdplot}" "Skewness: ${skplot}"  "Kurtosis: ${kuplot}" ///
						 "3.0 1" "2.5 1" "2.0 1"							 				
			
			}	// END loop over variables	
		}	// END loop over years 
	}	// END loop over samples
} 	// END of section





if "${figquan2}" == "yes"{ 
	
		
		local mm = 1 // 0: Women; 1: Men; 2: All	
		local jj = 1
		local var = "researn`jj'F"
		global vari = "`var'"

		*What is the label for title 
		if "${vari}"== "researn1F"{
			local labtitle = "g{sub:it}"
			global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
		}
		if "${vari}" == "researn5F"{
			local labtitle = "g{sub:it}{sup:5}"
			global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
		}
	 
		*Load the data for the last percentile
		insheet using "out${sep}${voladata}${sep}L_`var'_maleagerank.csv", clear case
		
		*Calculate additional moments 
		gen p9010${vari} = p90${vari} - p10${vari}
		gen p9510${vari} = p95${vari} - p10${vari}
		gen p9910${vari} = p99${vari} - p10${vari}
		
		gen p9050${vari} = p90${vari} - p50${vari}
		gen p5010${vari} = p50${vari} - p10${vari}
		gen p7525${vari} = p75${vari} - p25${vari}
		gen ksk${vari} = (p9050${vari} - p5010${vari})/p9010${vari}
		gen cku${vari} = (p97_5${vari} - p2_5${vari})/p7525${vari} - 2.91		// Excess Kurtosis
		replace kurt${vari} = kurt${vari} - 3.0		// Excess Kurtosis
		
		if `mm' == 1{
			keep if male == `mm'
			local lname = "men"
			local mlabel = "Men"
		}
		else if `mm' == 0{
			keep if male == `mm'
			local lname = "women"
			local mlabel = "Women"
		}
		
						
		collapse  p9010${vari}  p9510${vari} p9910${vari} p9050${vari} p5010${vari} sd${vari} ksk${vari} skew${vari} cku${vari} kurt${vari}, by(agegp permrank)
		reshape wide p9010${vari} p9510${vari} p9910${vari}  p9050${vari} p5010${vari} sd${vari} ksk${vari} skew${vari} cku${vari} kurt${vari}, i(permrank) j(agegp)
		
		*Idex for plot: the code calculates the top 0.1% in a seperated group (group 42). Since some countries might have 
		*top coded values, we do not plot the top 0.1%
		gen idex = _n
		order idex 
	
		*Figure A		
		if "${vari}" == "researn1F"{
			local ylimlo = 0.0
			local ylimup = 2.2
			local ylimdf = 0.5			
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = 0.5
			local ylimup = 3
			local ylimdf = 0.5		
		}
		
	
		
		*Ploting 9010
		*These will define the arrow; Change accordingly
		cap: drop  y1 x1 y2 x2
		input y1 x1 y2 x2
				0.8 87.7 0.66 95
		end
		
		
		tw (connected p9010${vari}1 p9010${vari}2 p9010${vari}3 permrank if idex<=41, msymbol(none none o)  ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)) ///
		(scatter p9010${vari}1 p9010${vari}2 p9010${vari}3 permrank if idex==42, ///
		color(red blue green) lpattern(dash dash dash) msymbol(D S O)) ///
		(pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 99.5 "99.5", labsize(${xlabsize}) grid) ///		
		graphregion(color(white)) plotregion(lcolor(black)) ///
		 text(0.9 85 "Top 0.5% of P{sub:it-1}", place(w) size(medium)) ///
		legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
		ytitle("P90-P10 Difference of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) 
		graph export "${folderfile}/fig6A_${vari}_`lname'_alt.${formatfile}", replace
				
		tw (connected p9510${vari}1 p9510${vari}2 p9510${vari}3 permrank if idex<=41, msymbol(none none o)  ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)) ///
		(scatter p9510${vari}1 p9510${vari}2 p9510${vari}3 permrank if idex==42, ///
		color(red blue green) lpattern(dash dash dash) msymbol(D S O)) ///
		(pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 99.5 "99.5", labsize(${xlabsize}) grid) ///		
		graphregion(color(white)) plotregion(lcolor(black)) ///
		 text(0.9 85 "Top 0.5% of P{sub:it-1}", place(w) size(medium)) ///
		legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
		ytitle("P95-P10 Difference of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) 
		graph export "${folderfile}/fig6A_${vari}_`lname'_9510_alt.${formatfile}", replace
		
	    
		cap: drop  y1 x1 y2 x2
		input y1 x1 y2 x2
				0.8 87.7 0.8 95
		end
		
	    tw (connected p9910${vari}1 p9910${vari}2 p9910${vari}3 permrank if idex<=41, msymbol(none none o)  ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)) ///
		(scatter p9910${vari}1 p9910${vari}2 p9910${vari}3 permrank if idex==42, ///
		color(red blue green) lpattern(dash dash dash) msymbol(D S O)) ///
		(pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 99.5 "99.5", labsize(${xlabsize}) grid) ///		
		graphregion(color(white)) plotregion(lcolor(black)) ///
		 text(0.9 85 "Top 0.5% of P{sub:it-1}", place(w) size(medium)) ///
		legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
		ytitle("P99-P10 Difference of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) 
		graph export "${folderfile}/fig6A_${vari}_`lname'_9910_alt.${formatfile}", replace
		
		
		*Figure B	
		if "${vari}" == "researn1F"{
			local ylimlo = -0.4
			local ylimup = 0.25
			local ylimdf = 0.2			
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = -0.5
			local ylimup = 0.2
			local ylimdf = 0.2		
		}
		
	    
		cap: drop  y1 x1 y2 x2
		input y1 x1 y2 x2
				-0.1 87.7 -0.1 95
		end
	
		tw (connected ksk${vari}1 ksk${vari}2 ksk${vari}3 permrank if idex<=41, msymbol(none none o)  ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)) ///
		(scatter ksk${vari}1 ksk${vari}2 ksk${vari}3 permrank if idex==42, ///
		color(red blue green) lpattern(dash dash dash) msymbol(D S O)) ///
		(pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 99.5 "99.5", labsize(${xlabsize}) grid) ///		
		graphregion(color(white)) plotregion(lcolor(black)) ///
		 text(-0.1 85 "Top 0.5% of P{sub:it-1}", place(w) size(medium)) ///
		legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
		ytitle("Kelley Skewness of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) 
		graph export "${folderfile}/fig6B_${vari}_`lname'_alt.${formatfile}", replace 
		
				
		*Figure C
		if "${vari}" == "researn1F"{
			local ylimlo = 1
			local ylimup = 28
			local ylimdf = 4
		}		
		if "${vari}" == "researn5F"{
			local ylimlo = 1
			local ylimup = 11
			local ylimdf = 2	
		}
		
		cap: drop  y1 x1 y2 x2
		input y1 x1 y2 x2
				4 87.7 4 95
		end
		
		tw (connected cku${vari}1 cku${vari}2 cku${vari}3 permrank if idex<=41, msymbol(none none o)  ///
		color(red blue green) lpattern(solid dash dash_dot) lwidth(thick thick thick)) ///
		(scatter cku${vari}1 cku${vari}2 cku${vari}3 permrank if idex==42, ///
		color(red blue green) lpattern(dash dash dash) msymbol(D S O)) ///
		(pcarrow y1 x1 y2 x2, msize(medlarge) mlwidth(medthick) mlcolor(black) lcolor(black) ), ///
		xlabel(2.5 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 99.5 "99.5", labsize(${xlabsize}) grid) ///		
		graphregion(color(white)) plotregion(lcolor(black)) ///
		 text(4 85 "Top 0.5% of P{sub:it-1}", place(w) size(medium)) ///
		legend(ring(0) position(2) order(1 "[25-34]" 2 "[35-44]" 3 "[45-55]") size(${legesize}) cols(1) symxsize(7) region(color(none))) ///
		xtitle("Percentiles of Permanent Income {&epsilon}{sup:P}{sub:it-1}", size(${xtitlesize})) ///
		ytitle("Excess Crow-Siddiqui Kurtosis of `labtitle'", size(${ytitlesize})) ///
		title("", color(black) size(${titlesize})) ylabel(`ylimlo'(`ylimdf')`ylimup',labsize(${ylabsize})) 
		graph export "${folderfile}/fig6C_${vari}_`lname'_alt.${formatfile}", replace 	 
		

	
		
		
}



if "${figext}" == "yes"{  

*Where the figures are going to be saved 
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
	
*Time series   
foreach var in  researn1F researn5F{				
	foreach subgp in male fem  all{
	*Which variable will be ploted
	global vari = "`var'"						 
	
	*What is the group under analysis? 
	*You can add more groups to this section 
	if "`subgp'" == "all"{
		insheet using "out${sep}${voladata}${sep}L_`var'_sumstat.csv", case clear
		local labtitle2 = "All"
	}
	if "`subgp'" == "male"{
		insheet using "out${sep}${voladata}${sep}L_`var'_male_sumstat.csv", case clear
		keep if male == 1	// Keep the group we want to plot 
		local labtitle2 = "Men"
	}
		
	if "`subgp'" == "fem"{
		insheet using "out${sep}${voladata}${sep}L_`var'_male_sumstat.csv", case clear
		keep if male == 0	// Keep the group we want to plot 
		local labtitle2 = "Women"
	}

	
	*What is the label for title 

	
	if "${vari}" == "researn1F"{		
		local labtitle = "g{sub:it}"
	}		
	if "${vari}" == "researn5F"{	
		local labtitle = "g{sup:5}{sub:it}" // ?? what labels here?
	}
		
	*What are the x-axis limits
	if "${vari}" == "researn1F"  | "${vari}" == "arcearn1F"  {
		local lyear = ${yrlast}-1		
		local ljum = 0
		local fyear = ${yrfirst} + `ljum'
		local nyear = ${normyear}
	}
	if "${vari}" == "researn5F" | "${vari}" == "arcearn5F"{
		local lyear = ${yrlast} - 2
		local ljum = 0		// So plot is centered in year 3
		local fyear = ${yrfirst} + 3
		local nyear = `fyear'
		replace year = year + 3		// This just re labels the year to center the 5-year changes to the "middle" year. 	
									// I.e. if your data goes from 1993/2017 and the first 5-years change in between 1993 and 1998
									// the "middle" year is 1996 (which is the starting point of your plot)
									// The last 5 year change dates on 2012, which will be plotted in the "middle" year, 2015
	}

	*Normalize Percentiles 
	gen var${vari} = sd${vari}^2
	gen p9010${vari} = p90${vari} - p10${vari}
	gen p9050${vari} = p90${vari} - p50${vari}
	gen p5010${vari} = p50${vari} - p10${vari}
	gen p7525${vari} = p75${vari} - p25${vari}
	
	gen ksk${vari} = (p9050${vari} - p5010${vari})/p9010${vari}
	gen cku${vari} = (p97_5${vari} - p2_5${vari})/p7525${vari}
	
	
	*Rescale by first year 
	foreach vv in sd$vari var${vari} p1$vari p2_5$vari p5$vari p10$vari p12_5$vari p25$vari ///
		p37_5$vari p50$vari p62_5$vari p75$vari p87_5$vari p90$vari p95$vari ///
		p97_5$vari p99$vari p99_5$vari ///
		p9010${vari} p9050${vari} p5010${vari} p7525${vari} ksk${vari} {
		sum  `vv' if year == `nyear', meanonly
		qui: gen n`vv' = `vv' - r(mean)
		
	}
		
	*What are the recession years
	gen rece = inlist(year,${receyears})
	
	tsset year
	
		
// Figure 4	
*
	tspltAREALimPA "L`ljum'.np90$vari L`ljum'.np75$vari L`ljum'.np50$vari L`ljum'.np25$vari L`ljum'.np10$vari " /// Which variables?
	   "year" ///
		`fyear' `lyear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 
	   "p90" "p75" "p50" "p25" "p10" "" "" "" ""  /// Labels 
	   "1" "11" ///
	   "" /// x axis title
	   "Percentiles of `labtitle' relative to ${yrfirst}" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "fig4_`subgp'_n${vari}_ext1"	/// Figure name
	   "-0.4" "0.4" "0.2" /// ylimits
	   "" /// If legend is active or nor	
	   "blue green red navy black maroon forest_green purple gray orange" /// Colors
	   "O + S x D" 	 
					  
	tspltAREALimPA "L`ljum'.np90$vari L`ljum'.np95$vari L`ljum'.np99$vari L`ljum'.np99_5$vari  " /// Which variables?
	   "year" ///
		`fyear' `lyear' 3 /// Limits of x and y axis. Example: x axis is -.1(0.05).1 	   
	   "p90" "p95" "p99" "p99.5" "" "" "" "" "" /// Labels 
	   "1" "11" ///
	   "" /// x axis title
	    "Percentiles of `labtitle' relative to ${yrfirst}" /// y axis title 
	   "" ///  Plot title
	   "" ///
	   "fig4_`subgp'_n${vari}_ext2"	/// Figure name
	   "-0.4" "0.4" "0.2" /// ylimits
	   "" /// If legend is active or nor	
	   "blue green red navy black maroon forest_green purple gray orange" /// Colors
	   "D + S x O" 	   		
	  
		    		   
	   }	// END of loop over subgroups
}	// END loop over variables


}



if "${figext2}" == "yes"{  

    global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"		
	use logearn2006 researn8F2006 using "$maindir${sep}dta${sep}master_sample.dta", clear 
	keep if !missing(logearn2006)&!missing(researn8F2006)
	
	xtile rank = logearn, n(50)
	
    replace rank = rank * 2
		
	collapse (p10) p10 = researn8F2006 ///
			(p25) p25 = researn8F2006 ///
			(p50) p50 = researn8F2006 ///
			(p75) p75 = researn8F2006 ///
			(p90) p90 = researn8F2006, by(rank)

	/*gen cvarm_norm1 = cvar_m_p50 if rank == 25
	gen res_norm1 = sdres1F if rank == 25
	egen cvarm_norm = max(cvarm_norm1)
	egen res_norm = max(res_norm1)
	drop cvarm_norm1 res_norm1*/
	

	
	*replace cvar_m_p10 = cvar_m_p10 + 1 - cvarm_norm
	*replace cvar_m_p50 = cvar_m_p50 + 1 - cvarm_norm
	*replace cvar_m_p90 = cvar_m_p90 + 1 - cvarm_norm
	*replace sdres1F = sdres1F +  1 - res_norm
	
	colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 )
	tw (line p10 rank  if rank>1 & rank<100, lcolor("`r(p1)'")  mfcolor("`r(p1)'") mlcolor("`r(p1)'") mlwidth(medthick) lpattern(solid) msymbol(T) ) ///
		(line p25 rank  if rank>1 & rank<100, lcolor("`r(p2)'") mfcolor("`r(p2)'") mlcolor("`r(p2)'") mlwidth(medthick) lpattern(dash) msymbol(T)  ) ///
		(line p50 rank  if rank>1 & rank<100, lcolor("`r(p3)'") mfcolor("`r(p3)'") mlcolor("`r(p3)'") mlwidth(medthick) lpattern(dash_dot) msymbol(T) ) ///
		(line p75 rank  if rank>1 & rank<100, lcolor("`r(p4)'") mfcolor("`r(p4)'") mlcolor("`r(p4)'") mlwidth(medthick)  lpattern(shortdash) msymbol(T) ) ///
		(line p90 rank  if rank>1 & rank<100, lcolor("`r(p5)'") mfcolor("`r(p5)'") mlcolor("`r(p5)'") mlwidth(medthick) lpattern(longdash_dot) msymbol(T) ), ///
		 legend(order(1 "p10" 2 "p25" 3 "p50" 4 "p75" 5 "p90") ///
		symxsize(9.0) ring(0) position(1) col(1) ///
		region(color(none) lcolor(white))) ///
		xtitle("Percentiles of log earnings at 2006", size(medium)) ///
		ytitle("Change in residualized log earnings 2006-2014") ///
		graphregion(color(white)  ) ///				Graph region define
		plotregion(lcolor(black))  ///				Plot regione define
		title("", color(black)) //
		
	cap noisily: graph export "${folderfile}/res8F2006_fig.${formatfile}", replace 



}



/*if "${tabext}" == "yes"{  

if inlist(`yr',${d5yrlist}){				// Has 5yr change (LX Sample)
			use  male yob educ researn1F`yr' researn5F`yr' arcearn1F`yr' arcearn5F`yr' permearn`yrp' ///
			using "$maindir${sep}dta${sep}master_sample.dta", clear   
		}
}*/


if "${tabext2}" == "yes"{  

	
	global folderfile = "$maindir${sep}figs${sep}${outfolder}${sep}FigsPaper"	
	
	use personid male yob educ logearn* using "$maindir${sep}dta${sep}master_sample.dta", clear 
	drop logearnc*
	reshape long logearn, i(personid) j(year) 
	rename personid person_id
	merge 1:1 person_id year using "$maindir${sep}dta${sep}mcvl_annual_FinalData_pt1_RemoveAllAfter2_morevars.dta", keepusing(sector main_occ)
	*merge 1:1 person_id year using "/Users/siqiwei/Dropbox/Global_Income_Dynamics_OLD_2022/Part1/dta/mcvl_annual_FinalData_pt1_RemoveAllAfter2_morevars.dta", keepusing(sector main_occ)
	 
	tab _merge if !missing(logearn)
	gen age = year-yob+1
	tab age if !missing(logearn)
	
	* quantiles of income 
	*xtile rank = logearn, n(100)
	sum logearn,de
	local t1 = r(p50) 
	local t2 = r(p75)
	local t3 = r(p90)
	local t4 = r(p95)
	local t5 = r(p99)
	sum logearn if logearn > `t5' & !missing(logearn),de
	local t6 = r(p50)  // 99.5
	* tab sector
	di "`t1'"
	di "`t2'"
	di "`t3'"
	di "`t4'"
	di "`t5'"
	di "`t6'"
	
	
	tab sector if logearn >= `t1' & logearn < `t2' & !missing(logearn) & sector > 0,matcell(m1)
	tab sector if logearn >= `t2' & logearn < `t3' & !missing(logearn) & sector > 0,matcell(m2)
	tab sector if logearn >= `t3' & logearn < `t4' & !missing(logearn) & sector > 0,matcell(m3)
	tab sector if logearn >= `t4' & logearn < `t5' & !missing(logearn) & sector > 0,matcell(m4)
	tab sector if logearn >= `t5' & logearn < `t6' & !missing(logearn) & sector > 0,matcell(m5)
	tab sector if logearn >= `t6' & !missing(logearn) & sector > 0,matcell(m6)

	matrix define table1 = (m1,m2,m3,m4,m5,m6)
	mata : st_matrix("B", colsum(st_matrix("table1")))
	forval i = 1/6{	    
	    forval j = 1/9{
	        matrix table1[`j',`i'] = table1[`j',`i']/B[1,`i']
		}
	}
		
	matrix colnames table1 = P50-P75 P75-P90 P90-P95 P95-P99 P99-P995 P995
	matrix rownames table1 = agri clothing_chemical_car sales_trans_energy construction hotels fin_corporate publicadminis edu_health socialservices
			
	esttab matrix(table1, fmt(2)) ///
		using "${folderfile}/table1_sector.tex", ///
		noobs nonumber nomtitles align(`=colsof(table1)*"c"') replace
	* occ
	tab main_occ if logearn >= `t1' & logearn < `t2' & !missing(logearn) & main_occ > 0,matcell(m1)
	tab main_occ if logearn >= `t2' & logearn < `t3' & !missing(logearn) & main_occ > 0,matcell(m2)
	tab main_occ if logearn >= `t3' & logearn < `t4' & !missing(logearn) & main_occ > 0,matcell(m3)
	tab main_occ if logearn >= `t4' & logearn < `t5' & !missing(logearn) & main_occ > 0,matcell(m4)
	tab main_occ if logearn >= `t5' & logearn < `t6' & !missing(logearn) & main_occ > 0,matcell(m5)
	tab main_occ if logearn >= `t6' & !missing(logearn) & main_occ > 0,matcell(m6)

	matrix define table1 = (m1,m2,m3,m4,m5,m6)
	mata : st_matrix("B", colsum(st_matrix("table1")))
	forval i = 1/6{	    
	    forval j = 1/10{
	        matrix table1[`j',`i'] = table1[`j',`i']/B[1,`i']
		}
	}
		
	matrix colnames table1 = P50-P75 P75-P90 P90-P95 P95-P99 P99-P995 P995
	matrix rownames table1 = engi_manager techn_engi_graduate_assis adminis_tech_manager non_grad_assis adminis_officers subordinates adminis_assis first_sec_officer third_class_off_tech labourers
			
	esttab matrix(table1, fmt(2)) ///
		using "${folderfile}/table1_occ.tex", ///
		noobs nonumber nomtitles align(`=colsof(table1)*"c"') replace
	
	* age
	gen agegp = . 
	replace agegp = 1 if age <= 34 & agegp == .
	replace agegp = 2 if age <= 44 & agegp == .
	replace agegp = 3 if age <= 55 & agegp == .
	
	tab agegp if logearn >= `t1' & logearn < `t2' & !missing(logearn) ,matcell(m1)
	tab agegp if logearn >= `t2' & logearn < `t3' & !missing(logearn) ,matcell(m2)
	tab agegp if logearn >= `t3' & logearn < `t4' & !missing(logearn) ,matcell(m3)
	tab agegp if logearn >= `t4' & logearn < `t5' & !missing(logearn) ,matcell(m4)
	tab agegp if logearn >= `t5' & logearn < `t6' & !missing(logearn) ,matcell(m5)
	tab agegp if logearn >= `t6' & !missing(logearn),matcell(m6)

	matrix define table1 = (m1,m2,m3,m4,m5,m6)
	mata : st_matrix("B", colsum(st_matrix("table1")))
	forval i = 1/6{	    
	    forval j = 1/3{
	        matrix table1[`j',`i'] = table1[`j',`i']/B[1,`i']
		}
	}
		
	matrix colnames table1 = P50-P75 P75-P90 P90-P95 P95-P99 P99-P995 P995
	matrix rownames table1 = 25-34 35-44 45-55
			
	esttab matrix(table1, fmt(2)) ///
		using "${folderfile}/table1_age.tex", ///
		noobs nonumber nomtitles align(`=colsof(table1)*"c"') replace
	
		
	
}




*END OF THE CODE
