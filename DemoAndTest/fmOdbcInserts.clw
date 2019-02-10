   member('fmOdbcDemo')

   map
   end

! ----------------------------------------------------------------------
! insert a row into a table using a stored procedure.  Read the value 
! of the identity column fomr an output parameter
! ----------------------------------------------------------------------
insertRow procedure(fileMgrODBC fmOdbc)

newLabel  cstring('Will Scarlet')
newAmount real(87.41)

identValue long,auto

retv       sqlReturn,auto

  code

  fmOdbc.parameters.AddInParameter(newLabel)
  fmOdbc.parameters.AddInParameter(newAmount)
  fmOdbc.parameters.AddOutParameter(identValue)

  retv = fmOdbc.callSp('dbo.addLabelRow')

  message('Identity value from the insert ' & identValue, 'Insert a Row')

  return
! end InsertRow ----------------------------------------------------------------------

! ----------------------------------------------------------------------
! insert a row into a table using a query in the code.  Read the value 
! of the identity column from the second query
! note the differences when using a two sql statements
! ----------------------------------------------------------------------
insertRowQuery procedure(fileMgrODBC fmOdbc)

dynStr     &IDynStr
! values for the new row
newLabel   cstring('Hank smith')
newAmount  real(33.12)
! id value out
identValue long,auto
retv       sqlReturn,auto

  code

  dynStr &= newDynStr()
  dynStr.cat('insert into dbo.LabelDemo(label, amount) ' & |
     'values(?, ?);' & |
     'select ? = scope_identity();')

  ! add the inputs and the output
  fmOdbc.parameters.AddInParameter(newLabel)
  fmOdbc.parameters.AddInParameter(newAmount)
  ! 
  fmOdbc.parameters.AddOutParameter(identValue)

  retv = fmOdbc.ExecuteNonQueryOut(dynStr)

  message('Identity value from the insert ' & identValue, 'Insert a Row')

  return
! end InsertRowQuery ----------------------------------------------------------------------

! ------------------------------------------------------------------------------
! insert some number of rows into the datbase using a table valued parameter TVP
! the demo inserts a 1,000 rows
! ------------------------------------------------------------------------------
insertTvp  procedure(fileMgrODBC fmOdbc, long rows)

!sqlStr        sqlStrClType 
retv          sqlReturn,auto

LabelArray     cstring(60),dim(Rows),auto
AmountArray    real,dim(Rows),auto
sysIdArray     long,dim(Rows),auto
RowActionArray long,dim(Rows),auto

x              long,auto
t              long,auto
hStmt          SQLHSTMT,auto

openedhere     byte,auto
parameters     ParametersClass
tablevalues    ParametersClass
typeName       cstring('LabelDemoType')

  code

  loop x = 1 to Rows
    get(demoQueue, x)
    sysIdArray[x] = demoQueue.sysId
    LabelArray[x] = demoQueue.label
    AmountArray[x] = demoQueue.Amount
    RowActionArray[x] = 1
  end 

  writeLine(logFile, 'begin Call Insert TVP')

  t = clock()  

  openedhere = fmOdbc.openConnection()
  
  hStmt = fmOdbc.conn.gethStmt()

  parameters.Init()

  tablevalues.init()
  
  Parameters.AddTableParameter(rows, typeName)
  retv = Parameters.bindParameters(hStmt, rows)
  
  tablevalues.focusTableParameter(hStmt, 1)   
  ! add the arrays and bind 
  tablevalues.AddlongArray(address(sysIdArray))  
  tablevalues.AddCStringArray(address(labelArray), size(labelArray[1]))
  tablevalues.addrealArray(address(amountArray))
  tablevalues.AddlongArray(address(rowActionArray))
  retv = tablevalues.bindParameters(hStmt) 
    ! remove the focus  and execute
  tablevalues.unfocusTableParameter(hStmt)

  retv = fmOdbc.odbccall.execSp(hStmt, 'dbo.InsertaTable', Parameters)

  fmOdbc.closeConnection(openedhere)

  if (retv = SQL_SUCCESS) or (retv = SQL_SUCCESS_WITH_INFO)
     writeLine(logFile, 'Insert TVP passed')
     writeLine(logFile, 'There were ' & rows & ' rows inserted in ' & format(clock() - t, @t4) & ' clock tics ' & clock() - t)
  else 
    fmOdbc.ShowErrors()
    writeLine(logFile, 'Insert TVP failed')
  end 

  writeLine(logFile, 'end Call Insert TVP')

  return
! end insertTvp --------------------------------------------------------------------------------   