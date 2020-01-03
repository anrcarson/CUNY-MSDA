## DATA622 HW #4
#### Andrew Carson

### Details:
- Assigned on October 27, 2019
- Due on Nov 24, 2019 11:59 PM EST
- 17 points possible, worth 17% of your final grade

### Instructions:

Use the two resources below to complete both the critical thinking and applied parts of this assignment.

1. Listen to all the lectures in Udacity's [Intro to Hadoop and Mapreduce](https://www.udacity.com/course/intro-to-hadoop-and-mapreduce--ud617) course.  

2. Read [Hadoop A Definitive Guide Edition 4]( http://javaarm.com/file/apache/Hadoop/books/Hadoop-The.Definitive.Guide_4.edition_a_Tom.White_April-2015.pdf), Part I Chapters 1 - 3.

### Critical Thinking (10 points total)

Submit your answers by modifying this README.md file.

1. (1 points) What is Hadoop 1's single point of failure and why is this critical?  How is this alleviated in Hadoop 2?

    The main failure points in Hadoop concern disk failures.  For the data nodes, this isn't as much of a concern.  The data is duplicated three times, across different data nodes.  If the disk fails on one of the nodes, then that portion of the data is lost.  However, Hadoop can re-replicate that lost data from the other backups elsewhere.  However, if one has a disk failure on the name node, this is a serious problem.  The data can be lost forever since the metadata stored on the namenode is not duplicated elsewhere.  Also, if there was a network failure to the namenode, then the rest of the data on the data nodes would be inaccessible.  In Hadoop 2, there is a standby namenode that duplicates the information stored on the active namenode and which can take over if the active namenode fails.  In this way, the metadata is not lost.

2. (2 points) What happens when a data node fails?

    The namenode realizes that the data node has failed and then it copies the data that was on that data node to other data nodes to make sure that there are 3 copies of that data in existence.  It automatically re-replicates the data that was lost from the data node failure.

3. (1 point) What is a daemon?  Describe the role task trackers and job trackers play in the Hadoop environment.

    A daemon is a piece of software that is stored on each node in the cluster (the namenode and the data nodes).  This daemon is running all the time and is what processes the code.  The coordination of all of the processing happens on the namenode, which is where one submits the job to the job tracker.  This kicks of tasks for each data node, which is tracked by each datanode's tasktracker daemon.  The tasktracker on each data node is responsible for handling the actual MapReduce process ocurring on its data node.

4. (1 point) Why is Cloudera's VM considered pseudo distributed computing?  How is it different from a true Hadoop cluster computing?

    The VM is just running on one actual machine, but is mimicking what would happen if it was actually distributed across multiple machines.  So it is "pseudo" in the sense that it is not really distibuted computing, whereas a true Hadoop cluster computing network would involve multiple actual machines.

5. (1 point) What is Hadoop streaming? What is the Hadoop Ecosystem?

    Hadoop streaming is what allows someone to write code in one's preferred language (e.g., Python) and have it translated into Java, which is what the MapReduce job actually runs on.  In short, it is the translation of one coding language into Java.  The Hadoop ecosystem consists of core Hadoop (Hadoop Distributed File Systeam, or HDFS, and MapReduce) as well as the applications to support the core of Hadoop and make it easier to use.  For example, there is software to help load data into HDFS and then query it, which are called Pig and Hive.  Hive is a SQL like language used for querying the data that automatically translates those queries into the Java needed to actually pull the data from HDFS using MapReduce.  Pig is a simple scripting language that also allows for loading and querying data using a translation to MapReduce.  Impala is a language that directly accesses the data in HDFS instead of using MapReduce. Sqoop uses data from a traditional relational database and puts it into HDFS for querying use.  Flume takes data from external systems and puts it into HDFS.  HBase is a real-time database built on HDFS.  Hue is  graphical front end.  Oozie is a workflow management tool.  Mahout is a machine learning library.  All of these applications and services make up the Hadoop Ecosystem.

6. (1 point) During a reducer job, why do we need to know the current key, current value, previous key, and cumulative value, but NOT the previous value?

    The reducer is processing the sorted list of key/value pairs.  Supposing that it has been processing key X, then it needs to know if the current key is X.  If it is, it can add the current value associated with X to the cumulative value for X.  If it isn't, and is instead key Y, then it knows that the previous key was X and that this is a new key.  So it can instead output the previous cumulative value and then start a new cumulative value for Y using the current value for Y.  Nowhere in all of this is knowing the previous value necessary in order for the reducer to do its job.

7. (3 points) A large international company wants to use Hadoop MapReduce to calculate the # of sales by location by day.  The logs data has one entry per location per day per sale.  Describe how MapReduce will work in this scenario, using key words like: intermediate records, shuffle and sort, mappers, reducers, sort, key/value, task tracker, job tracker.  

    The mappers take chunks of the log and read in each line of their chunk, pulling out the day and location and perhaps the sales amount.  The day and location are combined to create a key: day-location, and the sales amount is kept as the value.  We now have key/value pairs that are being output by the mappers.  This is all done in parallel, and produces what are called the intermediate records, which are the key/value pairs.  Once each mapper has completed its task, the intermediate records are then passed on to the reducers.  This is the shuffle phase.  All of the same key from each of the mappers is passed to a single reducer, that is, all of the records for a key are now with a single reducer.  A reducer may have multiple keys, but for whatever key it has, it will have all of the records for that key.  

    Next, the intermediate records are sorted by the reducers according to the keys alphabetically.  This is the sort phase.  Finally, each reducer combines the matching data from all of the mappers based on the key.  In this particular example, a reducer will add up all of the counts of sales for all of the individual location-day keys from all of the mappers.  It does this by going down the sorted list of keys and dealing with each key one at a time to eventually count up all of those intermediate records from all of the mappers.  The final results are then written out (and can be repartitioned into a single dataset as desired) back to HDFS.

    All of this is organized and administered by using the namenode, which has the job tracker.  To run the above, one must submit the desired job to the job tracker on the namenode (e.g., calculate the number of sales by location by day), which organizes and plans the overall MapReduce process (e.g., split the job up for the mappers and reducers).  Running the actual MapReduce process on each data node is handled by the tasktracker daemons, which run on each data node and are responsible for the results on each data node.
    

### Applied (5 points total)

Submit the mapper.py and reducer.py and the output file (.csv or .txt) for the first question in lesson 6 for Udacity.  (The one labelled "Quiz: Sales per Category")  Instructions for how to get set up is inside the Udacity lectures.  

#### References
- https://www.cloudera.com/downloads/quickstart_vms/5-13.html
- https://d20vrrgs8k4bvw.cloudfront.net/documents/en-IN/BigDataVM.pdf
- https://docs.google.com/document/d/1MZ_rNxJhR4HCU1qJ2-w7xlk2MTHVqa9lnl_uj-zRkzk/pub
- https://community.cloudera.com/t5/Community-Articles/How-to-setup-Cloudera-Quickstart-Virtual-Machine/ta-p/35056
- https://www.youtube.com/watch?v=5Ijhj2IcdFQ (Share files with VM)

#### Solution
Question to answer: "Instead of breaking the sales down by store, instead give us a sales breakdown by product category across all of our stores."

Using the above references, I was able to create a VM (the original VM file I could not get working).  I had to create a Shared folder with my laptop file system (see screenshots 1_ShareFolderWithVM, 2_ShareFolderWithVM2).  Then I was able to run the hadoop commands to put the data into HDFS (3_PutDataIntoHadoopFS, 4_DataTail).  Then I was able to run the mapper and reducer files to get the output (mapper.py, reducer.py, output.txt).  Finally, I was able to confirm that my job produced the correct result (5_SubmitAnswer, 6_SubmitAnswers_Success).

