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
    label_nums <- read.table(label_nums_file, col.names = "activity")
    
    # add a subject column by loading this data from the subjects file and binding the only column
    subjects_data <- read.table(subjects_file, col.names = "subject")
    
    # bind the following columns: subject ID, activity label ID and all sensor data variables with
    # mean or standard deviation values
    res_data <- bind_cols(subjects_data,
                          label_nums,
                          select(sensordata, sort(c(cols_w_mean, cols_w_sd))))

    # return the result data
    res_data
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
                              stringsAsFactors = T,
                              col.names = c("num", "activity_name"))
# transform the activity string to lowercase
activity_labels <- transform(activity_labels, activity_name = tolower(activity_name))

# now load the test and train data
test_data <- load_sensor_dataset("test")
train_data <- load_sensor_dataset("train")

# combine both by appending the rows (they both have the same layout)
complete_data <- bind_rows(test_data, train_data)

# set the proper activity labels instead of IDs by joining with the "activity_labels" table
complete_data$activity <- as.factor(inner_join(complete_data, activity_labels, by = c("activity" = "num"))$activity_name)


# group the complete data by activity and subject and summarize each variable by calculate the
# average per group;
# finally sort the output by subject and activity
grouped_data_avgs <- complete_data %>%
                     group_by(subject, activity) %>% 
                     summarise_each(funs(mean)) %>%
                     arrange(subject, activity)

# save the complete tidy dataset as CSV
write.table(complete_data, file = "complete_data.txt", row.names = F)

# save the grouped averages summary dataset as CSV
write.table(grouped_data_avgs, file = "grouped_averages.txt", row.names = F)


# df_subset %>% 
#     group_by(subjectID, activityID) %>% 
#     summarise_each(funs(mean)) -> df_mean_signals