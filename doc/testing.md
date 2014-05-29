# Testing your changes on HDA-Platform

After making changes in Amahi-Platform, if you want to test the change on HDA-Platform, then follow the following steps:

###By keeping a copy of original code.
#### Go to hda-platform folder.
````bash
cd /var/hda/platform
````
#### Make a "golden" copy of the tree as released.
````bash
 cp -a html golden-html 
````

#### Make your changes and Restart stack 
Make your changes in html/
Restart the stack to see the changes
````bash
touch restart.txt
````