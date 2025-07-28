# plumber.R

#* @apiTitle Diabetes Prediction API
#* @apiDescription This API predicts the probability that a patient has diabetes based on three health indicators: Body Mass Index (BMI), high blood pressure status, and recent physical activity. The underlying model is a logistic regression trained on a large public health dataset.
#* @apiVersion 1.0.0

# Load necessary packages
library(plumber)
library(tibble)
library(caret)

# Read in the final trained model (must be present in root directory)
final_model <- readRDS("final_model.rds")

#* Return project information
#* @get /info
#* @response 200 Returns metadata about the API and project
function() {
  list(
    project = "Diabetes Prediction API",
    author = "Calista Harris",
    site = "https://github.com/Harriscal/Project3_ST558",
    version = "1.0.0",
    date = as.character(Sys.Date()),
    description = "Predicts diabetes using a classification tree model trained on BMI, HighBP, and PhysActivity."
  )
}

#* Predict diabetes based on input values (Classification Tree Model)
#* @param BMI:number Body Mass Index (e.g., 28.0)
#* @param HighBP:string Indicator for High Blood Pressure: 'Yes' or 'No'
#* @param PhysActivity:string Indicator for Physical Activity in past 30 days: 'Yes' or 'No'
#* @get /predict_diabetes
#* @response 200 Returns predicted probability of diabetes
#* @response 400 Invalid input provided
function(BMI, HighBP = "No", PhysActivity = "Yes") {
  # Validate and convert input
  BMI <- as.numeric(BMI)
  if (is.na(BMI) || BMI <= 0) {
    return(list(error = "BMI must be a positive numeric value."))
  }
  
  if (!HighBP %in% c("Yes", "No")) {
    return(list(error = "HighBP must be either 'Yes' or 'No'."))
  }
  
  if (!PhysActivity %in% c("Yes", "No")) {
    return(list(error = "PhysActivity must be either 'Yes' or 'No'."))
  }
  
  # Create input dataframe
  new_data <- tibble(
    BMI = BMI,
    HighBP = factor(HighBP, levels = c("No", "Yes")),
    PhysActivity = factor(PhysActivity, levels = c("No", "Yes"))
  )
  
  # Predict probability
  prob <- predict(final_model, newdata = new_data, type = "prob")[, "Yes"]
  
  # Return prediction
  list(prob_diabetes = round(prob, 4))
}
