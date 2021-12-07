# Load libraries
library(tidycensus)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(aws.s3)

# Set API Key to access census data
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# Get 2010 census data for zip codes in NY
zip_code_data_long <- get_decennial(geography = "zcta",
                     state = "NY",
                     variables = c(medianage = "P013001",
                                   avghouseholdsize = "H012001"),
                     year = 2010)

# Clean the data
zip_code_data_df <- zip_code_data_long %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable, 
              values_from = value) %>%
  mutate(zip_code = str_remove_all(NAME, "ZCTA5 "),
         zip_code = str_remove_all(zip_code, ", New York")) %>%
  select(zip_code, medianage, avghouseholdsize)

# Save the cleaned data frame to a csv file
tmp <- tempfile()
write_csv(zip_code_data_df, tmp)

# Set necessary AWS credentials
# AWS_SECRET_ACCESS_KEY also need to be set up but outside out the script
Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIA6B7HL6SQT3E7ZO2H",
           "AWS_DEFAULT_REGION" = "us-east-2")

# Write the data file to the S3 bucket
bucket <- get_bucket("census-smoke-shops-pipeline")

put_object(tmp, 
           object = "census-data/new_york_zip_code_data.csv", 
           bucket = bucket)
