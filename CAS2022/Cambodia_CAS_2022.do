*Data source
*-----------
*The Cambodia Agriculture Survey was collected by the National Institude of Statistics of the Ministry of Planning in cooperation with the Ministry of Agriculture, Forestry and Fisheries, and the Food and Agriculture Organization of the United Nations (FAO).  
*The data were collected over two periods, household agricultural interviews 13 November 2021 - 26 November 2021, and Juridical 13 December 2021 - 23 December 2021.
*All the raw data, questionnaires, technical documents, and reports are available for downloading free of charge at the following link:
* https://nada.nis.gov.kh/index.php/catalog/44
*Throughout the do-file, we sometimes use the shorthand CAS2022 to refer to the Cambodia Agriculture Survey 2022.


*Purpose of this do.file
*-----------
*This do.file constructs selected indicators that describe smallholder agricultural activity in the Cambodia Agriculture
*Survey 2022 (CAS2022) data set. Data analysis entails the renaming, merging, reshaping, aggregating, and combining of variables 
*from the CAS2022 survey. Using data files from within the "Cambodia 50x30" folder within the "raw_data" folder, this .do file
*first constructs common and intermediate variables, saving dta files when appropriate in the folder "temp". 
*These variables are then compiled together at the household-level and saved to a consolidated file
*in the folder "final_data". The final variables (also known as "indicators") can be
*used to identify sub-national trends, statistical relationships, time-series trends, and international cross-sectional comparisons.

*As of the most recent update (December 2024) this .do file is constructed with the primary purpose of facilitating data analysis
*and visualization in the Cambodia Agriculture Survey Policy & Data Explorer, with special attention to livestock, poultry, and 
*cashew production. Certain sections in this .do file are commented-out or empty. These sections may be developed further 
*if circumstances require more comprehensive analysis (e.g. total household agricultural income, yield, etc.) akin to EPAR's LSMS
*Agricultural Indicator Data Curation project:
*https://github.com/EvansSchoolPolicyAnalysisAndResearch/LSMS-Agricultural-Indicators-Code

/*
OUTLINE OF THE DO.FILE STRUCTURE
Below are the list of the code sections and main files created by running this do.file

*SECTION							MAIN INTERMEDIATE FILES CREATED
*-------------------------------------------------------------------------------------
*HOUSEHOLD IDS						Cambodia_CAS_2022_hhids.dta
*WEIGHTS							Cambodia_CAS_2022_weights.dta
*INDIVIDUAL IDS						Cambodia_CAS_2022_person_ids.dta
*HOUSEHOLD SIZE						Cambodia_CAS_2022_hhsize.dta
*COVID IMPACT						Cambodia_CAS_2022_COVID_impact.dta
*ASSOCIATION MEMBERSHIP				Cambodia_CAS_2022_association_membership.dta
*AGRICULTURAL HOUSEHOLDS			Cambodia_CAS_2022_agriculture_activities.dta
*HOUSEHOLD DECISION MAKERS			Cambodia_CAS_2022_hh_decision_makers.dta
*LIVESTOCK							Cambodia_CAS_2022_hhid_livestock_type.dta
									Cambodia_CAS_2022_livestock_type_growth.dta
									Cambodia_CAS_2022_livestock_type_vaccination.dta
									Cambodia_CAS_2022_livestock_otherproducts.dta
									Cambodia_CAS_2022_livestock_explicit_costs.dta
									Cambodia_CAS_2022_livestock_productivity_1.dta
									Cambodia_CAS_2022_livestock_productivity_2.dta
									Cambodia_CAS_2022_livestock_productivity_3.dta
									Cambodia_CAS_2022_livestock.dta
*POULTRY							Cambodia_CAS_2022_hhid_poultry_type.dta
									Cambodia_CAS_2022_poultry_type_growth.dta
									Cambodia_CAS_2022_poultry_type_vaccination.dta
									Cambodia_CAS_2022_poultry_explicit_costs.dta
									Cambodia_CAS_2022_poultry_type_egg_productivity.dta
									Cambodia_CAS_2022_hhid_poultry_egg_productivity.dta
									Cambodia_CAS_2022_poultry_productivity_1.dta
									Cambodia_CAS_2022_poultry_productivity_2.dta
									Cambodia_CAS_2022_poultry_productivity_3.dta
									Cambodia_CAS_2022_poultry.dta


*SECTION							MAIN FINAL FILES CREATED
*-------------------------------------------------------------------------------------
*COMBINING POULTRY AND LIVESTOCK	Cambodia_CAS_2022_household_variables.dta
									Cambodia_CAS_2022_poultry_livestock.dta
									Cambodia_CAS_2022_household_variables.csv
									Cambodia_CAS_2022_poultry_livestock.csv
									Cambodia_CAS_2022_poultry.csv
									Cambodia_CAS_2022_livestock.csv
									Cambodia_CAS_2022_crops.csv
									Cambodia_CAS_2022_hh_vars.csv
									Cambodia_CAS_2022_weights.csv
*/

clear
clear matrix
clear mata
program drop _all
set more off
set maxvar 10000


*Set directory globals
global directory "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\440 - 50 x 2030 Senegal and Cambodia/Cambodia"

* where sub-directories are organized by survey year and contain the following folders:
* raw_data: contains downloaded files from https://nada.nis.gov.kh/index.php/catalog/38
* temp: contains intermediate files that were created by this code
* final_data: contains final files
* ShinyData: contains files that are necessary to run the Cambodia Agriculture Survey Policy & Data Explorer

global Cambodia_CAS_2022_raw_data "$directory\CAS2022\raw_data"
global Cambodia_CAS_2022_created_data "$directory\CAS2022\temp"
global Cambodia_CAS_2022_final_data "$directory\CAS2022\final_data"
global Cambodia_CAS_save_folder "$directory/CAS2022/ShinyData"


******************************************************************************** 
*EXCHANGE RATE AND INFLATION FOR CONVERSION IN USD*
********************************************************************************
* This section assigns values to key monetary indicators that may be relevant for future analyses.

global CAS_2022_exchange_rate 4050.58 // 2017 Official exchange rate (LCU per US$, period average) - Cambodia - https://data.worldbank.org/indicator/PA.NUS.FCRF?end=2017&locations=KH&start=2017
global CAS_2022_gdp_ppp_dollar 1428.35 // 2017 PPP conversion factor, GDP (LCU per international $) - Cambodia - https://data.worldbank.org/indicator/PA.NUS.PPP?end=2017&locations=KH&start=2017
global CAS_2022_cons_ppp_dollar  1488.8 // 2017 PPP conversion factor, private consumption (LCU per international $) - Cambodia - https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2017&locations=KH&start=2017
global CAS_2022_inflation 1.1067416 // 137.9/124.6=1.1067416 where 2021 (last year of survey reference period) Consumer price index (2010=100) - Cambodia is divided by 2017 (poverty line baseline year) Consumer price index (2010-100) - Cambodia - https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2021&locations=KH&start=2017 
global CAS_2022_poverty_threshold (1.90*1493.25*137.9/105.5) //see calcuation below
//WB's previous (PPP) poverty threshold is $1.90
//Multiplied by 1493.25 - 2011 PPP conversion factor, private consumption (LCU per international $) - Cambodia - https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2011&locations=KH&start=2011
//Multiplied by 137.9 - 2021 Consumer price index (2010=100) - Cambodia - https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2021&locations=KH&start=2017
//Divided by 105.5 - 2011 Consumer price index (2010 = 100) - Cambodia -  https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2011&locations=KH&start=2011
*Calculation for WB' previous $1.90 (PPP) poverty threshold, 3600.9264 Cambodian Riel KHR. This is calculated as the following: PovertyLine x PPP conversion factor (private consumption)t=2011 (reference year of PL, therefore 2011. This is fixed across waves so no need to change it) x Inflation(from t=2011 to t+1=last year of survey reference period). Inflation is calculated as the following: CPI Cambodia inflation from 2011 (baseline year) to 2020 (last year of survey reference period) Inflation = Inflation (t=last year of survey reference period =2020)/Inflation (t= baseline year of PL =2011)

global CAS_2022_poverty_215 2.15*($CAS_2022_inflation) * $CAS_2022_cons_ppp_dollar
*The $2.15 Poverty line ($US) is converted to Cambodian Riel KHR using the PPP Conversion Factor, Consumption of 2017 (so we get the value in KHR 2017) and then we deflate this value to the last year of the survey reference period 2020. The 2.15 PL is 3439.8328 Cambodian Riel KHR (2017) Notes: This time we had to inflate since our cpp was in 2017 but the last year of the survey was 2020, for the 2011 1.90 poverty line we had to inflate given that the baseline year was 2011 but the last year of the survey was 2020. 
*The national poverty line is merged later since it's already provided by the raw data (Also there npl has variation across regions so it's not a single number)


******************************************************************************** 
*THRESHOLDS FOR WINSORIZATION*
********************************************************************************
global wins_lower_thres 1    						//Threshold for winzorization at the bottom of the distribution of continous variables
global wins_upper_thres 99							//Threshold for winzorization at the top of the distribution of continous variables


******************************************************************************** 
*RE-SCALING SURVEY WEIGHTS TO MATCH POPULATION ESTIMATES
********************************************************************************
*https://databank.worldbank.org/source/world-development-indicators#
global CAS_2022_pop_tot 16589023  // (2021)
global CAS_2022_pop_rur 12496843 //  (2021)  https://data.worldbank.org/indicator/SP.RUR.TOTL?locations=KH
global CAS_2022_pop_urb 4092180 //   (2021)  https://data.worldbank.org/indicator/SP.URB.TOTL?locations=KH


********************************************************************************
*GLOBALS OF PRIORITY CROPS*
********************************************************************************
* This section is currently unfinished. In future updates, the user/developer may identify "priority crops"
* through analysis of survey data or reviewing policy priorities. In future versions, the "priority crops"
* global would limit the scope of certain analyses to select agricultural activities.

global topcropname "rice cashew"
global topcrop "100 861"
global nb_topcrops : list sizeof global(topcropname)

/*
global topcropname_area "napady apaddy cassav lemgrss limel banana mango jackfr cashew cocont cultfr vegtre" //Non aromatic paddy, aromatic paddy, lemon grass, lime lemon , banana, mango, jackfruit, cashew, coconut, cultivated fruit, ()vegetables tree flowers)
global topcrop_area "101 102 203 426 804 811 816 820 861 911 1003 1005"
global comma_topcrop_area "101, 102, 203, 426, 804, 811, 816, 820, 861, 911, 1003, 1005"
global topcropname_area_full "nonarompaddy arompaddy cassava lemongrass limelemon banana mango jackfruit cashew coconut cultivatedfruit cotton vegtreeflower"
global nb_topcrops : list sizeof global(topcropname_area) // Gets the current length of the global macro list "topcropname_area"

set obs $nb_topcrops //Update if number of crops changes
egen rnum = seq(), f(1) t($nb_topcrops)
gen crop_code = .
gen crop_name = ""
forvalues k = 1 (1) $nb_topcrops {
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area 
	replace crop_code = `c' if rnum == `k'
	replace crop_name = "`cn'" if rnum == `k'
}
drop rnum
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_cropname_table.dta", replace 
*/ 


********************************************************************************
*HOUSEHOLD IDS*
********************************************************************************
* This section produces a temporary file that may be used for analysis later in this .do file

use "${Cambodia_CAS_2022_raw_data}\CAS2022_FINAL.dta", clear
rename holding_id hhid
rename PROVINCE_ID province
rename Weight weight
//No additional geographic information.
keep hhid province weight
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", replace 


********************************************************************************
*WEIGHTS*
********************************************************************************
* This section produces a temporary file that may be used for analysis later in this .do file

use "${Cambodia_CAS_2022_raw_data}\CAS2022_FINAL.dta", clear
rename holding_id hhid
rename Weight weight 
keep hhid weight 
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_weights.dta", replace 


********************************************************************************
*INDIVIDUAL IDS*
********************************************************************************
* This section produces a temporary file that may be used for analysis later in this .do file

use "${Cambodia_CAS_2022_raw_data}\S14_HHROSTER.dta", clear
rename holding_id hhid
gen female=GENDER==2
lab var female "1= indivdual is female"
ren PROVINCE_ID province
decode AGE, g(age_str)
encode age_str, g(age) //Matching the value labels with the older data.
lab var age "Individual age"
ren HOLDER hh_head // relationship to hh head
lab var hh_head "1= individual is household head"
preserve
keep hhid province female age hh_head
save "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_person_ids.dta", replace
restore 
gen hh_members=1
gen fhh = (hh_head==1) & female==1
collapse (sum) hh_members (max) fhh, by(hhid province)
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhsize.dta", replace 


********************************************************************************
* CHECK WEIGHTS FOR ACCURACY *
********************************************************************************
use "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhsize.dta", clear
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_weights.dta", nogen keep(1 3)
tabstat hh_members [aw=weight], stat(sum) c(s) varwidth(30)
gen wt_hh_size = hh_members * weight
collapse (sum) wt_hh_size, by(province)
ren wt_hh_size province_pop_2022


********************************************************************************
* HEAD OF HOUSEHOLD *
********************************************************************************


********************************************************************************
* GPS COORDINATES *
********************************************************************************


********************************************************************************
* PARCEL/HOMELOT AREA *
********************************************************************************
//Categories from EPAR's LSMS coding:
/*
    farm_area: Sum of all cultivated plots/parcels/gardens
    farmsize_all_agland: Sum of all cultivated plots as well as those left fallow or used for pasture, but not areas occupied by homestead, or rented out
    land_size_total: All land owned or used, including rented in and rented out parcels, if measurements are available for the latter.
	
	Counting household as part of farm area if respondent reports cultivating livestock or aquaculture under the house. 
*/

//Parcel areas
//71 obs > 100, max 19000
use "${Cambodia_CAS_2022_raw_data}/S4_LANDUSE_PARCEL.dta", clear
ren S4_Q06_ha area 
ren S4_LANDUSE_PARCEL__id use_code
ren holding_id hhid 
ren Weight weight 
ren PROVINCE_ID province 
gen homelot=0
gen animal_area= area*inlist(use_code, 3,5,12)
gen farmsize_all_agland = area * inlist(use_code, 1, 2, 3,4,5,6,8,12)
gen farm_area = area * inlist(use_code, 1,4)
collapse (sum) animal_area farm_area farmsize_all_agland land_size_total=area, by(hhid province homelot)
tempfile luse_parcel
save `luse_parcel'

use "${Cambodia_CAS_2022_raw_data}\LANDUSE2.dta", clear
//8 obs > 1 ha, max 1.48
gen homelot=1
ren holding_id hhid
ren PROVINCE_ID province
ren Weight weight 
ren LANDUSE2__id use_code 
ren S4_Q23_ha area
gen animal_area=area*inlist(use_code, 3,5, 6)
gen farmsize_all_agland=area * inlist(use_code, 1,2,3,4,5,6,7,9,13)
gen farm_area = area * inlist(use_code, 1,4)
collapse (sum) farm_area farmsize_all_agland land_size_total=area, by(hhid province homelot)
append using `luse_parcel'
save "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmsize_agland_homelot_parcel.dta", replace 
collapse (sum) animal_area farm_area farmsize_all_agland land_size_total, by(hhid province)
gen animal_ded_area = animal_area!=0
gen ag_hh = farmsize_all_agland!=0 //98% of households
save "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmsize_agland.dta", replace

//backwards compatibility with 21
use "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmsize_agland_homelot_parcel.dta", clear
gen ag_hh_homelot = farmsize_all_agland != 0 & homelot==1
gen ag_hh_parcel  = farmsize_all_agland != 0 & homelot==0
gen ag_area_parcel = farmsize_all_agland * homelot==0
gen ag_area_homelot = farmsize_all_agland * homelot==1
collapse (max) ag_hh_homelot ag_hh_parcel (sum) ag_area_parcel ag_area_homelot ag_area = farmsize_all_agland, by(hhid province)
gen ag_hh = max(ag_hh_homelot, ag_hh_parcel)
recode ag_hh_homelot ag_hh_parcel ag_area_homelot ag_area_parcel (.=0)
la var ag_hh_parcel "Holding is involved in agricultural activities on parcel(s)"
la var ag_hh_homelot "Holding is involved in agricultural activities on homelot"
la var ag_hh "Holding is involved in agricultural activities"
la var ag_area_parcel "Area (ha) on parcel(s) where holding is involved in agricultural activities"
la var ag_area_homelot "Area (ha) on homelot where holding is involved in agricultural activities"
la var ag_area "Area (ha) where holding is involved in agricultural activities"

merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_weights.dta", nogen keepusing(weight) keep(1 3)
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_agriculture_activities.dta", replace


********************************************************************************
** USE OF IMPROVED SEED **
********************************************************************************
* This section is currently unfinished. In future updates, the user/developer may identify 
* households that grow improved and/or hybridized crop varieties.

/*use "${Cambodia_CAS_2022_raw_data}\S5_CROPSEED.dta", clear
rename holding_id hhid
rename s5_cropseed__id seed_code
gen imprv_seed_use = 1 if s5_q02__1 == 1 | s5_q02__2 == 1 // certified modern varieties or uncertified modern varieties
gen crop_variety = s5_q01

*Use of seed by type of crop
// commenting out the code below - no all plots section, so it's unclear whether $topcrops align with greatest area planted
/*
forvalues k=1/$nb_topcrops {
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	
	gen imprv_seed_`cn'=imprv_seed_use if crop_code==`c'
	gen crop_variety_`cn'=crop_variety if crop_code==`c'
	gen hybrid_seed_`cn'=.
}
collapse (max) imprv_seed_*  crop_variety* /*hybrid_seed_**/, by(hhid)
lab var imprv_seed_use "1 = Household uses improved seed"
lab var crop_variety "1 = Household uses more than one crop variety"

foreach v in $topcropname_area {
	lab var imprv_seed_`v' "1= Household uses improved `v' seed"
	lab var crop_variety_`v' "1= Household uses more than one `v' variety"
	
	*lab var hybrid_seed_`v' "1= Household uses improved `v' seed"
}
*/

save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_improvedseed_use.dta", replace
//Note: For Cashew Crops there's no information available regarding use of certified modern varieties. Also, not sure whether improved seed is the same es certified modern varities.

*Seed adoption by farmers ( a farmer is an individual listed as Holding Crop Decision-maker)
use "${Cambodia_CAS_2020_raw_data}\S3_CROP.dta", clear
rename Holding_ID hhid
rename S3_CROP__id cropID 
gen imprv_seed_use = S3_Q07/100 if S3_Q07!=-99
gen crop_variety = 1 if S3_Q06==2
replace crop_variety = 0 if S3_Q06==1
merge m:m hhid using "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_ids.dta", nogen keep(1 3)
ren imprv_seed_use all_imprv_seed_use
ren crop_variety all_crop_variety_use
save "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_improvedseed_use_temp.dta", replace

use "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_improvedseed_use_temp.dta", replace
*Use of seed by crops
forvalues k=1/$nb_topcrops {
use "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_improvedseed_use_temp.dta", replace
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	*Adding adoption of improved maize seeds
	gen all_imprv_seed_`cn'=all_imprv_seed_use if cropID==`c'  
	gen all_crop_variety_`cn'=all_crop_variety_use if cropID==`c'
	*gen all_hybrid_seed_`cn' =. 
	*We also need a variable that indicates if farmer (plot manager) grows crop
	gen `cn'_farmer= cropID==`c' 
	gen double PID = individ
	collapse (max) all_imprv_seed_use  all_imprv_seed_`cn' all_crop_variety_use all_crop_variety_`cn'   /*all_hybrid_seed_`cn'*/  `cn'_farmer, by (hhid individ)
	save "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_improvedseed_use_temp_`cn'.dta", replace

}
//Notes: This is a rough attempt to construct a similar version of Farmer by types of Crops use in Uganda LSMS-ISA. In UGA-w3, there's information on Farmer's decision-makers at the plot level, while CAS 2020 only reports decision-makers at the Holding level. Therefore, we are assuming that a decision-maker at the holding level has decision-making over all crops. Might want to discuss a better way than a m:m merge above. 

*Combining all crop disaggregated files together
foreach v in $topcropname_area {
	merge 1:1 hhid individ all_imprv_seed_use using "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_improvedseed_use_temp_`v'.dta", nogen

	}	 
drop if hhid==""
drop if individ==.
merge 1:1 hhid individ using "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_ids.dta", nogen keep(1 3)
lab var all_imprv_seed_use "1 = Individual farmer (plot manager) uses improved seeds"
lab var all_crop_variety_use "1 = Individual farmer (plot manager) uses variety of crops"

foreach v in $topcropname_area {
	lab var all_imprv_seed_`v' "1 = Individual farmer (plot manager) uses improved seeds - `v'"
	*lab var all_hybrid_seed_`v' "1 = Individual farmer (plot manager) uses hybrid seeds - `v'"
	lab var all_crop_variety_`v' "1 = Individual farmer (plot manager) uses variety of crops - `v'"
	lab var `v'_farmer "1 = Individual farmer (plot manager) grows `v'"
}

gen farm_manager=1 if individ!=.
recode farm_manager (.=0)
lab var farm_manager "1=Indvidual is listed as a manager for at least one plot" // 
*Replacing permanent crop seed information with missing because this section does not ask about permanent crops
save "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmer_improvedseed_use.dta", replace
*/

/* Not in CAS '22
********************************************************************************
* COVID Impact *
********************************************************************************
use "${Cambodia_CAS_2022_raw_data}\S8_COVID.dta", clear
ren holding_id hhid
gen covid_shock = 1
collapse (max) covid_shock, by(hhid)
la var covid_shock "Household experienced a shock due to the COVID-19 pandemic"
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_COVID_impact.dta", replace
*/

********************************************************************************
* Association Membership *
********************************************************************************
use "${Cambodia_CAS_2022_raw_data}\CAS2022_FINAL.dta", clear
ren holding_id hhid
gen ag_comm = 1 if S10_Q26 == 1
//gen ag_assoc = 1 if s8_q15 == 1
//gen ag_comm_assoc = 1 = ag_comm == 1 | ag_assoc == 1 // formal and informal agricultural/farmer's association or community
gen ag_comm_assoc = . //No formal association question?
recode ag_* (.=0)
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_association_membership.dta", replace


********************************************************************************
* Agricultural Households *
********************************************************************************
* This section defines an "agricultural household" as one that utilizes land for agricultural purposes



********************************************************************************
* HOUSEHOLD DECISION MAKERS *
********************************************************************************
* This section summarizes information concerning gender and age of household decision makers

use "${Cambodia_CAS_2022_raw_data}\S14_HHROSTER.dta", clear
rename holding_id hhid 
rename S14_HHROSTER__id indiv 
gen female=GENDER==2
lab var female "1= indivdual is female"
tostring AGE, g(age_str)
encode age_str, g(age)
lab var age "Individual age"
gen hh_head=HOLDER==1
lab var hh_head "1= individual is household head"
gen fhh = (hh_head==1) & female==1
gen dm_female=. //Missing in 2022?
gen dm_male=.
//gen dm_female = 1 if s9_q11==1 & female==1
//gen dm_male = 1 if s9_q11==1 & female==0
tostring S14_Q06, g(edu_str)
encode edu_str, gen(edu_hh)
recode edu_hh (1=0) (2=.) (3=1) (4=2) (5=3) // recode 2=missing because the survey asks for Other (Specify) but the raw data file does not report that variable
gen edu_hh_head = edu_hh if hh_head == 1
collapse (max) dm_female dm_male fhh edu_hh edu_hh_head, by(hhid)
/*
recode dm_female dm_male (.=0)
gen dm_mixed = (dm_female==1 & dm_male==1)
recode dm_female dm_male (1=0) if dm_mixed==1
gen dm_gender=1 if dm_female==1
replace dm_gender=2 if dm_male==1
replace dm_gender=3 if dm_mixed==1
*/
gen dm_mixed=.
gen dm_gender=.
*replacing observations without gender of plot manager with gender of HOH
replace dm_gender=1 if fhh==0 & dm_gender==. 
replace dm_gender=2 if fhh==1 & dm_gender==.
la var edu_hh_head "Highest level of education achieved by the household head"
la var edu_hh "Highest level of education achieved by anyone in the household"
la define edu 0 "No education" 1 "Primary" 2 "Secondary" 3 "Tertiary"
la values edu_hh_head edu 
la values edu_hh edu
drop if hhid == ""
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hh_decision_makers.dta", replace 
*Note: We are only able to construct Holding decision-makers - Information is not available at the plot or parcel level. 


********************************************************************************
*FORMALIZED LAND RIGHTS*
********************************************************************************


********************************************************************************
*LIVESTOCK*
********************************************************************************
use "${Cambodia_CAS_2022_raw_data}\S7A_LIVESTOCK", clear
ren holding_id hhid
ren S7A_LIVESTOCK__id livestock_id
ren PROVINCE_ID province
	
	
	*******************************
	*     LIVESTOCK HERD SIZE     *
	*******************************
	
	ren S7A_Q08 num_ado_male
	ren S7A_Q09 num_ado_fem
	ren S7A_Q10 num_adult_male
	ren S7A_Q11 num_adult_fem
	gen num_livestock = num_ado_male + num_ado_fem + num_adult_male + num_adult_fem // as of July 1, 2021
	
	/*
	assert num_livestock==S7A_Q07 //290 contradictions, range -8 to +18
	gen num_livestock = S7A_Q07
	*/
	drop if num_livestock == . // 8 obs for which all relevant livestock data is missing
	//Note: unclear meaning of livestockage. Variable not explicitly referenced on questionnaire. Variable label suggests age threshold between young and adult.
	//LIVESTOCKAGE contains two possible values, 1 and 2. Questionnaire defines 'young' as less than 2 years old. It is unclear if these values represent
	//unlabeled categorical data or represent numeric data, i.e. years=1 or years=2
	//Note: lack of clarity regarding LIVESTOCKAGE does not impair existing code
	
	* Checking variables for outliers
	//Visual inspection of num_livestock indicates the presence of significant outliers
	/*
	preserve
	su num_livestock, detail
	drop if num_livestock == 0
	codebook num_livestock
	inspect num_livestock
	hist num_livestock, frequency
	br hhid livestock_id num_livestock if num_livestock <= 25
	restore
	
	//Although visual inspection reveals large skew and presence of outlier values,
	//other relevant variables suggest that outlier values represent real events and therefore should be included
	*/
	
	
	********************************
	*TYPE OF LIVESTOCK RAISED BY HH*
	********************************
	preserve
	collapse (sum) livestock_id num_ado_male num_ado_fem num_adult_male num_adult_fem num_livestock, by(hhid)
	ren livestock_id livestock_raised
	label define raised 101 "cattle only" 102 "buffalo only" 104 "pigs only" 203 "cattle and buffalo" 205 "cattle and pigs" 206 "buffalo and pigs" 307 "cattle, buffalo, and pigs"
	label values livestock_raised raised
	ren num_ado_male num_ado_male_raised
	ren num_ado_fem num_ado_fem_raised
	ren num_adult_male num_adult_male_raised
	ren num_adult_fem num_adult_fem_raised
	ren num_livestock num_livestock_raised
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhid_livestock_type.dta", replace
	restore
	
	
	********************************
	*      LIVESTOCK OWNERSHIP     *
	********************************
	ren S7A_Q14 own_all_livestock
	ren S7A_Q16 own_livestock_off_holding
	recode own_all_livestock own_livestock_off_holding (2=0)
	label define binary_recode 0 "No" 1 "Yes"
	label values own_all_livestock own_livestock_off_holding binary_recode

	
	********************************
	*      LIVESTOCK PURCHASE      *
	********************************
	ren S7A_Q19 livestock_bought
	ren S7A_Q20 livestock_purchase_price
	gen livestock_purchase_spending = livestock_bought * livestock_purchase_price
	
	
	********************************
	*      LIVESTOCK BREEDING      *
	********************************
	ren S7A_Q38 livestock_breeding
	//ren S7A_Q22 livestock_breeding_cost
	//gen livestock_breeding_cost = .
	recode livestock_breeding /*livestock_breeding_cost*/ (2=0)
	label values livestock_breeding /*livestock_breeding_cost*/ binary_recode
	//ren S7A_Q23 livestock_breed_spending
	gen livestock_breed_spending=.

	
	********************************
	*       FEEDING PRACTICES      *
	********************************
	/*
	//Moved to CAS2022_FINAL.dta
	use "${Cambodia_CAS_2022_raw_data}\CAS2022_FINAL.dta", clear
	ren S7A_Q62 livestock_feed
	gen provision_feed = livestock_feed >= 2
	label define feed 0 "No feed" 1 "Feed"
	label values provision_feed feed
	*/
	
	
	/*
	**********************************
	*FEEDING PRACTICES VS. IRRIGATION*
	**********************************
	* This section allows the user/developer to visualize household behavior regarding
	* irrigation and animal feeding. It is not relevant for later analysis
	
	* irrigation vs. feeding practice (3-way)
	preserve
	recode livestock_feed (1=101) (2=102) (3=104)
	collapse (sum) livestock_id livestock_feed, by(hhid)
	recode livestock_feed  (202 = 101) (303 = 101) // only grazing
	recode livestock_feed  (208 = 104) (312 = 104) // only feed
	recode livestock_feed (203 204 205 206 304 305 306 307 308 309 310 = 102)
	label define feed_type 101 "only grazing" 102 "mix of grazing and feed" 104 "only feed"
	label values livestock_feed feed_type
	la var livestock_feed "Type of feed"
	ren livestock_id livestock_raised
	label define raised 101 "cattle only" 102 "buffalo only" 104 "pigs only" 203 "cattle and buffalo" 205 "cattle and pigs" 206 "buffalo and pigs" 307 "cattle, buffalo, and pigs"
	label values livestock_raised raised
	tab livestock_feed
	tempfile feeding_livestock
	save `feeding_livestock'
	restore
	
	preserve
	use "${Cambodia_CAS_2022_raw_data}\S4_CROP.dta", clear
	ren holding_id hhid
	ren s4_q05 irrigation
	recode irrigation (1=0) (2=1)
	label define binary3 0 "No" 1 "Yes"
	la var irrigation "Was this crop irrigated during 1 July 2020 through 30 June 2021?" //correction: aligning .dta file var label with questionnaire
	collapse (sum) irrigation, by(hhid)
	replace irrigation = 1 if irrigation >= 1
	label values irrigation binary3
	tempfile irrigation
	save `irrigation'

	use `feeding_livestock', clear
	merge m:1 hhid using `irrigation', keep (1 3) nogen
	la var irrigation "irrigation"
	la var livestock_feed "Livestock feed"
	tab livestock_feed irrigation
	restore
	
	* irrigation vs. feeding practice (2-way)
	preserve
	collapse (sum) livestock_id provision_feed, by(hhid)
	replace provision_feed = 1 if provision_feed > 1
	label define feed1 0 "No feed" 1 "Feed"
	label values provision_feed feed1
	ren livestock_id livestock_raised
	label define raised1 101 "cattle only" 102 "buffalo only" 104 "pigs only" 203 "cattle and buffalo" 205 "cattle and pigs" 206 "buffalo and pigs" 307 "cattle, buffalo, and pigs"
	label values livestock_raised raised1
	merge m:1 hhid using `irrigation', keep (1 3) nogen
	la var irrigation "irrigation"
	la var provision_feed "Livestock feed"
	tab provision_feed irrigation
	restore
	*/
	
	********************************
	*            CONTRACT          *
	********************************
	/*
	ren S7A_Q06 form_contract
	ren S7A_Q07 contract_coverage
	recode form_contract contract_coverage (2=0)
	label values form_contract contract_coverage binary_recode
	tab form_contract // 128 observations (1.87%) where hhid has at least one formal production or marketing contract.
	tab contract_coverage
	*/
	
	********************************
	*      LIVESTOCK PURPOSE       *
	********************************
	//Note: survey contains only information regarding livestock purpose:
	//1) "main purpose" of each observation (livestock_id/hh); and
	//2) number of units "used" (e.g., sold, slaughtered, etc.) for that purpose.
	//This data coverage likely underrepresents uses that are secondary or tertiary to the main purpose. E.g., hhs that maintain cattle primarily for meat
	//or sale but also produce milk among a minority of cattle; milk production in these hhs would not be recognized in the following variables
	/* Not in questionnaire?
	ren S7A_Q08 livestock_main_purpose
	gen for_sale_live = S7A_Q14f > 0
	recode for_sale_live 0 = 1 if livestock_main_purpose == 1 // capture hhs that raised livestock for sale (as main purpose) but did not make a sale within the survey timeframe
	gen for_gift = S7A_Q14i > 0
	gen for_meat = S7A_Q14j > 0
	gen for_hh_consum = livestock_main_purpose == 3
	gen for_product = livestock_main_purpose == 2
	gen for_savings = livestock_main_purpose == 4
	gen for_agriculture = livestock_main_purpose == 6 
	gen for_transport = livestock_main_purpose == 7
	gen for_breeding = livestock_main_purpose == 8
	recode for_* (.=0)
	label values for_sale_live for_gift for_meat for_agriculture for_hh_consum for_product for_savings for_transport for_breeding binary_recode
*/
	
	********************************
	*     LIVESTOCK HEADCOUNT      *
	********************************
	* num_ variables refer to herd size as of 1st July 2021
	
	gen num_cattle = num_livestock if livestock_id == 101
	recode num_cattle . = 0
	gen num_buffalo = num_livestock if livestock_id == 102
	recode num_buffalo . = 0
	gen num_pigs = num_livestock if livestock_id == 104
	recode num_pigs . = 0

	
	************************************
	*2020-21 LIVESTOCK HEADCOUNT GROWTH*
	************************************
	* all survey questions describing growth (loss) of livestock refer to timeframe Jul 1, 2020 - Jun 30, 2021
	
	ren S7A_Q18 livestock_births
	gen livestock_received = . //Not in questionnaire
	ren S7A_Q22 livestock_deaths
	ren S7A_Q22f livestock_sold
	gen livestock_slghtr = . //Missing?
	//ren S7A_Q14j livestock_slghtr
	//ren S7A_Q14i livestock_gift
	//ren S7A_Q14h livestock_stolen
	gen livestock_gift  = . //Missing
	gen livestock_stolen= . //Missing
	egen livestock_bought_received = rowtotal(livestock_bought livestock_received)
	egen livestock_growth = rowtotal(livestock_births livestock_bought livestock_received)
	egen livestock_loss = rowtotal(livestock_deaths livestock_sold livestock_slghtr livestock_gift livestock_stolen)
	recode livestock_growth livestock_loss (.=0)
	gen net_livestock_growth = livestock_growth - livestock_loss
	gen num_livestock_start = num_livestock - net_livestock_growth // num_livestock refers to Jul 1, 2021 headcount
	replace num_livestock_start = 1 if num_livestock_start <= 0 // where starting headcount = 0, +1 to maintain integrity of following variables
	//Note: 72 obs of num_livestock_start are < 0, implying some data entry error or incomplete coverage of headcount growth/loss variables in survey.
	//Alternative strategy for dealing with these observations (as opposed to 'replace' above) is dropping observations entirely

	gen livestock_growth_pct = livestock_growth / num_livestock_start
	gen livestock_loss_pct = livestock_loss / num_livestock_start
	gen net_livestock_growth_pct = net_livestock_growth / num_livestock_start
	gen peak_num_livestock = num_livestock_start + livestock_growth
	gen livestock_mortality_rt = livestock_deaths / peak_num_livestock
	gen livestock_sale_rate = livestock_sold / peak_num_livestock

	preserve
	collapse (sum) livestock_id num_livestock net_livestock_growth num_livestock_start livestock_growth livestock_deaths peak_num_livestock, by(hhid)
	ren livestock_id livestock_raised
	ren num_livestock num_livestock_2022
	label define raised2 101 "cattle only" 102 "buffalo only" 104 "pigs only" 203 "cattle and buffalo" 205 "cattle and pigs" 206 "buffalo and pigs" 307 "cattle, buffalo, and pigs"
	label values livestock_raised raised2
	gen net_livestock_growth_pct = net_livestock_growth / num_livestock_start
	gen livestock_mortality_rt = livestock_deaths / peak_num_livestock
	keep hhid livestock_raised num_livestock_2022 net_livestock_growth net_livestock_growth_pct livestock_mortality_rt peak_num_livestock
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_type_growth.dta", replace
	restore

	
	********************************
	*    LIVESTOCK VACCINATION     *
	********************************
	//ren S7A_Q25 num_vax
	//recode num_vax .=0 // CAS2022 encodes '.' for observations of 0 vaccinations; updating to CAS2020 format, which records no reported vaccinations as 0, not missing
	//gen vax_pct = num_vax / num_livestock
	//replace vax_pct = num_vax / num_livestock_start if num_livestock_start >= num_livestock // where net decline in livestock population would otherwise render a misleading datapoint for vaccination rate
	//replace vax_pct = num_vax / peak_num_livestock if peak_num_livestock >= num_livestock // same intent as above, approximate maximum absolute population of livestock over survey period to address edge-case where num_livestock not representative of livestock headcount
	//replace vax_pct = 1 if vax_pct >= 1 & vax_pct != . // corrects 17 obs where survey estimation procedure created vax_pct > 1.0
	ren S7A_Q41 livestock_vax
	recode livestock_vax (2=0)
	label values livestock_vax binary_recode
	gen num_vax = .
	gen vax_pct = .

	preserve
	collapse (sum) livestock_id num_vax num_livestock, by(hhid)
	ren num_livestock num_livestock_raised
	ren livestock_id livestock_type_raised
	label define raised 101 "cattle only" 102 "buffalo only" 104 "pigs only" 203 "cattle and buffalo" 205 "cattle and pigs" 206 "buffalo and pigs" 307 "cattle, buffalo, and pigs"
	label values livestock_type_raised raised
	gen livestock_vax_pct = num_vax / num_livestock_raised
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_type_vaccination.dta", replace
	restore

	
	********************************
	*    LIVESTOCK TREATMENTS      *
	********************************
	ren S7A_Q43__6 livestock_trt_parasite
	//ren S7A_Q27 livestock_trt_ext_parasite
	//ren S7A_Q28 livestock_trt_vax_spending
	//ren S7A_Q29 livestock_cur_trt
	//ren S7A_Q30 livestock_cur_trt_spending
	gen livestock_trt_int_parasite=.
	gen livestock_trt_ext_parasite=.
	gen livestock_trt_vax_spending =.
	gen livestock_cur_trt = .
	gen livestock_cur_trt_spending = .
	recode livestock_trt_int_parasite livestock_trt_ext_parasite livestock_cur_trt (2=0)
	label values livestock_trt_int_parasite livestock_trt_ext_parasite livestock_cur_trt binary_recode
	
	
	********************************
	*     LIVESTOCK LIVE SALES     *
	********************************
	* price of live sale
	ren S7A_Q22g livestock_sale_price // (riel/head)

	
	*There are significant outliers in livestock_sale_price that must be addressed
	/*
	su livestock_sale_price, detail // max value is 7,828,000; 4,722 missing obs
	inspect livestock_sale_price
	hist livestock_sale_price, frequency
	*/
	
	
	* construct Median Absolute Deviation (MAD) statistics around livestock_sale_price for each type of livestock
	preserve
	recode livestock_sale_price . = 0
	drop if livestock_sale_price == 0
	egen med_livestock_price = median(livestock_sale_price), by(livestock_id)
	egen MAD_livestock_price = median(abs(livestock_sale_price - med_livestock_price)), by(livestock_id)
	collapse (mean) med_livestock_price MAD_livestock_price, by(livestock_id)
	tempfile MAD_livestock_prices
	save `MAD_livestock_prices'
	restore

	
	* exclude outliers using MAD statistics
	merge m:1 livestock_id using `MAD_livestock_prices', nogen
	recode livestock_sale_price . = 0 // 100% of missing values for livestock_sale_price are associated with livestock_sold == 0 and vice versa; i.e livestock_sale_price == 0 and == . are equivalent
	replace livestock_sale_price = . if livestock_sale_price >= med_livestock_price + (3 * MAD_livestock_price) // 98 observations changed (1.4% of total)
	recode livestock_sale_price 0 = .

	
	* outlier exclusion was successful
	/*
	su livestock_sale_price, detail // max value in livestock_sale_price is 5,350,000
	br if livestock_sale_price <= 5350000 // excludes missing values ('.')
	keep hhid livestock_id num_livestock livestock_sold livestock_sale_price
	sort livestock_id livestock_sale_price, stable
	br if livestock_sale_price == .
	inspect livestock_sale_price // 4722 missing observations
	*/
	//All missing livestock_sale_price values are associated with 0 live sales,
	//therefore we derive no value re: live sale indicators by constructing a provincial or national median price for each livestock_id
	//However, we later assume that the livestock_sale_price value is equivalent to the sale price/value of meat production;
	//to avoid missing observations of livestock_slghtr_value where livestock_sold == 0,
	//we will construct an assumption for missing livestock_sale_price observations

	
	* generate livestock_sale_price provincial medians
	preserve
	merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", nogen
	recode livestock_sale_price . = 0
	drop if livestock_sale_price == 0
	collapse (median) livestock_sale_price, by(livestock_id province)
	ren livestock_sale_price livestock_price_prov_med
	decode livestock_id, gen(tempvar1)
	decode province, gen(tempvar2)
	gen livestock_province = tempvar1 + "_" + tempvar2
	drop tempvar1 tempvar2 livestock_id province
	tempfile livestock_province_price
	save `livestock_province_price'
	restore

	
	* generate livestock_sale_price national medians
	preserve
	recode livestock_sale_price . = 0
	drop if livestock_sale_price == 0
	collapse (median) livestock_sale_price, by(livestock_id)
	ren livestock_sale_price livestock_price_natl_med
	tempfile livestock_med_price
	save `livestock_med_price'
	restore

	
	* merge-in provincial median livestock_sale_price for missing values
	merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", nogen
	decode livestock_id, gen(tempvar1)
	decode province, gen(tempvar2)
	gen livestock_province = tempvar1 + "_" + tempvar2
	drop tempvar1 tempvar2
	merge m:1 livestock_province using `livestock_province_price', nogen
	drop if livestock_id == .
	gen livestock_sale_price_obs = livestock_sale_price // observed sale price
	gen livestock_sale_price_impt = livestock_price_prov_med if livestock_sale_price == . // imputed sale price
	replace livestock_sale_price = livestock_price_prov_med if livestock_sale_price == .  // combined (observed + imputed) sale price

	
	* merge-in national median livestock_sale_price for missing values
	merge m:1 livestock_id using `livestock_med_price', nogen
	replace livestock_sale_price = livestock_price_natl_med if livestock_sale_price == .
	replace livestock_sale_price_impt = livestock_price_natl_med if livestock_sale_price == .

	*livestock sold
	
	*Visual inspection of livestock_sold indicates the presence of significant outliers
	/*
	preserve
	drop if livestock_sold == 0
	su livestock_sold, detail
	codebook livestock_sold
	inspect livestock_sold
	hist livestock_sold, frequency
	restore
	*/
	//Although visual inspection reveals large skew and presence of outlier values,
	//other relevant variables suggest that outlier values represent real events and should be therefore included

	
	*construct indicator for revenue from live livestock sales
	gen livestock_sale_revenue = livestock_sale_price * livestock_sold // based on observed and imputed prices; same as observed only because all missing prices associated with 0 sales

	
	********************************
	*  LIVESTOCK MEAT PRODUCTION   *
	********************************
	/* //Not in questionnaire
	ren S7A_Q16 meat_sold
	recode meat_sold (2=0) (.=0)
	label values meat_sold binary_recode
	gen livestock_slghtr_unit_value = livestock_sale_price // not having a price (riel) for each slaughtered head of livestock, we assume equivalence to price (imputed or observed) of live sales
	gen livestock_slghtr_value = livestock_slghtr_unit_value * livestock_slghtr // includes slaughter for sale and slaughter for hh consumption (not fully disaggregated in source data)
	
	* stocking meat
	ren S7A_Q19 meat_stock
	recode meat_stock (2=0) (.=0) // note: decision to recode .=0 because hh having meat stocked is not predicated on slaughter; 0s indicate more accurate representation of hh behavior given livestock on holding
	label values meat_stock binary_recode
	ren S7A_Q20 meat_stock_purpose
*/
	
	********************************
	*  LIVESTOCK OTHER PRODUCTS    *
	********************************
	* note: animal products recorded on a household level, not hh/livestock
	/*
	preserve
	use "${Cambodia_CAS_2022_raw_data}\S6_OTHERPRODUCTS.dta", clear
	ren holding_id hhid
	ren s6_otherproducts__id product_id
	ren S7A_Q86 anim_prod_revenue
	ren S7A_Q83 anim_prod_qty
	ren S7A_Q83_unit unit
	replace anim_prod_qty = anim_prod_qty * 1.008 if unit == 2 // convert 2 obs from liters to kg (8.4 lb/gal or 1.008 kg/L) https://lpelc.org/common-manure-test-results-conversions/#:~:text=Liquid%20manure%20density%20can%20vary,and%20a%20set%20of%20scales.
	recode unit (2=1)
	ren S7A_Q84 anim_prod_sold
	ren S7A_Q85 anim_prod_qty_sold
	gen anim_prod_avg_price_impt = anim_prod_qty_sold / anim_prod_revenue
	gen anim_prod_val_impt = anim_prod_qty * anim_prod_avg_price
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_otherproducts.dta", replace
	restore
	*/
	
	********************************
	*   LIVESTOCK EXPLICIT COSTS   *
	********************************
	* Note: survey does not report cost of feed or other livestock-specific inputs
	/* //No expenses to report in 2022
	preserve
	keep hhid livestock_id province livestock_feed livestock_purchase_spending livestock_breed_spending livestock_cur_trt_spending livestock_trt_vax_spending
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_explicit_costs.dta", replace
	restore
	*/
	
	********************************
	*     TOTAL LIVESTOCK VALUE    *
	********************************
	* combine revenue and value variables
	
	recode livestock_sale_revenue /*livestock_slghtr_value*/ (.=0) // 7 obs
	// recoding because '.' brought in by missing prices, not '.' units sold;
	// all obs have some non-missing value for livestock_sold in the raw data,
	// so revenue/value should reflect 0, not missing
	//egen livestock_prod_value = rowtotal(livestock_sale_revenue livestock_slghtr_value) // not including livestock products (e.g. manure) which is measured on hh-lvl later
	gen livestock_prod_value = livestock_sale_revenue
	replace livestock_sale_revenue = . if livestock_sold == 0
	replace livestock_sale_price = . if livestock_sold == 0
	/*
	replace livestock_slghtr_value = . if livestock_slghtr == 0
	replace livestock_slghtr_unit_value = . if livestock_slghtr == 0
*/
	* save temp file, household-level
	preserve
	collapse (sum) livestock_sale_revenue /*livestock_slghtr_value*/ livestock_prod_value, by(hhid)
	//merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_otherproducts.dta", nogen keep(1 3) keepusing(anim_prod_val_impt)
	gen anim_prod_val_impt = .
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_productivity_1.dta", replace
	restore

	* save temp file, household-/livestock-level
	preserve
	collapse (sum) livestock_sale_revenue /*livestock_slghtr_value*/ livestock_prod_value, by(hhid livestock_id)
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_productivity_2.dta", replace
	restore

	* save temp file, household-/livestock type-level
	preserve
	collapse (sum) livestock_id livestock_sale_revenue /*livestock_slghtr_value*/ livestock_prod_value, by(hhid)
	ren livestock_id livestock_raised
	label define raised 101 "cattle only" 102 "buffalo only" 104 "pigs only" 203 "cattle and buffalo" 205 "cattle and pigs" 206 "buffalo and pigs" 307 "cattle, buffalo, and pigs"
	label values livestock_raised raised
	//merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_otherproducts.dta", nogen keep(1 3) keepusing(anim_prod_val_impt)
	gen anim_prod_val_impt = .
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_productivity_3.dta", replace
	restore
	
	
	********************************
	*LIVESTOCK PRODUCTIVITY & YIELD*
	********************************
	* save area (Ha) of parcel utilized for livestock and poultry by hhid
	preserve
	use "${Cambodia_CAS_2022_raw_data}\S4_LANDUSE_PARCEL.dta", clear
	ren holding_id hhid
	ren S4_LANDUSE_PARCEL__id main_use_parcel
	keep if main_use_parcel == 12 // where 12 = poultry or livestock
	collapse (sum) S4_Q06_ha, by(hhid)
	ren S4_Q06_ha parcel_area_poultry_livestock
	format parcel_area_poultry_livestock %8.0g
	drop if hhid == ""
	tempfile parcel_poultry_livestock
	save `parcel_poultry_livestock'
	restore

	* save area (Ha) of homelot utilized for livestock and poultry by hhid
	preserve
	use "${Cambodia_CAS_2022_raw_data}\LANDUSE2.dta", clear
	ren holding_id hhid
	ren LANDUSE2__id land_use_homelot
	keep if land_use_homelot == 3 | land_use_homelot == 6 // 3 == raised around homelot  6 == raised in/under homelot
	ren S4_Q23_ha area_dedicated
	collapse (sum) area_dedicated, by(hhid)
	ren area_dedicated homelot_area_poultry_livestock
	format homelot_area_poultry_livestock %8.0g
	tempfile homelot_poultry_livestock
	save `homelot_poultry_livestock'
	restore

	* save key poultry summary statistics by hhid
	preserve
	use "${Cambodia_CAS_2022_raw_data}\S7B_POULTRY.dta", clear
	ren holding_id hhid
	ren S7B_Q04 num_poultry
	collapse (sum) num_poultry, by(hhid)
	gen poultry = 1
	tempfile poultry_hhids
	save `poultry_hhids'
	restore
	
	* save animal_farm_area 
	preserve
	use `homelot_poultry_livestock', clear
	merge 1:1 hhid using `parcel_poultry_livestock', keep(1 3) nogen
	egen animal_farm_area = rowtotal(homelot_area_poultry_livestock parcel_area_poultry_livestock)
	collapse (sum) animal_farm_area, by(hhid)
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_animal_farm_area.dta", replace
	restore
	
	
	********************************
	*    LIVESTOCK RESHAPE WIDE    *
	********************************
	* reshape data from hhid/livestock_id to hhid
	
	decode livestock_id, gen(livestock_id_)
	drop livestock_id num_cattle num_buffalo num_pigs weight
	rename (*) (*_)
	rename (hhid_ livestock_id__) (hhid livestock_id)
	* address issues with variable length for reshape line below
	rename livestock_bought_received bought_received_
	rename livestock_sale_price_impt sale_price_impt_
	rename livestock_sale_price_obs sale_price_obs_ 
	//rename livestock_slghtr_unit_value slghtr_unit_value_
	rename livestock_mortality_rt_ mortality_rt_ 
	rename own_livestock_off_holding_ own_off_holding_
	rename livestock_trt_int_parasite_ trt_int_parasite_
	rename livestock_trt_ext_parasite_ trt_ext_parasite_
	rename livestock_trt_vax_spending_ trt_vax_spending_
	rename livestock_cur_trt_spending_ cur_trt_spending_
	rename livestock_purchase_spending_ purchase_spending_
	drop S7A* MAD*
	reshape wide *_, i(hhid) j(livestock_id) string
	ren province_Buffalo province
	drop province_*
	rename (*livestock_*) (**)
	ren LIVESTOCKAGE* livestockage*
	ren *Pig *Pigs //backwards compatibility
	* add labels to constructed variables and values in reshape format
	local animals "_Buffalo _Cattle _Pigs"
	//label define binary 1 "Yes" 0 "No"
	foreach x in `animals' {
		//la var feed`x' "Major feeding practice"
		//la var form_contract`x' "Does the holding have a production and/or marketing contract?"
		//la var contract_coverage`x' "Does the contract cover 100% of the animals raised?"
		//la var main_purpose`x' "Main purpose of animal"
		la var livestockage`x' "Age threshold used to distinguish between young and adult"
		la var num_ado_male`x' "Number of male animals of less than LIVESTOCKAGE"
		la var num_ado_fem`x' "Number of female animals of less than LIVESTOCKAGE"
		la var num_adult_male`x' "Number of male animals older than LIVESTOCKAGE"
		la var num_adult_fem`x' "Number of female animals older than LIVESTOCKAGE"
		la var own_all`x' "Does the household own all of the holding's livestock?"
		la var own_off_holding`x' "Does the household own any livestock off the holding?"
		la var births`x' "Number of animal births"
		la var bought`x' "Number of live animals that were bought"
		la var bought_received`x' "Number of live animals that were bought or received, including exchanged"
		la var purchase_price`x' "Average price of livestock live purchase? (imputed)"
		la var received`x' "Number of live animals that were received, including exchanged"
		la var deaths`x' "Number of animals that have died"
		la var sold`x' "Number of live animals sold"
		la var sale_price`x' "Price on last sale (in riels per head)"
		la var stolen`x' "Number of animals stolen"
		la var gift`x' "Number of animals given away as a gift"
		la var slghtr`x' "Number of animals slaughtered"
		//la var meat_sold`x' "Did the household sell meat from slaughtered livestock?"
		//la var meat_stock`x' "Did the household stock meat from slaughtered livestock?"
		//la var meat_stock_purpose`x' "Why did the household stock meat from slaughtered livestock?"
		//la var breeding`x' "Did the household breed livestock?"
		//la var breeding_cost`x' "Did the household incur costs associated with breeding livestock?"
		//la var vax`x' "At least one animal in holding's herd was vaccinated over survey timeframe"
		//la var num_vax`x' "Number of animals vaccinated"
		//la var trt_int_parasite`x' "Did the household treat livestock for internal parasites?"
		//la var trt_ext_parasite`x' "Did the household treat livestock for external parasites?"
		//la var trt_vax_spending`x' "How much did the houshold spend on parasite treatments and vaccinations?"
		//la var cur_trt`x' "Did the household purchase curative treatment for livestock?"
		//la var cur_trt_spending`x' "How much did the household spend on curative treatments?"
		la var num`x' "Number of animals, sum of sex and age"
		//la var purchase_spending`x' "How much did the household spend on purchasing live animals?"
		/*
		la var for_sale_live`x' "At least one animal in the holding's herd was cultivated for live sale"
		la var for_gift`x' "At least one animal in the holding's herd was cultivated for a gift"
		la var for_meat`x' "At least one animal in the holding's herd was cultivated for slaughter"
		la var for_agriculture`x' "At least one animal in the holding's herd was cultivated for agricultural use"
		la var for_breeding`x' "At least one animal in the holding's herd was cultivated for breeding"
		la var for_hh_consum`x' "At least one animal in the holding's herd was cultivated for hh consumption"
		la var for_product`x' "At least one animal in the holding's herd was cultivated for other products"
		la var for_savings`x' "At least one animal in the holding's herd was cultivated for savings"
		la var for_transport`x' "At least one animal in the holding's herd was cultivated for transport"
		*/
		la var growth`x' "Gross increase/growth in holding's herd headcount over survey timeframe"
		la var loss`x' "Gross decrease in holding's herd headcount over survey timeframe"
		la var net_growth`x' "Net increase/decrease in holding's herd headcount over survey timeframe"
		la var num_start`x' "Number of animals at the beginning of survey timeframe"
		la var peak_num`x' "Estimated maximum number of animals in household's herd over survey timeframe"
		la var growth_pct`x' "Gross increase/growth in holding's herd headcount over survey timeframe, %"
		la var loss_pct`x' "Gross decrease in holding's herd headcount over survey timeframe, %"
		la var net_growth_pct`x' "Net increase/decrease in holding's herd headcount over survey timeframe, %"
		la var mortality_rt`x' "Mortality rate over survey timeframe, %"
		//la var vax_pct`x' "Percent of holding's animals that were vaccinated over survey timeframe"
		la var price_prov_med`x' "Median price observed among hhids in the same province, as reported in survey"
		la var sale_price_obs`x' "Price on last sale (riels/head), observed in source data"
		la var sale_price_impt`x' "Price on last sale (riels/head), imputed from provincial or national medians"
		la var price_natl_med`x' "Median national price, based on sales in survey"
		la var sale_revenue`x' "Revenue realized from sale of live animals"
		//la var slghtr_unit_value`x' "Assumed value for price of meat from slaughter, equal to imputed sale price"
		//la var slghtr_value`x' "Assumed gross value realized (sold or consumed) in slaughter of animal"
		la var prod_value`x' "Gross value realized from animal live sales and slaughter over survey timeframe"
		la var breed_spending`x' "Household spending on breeding and herd reproduction activities"
		la var sale_rate`x'  "Share of household's herd sold over survey timeframe"
		//la var provision_feed`x' "Did the household use purchased feed?"
		// la var area`x' "Area to manage herd (TLU-adjusted)" // commented out section
		// la var productivity`x' "Output (riel) / area used for animal mgmt (imputed for missing prices)" // commented out section
		// la var yield`x' "AKA Density: Herd Size / area used for animal mgmt" // commented out section
		
		//label values for_sale_live`x' for_gift`x' for_meat`x' for_agriculture`x' for_breeding`x' for_hh_consum`x' for_product`x' for_savings`x' for_transport`x' vax`x' binary
	}
	merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_weights.dta", keep(1 3) nogen

	* fix issue with province (missing values)
	drop province*
	merge 1:m hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", nogen keepusing(province) keep(1 3)
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock.dta", replace


********************************************************************************
*POULTRY*
********************************************************************************
use "${Cambodia_CAS_2022_raw_data}\S7B_POULTRY.dta", clear
ren holding_id hhid
ren S7B_POULTRY__id poultry_id
ren PROVINCE_ID province
ren S7B_Q04 num_poultry // as of July 1, 2022


*Visual inspection of num_poultry indicates the presence of significant outliers
/*
su num_poultry, detail
codebook num_poultry
kdensity num_poultry
*/
//Although visual inspection reveals large skew and presence of outlier values,
//other relevant variables suggest that outlier values represent real events and should be therefore included


	*******************************
	*TYPE OF POULTRY RAISED BY HH *
	*******************************
	preserve
	collapse (sum) poultry_id num_poultry, by(hhid)
	ren poultry_id poultry_type_raised
	label define raised 201 "chicken only" 203 "ducks only" 404 "chicken and ducks"
	label values poultry_type_raised raised
	ren num_poultry num_poultry_raised
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhid_poultry_type.dta", replace
	restore
	
	
	*******************************
	*      POULTRY OWNERSHIP      *
	*******************************
	ren S7B_Q07 own_all_poultry
	ren S7B_Q09 own_poultry_off_holding
	recode own_all_poultry own_poultry_off_holding (2=0)
	label define binary_recode 0 "No" 1 "Yes"
	label values own_all_poultry own_poultry_off_holding binary_recode
	
	
	********************************
	*       POULTRY PURCHASE       *
	********************************
	ren S7B_Q12 poultry_bought
	ren S7B_Q13 poultry_purchase_price
	gen poultry_purchase_spending = poultry_bought * poultry_purchase_price
	
	
	********************************
	*       POULTRY BREEDING       *
	********************************
	//ren S7B_Q61 poultry_breeding
	//ren S7B_Q62 poultry_breeding_cost
	gen poultry_breeding = .
	gen poultry_breeding_cost = .
	recode poultry_breeding poultry_breeding_cost (2=0)
	label values poultry_breeding poultry_breeding_cost binary_recode
	
	/* hh-level only for this wave
	********************************
	*       FEEDING PRACTICES      *
	********************************
	ren S7B_Q45 poultry_feed
	tab poultry_feed poultry_id // snapshot of feeding practice across livestock type
	gen provision_feed = poultry_feed >= 2
	label define feed 0 "No feed" 1 "Feed"
	label values provision_feed feed
	*/
	
	/*
	**********************************
	*FEEDING PRACTICES VS. IRRIGATION*
	**********************************
	* This section allows the user/developer to visualize household behavior regarding
	* irrigation and animal feeding. It is not relevant or integrated into later analysis
	
	* irrigation vs. feeding practice (3-way)
	preserve
	recode poultry_feed (1=101) (2=102) (3=104)
	collapse (sum) poultry_id poultry_feed, by(hhid)
	recode poultry_feed  (202 = 101) (303 = 101) // only grazing
	recode poultry_feed  (208 = 104) (312 = 104) // only feed
	recode poultry_feed (203 204 205 206 304 305 306 307 308 309 310 = 102)
	label define feed_type 101 "only grazing" 102 "mix of grazing and feed" 104 "only feed"
	label values poultry_feed feed_type
	la var poultry_feed "Type of feed"
	ren poultry_id poultry_raised
	label define raised1 201 "chicken only" 203 "ducks only" 404 "chicken and ducks"
	label values poultry_raised raised1
	tab poultry_feed
	tempfile feeding_poultry
	save `feeding_poultry'
	restore
	
	preserve
	use "${Cambodia_CAS_2022_raw_data}\S4_CROP.dta", clear
	ren holding_id hhid
	ren s4_q05 irrigation
	recode irrigation (1=0) (2=1)
	label define binary3 0 "No" 1 "Yes"
	la var irrigation "Was this crop irrigated during 1 July 2020 through 30 June 2021?" //correction: aligning .dta file var label with questionnaire
	collapse (sum) irrigation, by(hhid)
	replace irrigation = 1 if irrigation >= 1
	label values irrigation binary3
	tempfile irrigation
	save `irrigation'

	use `feeding_poultry', clear
	merge m:1 hhid using `irrigation', keep (1 3) nogen
	la var irrigation "irrigation"
	la var poultry_feed "poultry feed"
	tab poultry_feed irrigation
	restore
	
	* irrigation vs. feeding practice (2-way)
	preserve
	collapse (sum) poultry_id provision_feed, by(hhid)
	replace provision_feed = 1 if provision_feed > 1
	label define feed1 0 "No feed" 1 "Feed"
	label values provision_feed feed1
	ren poultry_id poultry_raised
	label define raised2 201 "chicken only" 203 "ducks only" 404 "chicken and ducks"
	label values poultry_raised raised2
	merge m:1 hhid using `irrigation', keep (1 3) nogen
	la var irrigation "irrigation"
	la var provision_feed "poultry feed"
	tab provision_feed irrigation
	restore
	*/
	
	********************************
	*            CONTRACT          *
	********************************
	/* Not in this wave 
	ren S7B_Q47 form_contract
	ren S7B_Q48 contract_coverage
	recode form_contract contract_coverage (2=0)
	label values form_contract contract_coverage binary_recode
	tab form_contract // 98 observations (0.95%) where hhid has at least one formal production or marketing contract.
	tab contract_coverage
	*/
	
	********************************
	*       POULTRY PURPOSE        *
	********************************
	/* Not in this wave
	ren S7B_Q46 poultry_main_purpose
	gen for_sale_live = S7B_Q54f > 0 & S7B_Q54f !=.
	recode for_sale_live 0 = 1 if poultry_main_purpose == 1 // capture hhs that raised poultry for sale (as main purpose) but did not make a sale within the survey timeframe
	gen for_eggs = S7B_Q71 == 1 & S7B_Q71 !=.
	gen for_eggs_sale = S7B_Q73b > 0 & S7B_Q73b != .
	gen for_gift = S7B_Q54i > 0
	gen for_meat = S7B_Q54j > 0
	gen for_hh_consum = poultry_main_purpose == 3
	gen for_savings = poultry_main_purpose == 4
	gen for_breeding = poultry_main_purpose == 7
	recode for_* (.=0)
	label values for_sale_live for_eggs for_gift for_meat for_hh_consum for_savings for_breeding binary_recode
	*/
	
	*******************************
	*      POULTRY HEADCOUNT      *
	*******************************
	* num_ variables refer to flock size as of 1st July 2021
	gen num_chickens = num_poultry if poultry_id == 201
	recode num_chickens . = 0
	gen num_ducks = num_poultry if poultry_id == 203
	recode num_ducks . = 0
	//Note no geese in this wave
	gen num_geese = num_poultry if poultry_id == 208
	recode num_geese . = 0
	
	
	************************************
	* 2020-21 POULTRY HEADCOUNT GROWTH *
	************************************
	* all survey questions describing growth (loss) of poultry refer to timeframe Jul 1, 2020 - Jun 30, 2021
	ren S7B_Q11 poultry_births
	ren S7B_Q14 poultry_received
	ren S7B_Q15 poultry_deaths
	ren S7B_Q15f poultry_sold
	ren S7B_Q15j poultry_slghtr
	ren S7B_Q15i poultry_gift
	ren S7B_Q15h poultry_stolen
	egen poultry_bought_received = rowtotal(poultry_bought poultry_received)
	gen poultry_growth = poultry_births + poultry_bought + poultry_received
	gen poultry_loss = poultry_deaths + poultry_sold + poultry_slghtr + poultry_gift + poultry_stolen
	gen net_poultry_growth = poultry_growth - poultry_loss
	// If CAS2022 sampled the same hhs as CAS2020, then we could pull num_poultry_start from the previous survey.
	// However, CAS2022 samples a different set of households, so we must construct num_poultry_start
	gen num_poultry_start = num_poultry - net_poultry_growth // num_poultry refers to Jul 1, 2021 headcount
	replace num_poultry_start = 1 if num_poultry_start <= 0 // where 2020 headcount = 0, +1 to maintain integrity of following variables
	//Note: 72 obs of num_poultry_start are < 0, implying some data entry error or incomplete coverage of headcount growth/loss variables in survey.
	//Alternative  strategy for dealing with these observations (as opposed to 'replace' above) is dropping observations entirely
	
	gen poultry_growth_pct = poultry_growth / num_poultry_start
	gen poultry_loss_pct = poultry_loss / num_poultry_start
	gen net_poultry_growth_pct = net_poultry_growth / num_poultry_start
	gen peak_num_poultry = num_poultry_start + poultry_growth
	gen poultry_mortality_rt = poultry_deaths / peak_num_poultry
	gen poultry_sale_rate = poultry_sold / peak_num_poultry
	
	* ad hoc data visualization
	/*
	tabstat net_poultry_growth net_poultry_growth_pct num_poultry_start if poultry_id == 201, stat(mean min p1 p5 p50 p95 p99 max) col(stat) varwidth(30)
	//kdensity net_poultry_growth if poultry_id == 201
	//kdensity net_poultry_growth_pct if poultry_id == 201
	
	preserve
	keep if poultry_id == 201
	replace net_poultry_growth = 70 if net_poultry_growth > 70
	replace net_poultry_growth = -103 if net_poultry_growth < -103
	replace net_poultry_growth_pct = 62 if net_poultry_growth_pct > 62
	replace net_poultry_growth_pct = -0.8751 if net_poultry_growth_pct < -0.8751
	replace num_poultry_start = 245 if num_poultry_start > 245
	replace num_poultry_start = 1 if num_poultry_start < 1
	tabstat net_poultry_growth net_poultry_growth_pct num_poultry_start, stat(mean min p1 p5 p50 p95 p99 max) col(stat) varwidth(30)
	//kdensity net_poultry_growth
	//kdensity net_poultry_growth_pct
	restore
	*/
	
	preserve
	collapse (sum) poultry_id num_poultry net_poultry_growth num_poultry_start poultry_growth poultry_deaths peak_num_poultry, by(hhid)
	ren poultry_id poultry_raised
	ren num_poultry num_poultry_2022
	label define raised 201 "chickens only" 203 "ducks only" 404 "chicken and ducks"
	label values poultry_raised raised
	gen net_poultry_growth_pct = net_poultry_growth / num_poultry_start
	gen poultry_mortality_rt = poultry_deaths / peak_num_poultry
	keep hhid poultry_raised num_poultry_2022 net_poultry_growth net_poultry_growth_pct poultry_mortality_rt peak_num_poultry
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry_type_growth.dta", replace
	restore
	
	************************************
	*       POULTRY VACCINATION        *
	************************************
	//ren S7B_Q65 num_vax
	//recode num_vax (.=0) // CAS2022 encodes '.' for observations of 0 vaccinations; updating to CAS2020 format, which records no reported vaccinations as 0, not missing)
	//gen vax_pct = num_vax / num_poultry
	//replace vax_pct = num_vax / num_poultry_start if num_poultry_start >= num_poultry // where net decline in poultry population would otherwise render a misleading datapoint for vaccination rate
	//replace vax_pct = num_vax / peak_num_poultry if peak_num_poultry >= num_poultry // same intent as above, approximate maximum absolute population of poultry over survey period to address edge-case where num_poultry not representative of poultry headcount
	//replace vax_pct = 1 if vax_pct >= 1 & vax_pct != . // corrects obs where imputation above created vax_pct > 1.0 // 0 obs changed
	ren S7B_Q26 poultry_vax
	recode poultry_vax (2=0)
	gen vax_pct = .
	gen num_vax = .
	label values poultry_vax binary_recode
	

	preserve
	collapse (sum) poultry_id num_vax num_poultry, by(hhid)
	ren num_poultry num_poultry_raised
	ren poultry_id poultry_type_raised
	label define raised 201 "chickens only" 203 "ducks only" 404 "chicken and ducks"
	label values poultry_type_raised raised
	gen poultry_vax_pct = num_vax / num_poultry_raised
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry_type_vaccination.dta", replace
	restore
	
	********************************
	*      POULTRY TREATMENTS      *
	********************************
	ren S7B_Q28__5 poultry_trt_int_parasite
	ren S7B_Q28__6 poultry_trt_ext_parasite
	//ren S7B_Q68 poultry_trt_vax_spending
	ren S7B_Q28__2 poultry_cur_trt
	//ren S7B_Q70 poultry_cur_trt_spending
	gen poultry_trt_vax_spending = .
	gen poultry_cur_trt_spending = .
	recode poultry_trt_int_parasite poultry_trt_ext_parasite poultry_cur_trt (2=0)
	label values poultry_trt_int_parasite poultry_trt_ext_parasite poultry_cur_trt binary_recode
	
	
	*******************************
	*       EGG CULTIVATION       *
	*******************************
	* egg production and use
	ren S7B_Q22 collected_eggs
	recode collected_eggs (2=0)
	ren S7B_Q23c daily_avg_egg_prod
	ren S7B_Q23a months_eggs_collected
	ren S7B_Q23b days_per_month_eggs_collected
	gen eggs_total_prod = months_eggs_collected * days_per_month_eggs_collected * daily_avg_egg_prod
	gen eggs_prod_annualized =  daily_avg_egg_prod * 365.25
	label variable eggs_prod_annualized "extrapolate annual egg production if average egg daily production were applied every day of year"
	//gen eggs_lost_pct = S7B_Q73e / 100
	//gen eggs_kept_pct = 1 - eggs_lost_pct
	gen eggs_kept_pct = S7B_Q24a/100
	gen eggs_sold_pct = S7B_Q24b/100 
	recode eggs_sold_pct (.=0) if collected_eggs
	gen eggs_lost_pct = 1 - eggs_kept_pct - eggs_sold_pct 
	
	gen eggs_kept = eggs_total_prod * eggs_kept_pct
	gen eggs_lost = eggs_total_prod * eggs_lost_pct

	//kept = own consump here.
	//gen eggs_own_consump_pct = S7B_Q73a / 100
	//gen eggs_own_consump = eggs_total_prod * eggs_own_consump_pct

	//gen eggs_sold_pct = S7B_Q73b / 100
	gen eggs_sold = eggs_sold_pct * eggs_total_prod

	* egg prices
	ren S7B_Q24c_KHR_egg egg_price
	
	* generate egg_price provincial medians
	preserve
	merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", nogen
	drop weight
	recode egg_price . = 0
	drop if egg_price == 0
	collapse (median) egg_price, by(poultry_id province)
	ren egg_price egg_price_prov_med
	decode poultry_id, gen(tempvar1)
	decode province, gen(tempvar2)
	gen poultry_province = tempvar1 + "_" + tempvar2
	drop tempvar1 tempvar2 poultry_id province
	tempfile poultry_province_egg_prices
	save `poultry_province_egg_prices'
	restore
	
	* generate egg_price national medians
	preserve
	drop if egg_price == 0
	collapse (median) egg_price, by(poultry_id)
	ren egg_price egg_price_natl_med
	tempfile poultry_med_egg_prices
	save `poultry_med_egg_prices'
	restore
	
	* merge-in provincial median egg prices for missing values
	merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", nogen
	drop weight
	decode poultry_id, gen(tempvar1)
	decode province, gen(tempvar2)
	gen poultry_province = tempvar1 + "_" + tempvar2
	drop tempvar1 tempvar2
	merge m:1 poultry_province using `poultry_province_egg_prices', nogen

	gen egg_price_obs = egg_price
	gen egg_price_impt = egg_price_prov_med if collected_eggs == 1 & egg_price == .
	replace egg_price = egg_price_prov_med if collected_eggs == 1 & egg_price == .

	
	//NOTE: 96 observations where hhid collects poultry_id eggs (31% of total) are '.' due to no relevant province-level median for poultry_id egg_price
	/*
	recode egg_price 0 = .
	su egg_price, detail // max value in egg_price is 1000
	inspect egg_price
	keep hhid poultry_id S7B_Q71 egg_price daily_avg_egg_prod province poultry_province
	*/
	
	* merge-in national median egg prices for missing values
	merge m:1 poultry_id using `poultry_med_egg_prices', nogen
	replace egg_price = egg_price_natl_med if collected_eggs == 1 & egg_price == . 
	replace egg_price_impt = egg_price_natl_med if collected_eggs == 1 & eggs_sold == 0
	// replace egg_price = egg_price_natl_med if S7B_Q71 == 1 & province >= 26 // address edge-case where hhid not matched with province & therefore imputed incorrect assumption for egg_price // 4 real changes

	
	* double-check that all values for egg_price align with intended assumptions
	/*
	br hhid poultry_id daily_avg_egg_prod egg_price eggs_total_prod eggs_sold province///
	poultry_province egg_price_prov_med egg_price_natl_med egg_price_impt egg_price_obs if S7B_Q71 == 1
	*/
	
	drop if poultry_id >= 209 // eliminate non-relevant observations (i.e. not poultry) pulled in via merges
	recode egg_price egg_price_obs (0=.)

	* egg value
	gen eggs_value_lost = egg_price * eggs_lost // annual market value (riels) of eggs lost due to accident, illness, or injury
	recode eggs_value_lost .=0
	gen eggs_value_cultiv =  eggs_total_prod * egg_price - eggs_value_lost // annual market value (riels) of eggs produced for sale, consumption, given away, or other use; note egg price contains mix of imputed and observed values
	gen eggs_value_consump = eggs_kept * egg_price // annual market value (riels) of eggs consumed; egg price contains mix of imputed and observed values
	gen eggs_revenue = eggs_sold * egg_price // annual market value (riels) of eggs sold; egg price contains mix of imputed and observed values
	recode egg_price 0=.
	recode eggs_value_lost 0=.
	
	replace eggs_revenue = . if eggs_sold == 0
	replace egg_price = . if eggs_sold == 0
	
	* summary temp files
	preserve
	collapse (sum) poultry_id num_poultry eggs_total_prod eggs_prod_annualized eggs_kept eggs_value_cultiv /*eggs_own_consump*/ eggs_value_consump eggs_sold eggs_revenue, by(hhid)
	ren poultry_id poultry_type_raised
	label define raised 201 "chickens only" 203 "ducks only" 404 "chicken and ducks"
	label values poultry_type_raised raised
	ren num_poultry num_poultry_2022
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry_type_egg_productivity.dta", replace
	restore

	preserve
	keep hhid poultry_id num_poultry eggs_total_prod eggs_prod_annualized eggs_kept eggs_value_cultiv /*eggs_own_consump*/ eggs_value_consump eggs_sold eggs_revenue
	order hhid poultry_id num_poultry eggs_total_prod eggs_prod_annualized eggs_kept eggs_value_cultiv /*eggs_own_consump*/ eggs_value_consump eggs_sold eggs_revenue
	sort hhid poultry_id, stable
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhid_poultry_egg_productivity.dta", replace
	restore
	
	*******************************
	*     POULTRY LIVE SALES      *
	*******************************
	* price of live sale
	ren POULTRYSALE poultry_sale_ppkg // (riel/kg)
	
	*There are significant outliers in poultry_sale_ppkg that should be addressed
	/*
	su poultry_sale_ppkg, detail // max value in poultry_sale_ppkg is 25000
	br if poultry_sale_ppkg <= 25000 // excludes missing values
	keep hhid poultry_id num_poultry poultry_sold poultry_sale_ppkg
	sort poultry_id poultry_sale_ppkg, stable
	br
	inspect poultry_sale_ppkg
	*/

	* construct Median Absolute Deviation (MAD) statistics around poultry_sale_ppkg for each type of poultry
	preserve
	recode poultry_sale_ppkg . = 0
	drop if poultry_sale_ppkg == 0
	egen med_poultry_ppkg = median(poultry_sale_ppkg), by(poultry_id)
	egen MAD_poultry_ppkg = median(abs(poultry_sale_ppkg - med_poultry_ppkg)), by(poultry_id)
	collapse (mean) med_poultry_ppkg MAD_poultry_ppkg, by(poultry_id)
	tempfile MAD_poultry_prices
	save `MAD_poultry_prices'
	restore

	* exclude outliers using MAD statistics
	merge m:1 poultry_id using `MAD_poultry_prices', nogen
	recode poultry_sale_ppkg . = 0
	replace poultry_sale_ppkg = . if poultry_sale_ppkg >= med_poultry_ppkg + (3 * MAD_poultry_ppkg) // 131 observations changed (4.0% of total)
	recode poultry_sale_ppkg 0 = .

	
	* outlier exclusion was successful
	/*
	su poultry_sale_ppkg, detail // max value in poultry_sale_ppkg is 21000
	br if poultry_sale_ppkg <= 21000 // excludes missing values ('.')
	keep hhid poultry_id num_poultry poultry_sold poultry_sale_ppkg
	sort poultry_id poultry_sale_ppkg, stable
	br
	inspect poultry_sale_ppkg // 7294 missing observations
	*/
	//All missing poultry_sale_ppkg values are associated with 0 live sales, therefore we derive no value re: live sale indicators by constructing a
	//provincial or national median price for each poultry_id, in contrast to egg_price
	//However, we later assume that the poultry_sale_ppkg value is equivalent to the sale price/value of meat production;
	//to avoid missing observations of poultry_meat_value where poultry_sold == 0, we will construct an assumption for missing poultry_sale_ppkg observations

	
	* generate poultry_sale_ppkg provincial medians
	preserve
	merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", nogen
	drop weight
	recode poultry_sale_ppkg . = 0
	drop if poultry_sale_ppkg == 0
	collapse (median) poultry_sale_ppkg, by(poultry_id province)
	ren poultry_sale_ppkg poultry_ppkg_prov_med
	decode poultry_id, gen(tempvar1)
	decode province, gen(tempvar2)
	gen poultry_province = tempvar1 + "_" + tempvar2
	drop tempvar1 tempvar2 poultry_id province
	tempfile poultry_province_ppkg
	save `poultry_province_ppkg'
	restore

	* generate poultry_sale_ppkg national medians
	preserve
	recode poultry_sale_ppkg . = 0
	drop if poultry_sale_ppkg == 0
	collapse (median) poultry_sale_ppkg, by(poultry_id)
	ren poultry_sale_ppkg poultry_ppkg_natl_med
	tempfile poultry_med_ppkg
	save `poultry_med_ppkg'
	restore

	* merge-in provincial median poultry_sale_ppkg for missing values
	merge m:1 poultry_province using `poultry_province_ppkg', nogen
	gen poultry_sale_ppkg_obs = poultry_sale_ppkg
	gen poultry_sale_ppkg_impt = poultry_ppkg_prov_med if poultry_sold == 0
	replace poultry_sale_ppkg = poultry_ppkg_prov_med if poultry_sold == 0

	* merge-in national median poultry_sale_ppkg for missing values
	merge m:1 poultry_id using `poultry_med_ppkg', nogen
	recode poultry_sale_ppkg . = 0
	recode province . = 0
	replace poultry_sale_ppkg = poultry_ppkg_natl_med if poultry_sale_ppkg == 0 | province == 0
	replace poultry_sale_ppkg_impt = poultry_ppkg_natl_med if poultry_sale_ppkg == 0 | province == 0

	* price unit conversion
	local chicken_weight = 2.3 // assumed weight (kg/poultry) - based on mean weight of mature indigenous chicken production in Vietnam (Bett et. al 2014) https://www.lrrd.org/lrrd26/12/bett26229.html
	local duck_weight = 1.5 // assumeed weight (kg/poultry) - based on weighted average calculated from Tables 32 & 33 in "Characterization of the Domestic Duck Production System in Cambodia" (FAO 2008) https://www.fao.org/3/al680e/al680e00.pdf
	gen poultry_sale_price = poultry_sale_ppkg * `chicken_weight' // assumed price per chicken (riel/head)
	replace poultry_sale_price = poultry_sale_ppkg * `duck_weight' if poultry_id == 203 // assumed price per duck (riel/head)
	
	
	* Visual inspection of poultry_sold indicates the presence of significant outliers
	/*
	preserve
	drop if poultry_sold == 0
	su poultry_sold, detail
	codebook poultry_sold
	inspect poultry_sold
	br hhid poultry_id poultry_sold 
	kdensity poultry_sold
	restore
	*/
	//Although visual inspection reveals large skew and presence of outlier values, other relevant variables suggest that outlier values
	//represent real events and should be therefore included
	
	
	* construct indicator for revenue from live poultry sales
	gen poultry_sale_revenue = poultry_sale_price * poultry_sold // based on observed and imputed prices; same as observed only because all missing prices associated with 0 sales

	
	*******************************
	*   POULTRY MEAT PRODUCTION   *
	*******************************
	ren S7B_Q15k poultry_weight // avg weight of poultry prior to slaughter
	gen poultry_slghtr_ppkg = poultry_sale_ppkg // assuming equivalence between live sale and slaughter
	gen poultry_slghtr_unit_value = poultry_slghtr_ppkg * poultry_weight
	gen poultry_slghtr_value =  poultry_slghtr_unit_value * poultry_slghtr  
	
	* meat sales
	/* Not in questionnaire
	ren S7B_Q56 meat_sold
	recode meat_sold (2=0) (.=0)
	label define meat 0 "No" 1 "Yes"
	label values meat_sold meat	
	*/
	
	* stocking meat
	ren S7B_Q20 meat_stock
	recode meat_stock (2=0) (.=0)
	label define stock 0 "No" 1 "Yes"
	label values meat_stock stock
	ren S7B_Q21 meat_stock_purpose

	
	*******************************
	*    POULTRY EXPLICIT COSTS   *
	*******************************
	* Note: the survey does not report cost of feed, total spending on breeding expenses, or other explicit costs
	/*Not in questionnaire
	preserve
	keep hhid poultry_id province poultry_feed poultry_purchase_spending poultry_cur_trt_spending poultry_trt_vax_spending
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry_explicit_costs.dta", replace
	restore
	*/
	
	*******************************
	*     TOTAL POULTRY VALUE     *
	*******************************
	* combine revenue and value variables
	
	recode eggs_value_cultiv poultry_sale_revenue poultry_slghtr_value (. = 0)
	gen poultry_prod_value = eggs_value_cultiv + poultry_sale_revenue + poultry_slghtr_value
	replace eggs_value_cultiv = . if eggs_total_prod == .
	replace poultry_sale_revenue = . if poultry_sold == 0 
	replace poultry_sale_price = . if poultry_sold == 0 
	replace poultry_sale_ppkg = . if poultry_sold == 0 
	replace poultry_slghtr_value = . if poultry_slghtr == 0
	replace poultry_slghtr_unit_value = . if poultry_slghtr == 0
	
	* save temp file, household-level
	preserve
	collapse (sum) eggs_value_cultiv poultry_sale_revenue poultry_slghtr_value poultry_prod_value, by(hhid)
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry_productivity_1.dta", replace
	restore

	* save temp file, household-/livestock-level
	preserve
	collapse (sum) eggs_value_cultiv poultry_sale_revenue poultry_slghtr_value poultry_prod_value, by(hhid poultry_id)
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry_productivity_2.dta", replace
	restore

	* save temp file, household-/livestock type-level
	preserve
	collapse (sum) poultry_id eggs_value_cultiv poultry_sale_revenue poultry_slghtr_value poultry_prod_value, by(hhid)
	ren poultry_id poultry_type_raised
	label define raised 201 "chicken only" 203 "ducks only" 404 "chicken and ducks"
	label values poultry_type_raised raised
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry_productivity_3.dta", replace
	restore
	
	recode province 0 = .
	drop if poultry_id == . // drops empty observations brought in by merges
	//drop S7A_Q55 S7A_Q71 S7A_Q73a S7A_Q73b S7A_Q73d S7A_Q73e S7A_Q73f med_poultry_ppkg MAD_poultry_ppkg poultry_province
	drop S7B* med_poultry_ppkg MAD_poultry_ppkg poultry_province
	
	********************************
	*     POULTRY RESHAPE WIDE     *
	********************************
	* reshape data from hhid/poultry_id to hhid
	
	decode poultry_id, gen(poultry_id_)
	drop poultry_id num_chickens num_ducks num_geese
	rename (*) (*_)
	rename (hhid_ poultry_id__) (hhid poultry_id)
	* address issues with variable length (reshape below)
	rename poultry_bought_received bought_received_
	rename days_per_month_eggs_collected days_month_eggs_collect_
	rename poultry_mortality_rt mortality_rt_
	rename poultry_slghtr_unit_value slghtr_unit_value_
	rename poultry_trt_int_parasite trt_int_parasite_
	rename poultry_trt_ext_parasite trt_ext_parasite_
	rename poultry_trt_vax_spending trt_vax_spending_
	rename poultry_cur_trt_spending cur_trt_spending_
	rename poultry_purchase_spending purchase_spending_
	
	reshape wide *_, i(hhid) j(poultry_id) string
	ren province_Chicken province
	drop province_*
	rename (*poultry_*) (**)
	drop weight_*

	* add labels to constructed variables and values in reshape format
	local animals "_Chickens _Ducks"
	//label define binary2 1 "Yes" 0 "No"
	foreach x in `animals' {
		//la var feed`x' "Major feeding practice"
		//la var main_purpose`x' "Main purpose of animal"
		//la var form_contract`x' "Does the holding have a production and/or marketing contract?"
		//la var contract_coverage`x' "Does the contract cover 100% of the animals raised?"
		la var num`x' "Number of animals"
		la var own_all`x' "Does the household own all of the holding's poultry?"
		la var own_off_holding`x' "Does the household own any poultry off the holding?"
		la var births`x' "Number of births"
		la var bought`x' "Number of live animals that were bought, including exchanged"
		la var bought_received`x' "Number of live animals that were bought or received, including exchanged"
		la var purchase_price`x' "Average price of poultry live purchase? (imputed)"
		la var received`x' "Number of live animals that were received"
		la var deaths`x' "Number of animals that have died"
		la var sold`x' "Number of live animals sold"
		la var sale_ppkg`x' "Price on last sale (in riels per kg)"
		la var stolen`x' "Number of animals stolen"
		la var gift`x' "Number of animals given away as a gift"
		la var slghtr`x' "Number of animals slaughtered"
		//la var meat_sold`x' "Did the household sell meat from slaughtered poultry?"
		la var meat_stock`x' "Did the household stock meat from slaughtered poultry?"
		la var meat_stock_purpose`x' "Why did the household stock meat from slaughtered poultry?"
		//la var breeding`x' "Did the household breed poultry?"
		//la var breeding_cost`x' "Did the household incur costs associated with breeding poultry?"
		//la var vax`x' "Did the household vaccinate any poultry?"
		//la var num_vax`x' "Number of animals vaccinated"
		la var trt_int_parasite`x' "Did the household treat poultry for internal parasites?"
		la var trt_ext_parasite`x' "Did the household treat poultry for external parasites?"
		//la var trt_vax_spending`x' "How much did the houshold spend on parasite treatments and vaccinations?"
		la var cur_trt`x' "Did the household purchase curative treatment for poultry?"
		la var cur_trt_spending`x' "How much did the household spend on curative treatments?"
		la var months_eggs_collected`x' "Number of months during the survey period (annually) when holding collected eggs"
		la var days_month_eggs_collect`x' "Number of days per month that holding collected eggs"
		la var daily_avg_egg_prod`x' "Average number of eggs collected by holding for days when eggs were collected"
		la var egg_price`x' "Price of eggs sold (riels)"
		la var purchase_spending`x' "How much did the household spend on purchasing live animals?"
		//la var provision_feed`x' "At least one animal in the holding's flock was cultivated for live sale"
		/*
		la var for_sale_live`x' "At least one animal in the holding's flock was cultivated for live sale"
		la var for_eggs`x' "At least one animal in the holding's flock was cultivated to produce eggs"
		la var for_eggs_sale`x' "Some eggs were produced and collected by holding for sale"
		la var for_gift`x' "At least one animal in the holding's flock was cultivated for a gift"
		la var for_meat`x' "At least one animal in the holding's flock was cultivated for slaughter"
		la var for_hh_consum`x' "At least one animal in the holding's flock was cultivated for hh consumption"
		la var for_savings`x' "At least one animal in the holding's flock was cultivated for savings"
		la var for_breeding`x' "At least one animal in the holding's flock was cultivated for breeding"
		*/
		la var growth`x' "Gross increase/growth in holding's animal headcount over survey timeframe"
		la var loss`x' "Gross decrease in holding's flock headcount over survey timeframe"
		la var net_growth`x' "Net increase/decrease in holding's flock headcount over survey timeframe"
		la var num_start`x' "Number of animals at the beginning of survey timeframe"
		la var peak_num`x' "Estimated maximum number of animals in the household flock over survey timeframe"
		la var growth_pct`x' "Gross increase/growth in holding's flock headcount over survey timeframe, %"
		la var loss_pct`x' "Gross decrease in holding's flock headcount over survey timeframe, &"
		la var net_growth_pct`x' "Net increase/decrease in holding's flock headcount over survey timeframe, %"
		la var mortality_rt`x' "Mortality rate over survey timeframe, %"
		la var vax_pct`x' "Percent of holding's animals that were vaccinated over survey timeframe"
		la var vax`x' "At least one animal in holding's flock was vaccinated over survey timeframe"
		la var eggs_total_prod`x' "Sum of eggs produced and collected by holding over survey timeline"
		la var eggs_prod_annualized`x' "Annualized projection of total egg production, if production every day"
		la var eggs_lost_pct`x' "Eggs lost, %"
		la var eggs_kept_pct`x' "Eggs kept (i.e. not broken or lost), %"
		la var eggs_kept`x' "Eggs kept (i.e. not broken or lost)"
		la var eggs_lost`x' "Eggs lost (broken, etc.)"
		//la var eggs_own_consump_pct`x' "Eggs consumed by holding, %"
		//la var eggs_own_consump`x' "Eggs consumed by holding over survey timeframe"
		la var eggs_sold_pct`x' "Eggs sold over survey timeframe, %"
		la var eggs_sold`x' "Eggs sold over survey timeframe"
		la var egg_price_prov_med`x' "Median price of eggs sold by holdings sampled in the same province"
		la var egg_price_obs`x' "Price on last sale of eggs, observed in source data"
		la var egg_price_impt`x' "Price on last sale of eggs, imputed"
		la var egg_price_natl_med`x' "Median price of eggs sold by holdings sample across Cambodia"
		la var eggs_value_cultiv`x' "Estimated egg production value (riels) for holding"
		la var eggs_value_consump`x' "Estimated value of eggs consumed (riels) by holding"
		la var eggs_value_lost`x' "Estimated value of eggs lost (riels) by holding"
		la var eggs_revenue`x' "Estimated value of eggs sold (riels) by holding"
		la var ppkg_prov_med`x' "Median province price, based on live animal sales in the survey"
		la var sale_ppkg_obs`x' "Estimated price of selling live animals (riels/kg), observed in the source data"
		la var sale_ppkg_impt`x' "Estimated price of selling live animals, imputed"
		la var ppkg_natl_med`x' "Median national price, based on live animal sales in the survey"
		la var sale_price`x' "Estimated price of selling live animal (riels/head)"
		la var sale_revenue`x' "Estimated revenue from sale of live animals (riels)"
		la var slghtr_unit_value`x' "Assumed price for slaughtered bird, based on sale price (riels/head)"
		la var slghtr_ppkg`x' "Assumed price for slaughtered bird, based on sale price (riels/kg)"
		la var slghtr_value`x' "Estimated value (revenue and holding consumption) from slaughtered birds (riels)"
		la var prod_value`x' "Est. value from egg cultivation, bird slaughter, and live animal sale (riels)"
		la var sale_rate`x'  "Share of household's flock sold over survey timeframe"
		//la var provision_feed`x' "Did the household use purchased feed?"
		// la var area`x' "Area to manage flock (TLU-adjusted)" // commented out section
		// la var productivity`x' "Output (riel) / area used for animal mgmt (imputed for missing prices)" // commented out section
		// la var yield`x' "AKA Density: Flock Size / area used for animal mgmt" // commented out section

		//label values for_sale_live`x' for_eggs`x' for_gift`x' for_meat`x' for_hh_consum`x' for_savings`x' for_breeding`x' vax`x' binary
	}
	merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_weights.dta", keep(1 3) nogen
	
	* fix issue with province (missing values)
	drop province*
	merge 1:m hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhids.dta", nogen keepusing(province) keep(1 3)
	save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry.dta", replace
	
********************************************************************************
*CONSOLIDATE POULTRY AND LIVESTOCK, ADD HOUSEHOLD-SPECIFIC VARIABLES*
********************************************************************************
*merge reshaped poultry and livestock files together
use "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_poultry.dta", clear
merge m:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock.dta", nogen


*classify hhs by type of livestock raised
foreach i in Chickens Cattle Buffalo Pigs Ducks {
	gen raised_`i' = 1 if (num_`i' > 0 | num_start_`i' > 0) & num_`i' != .
}
gen raised_Poultry = 1 if raised_Chickens ==1 | raised_Ducks ==1
gen raised_cattle_buffalo = 1 if raised_Cattle ==1 | raised_Buffalo ==1
gen raised_Livestock =1 if raised_Cattle ==1 | raised_Buffalo ==1 | raised_Pigs ==1
gen raised_Livestock_Poultry = 1
recode raised_* (.=0)
foreach x in Chickens Cattle Buffalo Pigs Ducks Poultry cattle_buffalo Livestock Livestock_Poultry {
	la var raised_`x' "Household raised `x' over survey timeframe"
}
recode raised_* (.=0)


* merge-in agricultural activities
merge m:1 hhid province weight using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_agriculture_activities.dta", keepusing(ag_hh* ag_area*) nogen
recode ag_hh* (.=0)


* add zones
gen zone = ""
replace zone = "Tonle Sap" if inlist(province, 22,1,17,24,2,6,4,15) //Otdar Mean Chey, Banteay Mean Chey, Siem Reap, Pallin, Battambang, Kg. Thom, Kg. Chhnang, Pursat
replace zone = "Coastal" if inlist(province,9,7,23,18) //Koh Kong, Kampot, Kep, Preah Sihanouk
replace zone = "Plain" if inlist(province,21,8,14,20,3,25) //Takeo, Kandal, Prey Veng, Svay Rieng, Kg. Cham, Tbong Khmum
replace zone = "Mountain" if inlist(province,13,19,10,11,16,5) //Preah Vihear, Stung Treng, Kratie, Mondulkiri, Rattanakkiri
replace zone = "Phnom Penh" if province == 12


* summarize holding livestock characteristics by zone (ad-hoc analysis)
/*
global xxx ""
foreach i in Poultry cattle_buffalo Cattle Buffalo Pigs Chickens Ducks {
	global xxx $xxx raised_`i'
}
foreach i in Cattle Buffalo Pigs Chickens Ducks {
	global xxx $xxx num_`i'
}
foreach i in Cattle Buffalo Pigs Chickens Ducks {
	global xxx $xxx births_`i'
}
foreach i in Cattle Buffalo Pigs Chickens Ducks {
	global xxx $xxx bought_`i'
}
tabstat $xxx [aw=weight] if zone == "Plain", stat(sum) c(s) varwidth(30)
tabstat $xxx [aw=weight] if zone == "Tonle Sap", stat(sum) c(s) varwidth(30)
tabstat $xxx [aw=weight] if zone == "Coastal", stat(sum) c(s) varwidth(30)
tabstat $xxx [aw=weight] if zone == "Mountain", stat(sum) c(s) varwidth(30)
*/


*merge-in hh head gender
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hh_decision_makers.dta", keep(1 3) keepusing(fhh edu_hh edu_hh_head) nogen

/*
* merge-in COVID shock
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_COVID_impact.dta", keep(1 3) keepusing(covid_shock) nogen
recode covid_shock (.=0)
*/

*merge-in association membership
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_association_membership.dta", keep(1 3) keepusing(ag_comm ag_comm_assoc /*ag_assoc*/) nogen
gen ag_assoc=.

*merge in farm size (animal)
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_animal_farm_area.dta", keep(1 3) nogen
ren animal_farm_area animal_area
gen animal_ded_area = 1 if animal_area > 0 & animal_area != .
recode animal_ded_area .=0
tempfile farm_area
save `farm_area'


* merge-in holding size
// note: unlike CAS20, where the variable "TOTALAREA" covers all area (homelot and parcel) in the holding, we must construct that indicator
preserve
use "${Cambodia_CAS_2022_raw_data}\S4_PARCEL.dta", clear
ren PARCELHA parcel_area
collapse (sum) parcel_area, by(holding_id)
drop if holding_id == ""
ren holding_id hhid
tempfile aaa
save `aaa'
use `farm_area', clear
gen bin = 1
keep hhid bin
tempfile bbb
save `bbb'
use "${Cambodia_CAS_2022_raw_data}\CAS2022_FINAL.dta", clear
ren holding_id hhid
ren HOMELOTHA homelot_area
merge m:1 hhid using `aaa', nogen
merge m:1 hhid using `bbb', nogen
keep if bin == 1
egen holding_area = rowtotal(homelot_area parcel_area)
keep hhid holding_area homelot_area parcel_area
tempfile holding_size
save `holding_size'
restore
merge 1:1 hhid using `holding_size', nogen keep(1 3)
gen animal_area_rate = animal_area / holding_area //missing values (3,844) are generated due to missing values of animal_area as <100% of survey respondents addressed those questions 
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_livestock_prod.dta", replace

* ad hoc analysis - check for missing values in holding_area
/*
preserve
gen holding_area_missing = 1 if holding_area == .
recode holding_area_missing .=0
tab animal_ded_area holding_area_missing, missing
drop holding_area_missing

* t-test: difference in overall holding size (ha) betwen households that dedicate space to livestock vs. those that do not?
ttest holding_area, by(animal_ded_area)

* deep dive: missing animal_ded_areas
gen homelot_missing = 1 if homelot_area == .
gen parcel_missing = 1 if parcel_area == .
recode homelot_missing parcel_missing (.=0)
tab homelot_missing parcel_missing if animal_ded_area == 0
drop parcel_missing homelot_missing
restore
*/


*merge-in rice & cashew production

	use "${Cambodia_CAS_2022_raw_data}\S5A_HARVESTED.dta", clear 
	collapse (sum) area_planted=AREA_PLANTEDHA area_harvested=AREA_HARVESTEDHA PRODUCTION, by(holding_id PROVINCE_ID S5A_CROP__id S5A_PARCELHOMELOT__id)
	recode area_planted (0=.)
	replace area_harvested = . if area_planted==.
	tempfile crops_harv
	save `crops_harv'
	

	use "${Cambodia_CAS_2022_raw_data}\S5A_CROP.dta", clear
	keep if S5A_CROP__id < 1000 //dropping categories with more than one entry; reduces the sample by 213 households; mean value harvest changes by ~20,000 KHR
	//tempcrops
	gen share_own_use = S5A_Q32
	gen share_sale = S5A_Q33
	gen share_other = S5A_Q35
	
	//permcrops
	replace share_own_use = S5A_Q47 if share_own_use ==.
	replace share_sale = S5A_Q48 if share_sale==. 
	replace share_other = S5A_Q50 if share_other == .
	recode share* (.=0)

	gen qty_harvested = S5A_Q44_kg
	merge 1:1 holding_id PROVINCE_ID S5A_CROP__id S5A_PARCELHOMELOT__id using `crops_harv', nogen
	replace qty_harvested = PRODUCTION if qty_harvested==.
	
	gen qty_own_use = share_own_use /100 * qty_harvested
	gen qty_sale = share_sale/100 * qty_harvested
	gen qty_other = share_other/100 * qty_harvested
	
	gen price_kg = S5A_Q34
	replace price_kg=PRICECROP2 if price_kg==.
	recode price_kg (0=.)
	
	preserve
	collapse (median) hh_price_kg = price_kg, by(holding_id S5A_CROP__id)
	tempfile hh_median
	save `hh_median'
	restore
	
	preserve
	collapse (median) med_price_kg=price_kg [aw=Weight], by(PROVINCE_ID S5A_CROP__id)
	tempfile area_medians
	save `area_medians'
	restore
	
	preserve
	collapse (median) nat_price_kg = price_kg [aw=Weight], by(S5A_CROP__id)
	tempfile nat_medians
	save `nat_medians'
	restore
	
	merge m:1 holding_id S5A_CROP__id using `hh_median', nogen
	//assert price_kg == hh_price_kg //285 contradictions, possibly from differences in sales time; some prices also not recorded.
	merge m:1 PROVINCE_ID S5A_CROP__id using `area_medians', nogen 
	merge m:1 S5A_CROP__id using `nat_medians', nogen
	gen orig_price_kg = price_kg
	gen imputed = 0
	replace price_kg = hh_price_kg if price_kg == .
	replace imputed=1 if price_kg!=orig_price_kg
	replace orig_price_kg = price_kg
	replace price_kg = med_price_kg if price_kg == .
	replace imputed=2 if price_kg!=orig_price_kg 
	replace orig_price_kg = price_kg
	replace price_kg = nat_price_kg if price_kg == .
	replace imputed=3 if price_kg!=orig_price_kg 
	la def imputed 0 Original 1 Household 2 Province 3 National
	la val imputed imputed
	drop orig_price_kg med_price_kg nat_price_kg hh_price_kg 
	//13 obs where price_kg is missing, all dragonfruit
	
	gen val_harv = qty_harvested * price_kg
	gen val_own_use = price_kg*qty_own_use
	gen val_sale = price_kg*qty_sale
	gen val_other = price_kg*qty_other 

	recode qty* val* (0=.)
	//replace area_plant_perm = . if area_plant_perm==0
	//replace area_harv_perm = . if area_plant_perm==.
	//replace area_planted=area_plant_perm if area_planted==.
	//replace area_harvested = area_harv_perm if area_harvested==.
	
ren PROVINCE_ID province
ren Weight weight
ren holding_id hhid 
ren S5A_CROP__id crop_code 
collapse (sum) area_harvested area_planted qty_harvested qty_own_use qty_sale /*qty_gift qty_pay qty_feed qty_seed qty_lost qty_processed*/ val_* (max) imputed, by(province hhid crop_code)
gen price_kg = qty_harvested/val_harv //Do area-weighted averages.
save "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hh_crop_production.dta", replace
		

recode crop_code (101 102 103=100) //lumping rice
gen cname=""
	forvalues k = 1 (1) $nb_topcrops {
		preserve
		local c : word `k' of $topcrop
		local cn : word `k' of $topcropname
		replace cname = "`cn'" if crop_code==`c'
		di "`cn'"
		keep if crop_code==`c'
		collapse (sum) area* qty* val*, by(hhid)
		gen `cn'_price = val_harv/qty_harvested
		ren qty_* qty_`cn'_*
		ren area_* area_`cn'_*
		ren val_* val_`cn'_*
		gen `cn'=1
		
	
		tempfile `cn'
		save ``cn''
		restore
	}
collapse (sum) area* qty* val*, by(province hhid)
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_farmsize_agland.dta", nogen
foreach cn in $topcropname {
	merge 1:1 hhid using ``cn'', nogen
	recode `cn' (.=0)
	
		gen `cn'_harv_sold_pct = qty_`cn'_sale / qty_`cn'_harvested
	
	gen sold_`cn' = .
	replace sold_`cn' = 1 if qty_`cn'_sale > 0 & qty_`cn'_sale != .
	replace sold_`cn' = 0 if qty_`cn'_sale == 0
	replace sold_`cn' = . if qty_`cn'_harvested == 0 | qty_`cn'_harvested == .

	gen `cn'_area_agland_pct = area_`cn'_planted / farmsize_all_agland
	gen `cn'_area_total_pct = area_`cn'_planted / land_size_total
	gen value_`cn'_prod = val_harv
	
	
	label define binary_`cn' 0 "No" 1 "Yes"
	label values `cn' binary_`cn'
}


		unab vars : qty* val* area* 
	foreach var in `vars'{
		recode `var' (.=0)
	}
	
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}/Cambodia_CAS_2022_livestock_prod.dta", nogen

/* Not in 2022
* merge-in animal disease
preserve
use "${Cambodia_CAS_2022_raw_data}\CAS2022_FINAL.dta", clear
ren holding_id hhid
gen animal_disease = 1 if inrange(s8_q18__7, 1, 3)
recode animal_disease (.=0)
tempfile disease
save `disease'
restore
merge 1:1 hhid using `disease', nogen keep(1 3) keepusing(animal_disease)
recode animal_disease (0=.) if raised_Livestock_Poultry == 0
*/
gen animal_disease=.

/* Not in 2022
*merge-in irrigation
preserve
use "${Cambodia_CAS_2022_raw_data}\S4_CROP.dta", clear
ren holding_id hhid
ren s4_q05 irrigation
recode irrigation (2=0)
label define binary3 0 "No" 1 "Yes"
la var irrigation "Was this crop irrigated during 1 July 2020 through 30 June 2021?" //correction: aligning .dta file var label with questionnaire
label values irrigation binary3
collapse (sum) irrigation, by(hhid)
replace irrigation = 1 if irrigation >= 1
tempfile irrigation
save `irrigation'
restore
merge m:1 hhid using `irrigation', keep (1 3) nogen
recode irrigation .=0 if ag_hh == 1
*/
gen irrigation=.

*merge-in adverse weather events
preserve
use "${Cambodia_CAS_2022_raw_data}\S11_SHOCKS.dta", clear
ren holding_id hhid
gen drought=S11_SHOCKS__id==4 
gen flood = S11_SHOCKS__id==2
collapse (max) drought flood, by(hhid)
tempfile shocks
save `shocks'
restore
merge m:1 hhid using `shocks', keep (1 3) nogen keepusing(drought flood)
recode drought flood (.=0)

/* not in 2022?
*merge-in extension training
preserve
use "${Cambodia_CAS_2022_raw_data}\S14_HHROSTER.dta", clear
drop if holding_id == ""
rename holding_id hhid
rename s9_q08 ag_extension_training
recode ag_extension_training (2=0) (.=0) 
collapse (max) ag_extension_training, by(hhid)
tempfile main
save `main'
restore
merge 1:1 hhid using `main', keep(1 3) nogen keepusing(ag_extension_training)
*/
gen ag_extension_training=.

*merge-in household family labor
preserve 
use "${Cambodia_CAS_2022_raw_data}\S14_HHROSTER.dta", clear
drop if holding_id == ""
ren holding_id hhid
gen family_hours = S15_Q01_month * S15_Q01_day * S15_Q01_hour
gen family_full_days = family_hours / 8 //AT: I'm not sure the 8 hour day is standard here (6 is common in the African tropics), but I couldn't find any sources specific to Cambodia.
gen family_work_days = S15_Q01_month * S15_Q01_day
collapse (sum) family_hours family_full_days family_work_days, by(hhid)
tempfile hh_labor
save `hh_labor'
restore
merge 1:1 hhid using `hh_labor', nogen
merge 1:1 hhid using "${Cambodia_CAS_2022_created_data}\Cambodia_CAS_2022_hhsize.dta", nogen

*label new variables
la var irrigation "Did the household use irrigation? 1 = Yes, 0 = No"
la var drought "Did the household experience drought? 1 = Yes, 0 = No"
la var flood "Did the household experience flooding? 1 = Yes, 0 = No"
la var animal_area "Over what land area (Ha) did the household raise livestock or poultry?"
la var animal_ded_area "Did the household dedicate space to animal husbandry? 1 = Yes, 0 = No"
la var fhh "Household head is female"
la var ag_comm "Household has membership within a formal agricultural community"
la var ag_assoc "Household has membership within an informal agricultural association"
la var homelot_area "Household land that contains the homelot (hectares)"
la var ag_comm_assoc "Household has membership within a formal or informal agricultural organization"
la var parcel_area "Holding land that is not directly on the homelot (hectares)"
la var animal_area_rate "What share of the holding's land was used to raise livestock or poultry?"
la var holding_area "The sum of all lands owned or operated by the holding (hectares)"
la var animal_disease "Household experienced livestock or poultry disease"
la var ag_extension_training "A household member has received formal or informal vocational training on agriculture"
la var family_hours "How many hours of labor were provided by holding family members annually?"
la var family_full_days "How many full work days (8 hours) were provided by family members annually?"
la var family_work_days "How many cumulative days were worked by family members annually?"
foreach x in rice cashew {
	la var area_`x'_planted "Over what land area (hectares) did the household plant `x'?"
	la var qty_`x'_own_use "How much `x' (kg) did the household harvest for its own use?"
	//la var qty_`x'_lost "How much `x' (kg) harvested by the household was lost?"
	//la var qty_`x'_processed "How much `x' (kg) harvested by the household harvest was processed?"
	la var `x' "Did the household grow `x' on homelot or parcels? 1 = Yes, 0 = No"
	la var qty_`x'_harvested "How much `x' (kg) did the household harvest?"
	la var area_`x'_harvested "Over what land area (Ha) did the household harvest `x'?"
	la var sold_`x' "If the household harvested `x', did they sell any `x'?"
	la var `x'_harv_sold_pct "What share of the `x' harvest was sold?"
	la var `x'_area_agland_pct "On what share of land dedicated to agricultural activities did the holding grow `x'?"
	la var `x'_area_total_pct "On what share of holding land did the holding grow `x'?"
	la var `x'_price "What price (riel/kg) was the household paid for `x'?"
	//la var `x'_price_impt "Is the value for `x'_price imputed from province or country median sale prices due to non-sales?"
	la var value_`x'_prod "What is the value of the household's `x production?"
	foreach i in sale /*gift pay feed seed*/ {
		la var qty_`x'_`i' "How much `x' (kg) did the household harvest for `i'?"
	}
}


* save final file to appropriate locations
save "${Cambodia_CAS_2022_final_data}\Cambodia_CAS_2022_household_variables.dta", replace
//save "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_poultry_livestock.dta", replace //legacy naming - keeping to ensure compatibility with RShiny


* export csv and dta to save folder, RShiny
preserve
cd "$Cambodia_CAS_save_folder"
label drop _all
//export delimited Cambodia_CAS_2022_poultry_livestock.csv, replace
//export delimited Cambodia_CAS_2022_household_variables.csv, replace

use "${Cambodia_CAS_2022_final_data}\Cambodia_CAS_2022_household_variables.dta", clear
keep hhid province zone *_Chickens *_Ducks
save "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_poultry.dta", replace
label drop _all
export delimited Cambodia_CAS_2022_poultry.csv, replace

use "${Cambodia_CAS_2022_final_data}\Cambodia_CAS_2022_household_variables.dta", clear
keep hhid province zone *_Buffalo *_Cattle *_Pigs
save "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_livestock.dta", replace
label drop _all
export delimited Cambodia_CAS_2022_livestock.csv, replace

use "${Cambodia_CAS_2022_final_data}\Cambodia_CAS_2022_household_variables.dta", clear
keep hhid province zone *_rice_* rice *cashew*
save "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_crops.dta", replace
label drop _all
export delimited Cambodia_CAS_2022_crops.csv, replace

use "${Cambodia_CAS_2022_final_data}\Cambodia_CAS_2022_household_variables.dta", clear
drop weight *_Chickens *_Ducks *_Buffalo *_Cattle *_Pigs qty_rice_* area_rice_*
save "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_hh_vars.dta", replace
label drop _all
export delimited Cambodia_CAS_2022_hh_vars.csv, replace

use "${Cambodia_CAS_2022_final_data}\Cambodia_CAS_2022_household_variables.dta", clear
keep hhid province zone weight
save "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_weights.dta", replace
label drop _all
export delimited Cambodia_CAS_2022_weights.csv, replace
restore

use "${Cambodia_CAS_2022_final_data}\Cambodia_CAS_2022_household_variables.dta", clear
keep hhid fhh ag_comm irrigation drought flood animal_ded_area rice
save "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_groups.dta", replace
label drop _all
export delimited using "${Cambodia_CAS_save_folder}\Cambodia_CAS_2022_groups.csv", replace


*create indicator list summary for export to Excel
/*
preserve
describe, replace clear
ren position indicatorCategory
tostring indicatorCategory, replace
replace indicatorCategory = "Poultry" if regexm(name, "Chickens") | regexm(name, "Ducks")
replace indicatorCategory = "Livestock" if regexm(name, "Buffalo") | regexm(name, "Cattle") | regexm(name, "Pigs")
ren name shortName
ren varlab Long_Name
drop type isnumeric format vallab
export excel using "indicators_list_ex_export_2021", cell(A1) firstrow(variables) replace
restore
*/
