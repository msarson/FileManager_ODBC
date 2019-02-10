
  member()
  
  include('odbcColsCl.inc'),once 

  map 
    module('odbc32')
      SQLBindCol(SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLSMALLINT TargetType, SQLPOINTER TargetValuePtr, SQLLEN BufferLength, *SQLLEN StrLen_or_Ind),sqlReturn,pascal
    end
  end
! ---------------------------------------------------------------------------

columnsClass.construct procedure()  

  code 
  
  self.init()
  
  return 
! end construct
! ------------------------------------------------------------------------------
  
columnsClass.init procedure()

retv      byte(level:benign)

  code 
     
  if (self.colQ &= null) 
    self.colq &= new(columnsQueue)
    if (self.colQ &= null) 
      retv = level:notify
    end 
  end 
      
  return retv
! end init 
! ------------------------------------------------------------------------------
  
columnsClass.kill procedure()

  code 

  if (~self.colQ &= null)
    free(self.colQ)
    dispose(self.colQ)
    self.colQ &= null
  end    
  
  return
! end kill
! ------------------------------------------------------------------------------

columnsClass.destruct procedure()

  code 

  self.kill()  
  
  return 
! end destruct
! ------------------------------------------------------------------------------

! -----------------------------------------------------------------------------
! bindCols
! Bind the queue fields to the columns in the result set.
! Fields and colums must be in the same order, ie the select statement should match 
! the queue buffer.  
! mapping is ordinal not by name
! 
! parameters for the ODBC api call 
! hStmt   = handle to the ODBC statement
! colId = ord value of the parmaeter, 1, 2, 3 ... the ordinal position
! colType = the C data type of the column 
! colValue = pointer to the queue field 
! colSize = the size of the buffer or the queue field 
! colInd = pointer to a buffer for the size of the parameter. not used and null in this example 
! 
! SQLBindCol returns only one information messages and it is the driver specific 
! Genenral warning, 
! -----------------------------------------------------------------------------    
columnsClass.bindColumns procedure(SQLHSTMT hStmt) ! sqlReturn

retv      sqlReturn
colInd    &long
x         long,auto

  code 
 
  loop x = 1 to records(self.colq)
    get(self.colQ, x)
    retv = SQLBindCol(hStmt, self.colQ.colId, self.Colq.colType, self.colQ.colValue, self.Colq.colSize, colInd)
    if (retv <> sql_Success) and (retv <> Sql_Success_With_Info) 
      break
    end  
  end   
  
  return retv 
! end bindColumns
! ------------------------------------------------------------------------------
  
columnsClass.clearQ procedure()

  code 
  
  free(self.colQ)
   
  return
! end clearQ
! ------------------------------------------------------------------------------

columnsClass.AddColumn procedure(*long colPtr) !,sqlReturn,proc

retv   sqlReturn(sql_Success)

  code 
  
  self.addColumn(SQL_C_SLONG, address(colPtr), 4)  
   
  return retv
! end AddColumn
! ------------------------------------------------------------------------------
 
columnsClass.AddColumn procedure(string colLabel, *long colPtr) !,sqlReturn,proc

retv   sqlReturn(sql_Success)

  code 
  
  self.addColumn(SQL_C_SLONG, address(colPtr), 4)  
  
  self.addField(colLabel) 
     
  return retv
! end AddColumn
! ------------------------------------------------------------------------------
 
columnsClass.AddColumn procedure(*string colPtr) !,sqlReturn,proc     

retv   sqlReturn(sql_Success)

  code 

  self.addColumn(SQL_C_CHAr, address(colPtr), len(colPtr))  
   
  return retv
! end AddColumn
! ------------------------------------------------------------------------------

columnsClass.AddColumn procedure(*real colPtr) !,sqlReturn,proc

retv   sqlReturn(sql_Success)

  code 
  
  self.addColumn(SQL_C_DOUBLE, address(colPtr), 8)
     
  return retv
! end AddColumn
! ------------------------------------------------------------------------------

columnsClass.AddColumn procedure(*TIMESTAMP_STRUCT colPtr) !,sqlReturn,proc

retv   sqlReturn(sql_Success)

  code 
  
  self.addColumn(SQL_C_TYPE_TIMESTAMP, address(colPtr), size(TIMESTAMP_STRUCT))
   
  return retv
! end AddColumn
! ------------------------------------------------------------------------------
  
columnsClass.AddColumn procedure(SQLSMALLINT TargetType, SQLPOINTER TargetValuePtr, SQLLEN BufferLength)

retv   sqlReturn(sql_Success)

  code 
  
  if (self.setupFailed = false) 
    self.colQ.ColId = records(self.colq) + 1
    self.colq.ColType = targetType
    self.colQ.ColValue = TargetValuePtr
    self.colQ.ColSize = BufferLength
    add(self.Colq)
  end 
   
  return retv
! end AddColumn
! ------------------------------------------------------------------------------

columnsClass.bindArray procedure(SQLHSTMT hStmt, demoArrayG grp) !,sqlReturn

retv    sqlReturn,auto

  code 
  
  retv = SQLBindCol(hStmt, 1, SQL_C_CHAR, address(grp[1].fldOne), size(grp[1].fldOne), grp[1].SizeOne)
  retv = SQLBindCol(hStmt, 2, SQL_C_SLONG, address(grp[1].fldTwo), 4, grp[1].sizeTwo)
  retv = SQLBindCol(hStmt, 3, SQL_C_DOUBLE, address(grp[1].fldThree), 8, grp[1].SizeThree)
  retv = SQLBindCol(hStmt, 4, SQL_C_TYPE_TIMESTAMP, address(grp[1].fldFour), size(grp[1].fldFour), grp[1].SizeFour)
  retv = SQLBindCol(hStmt, 5, SQL_C_SLONG, address(grp[1].fldFive), 4, grp[1].SizeFive)
  retv = SQLBindCol(hStmt, 6, SQL_C_CHAR, address(grp[1].fldSix), size(grp[1].fldSix), grp[1].SizeSix)
  
  return 0