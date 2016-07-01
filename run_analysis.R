## This program loads 3 files for each of the observation types, Test and Train.
## Those files are X_Test, Y_Test, Subject_test, and same for Train
## The three files are cbind'd together to create data with the defining columns
## of Activity type and Subject, so that further calcs can be performed on one table.

## Yet another table is pulled in which holds the field names for the 561 columns.
## Field names are then applied to the Test and Train datasets.

## The two Test and Train tables are then combined via rbind to create a single
## concatenated whole.
##
## Columns are filtered down to only the std() and mean() columns, and then remaining
## columns are given tidy names.
## 
## Finally, a separate dataset, mean_data, is generated from this result, giving the means of
## values in each column, aggregated by Activity_Lbl and Subject, but retaining the original data column names.


## Load tables into R

## function to load table files
get_table_data<- function(incomingFile, working_directory){
    file_dir<- paste(working_directory,incomingFile,sep="")
    read.table(file_dir, header=FALSE)   
}



## Set up working directory prefix, to keep code lines short
working_directory<-"C:/Users/Dwight/Documents/R_Workspace/Cleansing_Data_Class/UCI HAR Dataset/"


## Get the field names from the features.txt file
field_Names1<-read.delim(paste(working_directory,"features.txt",sep=""),sep=" ", header=FALSE)

## turn field_Names1 into a single column vector
field_Names1<-field_Names1[,c(2)]

## Import test data
X_Test<-get_table_data("test/X_test.txt",working_directory)
Y_Test<-get_table_data("test/Y_test.txt",working_directory)
subject_test<-get_table_data("test/subject_test.txt", working_directory)

## apply field names
colnames(X_Test)<-field_Names1

## Import training data
X_Train<-get_table_data("train/X_train.txt",working_directory)
Y_Train<-get_table_data("train/Y_train.txt",working_directory)
subject_train<-get_table_data("train/subject_train.txt", working_directory)

colnames(X_Train)<-field_Names1

## get only std and mean columns
keep_cols<-grep("std()", colnames(X_Test), fixed=TRUE )
keep_cols<-c(keep_cols,grep("mean()", colnames(X_Test), fixed=TRUE ))
keep_cols<-sort(c(keep_cols))

X_Test<-X_Test[,keep_cols]
X_Train<-X_Train[,keep_cols]

## add activity type column to tables
X_Test2<-cbind(Y_Test, X_Test)
X_Train2<-cbind(Y_Train, X_Train)

## add dataset column to tables
X_Test2<-cbind("Test",X_Test2)
X_Train2<-cbind("Train",X_Train2)


## add subject column to each
X_Test2<-cbind(subject_test, X_Test2)
X_Train2<-cbind(subject_train, X_Train2)

## assign field names to observation tables
colnames(X_Test2)[1:3]<-c("Subject","Dataset","Activity_Type")
colnames(X_Train2)[1:3]<-c("Subject","Dataset","Activity_Type")

## get activity values and descriptions
activity<-get_table_data("activity_labels.txt", working_directory)

## append test2 and train2 to final table
Final_Data2<- rbind(X_Test2, X_Train2)


## merge activity labels to table.
Final_Data3<- merge(activity, Final_Data2,  by.x="V1", by.y="Activity_Type",  all=TRUE)

## get rid of numeric activity column
Final_Data3<- Final_Data3[, 2:length(colnames(Final_Data3))]

## name Activity label column
colnames(Final_Data3)[1]="Activity_Lbl"
Final_Data3$Subject<-as.factor(Final_Data3$Subject)

## Rename columns to be more descriptive
colnames(Final_Data3)<-sub("std\\(\\)\\-", "StdDevOf_",colnames(Final_Data3))
colnames(Final_Data3)<-sub("std\\(\\)", "StdDev",colnames(Final_Data3))
colnames(Final_Data3)<-sub("mean\\(\\)\\-", "MeanOf_",colnames(Final_Data3))
colnames(Final_Data3)<-sub("mean\\(\\)", "Mean",colnames(Final_Data3))
colnames(Final_Data3)<-sub("Acc", "Accel",colnames(Final_Data3))
colnames(Final_Data3)<-sub("Mag", "Magnitude",colnames(Final_Data3))


## change Subject field to factor before using melt
Final_Data3$Subject<-as.factor(Final_Data3$Subject)

## Load library with melt 
library(reshape2)

## create tidy format of main table
obs_tidy<-melt(Final_Data3)

## create tidy data of the means calcs

mean_tidy<-aggregate(value ~ 
                       Subject*
                       Activity_Lbl*
                       #Dataset*
                       variable,
                     data=obs_tidy
                     , FUN=mean)

