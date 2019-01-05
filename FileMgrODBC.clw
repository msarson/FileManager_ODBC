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
      SQLNumResultCols(SQLHSTMT StatementHandle,  *SQLSMALLINT ColumnCountPtr),sqlReturn,pascal
      SetStmtAttr(SQLHSTMT StatementHandle, SQLINTEGER Attribute, SQLPOINTER ValuePtr, SQLINTEGER StringLength),sqlReturn,pascal,name('SQLSetStmtAttrW')
      SetStmtEvent(SQLHSTMT StatementHandle, SQLINTEGER Attribute, SQLPOINTER ValuePtr, SQLINTEGER StringLength),sqlReturn,pascal,name('SQLSetStmtAttrW')
      SQLSetConnectAttr(SQLHDBC ConnectionHandle,  SQLINTEGER    Attribute, SQLPOINTER ValuePtr, SQLINTEGER StringLength),sqlreturn,pascal,name('SQLSetConnectAttrW')
    end 
  end

! ---------------------------------------------------------------------
! overloaded file manager init method, 
! used to provide a location to do some set up for this object
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
! before after some operation so the columns are cleared 
! for the next binding call.  this can be called when ever 
! it is needed, before an operation or after.  
! do not call duing an operation or the bound columns will be lost
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
! clears any parameters  in the queue.  typically called 
! after some operation to clear the queue for the next pass
! 
! can be called any time, before or after
! if calling after be sure the operation has completed
! or the bound parameters will be lost
! ---------------------------------------------------------
FileMgrODBC.ClearParameters procedure()

  code

  self.Parameters.clearQ()

  return
! end ClearParameters ---------------------------------------------------------

! ----------------------------------------------------------
! clears any columns and parameters used.  
! this is called from the disconnect function if the connection was 
! opened here, if not then the caller will need to do any clean up
!
! main issue with clearing is the use of multiple resutl sets.
! clearing the parameters would be fine, becasue the call has completed
! the columns may need to be cleared using a different queue in the second and 
! following reqult sets and in some cases they may 
! not need to be cleared, using the same queue for a like result set,  
! best to leave to the developer for the specific instance.
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

  if (openedHere <> Connection:Failed) 
    retv = self.odbc.execQuery(sqlStatement)    
  end 

  self.closeConnection(openedHere)

  return retv
! end ExecuteNonQuery -------------------------------------------------------------

! --------------------------------------------------------------------------
! execute the sql statment input 
! and get the value of an output parameter.  
! this call does not return a result set
!
! the withAuto parameter is used to tell the system this query is some type of 
! insert statement and there is a generated key of some type
! when calling to insert and get the generated value back set the paramerter to true
! and call with something like this 
! insert into schema.Table(col_one, colTwo) values(?, ?);
! select ? = scope_identity();
! or use a guid or a sequence generator, adjust the parameters as needed
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteNonQueryOut  procedure(*IDynStr sqlStatement, bool withAuto = false) !,virtual,sqlreturn

retv        sqlReturn(SQL_ERROR)
openedHere  byte,auto
rows        short,auto

  code
 
  openedHere = self.OpenConnection()

  if (openedHere <> Connection:Failed) 
    retv = self.odbc.execQueryOut(sqlStatement, self.Parameters)
    if (withAuto = true) 
      if (self.odbc.nextResultSet() = true)
        retv = self.odbc.fetch()
      end
    end 
  end

  self.closeConnection(openedHere)

  return retv
! end ExecuteQueryOut ------------------------------------------------------------- 

! --------------------------------------------------------------------------
! execute the sql statment input 
! this call will fill the queue with a result set
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteQuery  procedure(*IDynStr sqlStatement, *queue q) !,virtual,sqlreturn

retv        sqlReturn(SQL_ERROR)
openedHere  byte,auto

  code
 
  openedHere = self.OpenConnection()
  if (openedHere <> Connection:Failed) 
    retv = self.odbc.execQuery(sqlStatement, self.columns, self.Parameters, q)
  end 

  self.closeConnection(openedHere)

  return retv
! end ExecuteQuery -------------------------------------------------------------

! --------------------------------------------------------------------------
! execute the sql statment input 
! and get the value of one or more output parameters.  
! this call also returns a result set
! 
! note, the result set is processed first then the out parameters are set
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteQueryOut  procedure(*IDynStr sqlStatement, *queue q) !,virtual,sqlreturn

retv        sqlReturn(SQL_ERROR)
openedHere  byte,auto

  code
 
  openedHere = self.OpenConnection()

  if (openedHere <> Connection:Failed) 
    retv = self.odbc.execQuery(sqlStatement, self.columns, self.Parameters, q)
    if (retv = SQL_SUCCESS)
      if (self.odbc.nextResultSet() = true)

      end
    end 
  end
  
  self.closeConnection(openedHere)

  return retv
! end ExecuteQueryOut ------------------------------------------------------------- 

! --------------------------------------------------------------------------
! calls a scalar function and retruns the returned value
! --------------------------------------------------------------------------
FileMgrODBC.ExecuteScalar procedure(*IDynStr scalarQuery) !,long,virtual

retv        long,auto
openedHere  byte,auto

  code

  openedHere = self.OpenConnection()
  
  if (openedHere <> Connection:Failed) 
    retv = self.odbc.ExecQueryOut(scalarQuery, self.Parameters)
  end 

  self.closeConnection(openedHere)
  
  return retv
! end ExcuteSclar --------------------------------------------------------

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure does not return a result set but 
! may have output parameters
! --------------------------------------------------------------------------
FileMgrODBC.callSp procedure(string spName) !,virtual,sqlreturn

retv        sqlReturn(SQL_ERROR)
openedHere  byte,auto

  code
 
  openedHere = self.OpenConnection()
  if (openedHere <> Connection:Failed) 
    retv = self.odbc.ExecSp(spName, self.Parameters)
  end 

  self.closeConnection(openedHere)

  return retv
! end ExecuteSpOut ----------------------------------------------------------

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure returns a result set
! --------------------------------------------------------------------------
FileMgrODBC.callSp procedure(string spName, *queue q) !,virtual,sqlreturn

retv       sqlReturn(SQL_ERROR)
openedHere byte,auto

  code

  openedHere = self.OpenConnection()

  if (openedHere <> Connection:Failed) 
    retv = self.odbc.execSp(spName, self.columns, self.Parameters, q)
    if (retv <> SQL_SUCCESS)
      ! handle error messages
      ! not sure how it will be done      
    end
  end

  self.closeConnection(openedHere)
  
  return retv
! end ExecuteSp ------------------------------------------------------------

! --------------------------------------------------------------------------
! execute the stored procedure input in the string 
! this stored procedure returns multiple result sets
! 
! this one needs to be overloaded in a derived instance
! there will be more than one buffer is use and those buffers
! may change for each result set.  the queue parameter will be used 
! for the first result set.  the remaining result sets will have a buffer 
! defined in the over loaded function
! --------------------------------------------------------------------------
FileMgrODBC.callSpMulti procedure(string spName, *queue q) !,virtual,sqlreturn

  code
  return SQL_ERROR
! end callSpMulti ---------------------------------------------------------------  

! --------------------------------------------------------------------------
! calls a scalar function and retruns the returned value
! --------------------------------------------------------------------------
FileMgrODBC.callScalar procedure(string  fxName) !,long,virtual

retv        long(SQL_ERROR)
openedHere  byte,auto

  code

  openedHere = self.OpenConnection()
  
  if (openedHere <> Connection:Failed) 
    retv = self.odbc.callScalar(fxName, self.Parameters)
  end 

  self.closeConnection(openedHere)
  
  return retv
! end ExcuteSclar --------------------------------------------------------

! --------------------------------------------------------------------------
! read the second, third, ... resutls sets.  this can be from a query 
! or a stored procedure.  
! --------------------------------------------------------------------------
FileMgrODBC.readNextResult procedure(*queue q, *ColumnsClass cols) !,sqlreturn

retv  sqlReturn,auto

  code

  ! move to the next result set
  if (self.odbc.nextResultSet() = true)  
     if (cols.bindColumns(self.conn.getHStmt()) = SQL_SUCCESS)
       retv = self.odbc.readNextResult(q)
     end
  else 
    ! no more results
    retv = SQL_NO_DATA   
  end

  return retv
! end readNextResult -------------------------------------------------------

! --------------------------------------------------------------------------
! opens a connection for a call to the server, if the connection is not 
! currently open.  
! returns Connection:Opened if the connection was opened,
! Connection:CallerOpened if the connection is already opened
! and Connection:Failed if it was not open and the open attempt failed.
! --------------------------------------------------------------------------
FileMgrODBC.OpenConnection procedure() ! ,byte

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
! if opened by some other calling code they are not cleared and the user must 
! do any needed clean up.  
! --------------------------------------------------------------------------
FileMgrODBC.CloseConnection procedure(byte openedHere) 

  code

  if (openedHere = Connection:opened)
    self.ClearInputs()
    self.conn.disconnect()
  end 

  return
! end closeConnection ------------------------------------------------------