# import all outside modules for program

import requests
import soupsieve
import json
from bs4 import BeautifulSoup
import csv
import os
from re import sub, finditer
 
# This is the url with java script we want to parser | get html from site

def get_board_thread_ids(html):

    data = {}
    data['threads'] = []
    # Get URLs of all active threads of a board
    # I understand that this code is very hacked together
    # the while loop reads from an identifiable section of
    # the HTML backwards to the end of each thread ID.
    # BeautifulSoup cannot work with this because the respose
    # is actually a JSON object (I belive)
    
    # '":{"date"' is the only unique pattern found near each thread ID
    indicies = [x.start() for x in finditer('":{"date"', html)]

    for indice in indicies:
        thread_id = ""
        thread_subject = ""
        thread_teaser = ""
        counter = 1
        while html[indice-counter] != '"':
            thread_id = html[indice-counter] + thread_id
            counter += 1
        data['threads'].append({'thread_id': thread_id})
    # Omit the first post, because it's always a
    # mod's sticky for the board
    return data['threads'][1:] 

def main():
  
  url = "http://4chan.org/wsg/catalog"
  html = requests.get(url).text
  threads = get_board_thread_ids(html)

  for item in threads:
      # TEST add key value to thread object
      item.update({'thread_subject': ''})
      print(item)
  

main()
