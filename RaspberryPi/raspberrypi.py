import sys
import matplotlib.image as mpimg
import requests
import json

def sendImage(image):
	json_str = json.dumps({"image": image})
	r = requests.post("http://xxx.xxx.xxx.xxx:8000/"+json_str) 

if  __name__ == '__main__':
	imagePath = sys.argv[1]
	image = mpimg.imread(imagePath)
	sendImage(image)
