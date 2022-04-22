# Codes to produce common statistics in Global Repository of Income Dynamics

The codes in this section are based on the codes developed by [Sergio Salgado](https://sergiosalgado.net/) and [Serdar Ozkan](https://sites.google.com/site/serdarozkan/home). The guidelines they provided with the codes are included here.

A few modification to the code were made to accommodate specificities in the Spanish dataset:
* **4_Volatility.do**: Replace all 99.9 to 99.5— compute percentile 99.5 instead of 99.9 (due to sample size)
* **5_Mobility.do**: Replace all 99.9 to 99.5— compute percentile 99.5 instead of 99.9 (due to sample size)
* **7_Paper_Figs.do**:
  * Add figquan2: similar to figquan, only add top 0.5%
  * Add figext: distribution of income changes over business cycle
  *  Add figext2: produce the “log earnings changes between 2006 and 2014 against initial earnings” (Fig S-A5)
* **8_part1_paper_table.do**: Generate summary statistics tables in paper
* **myprogs.do**: add output 0.995 in function bymyPCT
