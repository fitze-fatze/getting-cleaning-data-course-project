# Getting and Cleaning Data Course Project

This repository contains a script `run_analysis.R` to create a tidy data set from test and train data of the [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

**For an explanation of how the R script works, please take a look in the R script itself -- the source code is completely documented.**

## Files of the repository

* `CodeBook.md` - Description of variables in the created data sets and the steps that were performed to create them from the original data
* `complete_data.csv` - Tidied up, combined data set from the test and train data of the original data set
* `grouped_averages.csv` - Averaged values of the variables in the above data set per activity-subject group
* `run_analysis.R` - R script to create the above to CSV-files from the original data with the steps explained in `CodeBook.md`

## Requirements

This script requires the `dplyr` package. Futhermore, the original data must be unzipped and reside in a subfolder of the R script and must be named "datasets".