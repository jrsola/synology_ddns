# synology_ddns
Information to create a customized DDNS provider for Synology DSM

To add your own provided you need to change some files in the DSM. 
SSH into your Synology
sudo -i once you are there to work as a root

You can use your regular directories to update the files needed
Just copy the files between /volume1/yoursharedirectory and your 
local DSM directory

**/etc directory **
Do not touch anything in the /etc directory. 
It will contain the ddns_provider.conf with added regular customizations 
made from DSM interface itself
  ddns_provider.conf -> (dont' touch anything)

**/etc.defaults **
Append your customized DDNS provider in the ddns_provider.conf file
Just add it to the end of the file with a text editor

* name of your custom ddns provided enclosed in square brackets
* path and filename of your bash .sh script to handle the ddns update
* queryurl and website are just cosmetics for your module

example:

```
  ddns_provider.conf 
    [customized service name, just for displaying]
      modulepath=/sbin/script_name.sh
      queryurl=https://www.ddns_provider.com
      website=https://www.ddns_provider.com
```
