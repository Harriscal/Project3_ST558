# plumber API - Diabetes Prediction (Classification Tree Model)

#* @apiTitle Diabetes Prediction API
#* @apiDescription This API predicts the probability that a patient has diabetes based on three health indicators: Body Mass Index (BMI), high blood pressure status, and recent physical activity. The underlying model is a classification tree trained on a large public health dataset.

# Load required packages
library(plumber)
library(tibble)
library(rpart)
library(rpart.plot)

# Read in the final classification tree model
final_model <- readRDS("final_model.rds")

#* Return project information
#* @get /info
function() {
  list(
    project = "Diabetes Prediction API",
    author = "Calista Harris",
    version = "1.0.0",
    date = Sys.Date(),
    site = "https://harriscal.github.io/Project3_ST558/"
  )
}

#* Predict diabetes based on input values (Classification Tree Model)
#* @param BMI:double Body Mass Index (default = 28)
#* @param HighBP:string High blood pressure status ("Yes" or "No", default = "No")
#* @param PhysActivity:string Physical activity status ("Yes" or "No", default = "Yes")
#* @get /predict_diabetes
function(BMI = 28, HighBP = "No", PhysActivity = "Yes") {
  
  # Input validation
  if (!is.numeric(as.numeric(BMI)) || as.numeric(BMI) <= 0) {
    return(list(error = "BMI must be a positive numeric value."))
  }
  if (!(HighBP %in% c("Yes", "No"))) {
    return(list(error = "HighBP must be 'Yes' or 'No'."))
  }
  if (!(PhysActivity %in% c("Yes", "No"))) {
    return(list(error = "PhysActivity must be 'Yes' or 'No'."))
  }
  
  # Construct input tibble (matching factor levels used in training)
  new_obs <- tibble(
    BMI = as.numeric(BMI),
    HighBP = factor(HighBP, levels = c("No", "Yes")),
    PhysActivity = factor(PhysActivity, levels = c("No", "Yes"))
  )
  
  # Make prediction using classification tree
  prob <- predict(final_model, newdata = new_obs, type = "prob")[, "Yes"]
  
  # Return result
  list(prob_diabetes = round(prob, 4))
}

# -------------------------------
# Example calls:
# GET /predict_diabetes?BMI=30&HighBP=Yes&PhysActivity=No
# curl "http://127.0.0.1:8000/predict_diabetes?BMI=28&HighBP=No&PhysActivity=Yes"
# R: httr::GET("http://127.0.0.1:8000/predict_diabetes?BMI=27&HighBP=Yes&PhysActivity=Yes")
