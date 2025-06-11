import os
import datetime

path = 'C:\\Users\\Zain\\Desktop\\test'

files = print(os.listdir(path))
creation_time = os.path.getctime(path)

# print(creation_time)

# readable_time = datetime.datetime.fromtimestamp(creation_time)

# print(readable_time)

for data in files:
    data = os.path.getctime(path)
    readable_time = datetime.datetime.fromtimestamp(data)

    print(readable_time)
