# import all outside modules for program

import requests
import soupsieve
import json
import sys
import time
from bs4 import BeautifulSoup
import csv
import os
import re
from re import sub, finditer
 
# This is the url with java script we want to parser | get html from site

def get_board_threads(board):

    url = "http://4chan.org/" + board + "/catalog"
    html = requests.get(url).text 
    data = {}
    data['threads'] = []
    # Get URLs of all active threads of a board
    # I understand that this code is very hacked together
    # the while loop reads from an identifiable section of
    # the HTML backwards to the end of each thread ID.
    # BeautifulSoup cannot work with this because the respose
    # is actually a JSON object (I belive)
    
    # '":{"date"' is the only unique pattern found near each thread ID
    thread_start = [x.start() for x in finditer('":{"date"', html)]

    for indice in thread_start:
        thread_id = ""
        counter = 1
        while html[indice-counter] != '"':
            thread_id = html[indice-counter] + thread_id
            counter += 1
        data['threads'].append({'thread_board': board , 'thread_id': thread_id})

    for item in data['threads']:
        indicies = [x.start() for x in finditer(item['thread_id'], html)]
        # print(indicies)
        for indice in indicies:
            thread_crawler = ""
            counter = 1
            while False != True:
                # 
                # 
                thread_crawler = thread_crawler + html[(indice-2)+counter] 
                             
                counter += 1
                # print(thread_crawler)
                subject_start = thread_crawler.find(',"sub":"')
                if subject_start != -1: 
                    # add index where sub html attribute starts to index where specific thread id starts
                    subject_start = subject_start + indice
                    break
            # print("subject start index: " + str(subject_start) + " subject content index: " +  str(html[subject_start]) )
            
            thread_crawler = ""
            counter = 1
            while False != True:
                # 
                # 
                thread_crawler = thread_crawler + html[(subject_start-2)+counter] 
                # print(html[indice+counter])
                counter += 1
                # print(thread_crawler)
                teaser_start = thread_crawler.find(',"teaser":"')
                if teaser_start != -1: 
                    # add index where teaser html attribute starts to index where specific thread id starts
                    teaser_start = teaser_start + subject_start
                    break
                # item.update({'thread_subject': thread_subject})
            subject_end = teaser_start-1        
            # print("subject content: " + str(html[subject_start+6:subject_end]) )
            # print("teaser start index: " + str(teaser_start) + " teaser content index: " +  str(html[teaser_start+9]) )
            item.update({'thread_subject': html[subject_start+7:subject_end-1]})
            thread_crawler = ""
            counter = 1
            while False != True:
                
                thread_crawler = thread_crawler + html[(subject_end-2)+counter] 
                # print(html[indice+counter])
                counter += 1
                # print(thread_crawler)

                # end of threads is noted by end of html thread array which looks like this in the html "}},
                teaser_end = thread_crawler.find('"},') + thread_crawler.find('"}},')
                if teaser_end != -2: 
                    # add index where teaser html attribute starts to index where specific thread id starts
                    teaser_end = teaser_end + subject_end
                    break
            # print("teaser content: " + str(html[teaser_start+9:teaser_end]) )
            item.update({'thread_teaser': html[teaser_start+10:teaser_end-1]})

        # print(item)
    
    
    # Omit the first post, because it's always a
    # mod's sticky for the board
    return data['threads'][1:] 

def main():
         
  # total arguments
  n = len(sys.argv)
  print("Total arguments passed:", n)
 
  # Arguments passed
  print("\nName of Python script:", sys.argv[0])
  print("\nArguments passed:", end = " ")
  

  threads = get_board_threads(sys.argv[1])
  
  if len(sys.argv) > 2:
    for i in range(2, n):
        threads.extend(get_board_threads(sys.argv[i]))

  

  print (json.dumps(threads, indent=4, sort_keys=True))
  

main()
