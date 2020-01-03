#!/usr/bin/env python
# coding: utf-8

# In[1]:


#train_model.py (5 points)

"""
When this is called using python train_model.py in the command line, this will 
take in the training dataset csv, 
perform the necessary data cleaning and imputation, and 
fit a classification model to the dependent Y. 

There must be data check steps and clear commenting for each step inside the .py file. 

The output for running this file is the random forest model saved as a .pkl file in the local directory. 

Remember that the thought process and decision for why you chose the final model 
must be clearly documented in this section. 
"""


# In[2]:


# References: 
# https://ehackz.com/2018/03/23/python-scikit-learn-random-forest-classifier-tutorial/
# https://stackoverflow.com/questions/55208734/save-lgbmregressor-model-from-python-lightgbm-package-to-disc
# https://stackoverflow.com/questions/28199524/best-way-to-count-the-number-of-rows-with-missing-values-in-a-pandas-dataframe

# packages
try:
    import pandas as pd
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.metrics import accuracy_score
    from sklearn.metrics import classification_report
    from sklearn.model_selection import train_test_split
    import joblib
    #from sklearn.preprocessing import OneHotEncoder
    print("Packages loaded successfully.")
except:
    print("One or more packages did not load correctly.  Please make sure all needed packages are installed.")


# In[3]:


######################
# read in train data, validate
#######################

#read
try:
    df_train = pd.read_csv('train.csv')
    print("Train data loaded succesfully.")
except:
    print("Train data did NOT load successfully.  Please check that data is available, needed packages are installed, and functions are available.")


# In[4]:


# validate data


# In[5]:


print(df_train)


# In[ ]:





# In[6]:


# train is 891 rows x 12 columns
#print(len(df_train) == 891)
#print(len(df_train.columns) == 12)

train_columns = (list(df_train.columns) == list(['PassengerId', 'Survived', 'Pclass', 'Name', 'Sex', 'Age', 'SibSp', 'Parch', 'Ticket', 'Fare', 'Cabin', 'Embarked']))
#print(train_columns)


# In[7]:


#set checkData condition
checkData = (
            (len(df_train) == 891) & 
            (len(df_train.columns) == 12) & 
            train_columns
            )

#print results
if(checkData):
    print("The train data imported correctly.")
else:
    print("Error: the train data did NOT import correctly.  Please check the schema and contents of the data.")


# In[8]:


###################################
# data cleaning and imputation
###################################


# In[9]:


#split categorical into dummy for model needs
try:
    df_train_sub = df_train[['Survived','Pclass', 'Age','Parch', 'Fare', 'Sex', 'SibSp', 'Embarked']] #select columns used for this model
    df_train_d = pd.get_dummies(df_train_sub)
    print("Train data successfully transformed with dummy columns.")
except:
    print("Train data did not get dummy values correctly.  Please review.")


# In[10]:


#show dummy data
print(df_train_d)


# In[11]:


# impute missing values
# in train data, only Age has missing values (177)
print("Initial Missing Data")
print(df_train_d.isnull().sum())


# In[ ]:





# In[ ]:





# In[12]:


#dropping NAs reduces rows from 891 to 714
# too drastic
# len(df_train_d.dropna())


# In[13]:


#impute with median instead
try:
    df_train_d.fillna(df_train_d.median(), inplace=True)
    print("Imputation successfull.")
except:
    print("Imputation of missing values failed.")


# In[14]:


#validation: check for missing values after imputation
try:
    if(df_train_d.shape[0] - df_train_d.dropna().shape[0]) > 0:
        print("Error: Missing values still exist in df_train_d.")
    else:
        print("No missing values in df_train_d.")
except:
    print("Error: check for missing values in df_train_d failed.")


# In[15]:


#feature engineering: create CabinMissing column to capture this information
df_train_d['CabinMissing'] = df_train['Cabin'].isnull().astype(int)


# In[ ]:





# In[16]:


# feature engineering: create categorical Pclass: 1, 2, 3
# treat classes as categories and not as numeric
df_train_d['Pclass_1'] = (df_train['Pclass']==1).astype(int)
df_train_d['Pclass_2'] = (df_train['Pclass']==2).astype(int)
df_train_d['Pclass_3'] = (df_train['Pclass']==3).astype(int)


# In[17]:


################################
# trains a random forest model on the training dataset using sklearn
# fit a classification model to the dependent Y
################################

#set data/target columns
# Note: excluded free text/many valued columns (Cabin, Name, Ticket).  
# With more time would extract more information from them and use the extracted information in the model.
data_cols = ['Pclass_1', 'Pclass_2','Pclass_3', 'Age', 'Parch', 'Fare', 'SibSp', 'Sex_female', 'Sex_male', 'Embarked_C', 'Embarked_Q', 'Embarked_S', 'CabinMissing']
target_cols = ['Survived']


# In[18]:


X = df_train_d[data_cols]
y = df_train_d[target_cols]


# In[19]:


#split into training/testing data
# 30% split
try:
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
    print("Model train and test split step successfull.")
except:
    print("Model train and test split step failed.")


# In[20]:


#train model
try:
    model = RandomForestClassifier(n_estimators = 100)
    model.fit(X_train, y_train.values.ravel())
    y_predict = model.predict(X_test)
    print("Model fit and prediction step successfull.")
except:
    print("Model fit and prediction step failed.")


# In[21]:


#classification report: print and save locally
try:
    classificationReport = classification_report(y_test.values, y_predict)
    text_file = open("modelClassificationReport.txt", "w")
    text_file.write(classificationReport)
    text_file.close()
    print("Classifcation Report:")
    print(classificationReport)
except:
    print("Failed to output or save classification report.")


# In[22]:


#######################################
# Output for running this file is the random forest model saved as a .pkl file in the local directory
######################################

# save model
try:
    joblib.dump(model, 'model.pkl')
    print("Model succesfully saved locally.")
except:
    print("Error: model.pkl file not saved.")

