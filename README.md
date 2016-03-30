# Getting and Cleaning Data Course Project

This repository contains a script `run_analysis.R` to create a tidy data set from test and train data of the [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

## Files of the repository

* `CodeBook.md` - Description of variables in the created data sets and the steps that were performed to create them from the original data
* `complete_data.csv` - Tidied up, combined data set from the test and train data of the original data set
* `grouped_averages.csv` - Averaged values of the variables in the above data set per activity-subject group
* `run_analysis.R` - R script to create the above to CSV-files from the original data with the steps explained in `CodeBook.md`

## Requirements

This script requires the `dplyr` package. Futhermore, the original data must be unzipped and reside in a subfolder of the R script and must be named "datasets".

## Explanation of the R script

**Note:** Please also have a look at the R script itself, the source code is documented.

The script does the following:

1. Load the feature names which will be used as variable names later
2. Identify columns with mean() and std() in their name as variables with mean values and std.dev. values
3. Create clean feature names to use them as column names: lowercase and words separated by underscore
4. Load the activity labels with label number -> activity string mapping and transform the activity string to lowercase
5. Load the test and train data by using the `load_sensor_dataset()` function which does the following:
  1. Load the sensor data and set the column names to the clean feature names
  2. Load the activity label numbers from a separate file
  3. Load the subject IDs from the subjects file
  4. Bind the following columns to form the whole data set: subject ID, activity label ID and all sensor data variables with mean or standard deviation values (those that were identified in step 2)
6. Form the complete data by binding together the test and train data
7. Set the proper activity labels instead of IDs by joining with the `activity_labels` table
8. Group the complete data by activity and subject and summarize each variable by calculate the average per group;  finally sort the output by subject and activity
9. Finally save the complete tidy dataset and the grouped averages as TXT files