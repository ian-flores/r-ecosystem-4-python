# Load libraries
library(RSocrata)
library(aws.s3)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)

# Get data from NY Health Data portal
smoke_shops_ny_raw <- read.socrata(
  "https://health.data.ny.gov/resource/9ma3-vsuk.csv"
)

# Clean data and group by zip code
smoke_shops_by_zipcode <- smoke_shops_ny_raw %>%
  as_tibble() %>%
  group_by(zip) %>%
  count() %>%
  filter(str_length(zip) == 5) %>%
  select(zip_code = zip, num_stores = n)

# Save file to csv file
tmp <- tempfile()
write_csv(smoke_shops_by_zipcode, tmp)

# Set necessary AWS credentials
# AWS_SECRET_ACCESS_KEY also need to be set up but outside out the script
Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIA6B7HL6SQT3E7ZO2H",
           "AWS_DEFAULT_REGION" = "us-east-2")

# Write the data file to the S3 bucket
bucket <- get_bucket("census-smoke-shops-pipeline")

put_object(tmp, 
           object = "smoke-shops-data/new_york_smoke_shops_data.csv", 
           bucket = bucket)
