  member

  include('FileMgrODBC.inc'),once
  include('odbcTypes.inc'),once
  include('odbcConn.inc'),once

  map 
    module('odbc32')
      SQLAllocHandle(SQLSMALLINT HandleType, SQLHANDLE InputHandle, *SQLHANDLE OutputHandlePtr),SqlReturn,pascal,name('SQLAllocHandle')
      SQLFreeHandle(SqlSmallInt hType, SqlHandle h),long,pascal
      SQLFreeStmt(SQLHSTMT StatementHandle, SQLSMALLINT opt),sqlReturn,pascal,proc
      SQLSetEnvAttr(SQLHENV EnvironmentHandle, SQLINTEGER Attribute,  SQLPOINTER Value, SQLINTEGER StringLength),sqlReturn,pascal
    end 
  end

! ---------------------------------------------------------------------
! overloaded file manager init method, 
! not really needed but provides a good location to do some set up for 
! this object
! ---------------------------------------------------------------------
FileMgrODBC.Init procedure() !,virtual 

  code 

  ! call the base object
  parent.Init()

  ! allocate the column and parameter objects
  self.columns &= new(columnsClass)
  self.columns.Init()
  
  self.Parameters &= new(ParametersClass)
  self.Parameters.Init()
  
  return 
! end Init -------------------------------------------------------------

! ----------------------------------------------------------
! sets the instance connection member to the one input
! that was created by the caller. 
! ---------------------------------------------------------
FileMgrODBC.SetEnviorment  procedure(*ODBCConnectionClType  conn)

  code 

  self.conn &= conn
  self.odbc &= new(odbcClType)
  self.odbc.init(self.conn)

  return
! end SetEnviorment ----------------------------------------------------------  

! ----------------------------------------------------------
! clears any columns in the queue.  typically called 
! before some operation and so the columns are cleared 
! for the next binding call
! ---------------------------------------------------------
FileMgrODBC.ClearColumns   procedure()

  code

  self.columns.clearQ()
  ! now make sure in the ODBC layer the columns are unbound
  ! if none currently bound then the call does no harm
  self.odbc.unBindColums()

  return
! end ClearColumns ------------------------------------------------------------

! ----------------------------------------------------------
! clears any columns in the queue.  typically called 
! before some operation and  the next set of parameters are used
! ---------------------------------------------------------
FileMgrODBC.ClearParameters procedure()

  code

  self.Parameters.clearQ()

  return
! end ClearParameters ---------------------------------------------------------

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
FileMgrODBC.ClearInputs procedure() !,virtual

  code

  self.ClearColumns()
  self.ClearParameters()

  return
! end ClaerInputs ---------------------------------------------------------   

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
FileMgrODBC.ExecuteNonQuery procedure(*IDynStr sqlStatement) !,virual,SQLRETURN

retv        sqlReturn(SQL_SUCCESS)
openedHere  byte,auto

  code
 
  openedHere = self.OpenConnection()
  if (retv = SQL_SUCCESS) 
    retv = self.odbc.execQuery(sqlStatement)    
  end 

  self.closeConnection(openedHere)

  return retv
! end ExecuteNonQuery -------------------------------------------------------------

! --------------------------------------------------------------------------
! execute the sql statment input 
! this call will fill the queue with a result set
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteQuery  procedure(*IDynStr sqlStatement, *queue q) !,virtual,sqlreturn

retv        sqlReturn(SQL_SUCCESS)
openedHere  byte,auto

  code
 
  openedHere = self.OpenConnection()
  if (retv = SQL_SUCCESS) 
    retv = self.odbc.execQuery(sqlStatement, self.columns, self.Parameters, q)
  end 

  self.closeConnection(openedHere)

  return retv
! end ExecuteQuery -------------------------------------------------------------

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

retv        sqlReturn(SQL_SUCCESS)
openedHere  byte,auto

  code
 
  openedHere = self.OpenConnection()
  if (retv = SQL_SUCCESS) 
    
  end 

  self.ClearInputs()

  return retv
! end ExecuteQueryOut ------------------------------------------------------------- 

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

retv        sqlReturn(SQL_SUCCESS)
openedHere  byte,auto

  code
 
  openedHere = self.OpenConnection()
  if (retv = SQL_SUCCESS) 
    
  end 
  
  self.closeConnection(openedHere)

  return retv
! end ExecuteQueryOut ------------------------------------------------------------- 

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure does not return a result set 
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteSp procedure(string spName) !,virtual,sqlreturn

retv       sqlReturn(SQL_SUCCESS)
p          &ParametersClass
openedHere byte,auto

  code
 
  openedHere = self.OpenConnection()

  if (retv = SQL_SUCCESS) 
    if (self.Parameters.hasParameters() = true)
      retv = self.odbc.ExecSp(spName, self.Parameters)
    else 
      retv = self.odbc.ExecSp(spName, p)
    end  
  end 

  self.closeConnection(openedHere)
  
  return retv
! end ExecuteSp ---------------------------------------------------------------------

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure returns a result set
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteSp procedure(string spName, *queue q) !,virtual,sqlreturn

retv       sqlReturn(SQL_SUCCESS)
openedHere byte,auto

  code

  openedHere = self.OpenConnection()

  if (openedHere <> Connection:Failed) 
    if (self.Parameters.hasParameters() = true)
      retv = self.odbc.execSp(spName, self.columns, self.Parameters, q)
    else 
      retv = self.odbc.execSp(spName, self.columns, q)
    end
    if (retv <> SQL_SUCCESS)
      ! handle error messages
      ! not sure how it will be done      
    end
  end

  self.closeConnection(openedHere)
  
  return retv
! end ExecuteSp ------------------------------------------------------------

! --------------------------------------------------------------------------
! calls a sclar function and retruns the rhe returned value
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteScalar procedure(*IDynStr scalarQuery) !,long,virtual

retv        long,auto
openedHere  byte,auto

  code

  openedHere = self.OpenConnection()
  
  if (openedHere <> Connection:Failed) 
    retv = self.odbc.callScalar(scalarQuery.str(), self.Parameters)
  end 

  self.closeConnection(openedHere)
  
  return retv
  ! end ExcuteSclar --------------------------------------------------------

! --------------------------------------------------------------------------
! opens a connection for a call to the server, if the connection is not 
! currently open.  
! returns true if the connection was opened and false if it ws not opened.
! false does not indicate an error, but that connection was opened before 
! the current call.
! --------------------------------------------------------------------------
FileMgrODBC.OpenConnection procedure() ! ,bool,private 

res  sqlreturn,auto
retv byte,auto

  code 
 
  ! if not open then open it
  if (self.conn.isConnected() = false)
    res = self.conn.connect();
    if (res = SQL_SUCCESS)
      retv = Connection:Opened
    else
      retv = Connection:Failed
    end  
  else 
    retv = Connection:CallerOpened
  end
  
  return retv
! end OpenConnection -------------------------------------------------------

! --------------------------------------------------------------------------
! closes  a connection
! the input value should be from the returned value of the OpenConnection call
! if the input is Connectio:Opened then connection is closed.  
! if any other value the connection is not closed because it was opened by the caller 
! or the open attempt failed
!
! note if the connection was opened here then the columns and parameters are cleared.
! if opened by some calling code they are not cleared.  
! --------------------------------------------------------------------------
FileMgrODBC.CloseConnection procedure(byte openedHere) !,private 

  code

  if (openedHere = Connection:opened) 
    self.ClearInputs()
    self.conn.disconnect()
  end 

  return
! end closeConnection ------------------------------------------------------