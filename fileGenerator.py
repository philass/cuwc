#!/usr/bin/env python3

"""
Generates random txt files

Usage :
   python3 fileGenerator.py 9999     # Generates file data.txt with 9999 characters
"""

import sys
import random
import string

size = int(sys.argv[1])

alphabet = string.ascii_lowercase
special_chars = "\n" + "\t" + " "
chars = alphabet + special_chars

list_text = random.choices(list(chars), k = size)
text = "".join(list_text)

with open("data.txt", 'w') as f:
    f.write(text)
