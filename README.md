# Replication files for "Income Risk Inequality: Evidence from Spanish Administrative Records" by Arellano, Bonhomme, De Vera, Hospido, and Wei

29/03/2022: This repository currently includes the codes to process the raw social security data, and obtain results for the first part of the paper where we compute various statistics on income dynamics common across all the countries in the [Global Repository of Income Dynamics (GRID)](https://mebdi.org/global-repository-income-dynamics). Soon, we will update this repository to include the codes to obtain results relating to the inequality of income risk.

## Muestra Continua de Vidas Laborales

This paper uses the 2005-2018 versions of the Muestra Continua de Vidas Laborales con Datos Fiscales (MCVL with fiscal data). Due to data security reasons, we cannot share the data files. However, researchers can apply to access the data for scientific purposes. Details for this application process can be found using [this link (in Spanish)](https://www.seg-social.es/wps/portal/wss/internet/EstadisticasPresupuestosEstudios/Estadisticas/EST211).

## Overview of Replication Package

There are three main parts to the replication package:
- mcvl_data_processing
  - do
    - **00_Main.do**: runs all steps 
    - **01_Past_Info.do**: do file to combine raw files to get base panels of individuals and firms
    - **02_MergeMCVL_05_12.do** and **02_MergeMCVL_13_latest.do**: do files to merge various components of MCVL
    - **03_MonthlyVars.do**: do file to compute some monthly data
    - **04_ReshapeData.do**: do file to reshape contribution data from wide to long
    - **05_OtherVars.do**: do file to create additional variables pertaining to the census, job types and contract types
    - **06_01_FixIDs.do**, **06_02_DatosFiscales_Unemp.do**, **06_03_Pensions.do**, and **06_04_Count_Days.do**: do files to generate variables (correct for firm ID changes, sum total income and unemployment benefits from fiscal data, identify individuals receiving a pension, count days worked)
    - **07_01_Prep_Data_RemoveAllAfter2_NotClustering.do**, …, **07_05_Prep_Data_NoConstraint.do**: do files to generate the final data sets that are inputs to part1_statistics and part2_income_risk
    - **mainjob_vars.do**: individual do file to identify the main job of an individual in the year and create variables pertaining to that main job
    - **mcvl_reading_2005.do**, …, **mcvl_reading_2018.do**: individual do files to read in raw data and name variables, called by 00_Main.do
  - raw 
    - **bounds.dta**: information needed to identify top-coded and bottom-coded data, collected from annual Boletín Oficial del Estado
- part1_statistics
  - **0_Initialize.do**: Define variable names, time span, and vectors used throughout the codes 
  - **1_Gen_Base_Sample.do**: Rename the variables, select basic sample, create new variables, generate and save the dataset master_sample.dta used in the rest of the do files 
  - **2_DescriptiveStats.do**: Generate descriptive statistics 
  - **3_Inequality.do**: Generate statistics for different income measures (e.g., log income, residualized log income, etc.) 
  - **4_Volatility.do**: Generate statistics for different income growth measures 
  - **5_Mobility.do**: Generate statistics for income ranking
  - **6_Insheeting_dataset.do**: Generate CSV files 
  - **7_Paper_Figs.do**: Generate figures 
  - **8_Part1_paper_table.do**: Generate summary statistics tables (F2-F12)
- part2_income_risk: TO BE UPDATED
