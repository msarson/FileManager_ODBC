!ABCIncludeFile


  omit('_EndOfInclude_',_FileMgrODBC_)  

_FileMgrODBC_         equate(1)

  include('abFile.inc'),once
  include('aberror.inc'),once
  include('ODBCTypes.inc'),once
  include('odbcParamsCl.inc'),once
  include('odbcColumnsCl.inc'),once
  include('dynstr.inc'),once
  include('odbcCl.inc'),once
  
odbcErrorValue equate(byte)
defautlStrSize equate(50)

! ------------------------------------------------------------------------------
! Derived file manager that will use the ODBC API's for the calls.
! this is an example of the interface and if the project goes forward then 
! the interface will grow some
! 
! the base classes memebrs are nto overloaded here.
! file mamanger object is not well written, main issue is the class was 
! written after the templates or at least written for the templates, not good
! ------------------------------------------------------------------------------
FileMgrOdbc   class(FileManager),type,MODULE('FileMgrODBC.clw'),link('FileMgrODBC.clw',_ABCLinkMode_),dll(_ABCDllMode_)   

conn            &ODBCConnectionClType
odbc            &odbcClType

! ---------------------------------------------------------------------
! instance of the columns class.
! add the columns that will be filled from the result set that  the 
! query or a stored procedure produced
! 
! if this instance contains an empty queue of columns then the query 
! or stored procedure does not return a result set.
! ---------------------------------------------------------------------
Columns         &ColumnsClass

! ---------------------------------------------------------------------
! instance of the parameters class.
! add the parameters  that will be used by a query or a stored procedure
! 
! if this instance contains an empty queue of parameters then the query 
! or stored procedure does not accept parameters
! ---------------------------------------------------------------------
Parameters      &ParametersClass

! ---------------------------------------------------------------------
! overloaded file manager init method, 
! used to provide a location to do some set up for this object
! ---------------------------------------------------------------------
Init          procedure(),virtual 

! ----------------------------------------------------------
! clears any columns in the queue.  typically called 
! before after some operation so the columns are cleared 
! for the next binding call.  this can be called when ever 
! it is needed, before an operation or after.  
!
! do not call duing an operation or the bound columns will be lost
! ---------------------------------------------------------------------
ClearColumns   procedure()

! ----------------------------------------------------------
! clears any parameters  in the queue.  typically called 
! after some operation to clear the queue for the next pass
! 
! can be called any time, before or after
! if calling after be sure the operation has completed
! or the bound parameters will be lost
! ---------------------------------------------------------
ClearParameters procedure()

SetEnviorment  procedure(*ODBCConnectionClType  conn)

! ----------------------------------------------------------
! clears any columns and parameters used.  
! this is called from the diconnect function if the connection was 
! opened here, if not then the caller will need to do any clean up
!
! main issue with clearing is the use of multiple resutl sets.
! clearing the parameters would be fine, becasue the call has completed
! the columns may need to be cleared using a different queue in the second and 
! following reqult sets and in some cases they may 
! not need to be cleared, using the same queue for a like result set,  
! best to leave to the developer for the specific instance.
! ---------------------------------------------------------
ClearInputs procedure(),virtual

! --------------------------------------------------------------------------
! execute the sql statment input 
! this call does not return a result set but may use parameters 
! 
! note, the columns member is ignored by this call
! this can be used to execute queries that do DML statements or 
! DDL statements, 
! 
! example DML,
! insert into schema.Table(col_one, colTwo) values(?, ?);
!
! example DDL,
! alter database <database name> set single_user with rollback immediate;
! --------------------------------------------------------------------------
ExecuteNonQuery  procedure(*IDynStr sqlStatement),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the sql statment input 
! and get the value of an output parameter.  
! this call does not return a result set
!
! the withAuto parameter is used to tell the system this query is some type of 
! insert statement and there is a generated key or index value in use
! when calling to insert and get the generated value back set the paramerter to true
! and call with something like this 
! insert into schema.Table(col_one, colTwo) values(?, ?);
! select ? = scope_identity();
! or use a guid or a sequence generator, adjust the parameters as needed
! --------------------------------------------------------------------------
ExecuteNonQueryOut  procedure(*IDynStr sqlStatement, bool withAuto = false),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the sql statment input 
! this call will fill the queue with a result set
! --------------------------------------------------------------------------
ExecuteQuery  procedure(*IDynStr sqlStatement, *queue q),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the sql statment input 
! and get the value of an output parameter.  
! this call also returns a result set
! 
! note, the result set is processed first then the out parameters are set
! --------------------------------------------------------------------------
ExecuteQueryOut  procedure(*IDynStr sqlStatement, *queue q),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the query input in the string 
! this query returns a result set of one row and one column
!
! the query should be formatted in this manner 
! select count(columName) from schemaName.TableName;
! or if parameters are used
! select count(columName) from schemaName.TableName where someCol = paramOne and/or ...;
! for scalar functions format theinput like this
! select @retv = schema.FunctionLabel(...) 
! bind any parameters for the function and bind the returned value 
! --------------------------------------------------------------------------
ExecuteScalar procedure(*IDynStr scalarQuery),long,virtual

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure does not return a result set 
! --------------------------------------------------------------------------
callSp procedure(string spName),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure returns a result set
! --------------------------------------------------------------------------
callSp procedure(string spName, *queue q),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the query input in the string 
! this query returns a result set of one row and one column
!
! use this function to call a scalar function on the server
! --------------------------------------------------------------------------
callScalar procedure(string scalarQuery),long,virtual

! --------------------------------------------------------------------------
! opens a connection for a call to the server, if the connection is not 
! currently open.  
! returns Connection:Opened if the connection was opened,
! Connection:CallerOpened if the connection is already opened
! and Connection:Failed if it was not open and the open attempt failed.
! --------------------------------------------------------------------------
OpenConnection procedure(),byte,private 

! --------------------------------------------------------------------------
! closes  a connection
! the input value should be from the returned value of the OpenConnection call
! if the input is Connectio:Opened then connection is closed.  
! if any other value the connection is not closed because it was opened by the caller 
! or the open attempt failed
!
! note if the connection was opened here then the columns and parameters are cleared.
! if opened by some other calling code they are not cleared and the user must 
! do any needed clean up.  
! --------------------------------------------------------------------------
CloseConnection procedure(byte openedHere),private 

              end ! class

_EndOfInclude_