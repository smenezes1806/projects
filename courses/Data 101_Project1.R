# Data 101 - Project #1 (Section 13)
# Sarah Menezes & Swetha Govindarajan

# load libraries
library(rpart)
library(klaR)
library(caret)
library(faraway)
library(rpart)
library(rpart.plot)
library(caTools)

# load data set "hsb (Career Choice of High School Students)
library(faraway)
data(hsb)

# get summary of data 
head(hsb)
summary(hsb)

# create data table
# subset data into male and female
female_data <- subset(hsb, gender == "female")
male_data <- subset(hsb, gender == "male")

summary(female_data$math)
summary(male_data$math)

# calculate means for scores of each gender
female_means <- c(mean(female_data$read, na.rm = TRUE),
                  mean(female_data$write, na.rm = TRUE),
                  mean(female_data$math, na.rm = TRUE),
                  mean(female_data$science, na.rm = TRUE))

male_means <- c(mean(male_data$read, na.rm = TRUE),
                mean(male_data$write, na.rm = TRUE),
                mean(male_data$math, na.rm = TRUE),
                mean(male_data$science, na.rm = TRUE))

# create data table using mean calculations 
gender_scores <- data.frame(gender = c("female", "male"),
                            mean_reading = female_means[1],
                            mean_writing = female_means[2],
                            mean_math = female_means[3],
                            mean_science = female_means[4])

# assign male values to the second row
gender_scores[2, 2:5] <- male_means

# print the data table
print(gender_scores)

# Check the distribution of categorical variables
table(hsb$gender)          # Counts of male/female
table(hsb$ses)             # Counts by SES level
table(hsb$gender, hsb$ses) # Counts by gender & SES level

# create histogram for math scores
hist(hsb$math, 
     main = "Histogram of Math Scores", 
     xlab = "Math Scores", 
     col = "lightblue", 
     border = "black", 
     breaks = 20)

# set up a 1x2 grid for side-by-side plots
par(mfrow = c(1, 2))

# create scatterplot of gender (female) vs math scores
plot(female_data$math, 
     main = "Scatterplot of Female vs Math Scores", 
     xlab = "Females", 
     ylab = "Math Scores", 
     pch = 19, 
     col = "lightblue")

# create scatterplot of gender (male) vs math scores
male_data <- subset(hsb, gender == "male")
plot(male_data$math, 
     main = "Scatterplot of Male vs Math Scores", 
     xlab = "Males", 
     ylab = "Math Scores", 
     pch = 19, 
     col = "lightblue")

# reset grid to 1x1
par(mfrow = c(1, 1))

# create box & whisker plot of gender vs math scores
plot(hsb$gender, hsb$math, 
     main = "Box & Whisker Plot of Gender vs Math Scores", 
     xlab = "Gender", 
     ylab = "Math Scores", 
     pch = 19, 
     col = "lightblue")

# create barplot to visualize the distribution of gender
barplot(table(hsb$gender), 
        main = "Gender Distribution", 
        col = "lightblue", 
        xlab = "Gender", 
        ylab = "Count")

# set a seed for reproducibility
set.seed(1234)

splitData <- sample.split(hsb, SplitRatio = 0.75)
trainData <- subset(hsb, splitData == "TRUE")
testData <- subset(hsb, splitData == "FALSE")

# cv
# cross validated (ten-fold)
trainCtrl <- trainControl(method = "cv", number = 10, savePredictions = TRUE)

# train the Naive-Bayes model
CvNaiveBayes <-train(gender ~ read + math + socst + ses, data = trainData, trControl = trainCtrl )

# predictions for the training and test data 
trainingPredictionss <- predict(CvNaiveBayes, trainData)
testPredictionss <- predict(CvNaiveBayes, testData)

# generate confusion matrices
trainingTables <- confusionMatrix(trainingPredictionss, trainData$gender)
print(trainingTables)

#  predictions for the training and test data
testTables <- confusionMatrix(testPredictionss, testData$gender)
print(testTables)


# train the Naive-Bayes model
hsbNaiveBayes <-NaiveBayes(gender ~ ., data = trainData)


# predictions for the training and test data hsb model
trainingPredictions <- predict(hsbNaiveBayes, trainData)
testPredictions <- predict(hsbNaiveBayes, testData)


# generate confusion matrices
trainingTable <- confusionMatrix(trainingPredictions$class, trainData$gender)
print(trainingTable)

#  predictions for the training and test data
testTable <- confusionMatrix(testPredictions$class, testData$gender)
print(testTable)

#  build decision tree model
help("rpart")
studentModelTree <- rpart(gender ~ math + ses , data = trainData , method = "class")

# plot the decision tree with rpart()
rpart.plot(studentModelTree)
rpart.plot(studentModelTree, extra = 100)