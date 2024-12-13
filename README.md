## Prerequisites
* Download the raw data from [https://microdata.nis.gov.kh/index.php/catalog/38](https://microdata.nis.gov.kh/index.php/catalog/38) and [https://microdata.nis.gov.kh/index.php/catalog/44](https://microdata.nis.gov.kh/index.php/catalog/44)
* Extract the files to the "raw_data" folder


## Table of contents
### Globals
* This section sets global variables for use later in the script, including:
  * Exchange rate and currency inflation conversion to USD
  * Winsorization Thresholds
    * We correct outliers by Winsorization - setting values above the 99th and/or below the 1st percentiles to the value of the 99th or 1st percentile. The thresholds can be adjusted here or removed by setting them to 0 and 100
  * Rescaling Survey Weights
    * Defines new population-based survey weight based on population change from date of data collection
  
### Household IDs
- **Description:** This section produces a dataset with Holding_ID (hhid) as a unique identifier, along with a single location identifier (province)
- **Output:** hhids.dta
- **Coding Status:** ![Complete](https://placehold.co/15x15/c5f015/c5f015.png) `Complete`
- **Known Issues:** None

### Weights
- **Description:** This section produces a dataset with Holding_ID (hhid) as a unique identifier and a weight variable defined in the source dataset
- **Output:** weights.dta
- **Coding Status:** ![Complete](https://placehold.co/15x15/c5f015/c5f015.png) `Complete`

### Individual IDs
- **Description:** This section produces a dataset with Holding_ID (hhid) and individual roster IDs as a unique identifier and contains variables that indicate an individual's gender, age, and status as female head of household
- **Output:** person_ids.dta

### Household Size
- **Description:** This section produces a dataset with Holding_ID (hhid) as a unique identifier and variables containing number of household members and whether the household head is female
- **Output:** hhsize.dta

### COVID Impact
- **Description:** This section produces a dataset with Holding_ID (hhid) as a unique identifier and a variable describing whether or not the household experienced a shock from the COVID-19 pandemic. 
- **Output:** COVID_impact.dta
- **Coding Status:** ![Complete](https://placehold.co/15x15/c5f015/c5f015.png) `Complete`

### Association Membership
- **Description:** This section produces a dataset with Holding_ID (hhid) as a unique identifier and variables describing the household's involvement with formal and informal agricultural associations or communities. 
- **Output:** association_membership.dta
- **Coding Status:** ![Complete](https://placehold.co/15x15/c5f015/c5f015.png) `Complete`

### Agricultural Households
- **Description:** This section produces a dataset with Holding_ID (hhid) as a unique identifier and variables describing the household's land use decisions on the homelot and parcel(s), as applicable. 
- **Output:** agricultural_activities.dta

### Household Decision Makers
- **Description:** This section produces a dataset with Holding_ID (hhid) as a unique identifier and variables that describe the education and gender of person or people who make household management decisions - 1: male, 2: female, or 3: mixed male and female
- **Output:** hh_decision_makers.dta

### Livestock
- **Description:** This section produces multiple datasets. The primary dataset produced by this section has Holding_ID (hhid) as a unique identifier and 46 variables for each form of livestock [cattle, buffalo, pigs] describing the household's agricultural activities related to raising that livestock.
- **Main Output:** livestock.dta
- **Known Issues:**
  - The given herd growth/loss factors [S4_Q10 in 2020 and s6_q14 in 2021] may not be comprehensive. This creates an issue when constructing certain intermediate variables, e.g. num_livestock_start, that form the denominator of constructed ratios or rate indicators, e.g. livestock_growth_pct.
  - Significant outliers in the given livestock sale price [riel/head, S4_Q10e s6_q14g] were handled by calculating median absolute deviation statistics and replacing observations with provincial or national medians.
  - Missing values for livestock sale price are replaced by constructed provincial or national medians.
  - The survey does not provide a market or implicit unit price for slaughtered livestock meat. We assume equivalence to the price of live livestock sales.

### Poultry
- **Description:** This section produces multiple datasets. The primary dataset produced by this section has Holding_ID (hhid) as a unique identifier and 46 variables for each form of poultry [chicken, duck, goose (2020 only)] describing the household's agricultural activities related to raising that poultry.
- **Main Output:** poultry.dta
- **Known Issues:**
  - The given flock growth/loss factors [S4_Q15 in 2020 and s6_q54 in 2021] may not be comprehensive. This creates an issue when constructing certain intermediate variables, e.g. num_poultry_start, that form the denominator of constructed ratios or rate indicators, e.g. poultry_growth_pct.
  - Missing values for egg_price are replaced by constructed provincial or national medians.
  - Significant outliers in the given poultry sale price [riel/kg, POULTRYSALE poultrysale] were handled by calculating median absolute deviation statistics and replacing observations with provincial or national medians.
  - Missing values for poultry sale price are replaced by constructed provincial or national medians.

### Consolidating Poultry and Livestock, Adding Household-Specific Variables
- **Description:** This section consolidates intermediate files and adds variables related to holding size (area), rice production, cashew production, animal disease, irrigation, adverse weather events, extension training, and household family labor.
- **Main Output:** household_variables.dta











