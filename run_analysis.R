#Renaud Eynard
#Getting and Cleaning Data - Peer review exam - Week 4
#install and load package, make sure to check the package box after installation in the packages settings
#Load packages
library(data.table)
library(dplyr)

#Set wd
setwd("/Users/renaudeynard/Desktop/Rstudio-coursera/Module 3 - Getting and cleaning data/Peer_review_project")

#Download data file
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
#unzip data
if (!file.exists("/Users/renaudeynard/Desktop/Rstudio-coursera/Module 3 - Getting and cleaning data/Peer_review_project/UCI HAR Dataset")){
  unzip(destFile)
}
#Include date of dowload
dateDownloaded <- date()

#Start reading files, first precise your wd where you will read the data
setwd("/Users/renaudeynard/Desktop/Rstudio-coursera/Module 3 - Getting and cleaning data/Peer_review_project/UCI HAR Dataset")

#Reading Activity files
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

#Read features files
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

#Read subject files
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

#Read Activity Labels
ActivityLabels <- read.table("./activity_labels.txt", header = F)

#Read Feature Names
FeaturesNames <- read.table("./features.txt", header = F)

#Merge dataframes by features
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

#Renaming colums in ActivityData & ActivityLabels dataframes
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

#Get factor of Activity names
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

#Rename SubjectData columns
names(SubjectData) <- "Subject"
#Rename FeaturesData columns using columns from FeaturesNames
names(FeaturesData) <- FeaturesNames$V2

#Create one dataset with only three variables: SubjectData,  Activity,  FeaturesData
DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

#Create datasets by extracting only the measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

#Rename the columns of the large dataset using more descriptive activity names
names(DataSet)<-gsub("^t", "Time", names(DataSet))
names(DataSet)<-gsub("^f", "Frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

#Create independent tidy data set with the average of each variable for each activity and each subject
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

#Save this tidy dataset
write.table(SecondDataSet, file = "tidydata.txt",row.name=FALSE)