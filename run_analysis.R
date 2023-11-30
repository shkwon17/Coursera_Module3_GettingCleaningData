## Preparation
# Set the URL for the dataset
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Set the filename for the downloaded file
filename <- "data.zip"

# Download the file
download.file(url, destfile = filename, method = "curl")

# Unzip the downloaded file
unzip(filename)

# List the files in the extracted folder to understand the structure
list.files("UCI HAR Dataset")

# Load necessary packages
# install.packages("data.table")
# install.packages("dplyr")
library(data.table)
library(dplyr)

# Load the data into R

# Load the training data
train_data <- fread("UCI HAR Dataset/train/X_train.txt")
train_labels <- fread("UCI HAR Dataset/train/y_train.txt")
train_subjects <- fread("UCI HAR Dataset/train/subject_train.txt")

# Load the test data
test_data <- fread("UCI HAR Dataset/test/X_test.txt")
test_labels <- fread("UCI HAR Dataset/test/y_test.txt")
test_subjects <- fread("UCI HAR Dataset/test/subject_test.txt")



## Step 1: Merges the training and the test sets to create one data set.
# Merge the training and test datasets for features, labels, and subjects
merged_data <- rbind(train_data, test_data)
merged_labels <- rbind(train_labels, test_labels)
merged_subjects <- rbind(train_subjects, test_subjects)

# Save the merged_data as a CSV file for visual inspection
write.csv(merged_data, file = "merged_data_Step1.csv", row.names = FALSE)



## Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.
# Load the feature names from the file features.txt
features <- fread("UCI HAR Dataset/features.txt", col.names = c("index", "feature"))

# Extract indices of measurements related to mean and standard deviation
mean_std_indices <- grep("mean\\(\\)|std\\(\\)", features$feature)

# Adjust indices to account for subject and activity columns (if present)
mean_std_indices <- c(mean_std_indices, length(merged_data))

# Select only the columns (measurements) related to mean and standard deviation
selected_data <- merged_data[, mean_std_indices, with = FALSE]

# Save the selected_data as a CSV file for visual inspection to ensure the changes
write.csv(selected_data, file = "selected_data_Step2.csv", row.names = FALSE)



## Step 3: Uses descriptive activity names to name the activities in the data set 
# Load activity labels from activity_labels.txt
activity_labels <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_id", "activity_name"))

# Replace activity codes with descriptive activity names
merged_labels$V1 <- factor(merged_labels$V1, levels = activity_labels$activity_id, labels = activity_labels$activity_name)

# Assign descriptive activity names to the dataset
selected_data$activity <- merged_labels$V1

# Save the selected_data as a CSV file for visual inspection to ensure the changes
write.csv(selected_data, file = "selected_data_Step3.csv", row.names = FALSE)



## Step 4: Appropriately labels the data set with descriptive variable names. 
# Load the feature names from the file features.txt
features <- fread("UCI HAR Dataset/features.txt", col.names = c("index", "feature"))

# Extract indices of measurements related to mean and standard deviation
mean_std_indices <- grep("mean\\(\\)|std\\(\\)", features$feature)

# Get the names of the selected columns
selected_feature_names <- features$feature[mean_std_indices]

# Assign descriptive variable names to the dataset columns
names(selected_data)[1:length(mean_std_indices)] <- selected_feature_names

# Save the selected_data as a CSV file for visual inspection to ensure the changes
write.csv(selected_data, file = "selected_data_Step4.csv", row.names = FALSE)



## Task 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# Create a summarized tidy dataset with averages for each activity
summarized_data <- selected_data %>%
  group_by(activity) %>%
  summarize(across(everything(), mean))

# Now, 'summarized_data' contains the average of each variable for each activity
summarized_data

# Save the summarized dataset as a CSV file
write.csv(summarized_data, file = "summarized_data_Step5.csv", row.names = FALSE)

# Save 'summarized_data' containing the tidy dataset
write.table(summarized_data, file = "tidy_dataset.txt", row.names = FALSE)

