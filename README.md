# Stack Overflow Duplicate Detection
We are training a language model to detect whether a pair of Stack Overflow posts are duplicates.

## Directories
### data
You can see some CSV files we queired in the `data` directory. However, GitHub only allows a maximum file upload of 100MB, so we stored the larger dataset files in Google Drive.

### queries
The `queries` directory stores the SQL queries we used to collect our data, both on the Data Explorer online and locally.

### scripts
This directory stores scripts we used to download and preprocess the SQL data. `load_data.py` is the script we used locally to convert the zipped data dump data to XML files and loading them to our local DBMS.

`data_loader.ipynb` is the script used to join two CSV files into one data frame.

`data_processing.ipynb` processes the queried CSV data, it includes scripts to separate code and text blocks from post bodies, remove HTML tags, and a heuristic function measuring post similarity through tag similarity.

Note that we have been running the `data_loader.ipynb` and `data_processing.ipynb` files on Google Colab, so some code blocks involving linking to the Google Drive remote directory will not be relevant for local development.

### model
Code for training the transformer weights and classifier head is in `mqdd.ipynb`.