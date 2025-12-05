*------------------------------------------------------------------------------*
* Reproduction code for article "The underlying mechanisms behind the heatwave 
* impacts on birth outcomes: Evidence from a new birth cohort study in Brazil"
*------------------------------------------------------------------------------*

* Created by: Bruno Kawaoka Komatsu
* Last modified: 2025-12-05

*------------------------------------------------------------------------------*
**# 1. Reference folders
*------------------------------------------------------------------------------*

	clear all
	cd "data_folder_name"
	
	* Necessary packages:
	* ssc install ftools
	* ssc install reghdfe
	
*------------------------------------------------------------------------------*
**# 2. Data and variable lists
*------------------------------------------------------------------------------*

	* Loading data
	use "pone_registry_data", clear

	* Variable lists
	global covlist ppi_mae emi_mae gemeo fi_mae1 fi_mae3
	global ef codmunres#mes_c uf#ano_sinasc

*------------------------------------------------------------------------------*
**## Table 1 - Descriptive Statistics of Main Variables - Brazil 2019-2023
*------------------------------------------------------------------------------*

	* Creating indicators multiplied by 100 for Table 1
	foreach v of varlist bp ancong pn fi_mae1 fi_mae2 fi_mae3 emi_mae ppi_mae gemeo {
		cap drop `v'100
		gen `v'100 = `v' * 100
	}

	* Descriptive statistics
	tabstat peso bp100 idade_g ancong100 pn100 dias_oc3_35 prec fi_mae1100 fi_mae2100 fi_mae3100 emi_mae100 ppi_mae100 gemeo100, s(n mean sd min max) columns(statistics)

*------------------------------------------------------------------------------*
**## Figure 1B - Average Exposure to Heatwave Days by Month of Conception
*------------------------------------------------------------------------------*
	
	* Necessary Stata 16+ to deal with command "frame"
	* The command sequence below can alternatively run with commands "preserve"
	* and "restore"
	
	frame put dias_oc3_35 ano_c mes_c am, into(graphs)
	frame change graphs
	
	* Variable for year-month of conception
	gen ym_c = ym(ano_c,mes_c)
	format ym_c %tm

	* Graph
	gcollapse (mean) dias_oc3_35, by(ym_c)
	tw(bar dias_oc3_35 ym_c), 	///
		ylabel(,labsize(large)) 	///
		xlabel(696(6)763, angle(90) labsize(large)) 	///
		xtitle("Date of conception", size(large)) 	///
		ytitle("Days of exposure", size(large))
		
	frame change default
	frame drop graphs

*------------------------------------------------------------------------------*
**## Table 2 - Share of Newborns exposed to heatwaves, by parameters of heatwave definition
*------------------------------------------------------------------------------*

	* Loop on the number of consecutive days
	foreach i of numlist 2/7 {
		
		tabstat 			///
			dummy_oc`i'_30	///
			dummy_oc`i'_31 	///
			dummy_oc`i'_32 	///
			dummy_oc`i'_33 	///
			dummy_oc`i'_34 	///
			dummy_oc`i'_35 	///
			dummy_oc`i'_36	///
			if am == 1, s(mean) columns (statistics)

	}

*------------------------------------------------------------------------------*
**## Table 4 - Heatwave Days and Growth Outcomes using Registry Data
*------------------------------------------------------------------------------*

* 2019-2023 Unadjusted regressions 
	
	* Brazil
	reghdfe peso dias_oc3_35 prec, a(${ef}) vce(cluster codmunres) level(90)
	
	* Southeast region
	reghdfe peso dias_oc3_35 prec if mr == 3 , a(${ef}) vce(cluster codmunres) level(90)
	
	* São Paulo state
	reghdfe peso dias_oc3_35 prec if uf == 35 , a(${ef}) vce(cluster codmunres) level(90)

	* Ribeirão Preto
	reghdfe peso dias_oc3_35 prec if codmunnasc == 354340 , a(${ef}) vce(cluster codmunres) level(90)

	
* 2019-2023 Adjusted regressions

	* Brazil
	reghdfe peso dias_oc3_35 prec ${covlist}, a(${ef}) vce(cluster codmunres) level(90)
	
	* Southeast region
	reghdfe peso dias_oc3_35 prec ${covlist} if mr == 3 , a(${ef}) vce(cluster codmunres) level(90)
	
	* São Paulo state
	reghdfe peso dias_oc3_35 prec ${covlist} if uf == 35 , a(${ef}) vce(cluster codmunres) level(90)
		
	* Ribeirão Preto
	reghdfe peso dias_oc3_35 prec ${covlist} if codmunnasc == 354340 , a(${ef}) vce(cluster codmunres) level(90)
	
	
* 2023 Adjusted regressions

	* Brazil
	reghdfe peso dias_oc3_35 prec ${covlist} if ano_sinasc == 2023 , a(${ef}) vce(cluster codmunres) level(90)

	* Southeast region
	reghdfe peso dias_oc3_35 prec ${covlist} if mr == 3 & ano_sinasc == 2023 , a(${ef}) vce(cluster codmunres) level(90)

	* São Paulo state
	reghdfe peso dias_oc3_35 prec ${covlist} if uf == 35 & ano_sinasc == 2023 , a(${ef}) vce(cluster codmunres) level(90)

	* Ribeirão Preto
	reghdfe peso dias_oc3_35 prec ${covlist} if codmunnasc == 354340 & ano_sinasc == 2023 , a(${ef}) vce(cluster codmunres) level(90)
	
*------------------------------------------------------------------------------*
**## Table 5 - Potential Mechanisms for the Heatwave Impact
*------------------------------------------------------------------------------*
	
	reghdfe idade_g dias_oc3_35 prec ${covlist}, a(${ef}) vce(cluster codmunres) level(90)

*------------------------------------------------------------------------------*
**## Table 8 - Varying the Parameters in the Definition of Heatwaves
*------------------------------------------------------------------------------*

	* Loop on the number of consecutive days
	forvalues i = 2/7 {
		
		* Loop on the temperature cutoff
		forvalues j = 30/35 {
			
			* Amostra de 2019-2023
			reghdfe peso dias_oc`i'_`j' prec ${covlist}, a(${ef}) vce(cluster codmunres) level(90)
			
		}
		
	}

