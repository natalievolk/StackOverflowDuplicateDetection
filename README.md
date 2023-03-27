# Stack Overflow Duplicate Detection

## Directories
### data
You can see some CSV files we queired in the `data` directory. However, GitHub only allows a maximum file upload of 100MB, so we stored the larger dataset files in Google Drive.

### queries
The `queries` directory stores the SQL queries we used to collect our data, both on the Data Explorer online and locally.

### scripts
This directory stores scripts we used to download and preprocess the data. Note that we have been running the `data_loader.ipynb` and `data_processing.ipynd` files on Google Colab, so some code blocks involving linking to the Google Drive remote directory will not be relevant for local development.

### model
Script for the transformer weights and classifier head is in `mqdd.ipynb`.