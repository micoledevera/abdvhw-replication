# Processing MCVL data

## Recommended folder structure

The code was written with the following folder structure in mind:
- **do**: contains all the do files that are included in this repository
- **out**: folder that will store the outputs needed for "part1_statistics" and "part2_income_risk"
- **raw**: folder that will house the raw files and "bounds.dta"
  - subfolders mcvl_2005, ..., mcvl_2018 need to be created to store the raw data files of the different MCVL versions
- **temp**: folder that will store temporary files produced during the course of processing the data


## How to use the codes

- The MCVL data files are either .txt or .trs files. Place the data files in separate folders by version – that is, mcvl_20** will contain the 20** MCVL data files. In general, each version of the MCVL (con datos fiscales) will include 1 file including information on individuals, 3-4 files that includes information on affiliations, 13 files for the social security contributions, 1 file for information from the census (Padrón), 1 file on pensions, and 1 file on the fiscal data. There may be other files included but these are the main ones needed in our analysis.
- Once you have the correct folder structure (described above) and the raw data files, then running 00_Main.do should be enough to produce the datasets that are inputs to “part1_statistics” and “part2_income_risk”. 
- Note that in order for 00_Main.do to work, you would need to change lines 10-16 to reflect the paths to the appropriate folders.
