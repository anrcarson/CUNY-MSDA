#!/usr/bin/env python
# coding: utf-8

# In[1]:


### pull_data.py (5 points)

"""
When this is called using python pull_data.py in the command line, 
this will go to the 2 Kaggle urls provided below, authenticate using your own Kaggle sign on, 
pull the two datasets, and save as .csv files in the current local directory. 

The authentication login details (aka secrets) need to be in a hidden folder (hint: use .gitignore). 
There must be a data check step to ensure the data has been pulled correctly and clear commenting and 
documentation for each step inside the .py file. 

Training dataset url: https://www.kaggle.com/c/titanic/download/train.csv 
Scoring dataset url: https://www.kaggle.com/c/titanic/download/test.csv
        
"""


# In[2]:


# References:
# https://github.com/Kaggle/kaggle-api
# https://www.kaggle.com/c/titanic/data


# In[3]:


#################################
# Authenticate Kaggle sign on
#################################
# Note:  API key stored in kaggle package information
# Follow instructions for setup here: https://github.com/Kaggle/kaggle-api

#packages
try:
    import kaggle
    kapi = kaggle.api
    print("Kaggle package and authentication successfull.")
except:
    print("Error: Make sure kaggle package is installed and that the kaggle.json file is located in C:\\Users\\[user]\\.kaggle.  This file is needed for authentication.")


# In[4]:


try:
    import pandas as pd
    from io import BytesIO
    #from io import StringIO
except:
    print("Error: check installation of needed packages.")


# In[ ]:





# In[5]:


###########################
### Pull two data sets: train and test
###########################


# In[6]:


# get train data
try:
    train = kapi.competitions_data_download_file('titanic', 'train.csv')
    df_train = pd.read_csv(BytesIO(train.encode()), header=0)
    print("Train data")
    print(df_train)
except:
    print("Error: train data did not import from API.")


# In[ ]:





# In[7]:


# get test data
try:
    test = kapi.competitions_data_download_file('titanic', 'test.csv')
    df_test = pd.read_csv(BytesIO(test.encode()), header=0)
    print("Test data")
    print(df_test)
except:
    print("Error: test data did not import from API.")


# In[ ]:





# In[8]:


#####################
### validate data sets -  check number of rows and columns; check column names
######################

# train is 891 rows x 12 columns
#print(len(df_train) == 891)
#print(len(df_train.columns) == 12)

# test is 418 rows by 11 columns
#print(len(df_test) == 418)
#print(len(df_test.columns) == 11)

#check column names
train_columns = (list(df_train.columns) == list(['PassengerId', 'Survived', 'Pclass', 'Name', 'Sex', 'Age', 'SibSp', 'Parch', 'Ticket', 'Fare', 'Cabin', 'Embarked']))
#print(train_columns)
test_columns = (list(df_test.columns) == list(['PassengerId', 'Pclass', 'Name', 'Sex', 'Age', 'SibSp', 'Parch', 'Ticket', 'Fare', 'Cabin', 'Embarked']))
#print(test_columns)


# In[9]:


#set variable for validated data
checkData = (
            (len(df_train) == 891) & 
            (len(df_train.columns) == 12) & 
            (len(df_test) == 418) & 
            (len(df_test.columns) == 11) &
            train_columns &
            test_columns
            )

#print results
if(checkData):
    print("The train and test data pulled correctly.")
else:
    print("Error: the train or test data did NOT pull correctly.")


# In[11]:


####################
# save as .csv in local directory
##################

#write to local path
if(checkData):
    try:
        df_train.to_csv('train.csv', index=False)
        df_test.to_csv('test.csv',index=False)
        print("Files saved successfully.  End of file.")
    except:
        print("Error: could not save train and test files to local directory.  Previously saved files will be used in subsequent code.")
else:
    print("Train and test data NOT written to local file due to failed data validation step.")

