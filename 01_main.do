/*
program:    		01_main.do
project:    		ENTRA SCIP harmonization
author:     		Daniel Degen
date:       		25 Mar 2023 (first version in 2021)
task:       		Prepare and harmonize data from tow surveys ENTRA SCIP to get a comparable sample to analyse differences in the effect of the pandemic on integration outcomes
folder structure: (UPDATE!!!!!!)
			.
			├── 01_input_data
			│   ├── entra-long-v1.0.dta
			│   ├── GER_w1_15-03-19.dta
			│   └── GER_w2_15-03-19.dta
			├── 02_intermediate_data
			│   ├── 01_scip_prepared.dta
			│   ├── 02_entra_prepared.dta
			│   └── 03_entra_scip_raw.dta
			├── 03_output_data
			│   └── entra-scip-harmonize.dta
			├── 01_main.do
			├── 02_prep_scip.do
			├── 03_prep_entra.do
			├── 04_harmonize.do
			└── entra_scip_harmonization.log

			3 directories, 12 files

			info: for future replication you would need the folder structure, the data in the folder "01_input_data", and the do-files in the main directory. 

*/


*Task 0: setup
clear all
macro drop all

cd "/home/daniel/Dokumente/University/Datasets/ENTRA_SCIP_update"		// change working directory (= root)

capture log close
log using "entra_scip_harmonization.log", replace


version 17.0
clear all
set linesize 120
set more off


global WD "/home/daniel/Dokumente/University/Datasets/ENTRA_SCIP_update"	// define the working directory (= root)

global INPUT "${WD}/01_input_data"						// define the input folder (root/input_data); this folder contains the SCIP and ENTRA datasets
global INTERMEDIATE "${WD}/02_intermediate_data"				// define a folder for steps between the raw input and the final output (root/intermediate_data); this folder contains the prepared
global OUTPUT "${WD}/03_output_data"						// define the output folder (root/output_data); this folder contains the final harmonized dataset




*Task 1: prepare SCIP data
use "${INPUT}/GER_w1_15-03-19.dta" ,clear
append using "${INPUT}/GER_w2_15-03-19.dta"
do "${WD}/02_prep_scip.do"							// prepare SCIP dataset
save "${INTERMEDIATE}/01_scip_prepared.dta", replace				// save prepared SCIP dataset
clear 


*Task 2: prepare ENTRA data
use "${INPUT}/entra-long-v1.0.dta", clear
do "${WD}/03_prep_entra.do"							// prepare ENTRA dataset
save "${INTERMEDIATE}/02_entra_prepared.dta", replace				// save prepared ENTRA dataset
clear 


*Task 3: merge SCIP and ENTRA data
use "${INTERMEDIATE}/01_scip_prepared.dta", clear				// load prepared SCIP dataset
append using "${INTERMEDIATE}/02_entra_prepared.dta", 				// append prepared ENTRA dataset
save "${INTERMEDIATE}/03_entra_scip_raw.dta", replace				// save the raw (unharmonized SCIP and ENTRA data)
clear


*Task 4: harmonize data
use "${INTERMEDIATE}/03_entra_scip_raw.dta", clear				// load the raw (unharmonized SCIP and ENTRA data)
do "${WD}/04_harmonize.do"							// harmonize the data
save "${INTERMEDIATE}/04_entra-scip-harmonized.dta", replace			// save the harmonized (final dataset)


*Task 5: Define final dataset (make samples comparable)
use "${INTERMEDIATE}/04_entra-scip-harmonized.dta", clear			// load the raw (unharmonized SCIP and ENTRA data)
do "${WD}/05_data_limit.do"							// harmonize the data
save "${OUTPUT}/entra-scip-final_sample.dta", replace				// save the harmonized (final dataset)


* key variables:
* language skills
* social contacts
* labor market
* political interest
* education, age, sex, origin, time in germany, time between panel waves, expectation to stay in germany, reason to migrate

capture log close

