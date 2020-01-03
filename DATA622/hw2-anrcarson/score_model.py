#!/usr/bin/env python
# coding: utf-8

# In[1]:


#score_model.py (2 points)

"""
When this is called using python score_model.py in the command line, this will 

ingest the .pkl random forest file and 
apply the model to the locally saved scoring dataset csv. 

There must be data check steps and clear commenting for each step inside the .py file. 

The output for running this file is a csv file with the predicted score, 
as well as a png or text file output that contains the model accuracy report 
(e.g. sklearn's classification report or any other way of model evaluation).
"""


# In[ ]:





# In[2]:


#packages
try:
    import pandas as pd
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.metrics import accuracy_score
    from sklearn.metrics import classification_report
    from sklearn.model_selection import train_test_split
    import joblib
    print("Packages imported correctly.")
except:
    print("One or more packages did not load correctly.  Please make sure all needed packages are installed.")


# In[3]:


#####################
#ingest .pkl file
####################

#read in
try:
    model = joblib.load('model.pkl')
    print("Model loaded correctly.")
except:
    print("Error: Model failed to load.")

#check model loaded
print(model)


# In[4]:


#############################
# apply model to locally saved scoring dataset
#############################

#bring in data
try:
    df_test= pd.read_csv('test.csv')
    print("Test data loaded correctly.")
except:
    print("Test data did NOT load correctly.")
    
#validate data
print(df_test)


# In[ ]:





# In[5]:


# test is 418 rows x 11 columns
#print(len(df_test) == 418)
#print(len(df_test.columns) == 11)

test_columns = (list(df_test.columns) == list(['PassengerId', 'Pclass', 'Name', 'Sex', 'Age', 'SibSp', 'Parch', 'Ticket', 'Fare', 'Cabin', 'Embarked']))
#print(test_columns)


# In[6]:


#set checkData condition
checkData = (
            (len(df_test) == 418) & 
            (len(df_test.columns) == 11) & 
            test_columns
            )

#print results
if(checkData):
    print("The test data imported correctly.")
else:
    print("Error: the test data did NOT import correctly.")


# In[7]:


###################################
# data cleaning and imputation - match same as training data
###################################

#split categorical into dummy
try:
    df_test_sub = df_test[['Pclass', 'Age','Parch', 'Fare', 'Sex', 'SibSp', 'Embarked']]
    df_test_d = pd.get_dummies(df_test_sub)
    print("Test data successfully transformed with dummy columns.")
except:
    print("Test data did not get dummy values correctly.  Please review.")


# In[8]:


#show dummy data
print(df_test_d)


# In[9]:


# impute missing values
# in test data, Age has missing values (86), and Fare (1)
print("Initial Missing Data")
print(df_test_d.isnull().sum())


# In[ ]:





# In[10]:


#impute with medians from training data
#read train data
try:
    df_train = pd.read_csv('train.csv')
    print("Train data loaded succesfully for test data imputation.")
except:
    print("Train data did NOT load successfully for test data imputation. Please check that data is available, needed packages are installed, and functions are available.")


# In[ ]:





# In[11]:


#impute
try:
    df_test_d.fillna(df_train.median(), inplace=True)
    print("Imputation of missing values successfull.")
except:
    print("Imputation of missing values failed.")


# In[12]:


#validation: check for missing values after imputation
try:
    if(df_test_d.shape[0] - df_test_d.dropna().shape[0]) > 0:
        print("Error: Missing values still exist in df_test_d.")
    else:
        print("No missing values in df_test_d.")
except:
    print("Error: check for missing values in df_test_d failed.")


# In[13]:


#feature engineering: create CabinMissing column to capture this information
df_test_d['CabinMissing'] = df_test['Cabin'].isnull().astype(int)


# In[14]:


# feature engineering: create categorical Pclass: 1, 2, 3
# treat classes as categories and not as numeric
df_test_d['Pclass_1'] = (df_test['Pclass']==1).astype(int)
df_test_d['Pclass_2'] = (df_test['Pclass']==2).astype(int)
df_test_d['Pclass_3'] = (df_test['Pclass']==3).astype(int)


# In[15]:


#set data/target columns
data_cols = ['Pclass_1', 'Pclass_2', 'Pclass_3', 'Age', 'Parch', 'Fare', 'SibSp', 'Sex_female', 'Sex_male', 'Embarked_C', 'Embarked_Q', 'Embarked_S','CabinMissing']


# In[ ]:





# In[16]:


#only include data for model
X = df_test_d[data_cols]


# In[17]:


#make prediction
try:
    y_predict = model.predict(X)
    print("Model prediction step successfull.")
except:
    print("Error: model prediction on test data failed.")


# In[18]:


#check length of prediction
try:
    if(len(y_predict)==418):
        print("Model prediction output correct number of predictions.")
    else:
        print("Model predicted failed to output correct number of predictions.")
except:
    print("Error: model did NOT correctly output predictions.")


# In[19]:


##########################################
# output: csv file with predicted score
###########################################


# In[20]:


scored = df_test


# In[21]:


scored['Survived_Prediction'] = y_predict


# In[22]:


#validate assignment
print(scored)


# In[23]:


#output
try:
    scored.to_csv('scored.csv',index=False)
    print("Scored file successfully saved locally.")
except:
    print("Scored file did NOT successfully save locally.")


# In[24]:


################################################################################
# output: png/text file with model accuracy report: sklearn classification report
#############################################################################

# Note: see train_model.py file for the code that supports this.

