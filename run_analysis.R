##############################################################################
#
# FILE
#   run_analysis.R
#
# OVERVIEW
#   Using data collected from the accelerometers from the Samsung Galaxy S 
#   smartphone, work with the data and make a clean data set, outputting the
#   resulting tidy data to a file named "tidy_data.txt".
#   See README.md for details.
#

library(dplyr)



##############################################################################
# STEP 1 
##############################################################################

# read training data
trainingSubjects <- read.table(Users/addison/Desktop/UCIHARDataset/train, "train", "subject_train.txt"))
trainingValues <- read.table(Users/addison/Desktop/UCIHARDataset/train, "train", "X_train.txt"))
trainingActivity <- read.table(Users/addison/Desktop/UCIHARDataset/train, "train", "y_train.txt"))

# read test data
testSubjects <- read.table(Users/addison/Desktop/UCIHARDataset/test, "test", "subject_test.txt"))
testValues <- read.table(Users/addison/Desktop/UCIHARDataset/test, "test", "X_test.txt"))
testActivity <- read.table(Users/addison/Desktop/UCIHARDataset/test, "test", "y_test.txt"))

# read features, don't convert text labels to factors
features <- read.table(file.path(Users/addison/Desktop/UCIHARDataset, "features.txt"), as.is = TRUE)
  ## note: feature names (in features[, 2]) are not unique
  ##       e.g. fBodyAcc-bandsEnergy()-1,8

# read activity labels
activities <- read.table(Users/addison/Desktop/UCIHARDataset, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")


##############################################################################
# Step 2 - creating one data set
##############################################################################

# concatenate individual data tables to make single data table
humanActivity <- rbind(
  cbind(trainingSubjects, trainingValues, trainingActivity),
  cbind(testSubjects, testValues, testActivity)
)

# remove individual data tables to save memory
rm(trainingSubjects, trainingValues, trainingActivity, 
   testSubjects, testValues, testActivity)

# assign column names
colnames(humanActivity) <- c("subject", features[, 2], "activity")


##############################################################################
# Step 3 - Extract o mean and standard deviation
##############################################################################

# determine columns of data set to keep based on column name...
columnsToKeep <- grepl("subject|activity|mean|std", colnames(humanActivity))

# ... and keep data in these columns only
humanActivity <- humanActivity[, columnsToKeep]


##############################################################################
# Step 4 - Use activities in data set
##############################################################################

# replace activity values with named factor levels
humanActivity$activity <- factor(humanActivity$activity, 
  levels = activities[, 1], labels = activities[, 2])


##############################################################################
# Step 5 -  label data
##############################################################################

# get column names
humanActivityCols <- colnames(humanActivity)

# remove special characters
humanActivityCols <- gsub("[\\(\\)-]", "", humanActivityCols)

# expand abbreviations and clean up names
humanActivityCols <- gsub("^f", "frequencyDomain", humanActivityCols)
humanActivityCols <- gsub("^t", "timeDomain", humanActivityCols)
humanActivityCols <- gsub("Acc", "Accelerometer", humanActivityCols)
humanActivityCols <- gsub("Gyro", "Gyroscope", humanActivityCols)
humanActivityCols <- gsub("Mag", "Magnitude", humanActivityCols)
humanActivityCols <- gsub("Freq", "Frequency", humanActivityCols)
humanActivityCols <- gsub("mean", "Mean", humanActivityCols)
humanActivityCols <- gsub("std", "StandardDeviation", humanActivityCols)

# correct typo
humanActivityCols <- gsub("BodyBody", "Body", humanActivityCols)

# use new labels as column names
colnames(humanActivity) <- humanActivityCols


##############################################################################
# Step 6 - Create a new tidy set 
##############################################################################

# group by subject and activity and summarise using mean
humanActivityMeans <- humanActivity %>% 
  group_by(subject, activity) %>%
  summarise_each(funs(mean))

# output to file "tidy_data.txt"
write.table(humanActivityMeans, "tidy_data.txt", row.names = FALSE, 
            quote = FALSE)
