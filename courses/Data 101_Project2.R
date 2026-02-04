# Data 101 - Project #2 (Section 13)
# Sarah Menezes & Swetha Govindarajan

# load Libraries
library(rpart)
library(faraway)
library(rpart.plot)
library(caTools)
library(randomForest)

# load Data Set "hsb" (Career Choice of High School Students)
data(hsb)

# set seed for reproducibility
set.seed(1234)

# subset data into male and female
female_data <- subset(hsb, gender == "female")
male_data <- subset(hsb, gender == "male")

# calculate means for scores of each gender
female_means <- c(mean(female_data$read, na.rm = TRUE),
                  mean(female_data$write, na.rm = TRUE),
                  mean(female_data$math, na.rm = TRUE),
                  mean(female_data$science, na.rm = TRUE))

male_means <- c(mean(male_data$read, na.rm = TRUE),
                mean(male_data$write, na.rm = TRUE),
                mean(male_data$math, na.rm = TRUE),
                mean(male_data$science, na.rm = TRUE))

# ---------------Bootstrapping--------------- 
n_bootstrap <- 1000
bootstrap_diffs <- numeric(n_bootstrap)

for (i in 1:n_bootstrap) {
  sample_F <- sample(female_means, length(female_means), replace = TRUE)
  sample_M <- sample(male_means, length(male_means), replace = TRUE)
  bootstrap_diffs[i] <- mean(sample_F) - mean(sample_M)
}

# estimate confidence interval of the difference 
ci_diff <- quantile(bootstrap_diffs, c(0.025, 0.975))
print(ci_diff)

# ---------------Random Forest--------------- 

# get the structure of the data
str(hsb)
cat("Number of incomplete cases: ", sum(!complete.cases(hsb)), "\n")

# replace NAs with column medians for numeric columns only
for (i in 1:ncol(hsb)) {
  if (is.numeric(hsb[, i])) {
    hsb[, i][is.na(hsb[, i])] <- median(hsb[, i], na.rm = TRUE)
  }
}

# set seed for reproducibility
set.seed(1234)

data(hsb)

train <- sample(nrow(hsb), 0.75 * nrow(hsb), 
                replace = FALSE) 
train_data <- hsb[train, ] 
test_data <- hsb[-train, ] 


# fit the random forest model
model <- randomForest(
  formula = gender ~ .,
  data = train_data, 
  importance = TRUE
)

# predicating the outputs
predictions <- predict(model, test_data)

accuracy <- sum(predictions == test_data$gender) / nrow(test_data) 
print(paste("Accuracy:", round(accuracy, 2)))

# find the number of trees that produce the lowest test MSE
if (!is.null(model$mse)) {
  print(which.min(model$mse))
} else {
  cat("MSE values are not available.\n")
}

# plot variable importance
plot(model)
varImpPlot(model)

# tune the model with handling of missing values
mtry <- tuneRF(
  x = hsb[, -which(names(hsb) == "gender")],
  y = hsb$gender,
  ntreeTry = 500,
  stepFactor = 1.5,
  improve = 0.01,
  trace = FALSE,
  na.action = na.omit
)

# print the tuning result
print(mtry)

# ---------------Bagging--------------- 

# set seed for reproducibility
set.seed(1234)

# fit bagging model using Random Forest
data(hsb)
# fit a bagging model using the ipred package
bag_model <- bagging(
  formula = gender ~ ., 
  data = train_data, 
  nbagg = 100,       # Number of bags
  coob = TRUE,       # Out-of-bag error estimation
  control = rpart.control(minsplit = 10, cp = 0.01)  # tuning tree parameters
)

# print the bagging model and OOB error rate
print(bag_model)
cat("OOB error rate: ", round(bag_model$err, 4), "\n")