##########
# Download Images for Image Classification from Bing Image Search API

# References
# https://docs.microsoft.com/en-us/rest/api/cognitiveservices-bingsearch/bing-images-api-v7-reference
# https://docs.microsoft.com/en-us/azure/cognitive-services/bing-image-search/image-sdk-python-quickstart
# https://stackoverflow.com/questions/8286352/how-to-save-an-image-locally-using-python-whose-url-address-i-already-know

############


#load packages
import platform
print(platform.python_version())

import os

from azure.cognitiveservices.search.imagesearch import ImageSearchAPI
from msrest.authentication import CognitiveServicesCredentials

import urllib.request


#credentials
subscription_key = "<your key here>"

#search terms
search_term = "nfl rams logo" #"cardinals arizona logo" #"49ers logo" #"seahawks logo"
client = ImageSearchAPI(CognitiveServicesCredentials(subscription_key))

#loop through results to save images
for j in range(0, 10):

    offsetcount = j*100
    image_results = client.images.search(query=search_term, count=100, offset=offsetcount)

    #save images
    for i in range(0, len(image_results.value)):
        image_result = image_results.value[i]

        # image_result.thumbnail_url #thumbnail url
        image_url = image_result.content_url #large image url

        #save location
        main_path = r'<your path here>'
        folder_path = r'\Rams' + r'\rams_' #r'\Cardinals' + r'\cardinals_'#r'\FortyNiners' + r'\fortyniners_'#r'\Seahawks' + r'\seahawks_'
        file_path = str(i+1000 + offsetcount)+ r'.jpg'

        save_location = main_path + folder_path + file_path
        #print(save_location)
                                                        
        #save image
        try:
            urllib.request.urlretrieve(image_result.content_url,save_location)
        except:
            print("error on " + str(i+1000 + offsetcount))

        #print
        print(str(j)+ ": " + str(i+1000 + offsetcount))
