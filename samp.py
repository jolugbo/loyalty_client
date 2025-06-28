import pandas as pd 
import os 

# Import os to be able to rename the csv.file 
# rename the file 

old_file_path = ' /mnt/data/extracted/supermarket_sales.csv'
new_file_path = ' /mnt/data/extracted/For_prediction.csv'
os.rename(old_file_path , new_file_path)

# read renamed CSV file 

df=pd.read_csv("For_prediction")

# display the first 200 rows of the dataset 

print(df.head(200))