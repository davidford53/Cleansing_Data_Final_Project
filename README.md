# Cleansing_Data_Final_Project
Tidy data set created from UCI original data, with means calculated for aggregated values.

Data is imported, Test and Train data is appended, only std and mean columns are retained.

Result is run through the "melt" function of the reshape2 library to create a "tidy" format for the data.

First three columns are changed to factors, to facilitate the aggregating by the means() function on the value columns.


