library(dplyr)

# This script loads the "Human Activity Recognition Using Smartphones Data Set" and clean/transforms
# it according to the enclosed Codebook.
# The unzipped original dataset must be available in the "datasets" directory.

# A function for later use to a load either the "test" or the "train" dataset (specified by
# dataset_type argument).
# This function also cleans the column names, adds the "dataset_type", "activity" and "subject"
# columns and only returns the sensor data with mean or standard deviation values.
load_sensor_dataset <- function(dataset_type) {
    # specify the file names via sprintf() -> %s will by substituted by either "test" or "train"
    sensordata_file <- sprintf("dataset/%s/X_%s.txt", dataset_type, dataset_type)
    label_nums_file <- sprintf("dataset/%s/y_%s.txt", dataset_type, dataset_type)
    subjects_file <- sprintf("dataset/%s/subject_%s.txt", dataset_type, dataset_type)
    
    # load the sensor data and set the column names to feature_names_clean
    sensordata <- tbl_df(read.table(sensordata_file, col.names = feature_names_clean))
    
    # load the activity label numbers from a separate file
    label_nums <- read.table(label_nums_file, col.names = "num")
    
    # set the dataset type so that one later can identify from which dataset each row comes from
    sensordata$dataset_type <- dataset_type
    
    # add an activity column by merging the activity label numbers with the numbers in the
    # activity_labels data frame
    sensordata$activity <- merge(label_nums, activity_labels, by.x = "num", by.y = "num")$activity
    
    # add a subject column by loading this data from the subjects file and binding the only column
    sensordata$subject <- read.table(subjects_file)[,1]
    
    # "select_cols" contains column numbers of dataset type column, activity column, subject column,
    # columns with mean values and columns with std.dev. values
    # retains the order of the columns for the original feature data
    ncols <- ncol(sensordata)
    select_cols <- c(ncols - 2, ncols - 1, ncols, sort(c(cols_w_mean, cols_w_sd)))
    
    # now select these columns and return the data
    select(sensordata, select_cols)
}

# load the feature names which will be used as variable names later
feature_names <- read.table("dataset/features.txt", stringsAsFactors = F)[,2]

# identifiy columns with mean() and std() in their name as variables with mean values and std.dev.
# values
cols_w_mean <- grep("mean\\(\\)", feature_names)
cols_w_sd <- grep("std\\(\\)", feature_names)

## create clean feature names: lowercase and words separated by underscore
# substitute parentheses, commata, dots, hyphens by underscore
feature_names_clean <- gsub("[)(,.-]", "_", feature_names)
# add an underscore before each word that begins with an uppercase character
feature_names_clean <- gsub("([A-Z])([a-z]+)", "_\\1\\2", feature_names_clean)
# transform successive underscores to single underscore
feature_names_clean <- gsub("_+", "_", feature_names_clean)
# delete underscores at the end of a feature name
feature_names_clean <- tolower(gsub("_$", "", feature_names_clean))

# load the activity labels with label number -> activity string mapping
activity_labels <- read.table("dataset/activity_labels.txt",
                              stringsAsFactors = F,
                              col.names = c("num", "activity"))
# transform the activity string to lowercase
activity_labels <- transform(activity_labels, activity = tolower(activity))

# now load the test and train data
test_data <- load_sensor_dataset("test")
train_data <- load_sensor_dataset("train")

# combine both by appending the rows (they both have the same layout)
complete_data <- bind_rows(test_data, train_data)

# In the assignment instructions it says one should create a data set with the average values of
# *each* variable (for each activity and each subject)
# I understood this as grouping by activity and subject and then summarizing on the grouped data
# frame by calculating the mean of each variable per group. I definitely did not want to write
# out the names of each of the 60+ variables in the dataset to specify the summarize() arguments,
# so I sought for a way to do it  programmatically. I tried several things out, but the only way
# that worked was by dynamically generating R code in a loop as string and parsing/evaluating it.

# group the complete data by activity and subject
grouped_data <- group_by(complete_data, activity, subject)

# get all variable names for which the average values should be calculated
complete_data_vars <- names(complete_data)
complete_data_vars <- complete_data_vars[4:length(complete_data_vars)]

# Here comes to loop for generating the arguments string for the summarize() function. It creates
# a string like:
# ", t_body_acc_mean_x=mean(t_body_acc_mean_x), t_body_acc_mean_y=mean(t_body_acc_mean_y), etc."
summarize_args_str <- ""
for (v in complete_data_vars) {
    # create the argument string
    arg_str <- sprintf("%s=mean(%s)", v, v)
    # append it to the existing argument string
    summarize_args_str <- paste(summarize_args_str, arg_str, sep = ", ")
}

# create the call to summarize() as string
summarize_call_str <- sprintf("grouped_data_avgs <- summarize(grouped_data%s)", summarize_args_str)

# now parse and evaluate the string as R code
# the result, i.e. the data frame with the variable means per activity and subject will be 
# available in the variable "grouped_data_avgs"
eval(parse(text = summarize_call_str))

# save the complete tidy dataset as CSV
write.csv(complete_data, file = "complete_data.csv", row.names = F)

# save the grouped averages summary dataset as CSV
write.csv(grouped_data_avgs, file = "grouped_averages.csv", row.names = F)