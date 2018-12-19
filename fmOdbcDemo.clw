   program

   include('aberror.inc'),once
   include('fileMgrOdbc.inc'),once
   include('odbcCl.inc'),once
   include('odbcConn.inc'),once

   map
     main()
     odbcSetup()
     fileManagerSetup()
     fillSp()
     fileFill()
   end

! define the connection string for use by the file
Connstr     string('Driver={{ODBC Driver 13 for SQL Server};server=dennishyperv\dev;Database=default_test;trusted_connection=yes;')
! define a simple file for the demo
LabelDemo   file,driver('ODBC','/BUSYHANDLING=1 /LOGONSCREEN=FALSE'),owner(ConnStr),name('dbo.LabelDemo'),pre(Lab),bindable
Record        record,pre()
SysId           long
Label           string(60)
Amount          real
              end ! record 
            end ! file

demoQueue   queue
SysId           long
Label           string(60)
Amount          real
            end

! error class used by the file manager
errors         &errorclass
ErrorStatus    ErrorStatusClass

! connection object for the ODBC file manager
conn          &ODBCConnectionClType
! connection string object for the ODBC file manager
odbcConnStr   &MSConnStrClType

localFm       class(fileMgrODBC),type
init            procedure(),virtual
              end
fm  &localFm

  code

  odbcSetup()
  fileManagerSetup()

  main()

  return
! end program ------------------------------------------------------------

main procedure()

Window WINDOW('Demo'),AT(,,275,103),FONT('MS Sans Serif',8,,FONT:regular),GRAY
       BUTTON('Call Stored Procedure'),AT(37,32,85,14),USE(?btnSpCall)
       BUTTON('File Manager Loop'),AT(137,33,81,14),USE(?btnFileManager)
       BUTTON('&Done'),AT(115,65,36,14),USE(?btnCancel)
     END

  code

  open(window)
  accept
    case event()
      of Event:Accepted
      case field()
        of ?btnSpCall
          fillSp()
        of ?btnFileManager
          fileFill()
        of ?btnCancel
          break
      end ! case field
    end ! case event
  end

  close(window)

  return
! end main -------------------------------------------------

! --------------------------------------------------
! fills the queue from a stored procedure 
! --------------------------------------------------
fillSp procedure()

retv   byte,auto

  code

  free(demoQueue)

  fm.clearColumns()
  fm.columns.AddColumn(demoQueue.sysId)
  fm.columns.AddColumn(demoQueue.Label)
  fm.columns.AddColumn(demoQueue.amount)

  retv = fm.ExecuteSp('dbo.ReadLabelDemo', demoQueue)
  stop(records(demoQueue))

  return 
! end callSp ---------------------------------------------------

! --------------------------------------------------
! sets up the connection and connection string instances
! --------------------------------------------------
odbcSetup procedure()

  code

  odbcConnStr &= new(MSConnStrClType)
  odbcConnStr.Init('dennisHyperv\dev', 'default_test')
  conn &= new(ODBCConnectionClType)
  conn.Init(odbcConnStr)

  return
! end odbcSetup -------------------------------------------------------------

! --------------------------------------------------
! allocates the file manager and the error class
! does some default set up
! --------------------------------------------------
fileManagerSetup procedure()

  code

  errors &= new(errorclass)
  errors.Init(ErrorStatus)

  fm &= new(localFm)
  fm.init()
  fm.init(labelDemo, errors)
  
  fm.setEnviorment(conn)

  return
! end fileMangerSetup -------------------------------------------------------------

! --------------------------------------------------
! fill a queue using the typcial file manager access
! --------------------------------------------------
fileFill procedure()

retv   byte,auto

  code

  free(demoQueue)
  fm.open()
  fm.useFile()

  set(labelDemo)

  loop
    if (fm.next() <> level:Benign)
      break
    end
    demoQueue.sysId = labelDemo.Sysid
    demoQueue.Label = labelDemo.Label
    demoQueue.amount = labelDemo.amount
    add(demoQueue)
  end

  fm.close()

  stop(records(demoQueue))

  return
! end fileFill -----------------------------------------------

! --------------------------------------------------
! overloaded init method so the buffer and some other defaults can be set
! --------------------------------------------------
localFm.Init PROCEDURE

  code

  self.Initialized = False
  self.Buffer &= Lab:Record
  self.FileNameValue = 'LabelDemo'
  self.SetErrors(Errors)
  self.File &= LabelDemo
  parent.Init()

  return
! end init --------------------------------------------