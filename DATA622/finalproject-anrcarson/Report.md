## DATA622 Project
### Andy Carson
- Assigned on November 1, 2019
- Due on December 15, 2019 11:59 PM EST

### Report: Question 1
*Build an image recognition model. Please try to build the model and summarize your results. For the final project, you may choose any data set that you are interested in exploring. The key for the project is to see how you think through solving the problem. (20 points)*

#### Overview
I chose to use a different data set other than the MNIST assigned set per the additional instructions.  For my project I downloaded images of NFL logos for the four following teams that make up the NFC West: Cardinals, Rams, Seahawks, and 49ers.  My task was then to build an image classifier that correctly classified each logo image to the corresponding team.  I followed TensorFlow Keras tutorials (relying most heavily on the link here: https://www.tensorflow.org/tutorials/images/classification), as well as code snippets from around the internet, to build an end-to-end solution.  The final code (imageClassification.ipynb) ran on my personal machine.

Here are the files/folders contained in this repository:
* ModelImages: the results of downloadpics.py (the code used to search for and download images).  Sorted into train/test sets.
* Screenshots: screenshots of my progress along the way.  Images referenced below.
* README.md: initial instructions as well as additional instructions for the project.
* Report.md: this file.  The final report.
* downloadpics.py: the code used to leverage the Bing Image Search API to find and download images of NFL team logos for use in building the model.
* imageClassification.ipynb: the image processing and model building, training, and testing code.  

#### Image Search
I used the Bing Image Search API, available via Azure Cognitive Services, to search for images relating to NFL team logos.  After signing up for Azure and setting up the API, I used the key provided along with sample code to do my automated searching. For example, one search was for "seahawks logo", just as you would do an image search in Bing using a browser.  The results were then paged through, while each main image url was used for downloading the image locally for later use in training the model.

Not all images were useful or accurate for my purposes.  I manually combed through the roughly 800-900 images returned for each of the four teams to only retain those that I judged to accurately match the team in question.  I also needed to remove animated GIFs that created errors in code processing to keep only JPEGs.  This left about 600-700 images per team for a total of 2653 images.

#### Split into Train and Validation
Having gotten the images, I needed to split them into a training set and validation set for use in training the model.  I created some code to do this automatically using a 67% training 33% validation split.  The code pulled evenly from each team class.  This gave me 1765 training images and 888 validation images.  In exploring documentation for something else I learned that I could have used the "validation_split" in the image_generator to do this for me, but as this was no longer needed, I did not redo this (although I will redo this in the future if I decide to extend this project).

#### Training
I did several rounds of training using different methods for preventing overfitting, adding additional layers in the model, and using different kinds of image augmentation.  In particular, I experimented with the following:

* With and without data augmentation: image rotation, width shift, height shift, horizontal flip, and zoom. (see "trainingImages" and "trainingImages_withDataAug" screenshots for difference).
* With and without dropout layers
* With and without learning rate schedules
* With and without early stopping
* With and without L2 regularization

The basic model was a convolutional neural network (CNN).  Using the example of the tensorflow tutorial, I used a sequential model with three Conv2D layer / MaxPooling2D layer combinations (using ReLu activation) before a flatten/dense layer, with a final dense layer of 4 softmax outputs. 

#### Results

A brief history of the results is as follows:
* The initial model with 15 epochs had a training accuracy of 0.99 with a validation accuracy of 0.89.  Not bad, but quite a gap between training and validation.(results_01_originalCNN)
* Adding dropouts lowered the training accuracy to 0.92 and increased the validation accuracy to 0.85.  While decreasing the accuracy this did bring the training closer to the testing accuracy, avoiding overfitting to some degree. (results_02_addDropouts)
* Increasing the epochs to 25 increased the training accuracy back up to 0.99 and the validation accuracy up to 0.89.  No real improvement except that having more epochs gave the model more time to learn. (results_03_25Epochs)
* Adding all of the above data augmentation with 15 epochs lowered the training accuracy to 0.69 and the validation accuracy to 0.69.  This brought training and validation accuracy into alignment. (results_04_15Epochs_DataAug)
* I removed the horizontal flip as I didn't think this was fair to the logos (is the 49ers logo correct if it is backwards?) and increased to 25 epochs while implementing early stopping.  Training accuracy improved to 0.74 and validation accuracy to 0.81 (Note: I did not have data augmentation on the validation data, so these were easier to predict).  So a longer training time was important to improving the accuracy. (results_04_25Epochs_RemoveFlip)
* Adding a learning schedule and L2 regularization in one place increased the accuracy to 0.80 and the validation accuracy to 0.84.  These adjustments appeared to help the model learn better.  However, the model did not have to use early stopping, meaning that even 25 epochs was not long enough for training. (results_05_25Epochs_L2_LearningSch)
* I increased to 100 epochs.  The training accuracy went to 0.87 and the validation accuracy went to 0.88.  The model early stopped at 57 epochs.  I saved this model as the "data augmented" version. (results_06_100Epochs)
* I removed the data augmentation and reran the training model with the other additions in place.  Stopping at 52 epochs, the model had an accuracy of 0.98 and a validation accuracy of 0.90.  I saved this as the "no data augmentation" version of the model. (results_07_100Epochs_NoDataAug)

#### Prediction and Misclassified Images

To view the misclassified images, it was necessary (in so far as I could find based on documentation and online discussion) to predict the training images with the shuffle flag set to False.  I then converted the probabilities output by the model into the appropriate class value with the highest probability.  Then I matched these with the correct labels. The model with data augmentation using this method predicted 88.7% correctly on the training data (accuracy_modelWithDataAug). The accuracy when using the "no data augmentation" version of the model and this method was 99.6% on the training images (accuracy_modelWithNoDataAug), meaning that 7 were misclassified.  I viewed these individually.

Six of the seven images (see misclassifiedImages) were actually Rams images, and one was a 49ers image. Here is my best guess as to what happened.
* 49ers shirt classified as "Cardinals"/ Rams shirt classified as "Cardinals": if I look at the training data, the Cardinals have about 20 images of shirts with the Cardinal's logo on it.   The 49ers had fewer shirts and these didn't look as similar to the misclassified image (viewed straight on and flat image).  The Rams had only about 5 shirts.  Hence, the model learned that if it is a certain kind of shirt, it is "Cardinals".
* The exception to the above was a Rams shirt that was labelled as "FortyNiners".  This shirt is 3D looking and viewed from an angle.  The 49ers have a lot of these similar images whereas the Rams have very few.
* The Rams skull is labeled as "FortyNiners": The 49ers have three similar skulls (and another less similar one) in the training data while the Rams have one.  So "if it's a skull, its 'FortyNiners'" was the learned rule.
* Rams carpet circle labeled as Seahawks: Not really sure why.  There were other Rams carpet circles that correctly classified.  The Seahawks logo does have similar colors and geometry, and there were lots of round Seahawks logo images in the training set, so perhaps this is why.
* Rams lettering labeled as "FortyNiners":  the colors here are gray and white.  The 49ers do have some images that are similar, but perhaps it is the fact that the 49ers logo is usually an "SF" or says "49ers".  Meanwhile, the Rams logo usually is just the Ram, the horns, or the the Ram along with the spelled out "Rams".  But not really clear why this was misclassified.
* Rams player labeled as "FortyNiners": The 49ers have a lot more images of players than the Rams do.  I think absent a clear logo or symbol (e.g., side view of the helmet), the learned rule was "if a player, it is FortyNiners".


### Report: Question 2 (Critical Thinking)
*Submit a ~100 word explanation (or 1-3 page) of the potential choices and tradeoffs you may think through in the process of building this model.  (e.g. why you go X layers deep? why you choose X cost function?).  You can write up short paragraphs to explain what you have done and what are your key findings, what you may further enhance in the future. It can be 100 words or 2-3 pages. Please also submit the link for your code. (10 points)*

There are lots of variables I could still tweak in the model.  I largely left the initial variables in place that the tutorials used because they seemed to be working well in my testing, they presumably worked well for the tutorials, and they seemed to use best practices from the literature I have read for this sort of problem.  In the future I would experiment with different cost or activation functions, adding additional layers, changing the number of nodes within layers, and changing image sizes or batch sizes.  The changes and combinations I could make to the model are virtually infinite, and while I would expect some improvement, I don't know if much would change in terms of accuracy and generalizability with these model-specific tweaks.

However, I think the biggest improvements would come from better data.  I would try to get more data for each of the teams, and I would try to make the images more balanced across teams.  For example, I could try to balance out the number of images of players per team.  I could remove the "skull" images from the data unless there were similar images available for all of the teams.  That is, I would try to make it so that the only real difference among the images considered as a set for each team is the identifiable logo, symbol, etc. for that team.  I would do more experimentation with the data augmentation controls as well in order to make the model more generalizable to new images.  And I would experiment with the automatic splitting of the data into training and validation sets in hopes that the model would become more generalizable (and not just learn what was in a static training set).

Another future enhancement would be to expand the model to include other teams, and eventually all 32 NFL teams.  I would want to get the model performing very solidly on the current scope of teams and would definitely experiment with the tweaks and data augmentation mentioned above before.  But it would be nice to have a model that covers all teams.  This would be a much more extensive data collection effort, but could be a fun continuation of this project in the future.