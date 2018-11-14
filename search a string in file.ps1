﻿
 Below command is used to search for a string in a file named "myfile.txt"
 ReadCount attribute reads the number of lines upto 10000000
 So for each line it tries to match with the string "hostname" in the file "myfile.txt"
 
 get-content myfile.txt -ReadCount 10000000 | foreach { $_ -match "hostname" }
