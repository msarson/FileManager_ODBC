# FileManager_ODBC

this is the interface and derived file manager that uses the ODBC api's directly.  It works now but there are some minor items that will be added so it should not be considered the final version.

the files in the ODBC directory are required.  The files in the demo and test are optional.

clone or fork the repo to your local system.  adjust the redirection files used to include these directories or copy the files to some existing directory.  copying the files is a bad idea for many reasons, the main one not getting updates, but your call

there is a lib file and a dll that are required for use by the file manager 
cla_bcp.lib and clabcp.dll 
there are copies in the demo and test directory and in the BCP directory 

the current BCP code is setup for use with ODBC 17.x.   If other versions are needed the dll will need to be rebuilt. 
