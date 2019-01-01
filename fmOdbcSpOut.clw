   member('fmOdbcDemo')

   map
   end

! --------------------------------------------------
! call a stored procedure with an out parameter
! while this example uses a single parameter a 
! procedure can have more than one output, just 
! add the fields or locals as parameters
! --------------------------------------------------
spWithOut procedure(fileMgrODBC fmOdbc)

retv     byte,auto
rowCount long,auto

  code

  fmOdbc.parameters.addOutParameter(rowCount)

  retv = fmOdbc.callSp('dbo.CountDemoLabels')

  Message('There are ' & rowCount & ' rows in the table.', 'Number Rows')
  
  fmOdbc.ClearInputs()

  totalRows = rowCount
  
  return
! end spWithOut ---------------------------------------------------

spResutSetWithOut procedure(fileMgrODBC fmOdbc)

retv       byte,auto
rowCount   long,auto
openedHere byte,auto

  code

  ! set to a value outside the range of the count 
  ! function, just so we can see the value was actually set
  rowCount = -1

  fmOdbc.parameters.addOutParameter(rowCount)

  fmOdbc.columns.AddColumn(demoQueue.sysId)
  fmOdbc.columns.AddColumn(demoQueue.Label)
  fmOdbc.columns.AddColumn(demoQueue.amount)

  retv = conn.connect()

  if (retv = SQL_SUCCESS)
    retv = fmOdbc.callSp('dbo.ReadLabelDemoWithCount', demoQueue)

    if (retv = SQL_SUCCESS)
      retv = fmOdbc.odbc.nextResultSet()
      ! out parameter is now filled
    end
    conn.Disconnect()
  end

  Message('There are ' & rowCount & ' rows in the table.', 'Number Rows')

 
  fmOdbc.ClearInputs()
 
  return
! end spWithOut ---------------------------------------------------

