# Stack Overflow Duplicate Detection
This GitHub repository contains code for our project on automatically detecting duplicate questions on Community Question Answering (CQA) programming platforms like Stack Overflow. The current process of manually flagging duplicate questions is inefficient and time-consuming, given that the site currently contains 23 million questions and over a million duplicates. The project proposes a bimodal Natural Language / Programming Language (NL-PL) model that makes use of code snippets to detect duplicates. We contribute a new model, combining approaches from the MQDD and S-BERT papers, and a new dataset for finetuning.

## Directories
### Data
You can see some CSV files we queired in the `data` directory. However, GitHub only allows a maximum file upload of 100MB, so we stored the larger dataset files in Google Drive. Thus, the better place to reference our dataset is [here](https://drive.google.com/drive/u/0/folders/1vXfV9NErpZDnzNIxkOKePa_vomN1_auk). 

### Queries
The `queries` directory stores the SQL queries we used to collect our data, both on the Data Explorer online and locally.

### Scripts
Here, you can find the scripts that we used to download and preprocess the SQL data. 

- `load_data.py` is the script we used locally to convert the zipped data dump data to XML files and loading them to our local DBMS.
- `data_loader.ipynb` is the script for initially loading and modifying the data into more usable CSV files.
- `data_processing.ipynb` processes the queried CSV data, it includes scripts to separate code and text blocks from post bodies, remove HTML tags, and a heuristic function measuring post similarity through tag similarity. You can find our two stages of data processing in `data_processing_1.ipynb` and `data_processing_2.ipynb`

Note that we have been running the `data_loader.ipynb` and `data_processing.ipynb` files on Google Colab, so some code blocks involving linking to the Google Drive remote directory will not be relevant for local development.

### Model Implementation & Training
Code for implementing our model and training the transformer weights is in `mqdd.ipynb`.