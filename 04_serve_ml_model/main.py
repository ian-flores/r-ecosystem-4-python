# Load libraries
import boto3
from fastapi import FastAPI
from joblib import load

# Download model
s3 = boto3.client('s3')
    
s3.download_file("census-smoke-shops-pipeline", 
"ml-models/linear_regression.joblib", 
"linnear_regresion.joblib")

# Load model
linear_regression = load("linnear_regresion.joblib")

# Instantiate the app
app = FastAPI()

# Define endpoint
@app.get("/prediction")
def predict(medianage, avghouseholdsize):
  return linear_regression.predict([[medianage, avghouseholdsize]])
