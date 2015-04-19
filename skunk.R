skunk <- function(){

#----------------------DESCRIPTION------------------------------------------
#
#Read in the subject id's, the corresponding activities, and the corresponding
#measurements and store as data frames.
#Assign the column names: "subjectId" for the subject/person (value 1-30),
#"activityNumber" (value 1-6 for WALKING, WALKING_UPSTAIRS,...,LAYING),
#and the variable names in features.txt for the measurement columns.
#Then select only the measurements that
#look like <measurement name>-mean()-<other stuff> or
#<measurement name>-std()-<other stuff> to reduce the number
#of columns.  Do this for all the test data, then repeat for the training data.
#Combine the test and training data.
#------------------------------------------------------------------------------
library(reshape)
library(reshape2)

#
# Read in the test data and any associated files, save as dataframe and
# assign column name either manually or linking with the features.txt file.
#
test_subject_table <- read.table("./test/subject_test.txt")
subject_df <- as.data.frame.matrix(test_subject_table)
names(subject_df)<-c("subject")
activity_table <- read.table("./test/y_test.txt")
activity_df <- as.data.frame.matrix(activity_table)
names(activity_df)<- c("activity")
test_measure_table <- read.table("./test/X_test.txt")
test_measure_df <- as.data.frame.matrix(test_measure_table)
test_vars <- read.csv("./features.txt", sep=" ", header=FALSE)
names(test_measure_df) <- test_vars[,2]

#Repeat for the train data
train_subject_table <- read.table("./train/subject_train.txt")
tr_subject_df <- as.data.frame.matrix(train_subject_table)
names(tr_subject_df)<-c("subject")
tr_activity_table <- read.table("./train/y_train.txt")
tr_activity_df <- as.data.frame.matrix(tr_activity_table)
names(tr_activity_df) <- c("activity")
train_measure_table <- read.table("./train/X_train.txt")
train_measure_df <- as.data.frame.matrix(train_measure_table)
names(train_measure_df) <- test_vars[,2]
train_vars <- test_vars



#Retrieve only the measurements with mean() or std()
#index <- grep("mean[(]+[)]+|std[(]+[)]+", test_vars[,2])
index <- grep("fBodyAccJerk-std[(]+|fBodyAccJerk-mean[(]+",test_vars[,2])
test <- cbind(subject_df,activity_df,test_measure_df[,index])
train <- cbind(tr_subject_df, tr_activity_df, train_measure_df[,index])

#Combine the columns to create the test data frame
#test <- cbind(subject_df,activity_df,test_measure_df)
test_merged <- as.data.frame(test)
train_merged <- as.data.frame(train)
total <- rbind(test_merged, train_merged)
#print(cat("number of rows in test_merged:", nrow(test_merged)))
#print(cat("number of rows in train_merged: ", nrow(train_merged)))
#print(cat("number of rows in total: ", nrow(total)))
#names(total) <- c("subject", "activity", test_vars[,2])
#print(head(total,2))
#print(tail(total,2))


#Clean up the column names corresponding to the mean and std measurements so
#they are:
# 1) Lower case
# 2) Descriptive
# 3) Are not duplicates
# 4) Have no underscores or whitespaces
#there are 32 types of measurements of format:
# tBodyAcc-XYZ, tGravityAcc-XYZ, etc.
#Replace Acc with acceleration, Gyro with gyroscope, Mag with magnitude, etc.
#colnames <- tolower(test_vars[,index])
clean<- tolower(names(total))
#clean<-gsub("-","",clean)
clean<-gsub("\\(","",clean)
clean<-gsub("\\)","",clean)
clean<-gsub("acc","acceleration",clean)
clean<-gsub("mag","magnitude",clean)
clean<-gsub("gyro","gyroscopic",clean)
clean<-gsub("std","standarddeviation",clean)
#print((clean))
names(total)<-c(clean)
measurements<-c(clean[3:length(clean)])
#print(measurements)

#Get the average for each measurement for every subject and activity.
#i.e. for any given subject, provide the average value for every measurement
#for all activities the subject was doing.
#Do this by using melt to make each row a unique subject-activity
#(i.e. id-variable) combination.
melteddata<-  melt(total,id=c("subject","activity"))
#print(melteddata)
#apply cast to the melted data to calculate the average (mean) for each
#mean and std measurement.
#usage: cast(dataframe, formula, function)
#avg<- cast(mdata, id ~ variable, mean)
md <- dcast(melteddata, subject + activity ~ variable, mean)
#print(head(md,3))
print(tail(md,3))
tidy<- melt(md,id=c("subject","activity"))
print(tail(tidy,3))

#ToDo rename each measurement by appending with "average"

}
