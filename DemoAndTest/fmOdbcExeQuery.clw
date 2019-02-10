   member('fmOdbcDemo')

   map
   end

   include('odbcTranscl.inc'),once
! -------------------------------------------------------------------
! execute a single query and place the result set into a queue
! the queue is displayed in a list box on the screen
! -------------------------------------------------------------------
executeQuery procedure(fileMgrODBC fmOdbc)

dynStr    &IDynStr
retv      byte,auto
x         long,auto
trans     odbcTransactionClType

  code

  writeLine(logFile, 'Begin Execute Query new')

  dynStr &= newDynStr()
  dynStr.cat('select ld.SysId, ld.Label, ld.amount, ld.bitFlag, ld.guid, ld.bigChar, ld.bigBin ' & |
             'from dbo.LabelDemo ld ' & |
             ' where ld.SysId = 8 ' & |
             ' order by ld.SysId;')

  ! add the colums of the queue that will be read by the query
  fmOdbc.columns.AddColumn(demoQueue.SysId)
  fmOdbc.columns.AddColumn(demoQueue.Label)
  fmOdbc.columns.AddColumn(demoQueue.amount)
  fmOdbc.columns.AddBooleanColumn(demoQueue.bitFlag, true)
  fmOdbc.columns.AddColumn(demoQueue.guid)
  fmOdbc.columns.AddLargeColumn(SQL_LONGVARCHAR, 6)
  !demoQueue.bigBin &= blobFile.testBlob
  fmOdbc.columns.AddLargeColumn(SQL_LONGVARBINARY, 7) !demoQueue.bigBin)

  fmOdbc.conn.Connect()
  trans.init(fmOdbc.conn.getHdbc())
  trans.setIsolationSerializable()

  ! do the actual read
  retv = fmOdbc.ExecuteQuery(dynStr, demoQueue)

  loop x = 1 to records(fmOdbc.columns.colb)
    get(fmOdbc.columns.colb, x)
    case fmOdbc.columns.colb.colType
      of SQL_LONGVARCHAR
        demoQueue.bigChar &= fmOdbc.Columns.colb.charHolder
      of SQL_LONGVARBINARY
       demoQueue.bigBin &= fmOdbc.Columns.colb.binaryHolder
    end ! case
    put(demoQueue)
  end 

  fmOdbc.clearInputs()
  
  dynStr.kill()
  trans.commit()
  
  fmOdbc.Conn.disconnect()

  stop(demoQueue.bigBin)  
  stop(demoQueue.bigchar)  
  if (retv = SQL_SUCCESS)
    writeLine(logFile, 'Execute Query, passed and returned ' & records(demoQueue) & ' Rows.')
  else 
    writeLine(logFile, 'Execute Query, Failed')  
  end 

  writeLine(logFile, 'end Execute Query')

  return
! end execureQuery -----------------------------------------------------------

! -----------------------------------------------------------------
! executes a scalar style query that returns one row and one column
! the value returned by the scalar is shown in a message box
! -----------------------------------------------------------------
execScalar procedure(fileMgrODBC fmOdbc, *cstring fltLabel)

dynStr    &IDynStr
retv      byte,auto
outParam  long,auto

  code

  writeLine(logFile, 'begin Execute Scalar Query')

  dynStr &= newDynStr()
  dynStr.cat('select ? = count(*) from dbo.LabelDemo ld where ld.Label <> ?;')

  ! note the order of the bindings, the out parameter and 
  ! then the in parameter
  fmOdbc.parameters.AddOutParameter(outParam)
  fmOdbc.parameters.AddInParameter(fltLabel)

  retv = fmOdbc.ExecuteScalar(dynStr)

  writeLine(logFile, 'Label Used as a filter was ' & fltLabel & ', the count of rows is ' &  outParam & '. One row was removed by the filter.')

  dynStr.kill()

  if (retv = SQL_SUCCESS)
    writeLine(logFile, 'Execute Scalar Query, passed')
  else 
    writeLine(logFile, 'Execute Scalar Query, Failed')  
  end 

  writeLine(logFile, 'end Execute Scalar Query')

  return
! end execScalar ---------------------------------------------------

! -------------------------------------------------------------------
! execute a query with a single join clause and place the result set into 
! a queue, the queue is displayed in a list box on the screen
! -------------------------------------------------------------------
executeQueryTwo procedure(fileMgrODBC fmOdbc)

dynStr    &IDynStr
retv      byte,auto

  code

  writeLine(logFile, 'begin Execute Query with a simple join')

  dynStr &= newDynStr()
  dynStr.cat('select ld.SysId, ld.Label, ld.amount, d.Label ' & |
             'from dbo.labelDemo ld ' & |
             'inner join dbo.Department d on ' & |
               'd.ldSysId = ld.sysId ' & |
             'order by d.Label desc, ld.label asc;')
  
  fmOdbc.columns.AddColumn(demoQueue.sysId)
  fmOdbc.columns.AddColumn(demoQueue.Label)
  fmOdbc.columns.AddColumn(demoQueue.amount)
  ! column department is a memeber of the queue, not a member of the file
  ! the table does not have a file definition in the application
  !fmOdbc.columns.AddColumn(demoQueue.department)

  retv = fmOdbc.ExecuteQuery(dynStr, demoQueue)

  dynStr.kill()

if (retv = SQL_SUCCESS)
    writeLine(logFile, 'simple join Query, passed')
  else 
    writeLine(logFile, 'simple join Query, Failed')  
  end 

  writeLine(logFile, 'end Execute Query with a simple join')

  return
! end execureQury -----------------------------------------------------------