  member

  include('FileMgrODBC.inc'),once
  include('odbcTypes.inc'),once

  map 
    module('odbc32')
      SQLAllocHandle(SQLSMALLINT HandleType, SQLHANDLE InputHandle, *SQLHANDLE OutputHandlePtr),SqlReturn,pascal,name('SQLAllocHandle')
      SQLFreeHandle(SqlSmallInt hType, SqlHandle h),long,pascal
      SQLFreeStmt(SQLHSTMT StatementHandle, SQLSMALLINT opt),sqlReturn,pascal,proc
      SQLSetEnvAttr(SQLHENV EnvironmentHandle, SQLINTEGER Attribute,  SQLPOINTER Value, SQLINTEGER StringLength),sqlReturn,pascal
    end 

  end

FileMgrODBC.SetEnviorment  procedure(*ODBCConnectionClType  conn)

  code 

  self.conn &= conn
  self.odbc &= new(odbcClType)
  self.odbc.init(self.conn)

  return
! ----------------------------------------------------------  

FileMgrODBC.GetEnv  procedure() !,SQLHENV

  code

  return 0
! ---------------------------------------------------------

FileMgrODBC.ClearColumns   procedure()

  code
  return

FileMgrODBC.ClearParameters procedure()

  code
  return

FileMgrODBC.ExecuteNonQuery procedure(*IDynStr sqlStatement) !,virual,SQLRETURN

hDbc    SQLHDBC,auto
retv    sqlReturn(SQL_SUCCESS)

  code
 
  retv = self.conn.connect();
  if (retv = SQL_SUCCESS) 
    retv = self.odbc.execQuery(sqlStatement)    
  end 

  return retv
! -------------------------------------------------------------

FileMgrODBC.ExecuteQuery  procedure(*IDynStr sqlStatement, *queue q) !,virtual,sqlreturn

   code 

   return 0

! --------------------------------------------------------------------------
! execute the sql statement input 
! and get the value of an output parameter.  
! this call does not return a result set
! 
! the group may contain one to n fields, each field must be bound prior to the call
! if the field is used as an out parameter.  the group may contain many fields and 
! only one or two are actually used as out parameters.
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteQueryOut  procedure(*IDynStr sqlStatement, *group outParameters) !,virtual,sqlreturn

  code
  return 0  
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
FileMgrODBC.ExecuteQueryOut  procedure(*IDynStr sqlStatement, *queue q, *group outParameters) !,virtual,sqlreturn

  code
  return 0

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure does not return a result set 
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteSp procedure(string spName) !,virtual,sqlreturn

  code
  return 0  

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure returns a result set
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteSp procedure(string spName, *queue q) !,virtual,sqlreturn

  code
  return 0

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
FileMgrODBC.ExecuteScalar procedure(*IDynStr scalarQuery) !,long,virtual

  code
  return 0