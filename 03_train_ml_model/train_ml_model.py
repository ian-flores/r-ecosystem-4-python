# Load packages
import boto3
import pandas
from sklearn import linear_model
from sklearn.model_selection import train_test_split
from joblib import dump

# Download data for training
s3 = boto3.client('s3')
    
s3.download_file("census-smoke-shops-pipeline", 
"census-data/new_york_zip_code_data.csv", 
"new_york_zip_code_data.csv")

s3.download_file("census-smoke-shops-pipeline", 
"smoke-shops-data/new_york_smoke_shops_data.csv", 
"new_york_smoke_shops_data.csv")
          
# Read in data        
zip_code_data = pandas.read_csv("new_york_zip_code_data.csv")
smoke_shops_data = pandas.read_csv("new_york_smoke_shops_data.csv")

# Left join of the datasets
joined_data = smoke_shops_data.set_index('zip_code').join(zip_code_data.set_index('zip_code'), on = 'zip_code')

# Drop all rows that have at least 1 NA
clean_data = joined_data.dropna()

# Split data
predictors = clean_data[['medianage', 'avghouseholdsize']]
targets = clean_data[['num_stores']]

predictor_train, predictor_test, target_train, target_test = train_test_split(
  predictors, targets, test_size = 0.33, random_state = 2021)
  
# Train LR
regr = linear_model.LinearRegression()

regr.fit(predictor_train, target_train)

# Save model to S3 bucket
dump(regr, 'linear_regression.joblib')

s3.upload_file("linear_regression.joblib", 
"census-smoke-shops-pipeline", 
"ml-models/linear_regression.joblib")
