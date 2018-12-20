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

! -----------------------------------------------------
! used to store queries in some resource outside of the 
! application.  
! the list would be loaded when and then the 
! not yet added to the derived file manger interface
! -----------------------------------------------------
queryQueue    queue,type
ObjectName      string(defautlStrSize)
groupName       string(defautlStrSize)
queryStr        &IDynStr
              end

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
! not really needed but provides a good location to do some set up for 
! this object
! ---------------------------------------------------------------------
Init          procedure(),virtual 

! ---------------------------------------------------------------------
! clears the data meber of any columns 
! typical use would be 
! FileMgrOdbc.ClearColumns()
! FileMgrOdbc.Columns.AddColumns(...)
! FileMgrOdbc.Columns.AddColumns(...)
! FileMgrOdbc.ExecuteSp(some statement)
! ---------------------------------------------------------------------
ClearColumns   procedure()

! ---------------------------------------------------------------------
! clears the data meber of any parameters
! typical use would be 
! FileMgrOdbc.ClearParameters()
! FileMgrOdbc.Parameters.AddInParameter(...)
! FileMgrOdbc.Parameters.AddInParameter(...)
! FileMgrOdbc.ExecuteSp(some statement)
! ---------------------------------------------------------------------
ClearParameters procedure()

SetEnviorment  procedure(*ODBCConnectionClType  conn)

! ----------------------------------------------------------
! clears any columns and parameters used.  
! this is called from the diconnect function if the connection was 
! opened here, if not then the caller will need t odo any clean up
!
! main issue with clearing is the use of multiple resutl sets.
! clearing the parameters would be fine, the columns may need to 
! be cleared and they may not need to be cleared, best to leaveto the 
! developer for the specific instance.
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
! this call will fill the queue with a result set
! --------------------------------------------------------------------------
ExecuteQuery  procedure(*IDynStr sqlStatement, *queue q),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the sql statment input 
! and get the value of an output parameter.  
! this call does not return a result set
! 
! the group may contain one to n fields, each field must be bound prior to the call
! if the field is used as an out parameter.  the group may contain many fields and 
! only one or two are actually used as out parameters.
! --------------------------------------------------------------------------
ExecuteQueryOut  procedure(*IDynStr sqlStatement, *group outParameters),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the sql statment input 
! and get the value of an output parameter.  
! this call also returns a result set
! 
! the group may contain one to n fields, each field must be bound prior to the call
! if the field is used as an out parameter.  the group may contain many fields and 
! only one or two are actually used as out parameters.
! 
! note, the result set is processed first then the out parameters are set
! --------------------------------------------------------------------------
ExecuteQueryOut  procedure(*IDynStr sqlStatement, *queue q, *group outParameters),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure does not return a result set 
! --------------------------------------------------------------------------
ExecuteSp procedure(string spName),virtual,sqlreturn

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure returns a result set
! --------------------------------------------------------------------------
ExecuteSp procedure(string spName, *queue q),virtual,sqlreturn

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
! opens a connection for a call to the server, if the connection is not 
! currently open.  
! returns true if the connection was opened and false if it ws not opened.
! false does not indicate an error, but that connection was opened before 
! the current call.
! --------------------------------------------------------------------------
OpenConnection procedure(),byte,private 

! --------------------------------------------------------------------------
! closes  a connection
! the input value should be from the returned value of the OpenConnection call
! if the inpput is true then connection is closed.  if false the connection is not closed
! --------------------------------------------------------------------------
CloseConnection procedure(byte openedHere),private 

              end ! class

_EndOfInclude_