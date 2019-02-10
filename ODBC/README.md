# cla_Odbc
Demo of using ODBC 13 with Clarion win32.

Demo shows how to use the ODBC 13.1 driver with clarion.  the demo will work wit h11 and 17.1, 17.2 and 17.3


The ODBC 13 driver does not expose ANSI strings functions only wide strings. Clarion does not support wide strings,
at least not yet. some day, soon (tm), maybe, it could happen, ...

Anyway. the code uses the svcom.* files to convert the ansi string from clarion to wide srings required by the driver.  Most functions do not use string but the ones that do require wide strings.

there are examples of calling a query, 
calling stored procedures, with and without parameters,
calling a stored procedure with multiple result sets, the demo use two result sets.
caling a stored proceudre with out parameters,
calling a scalar function,
calling a stored procedure with a table valued parameter, the table input can be used to insert, update and delete rows.

There is a backup of a small 2014 database, file name is odbcdemo.bakup.  the .bakup extension ise used because .bak files are in the git ignore.  be sure to change the default extension when restoring.
