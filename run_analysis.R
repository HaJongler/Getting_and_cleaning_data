### This script performs the six requested tasks for the Getting and Cleaning Data course.


## Step one - merge the data:

# Before reading the files, let's obtain the variable names (that's actually step 4)
features <- read.table('./features.txt', 
                       stringsAsFactors = FALSE, 
                       col.names = c("index", "name"))
variable_names = features$name

# Now let's merge the tables
train_data <- read.table('./train/X_train.txt',
                         col.names = variable_names)
test_data <- read.table('./test/X_test.txt',
                        col.names = variable_names)
merged_data <- rbind.data.frame(train_data, test_data)

## Step two - extract only the measurements on the mean and standard deviation for each measurement

# Let's find the relevant columns using regex
mean_cols <- grep("-mean\\(\\)", variable_names)
std_cols <- grep("-std\\(\\)", variable_names)
relevant_cols <- union(mean_cols, std_cols)

# Extract the relevant data
relevant_data <- merged_data[,relevant_cols]


## Step three - name the activities in the data set

# First, let's create the activities column and bind it to our DF
train_activities <- read.table('./train/y_train.txt', col.names = "activity_index")
test_activities <- read.table('./test/y_test.txt', col.names = "activity_index")
activities_vec <- rbind(train_activities, test_activities) # The same order as the data!
relevant_data <- cbind(relevant_data, activities_vec)

# Now let's replace the numeric values with the descriptive name of the activity
activities_df = read.table('./activity_labels.txt',
                           col.names = c("index", "activity"))
relevant_data <- merge(relevant_data, activities, 
                       by.x = 'activity_index',
                       by.y = 'index') %>% select(-activity_index) # Removes the numeric column, 
                                                                   # leaving us only with the descriptive one

## Step five - create a new, tidy, dataset

# First we will have to join the subjects vector. We will use the same technique we used for the activities vector.
train_subjects <- read.table('./train/subject_train.txt', col.names = "subject")
test_subjects <- read.table('./test/subject_test.txt', col.names = "subject")
subjects_vec <- rbind(train_subjects, test_subjects) # The same order as the data!
relevant_data <- cbind(relevant_data, subjects_vec)

# Now lets group it with a simple aggregate function!
new_data <- aggregate(. ~ activity + subject, data = relevant_data, FUN = mean) # grouping by activity AND subject, if I understood the quetion correctly. 
write.table(new_data, 'coursera.txt', row.names = FALSE) # Write the result to a file.
