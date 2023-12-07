/*
program:    		01_main.do
project:    		ENTRA SCIP harmonization
author:     		Daniel Degen
date:       		21 Nov 2023 (first version in 2021)
task:       		Prepare and harmonize data from tow surveys ENTRA SCIP to get a comparable sample to analyse differences in the effect of the pandemic on integration outcomes
folder structure: 
			.
			├── input_data
			│   ├── entra-long-v1.0.dta [MAKE SURE THE DATA IS PLACED IN THIS FOLDER]
			│   ├── GER_w1_15-03-19.dta [MAKE SURE THE DATA IS PLACED IN THIS FOLDER]
			│   └── GER_w2_15-03-19.dta [MAKE SURE THE DATA IS PLACED IN THIS FOLDER]
			├── harmonized_data
			│   └── entra-scip-harmonize.dta [WILL BE CREATED IN THIS FILE]
			├── 01_main.do
			├── 02_prep_scip.do
			├── 03_prep_entra.do
			├── 04_harmonize.do
			├── 05_finalize.do
			└── entra_scip_harmonization.log

			2 directories, 3 data files, 5 do-files

			info: for future replication you would need the folder structure, the data in the folder "input_data", and the do-files in the main directory. 
			
			
			Information about the datasets for replication:
			
			ENTRA
			Info: ENTRA version 1.0 (2022-07-29)
			Filename: entra-long-v1.0.dta
			
			SCIP W1
			Filename: GER_w1_15-03-19.dta
			
			SCIP W2
			Filename: GER_w2_15-03-19.dta
*/


*Task 0: setup
clear all
macro drop all


global WD "/home/daniel/Dokumente/University/Datasets/20231121_ENTRA_SCIP"			// define working directory
global INPUT "${WD}/input_data"									// define the input folder (root/input_data); this folder contains the SCIP and ENTRA datasets
global OUTPUT "${WD}/harmonized_data"								// define the output folder (root/output_data); this folder contains the final harmonized dataset

cd ${WD}											// change working directory (= root)
capture mkdir ${OUTPUT}									// create output directory if it does not exist



capture log close
log using "entra_scip_harmonization.log", replace


version 17.0
clear all
set linesize 120
set more off





*Integration course SCIP: IGRCRSE_GER	
*Integration course ENTRA: lgerimprhow1
*Language course ENTRA: lgerimprhow2 and lgerimprc

*Migration motive: 
*reas_economic 
*reas_education 
*reas_family 
*reas_political 

*Task 1: prepare SCIP data
use "${INPUT}/GER_w1_15-03-19.dta" ,clear
append using "${INPUT}/GER_w2_15-03-19.dta"
do "${WD}/02_prep_scip.do"							// prepare SCIP dataset
tempfile 01_scip_prepared
save `01_scip_prepared'
clear 


*Task 2: prepare ENTRA data
use "${INPUT}/entra-long-v1.0.dta", clear					// load dataset
do "${WD}/03_prep_entra.do"							// prepare ENTRA dataset
tempfile 02_entra_prepared
save `02_entra_prepared'
clear 


*Task 3: merge SCIP and ENTRA data
use `01_scip_prepared'								// load prepared SCIP dataset
append using `02_entra_prepared' 						// append prepared ENTRA dataset
tempfile 03_entra_scip_raw
save `03_entra_scip_raw'
clear


*Task 4: harmonize data
use `03_entra_scip_raw'								// load the raw (unharmonized SCIP and ENTRA data)
do "${WD}/04_harmonize.do"							// harmonize the data
tempfile 04_entra_scip_harmonized
save `04_entra_scip_harmonized'
clear



*Task 5: Define final dataset (make samples comparable)
use `04_entra_scip_harmonized'							// load the raw (unharmonized SCIP and ENTRA data)
do "${WD}/05_finalize.do"							// harmonize the data
save "${OUTPUT}/entra-scip-final_sample.dta", replace				// save the harmonized (final dataset)


* key variables:
* language skills
* social contacts
* labor market
* political interest
* education, age, sex, origin, time in germany, time between panel waves, expectation to stay in germany, reason to migrate

capture log close

