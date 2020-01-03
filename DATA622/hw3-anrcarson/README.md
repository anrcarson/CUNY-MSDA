
# Fall 2019 DATA 622 # hw3
Andrew Carson

10/30/2019

 - Assigned on October 16, 2019 Due on Nov 3rd 2019 11:59 PM EST
 - 17 points possible, worth 17% of your final grade

## Instructions:

Get set up with free academic credits on both Google Cloud Platform (GCP) and Amazon Web Services (AWS). Instructions were sent in 2 separate emails to your CUNY inbox a couple of weeks ago, please reach out to me if you did not get them.

        Done

Research the products that AWS and GCP offer for storage, computing and analytics. A few good starting points are: 
- GCP product list 
- AWS product list 
- GCP quick-start tutorials 
- AWS quick-start tutorials 
- Mapping GCP to AWS products 
- Mapping GCP to MS Azure 
- Evaluating GCP against AWS

        See additional HW3_Research file for my notes and references in comparing AWS and GCP.

## Critical Thinking (5 points total)

1. Design one way of migrating homework 2's outputs to GCP. Evaluate the strength and weakness of each method using the Agile Data Science framework. Design and discuss the method (2.5 points).

      My HW2 output ran Python code on a local machine, with special packages (e.g., Kaggle), calling the Kaggle API, saving and operating on local files, and saving the output of model.  The most straigtforward approach to accomplish this on GCP is through the use of Compute Engine, which are virtual machines.  With this, one can choose the OS one wants, login into the VM, run the code according to one's desired environment (install packages), and then save the output as done in HW2.  In short, this basically replicates my local computer in a cloud computer.
      
      Other options include the use of App Engine, which allows one to deploy code and run code with command line.  The standard version does not allow package installation while the flexible version does.  Cloud Data Proc is a big data cluster (similar to Azure HDInsight).  One can run Jupyter notebooks on this with Apache Spark and Hadoop.  Both of these options would require the use of storage.  Storage options include Cloud Storage, which is unstructured object blob storage (like Azure storage, except instead of containers one uses buckets).  One can also store data in BigQuery, which is like Azure DataLake.
      
      Agile is about iterative delivery that builds incrementally on a project.  Intermediate output needs to be shipped, even when the "final" solution is a long way off.  The goal in these iterations is to move from raw data -> charts -> reports -> predictions -> actions.  When it comes to the cloud, the cloud should help make sharing intermediate output easier, increase transparency in the process of the data, and allow for faster iteration and modification of processes when needed.
      
      So how do these solutions rate in terms of being "agile"?  The first approach using Compute Engine is fairly agile.  It is flexible (can directly modify code, install packages) and it is pretty quick to set up.  A drawback is that it would be difficult to get the results out of the VM and into Cloud Storage or other cloud storage locations for use in reporting.  App Engine might be better in the long run as one can separate the Cloud Storage from the compute, although this would require a bit more configuration up front and will not be as flexible with packages.  Cloud Data Proc is overkill from the compute perspective and would be more expensive, although it does more easily allow one to work directly with the code in a Jupyter notebook and for the code to output to Cloud Storage or BigQuery.
      

2. Design one way of migrating homework 2's outputs to AWS. Evaluate the strength and weakness of each method using the Agile Data Science framework. Design and discuss the method (2.5 points).

    Much of what was said for (1) applies here.  The most straightforward approach to migrating HW2 outputs to AWS is the use of EC2 (Elastic cloud computing).  This is AWS' VM service and offers largely the same capabilities as Compute Engine.  Other options similar to GCP include EMR, which is the big data compute similar to Cloud Data Proc for GCP or Azure HDInsight for Microsoft.  Storage is S3 (Simple Storage Services), similar to Azure Storage and GCP Cloud Storage.  For big data storage one can use Kinesis analytics, which provides data lake storage and analytics, similar to GCP's big query (and Microsoft's Azure Data Lake and Data Lake Analytics).
    
    With regards to the Agile Data Science framework, similar things can also be said.  The fastest and most straightforward way is to use EC2, and this provides great flexibility for code modification.  The difficulty is getting data out of the VM.  Other solutions like EMR and Kinesis analytics take a lot more work to set up properly and cost more, but once done so, can make access to the data easier and are probably more "production" and "data engineering" solutions for the long term.

Fill out the critical thinking section by modifying this README.md file. If you want to illustrate using diagrams, check out draw.io, which has a nice integration with github. 



## Applied (12 points total) 

1. Choose one of the methods described above, and implement it using your work from homework 2.

    I chose the use of AWS EC2.  Why AWS instead of GCP?  First, AWS is the cloud leader, so getting experience with AWS makes sense from a learning perspective, as I have not worked with AWS or GCP before.  Second, AWS provided a larger free educational credit, so it seemed more financially sound/less risky.  Third, the AWS layout was easier to navigate, the solution documentation was more straightforward, and it just seemed to make sense to me faster than GCP did.
    
    Now why EC2 instead of the other possibilities?  First, I had not worked with a VM before in a cloud environment while I have worked with the other solution types (albeit in the Microsoft Azure context), so I wanted to learn more about that.  Second, it seemed to be the fastest way to get the HW2 code up and running, and with the need to install third party packages and do API calls to Kaggle, it seemed like this would be the most straigthforward solution and lead me to success most quickly.  Third, a big data solution or data engineering pipeline did not seem justified at this point.  HW2 feels more like a temporary solution instead of a production implementation, and so something small scale, quick to stand up, and easy to modify seems like the correct approach for this stage.  If HW2 were running for awhile and yielding good results, then perhaps a more production-like and robust data engineering approach would be justified and required.

2. Submit screenshots in the screenshot folder on this repo to document the completion of your process.

    To use EC2 to implement HW2,  first, I created a free tier EC2 VM.  The set up was quick and it was easy to connect to.  I created a  Windows VM as this is what I use on my personal machine. (01_CreateEC2_Instance)  Next, once the VM was up and running, I connected to the VM using an RDP session (02_ConnectRDP).  Then I installed Python by using a web browser to navigate (03_InstallPythonOnVM).  I copied code files over onto a desktop folder named "Code".
    
    Next, after opening up command line and navigating to the Code folder, I tried to run "pip install -r requirements.txt".  This didn't work, and after doing some research, the solution was to add the Python path to %PATH%.  So I checked for the path (04_Path), confirmed that pip was there (05_Path), and then added that path to %PATH% (06_SetPath).  I tried the pip install command and it ran, but an error resulted indicating that I needed to install Microsoft Visual C++ 14.0.  So I installed Visual C++ Build Tools (07_installBuildTools).  Running the pip install command again made it farther this time, but yielded an error stating that I had missing "BLAS/LAPACK libraries".  After more research, I discovered that I needed to install some numpy and scipy wheel files that have these necessary libraries built in.  I downloaded the wheel files and installed them (08_InstallNumpyWheel, 09_InstallSciPyWheel).  I ran the pip command again and another error resulted: no Cython module.  So I pip installed Cython and ran "pip install -r requirements.txt --user" and it was finally successfull (10_InstallRquirementsSuccess).
    
    Now I needed to run "python pull_data.py".  A first attempt didn't work because I was missing the kaggle.json file with the needed credentials for API authentication.  After copying that over (11_CopyKaggleJSON), it still wasn't working.  I realized that the python command was using a different version of Python (referencing an Anaconda installation/environment I had tried to get the BLAS/LAPACK error to clear before using the wheel installation approach).  Changing the command to "py pull_data.py" made the code run as it referenced the correct version of python (12_Python_Pull_Data).
    
    Running "py train_model.py" worked fine (13_Python_train_model), and so did "py score_model.py" (14_Python_score_model).  Looking at the Code folder I could see that all of the output was there (scoring model, CSV data files, and accuracy report)(15_final_output, 16_final_output).  So the migration of HW2 to the cloud using EC2 was a success.  




