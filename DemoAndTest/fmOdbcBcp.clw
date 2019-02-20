   member('fmOdbcDemo')

   map
     BindColumns(fileMgrODBC fmOdbc),bool
     fillQueue()
     fillSmallStr(),string
     module('fmOdbcInserts')
       readCurrentCount(fileMgrODBC fmOdbc),long
       deletenewRow(fileMgrODBC fmOdbc)
     end 
   end

bcpRowsToInsert long(10000)

fmOdbcBcpUpdate procedure(fileMgrODBC fmOdbc)

tname cstring('dbo.Bcpdemo')
retv  bool,auto

x     long,auto
numberInserted  long,auto

currentRows   long,auto

  code

  writeLine(logFile, 'Begin BCP test')

  fillQueue()

  if (fmOdbc.init_bcp() <> level:benign) 
    message('Init of the BCP operation failed.')
    return
  end

  if (fmodbc.connectBcp() <> level:benign) 
    message('Connection for the BCP operation failed.')
    return
  end   

  retv = fmOdbc.bcp.init_Bcp(tname)

  if (retv = bcp_Success)
    if (BindColumns(fmOdbc) = bcp_Success)
      loop x = 1 to bcpRowsToInsert
        get(DemoQueue, x)
        retv = fmOdbc.bcp.sendRow()
        if (retv <> bcp_Success)
          message('Sending a row to the server failed.')
          break
        end 
      end
   
      numberInserted = fmodbc.bcp.done_bcp()
    end 
  end 

  fmodbc.disconnectBcp()
  
  writeLine(logFile, 'BCP test inserted ' & numberInserted & ' rows.')

  if (bcpRowsToInsert = numberInserted)
    writeLine(logFile, 'BCP test passed')
  else 
    writeLine(logFile, 'BCP test failed')
  end 
  
  writeLine(logFile, 'End BCP test')

  return

! bind the queue fields to table columns.
! note the idNumber is the second column in the table.  there is an identity
! column in the table and it is the first column.
! the identity column can be at any ordinal position but the
! binding must be adjusted so there is no data inserted into that column.
! there are options to allow the identity column to be 
BindColumns procedure(fileMgrODBC fmOdbc) !,bool

retv   bool(true)

  code

  ! add the two columns for the insert, start at column 2
  ! skip the first one becauswe it is an identity column
  ! there are options to preserve identity columns
  if (fmOdbc.bcp.addColumn(DemoQueue.label, 2) = bcp_fail)
    return false
  end
  if (fmOdbc.bcp.addColumn(DemoQueue.amount, 3) = bcp_fail)
    return false
  end

  return retv
! -------------------------------------------------------------------------------------
! fll the queue with some values, don't care what they are
! for the demo
fillQueue procedure()

  code

  loop bcpRowsToInsert  times
    DemoQueue.SysId = 1
    demoQueue.label = fillSmallStr()
    demoQueue.amount = random(1, 23000)
    
    add(DemoQueue)
  end
  
  return

! these two just generate some random string data
fillSmallStr procedure() ! string

x long
l long
s string(30)

  code

  l = random(1, 30)
  loop x = 1 to l
    s[x] = chr(random(65, 127))
  end

  return s

