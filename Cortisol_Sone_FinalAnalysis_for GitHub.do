//New Cortisol/Cortisone Analysis
use "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_elsa_cortisol_data_eul.dta"
use "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_elsa_data_v2.dta"
use "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_elsa_nurse_data_v2.dta"
use "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_ifs_derived_variables.dta"
use "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_financial_derived_variables.dta"
merge 1:1 idauniq using "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_elsa_data_v2.dta"
drop _merge
merge 1:1 idauniq using "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_elsa_nurse_data_v2.dta"
drop _merge
merge 1:1 idauniq using "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_ifs_derived_variables.dta"
drop _merge
merge 1:1 idauniq using "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_financial_derived_variables.dta"
drop _merge
merge 1:1 idauniq using "/Users/georgiachatzi/Desktop/ELSA Study/UKDA-5050-stata/stata/stata13_se/wave_6_elsa_cortisol_data_eul.dta"
drop _merge
save "/Users/georgiachatzi/Desktop/Cortisol Paper/Analysis/Wave_6_final_final"


set seed 1234 
//Only core members
keep if samptyp==1

//Regression models - Scenarios
//Create a response model for Inverse Probability Weighting 
svyset [pweight=w6xwgt], strata(GOR)
svy:logistic biomarker i.agecat#i.indsex i.fqethnr i.educ i.class i.GOR2 i.volwork i.physact i.date i.hedimbp i.hedibos i.economicact i.smoke 
predict pr
gen pm=1/pr
gen bioweight=w6xwgt*pm

//Complete case analysis for cortisol
//Education
regress lncortisolc i.educ i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase
//Weighted analysis
svyset [pweight=bioweight], strata(GOR)
svy: regress lncortisolc i.educ i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

//Wealth tertiles
regress lncortisolc i.wealth i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

svyset [pweight=bioweight], strata(GOR)
svy: regress lncortisolc i.wealth i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

//Social class
regress lncortisolc i.class i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

svyset [pweight=bioweight], strata(GOR)
svy: regress lncortisolc i.class i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

//Complete case analysis for cortisone
regress lncortisonec i.educ i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase
//Weighted analysis
svyset [pweight=bioweight], strata(GOR)
svy: regress lncortisonec i.educ i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

//Wealth tertiles
regress lncortisonec i.wealth i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

svyset [pweight=bioweight], strata(GOR)
svy: regress lncortisonec i.wealth i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

//Social class
regress lncortisonec i.class i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

svyset [pweight=bioweight], strata(GOR)
svy: regress lncortisonec i.class i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

//Multiple imputation 
//Cortisol/cortisone - multiple imputation
gen w6xwgt2=w6xwgt
mi set mlong
mi register imputed lncortisolc lncortisonec w6xwgt2 educ wealth class agecat indsex GOR2 marital fqethnr physact futype volwork treatment haircol hedimbp hedibos vismon smoke phase bmi NumMeds4 economicact date
mi register regular w6xwgt 
mi impute chained (regress) lncortisolc lncortisonec w6xwgt2 date (mlogit) marital GOR2 futype haircol vismon smoke (ologit) educ wealth class agecat physact economicact bmi NumMeds4 (logit) treatment hedimbp hedibos indsex fqethnr volwork phase, add (5)rseed (1234) force augment

mi svyset [pweight=w6xwgt], strata(GOR)
mi estimate:svy :regress lncortisolc i.educ i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

mi estimate:svy :regress lncortisolc i.wealth i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

mi estimate:svy :regress lncortisolc i.class i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase


mi estimate:svy :regress lncortisonec i.educ i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

mi estimate:svy :regress lncortisonec i.wealth i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase

mi estimate:svy :regress lncortisonec i.class i.agecat##i.indsex i.fqethnr i.marital i.treatment i.haircol i.vismon i.phase






