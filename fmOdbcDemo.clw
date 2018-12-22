   program

   include('aberror.inc'),once
   include('fileMgrOdbc.inc'),once
   include('odbcCl.inc'),once
   include('odbcConn.inc'),once

   map
     main()
     odbcSetup()
     fileManagerSetup()

     module('fmOdbcSpCalls')
       fillSp(fileMgrODBC fmOdbc)
       fillSpNoOpen(fileMgrODBC fmOdbc)
       fillSpWithParam(fileMgrODBC fmOdbc)
       callScalar(fileMgrODBC fmOdbc)
     end

     module('fmOdbcFileMgr')
       fileFill(fileMgrODBC fmOdbc)
       propSqlFill()
     end

     module('fmOdbcSpOut')
       spWithOut(fileMgrODBC fmOdbc)
     end

     module('fmodbcExeQuery')
      executeQuery(fileMgrODBC fmOdbc)
      execScalar(fileMgrODBC fmOdbc)
      executeQueryTwo(fileMgrODBC fmOdbc)
     end

     module('fmOdbcInserts')
       insertRow(fileMgrODBC fmOdbc)
       insertRowQuery(fileMgrODBC fmOdbc)
     end

   end ! map

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
Department      string(60)
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

Window WINDOW('Demo'),AT(,,387,286),FONT('MS Sans Serif',8,,FONT:regular),GRAY
       BUTTON('Insert Row Query'),AT(11,70,109,14),USE(?btnInsertRowQuery)
       BUTTON('Execute a Query'),AT(11,14,109,14),USE(?btnExecQuery)
       BUTTON('Insert Row w/Identity out'),AT(143,72,124,14),USE(?btnInsertRow)
       BUTTON('Execute Scalar'),AT(143,14,124,14),USE(?btnExecScalar)
       BUTTON('Execute Query Two Tables'),AT(273,15,109,14),USE(?btnExecQueryTwo)
       BUTTON('Call Stored Procedure'),AT(11,32,109,14),USE(?btnSpCall)
       BUTTON('File Manager Loop'),AT(11,90,109,14),USE(?btnFileManager)
       BUTTON('Prop Sql'),AT(143,93,74,14),USE(?btnPropSql)
       BUTTON('Call Stored Procedure (No Connect)'),AT(143,32,124,14),USE(?btnSpNoConnect)
       BUTTON('Stored Procedure W/Parameter'),AT(11,51,109,14),USE(?btnSpWithParam)
       BUTTON('Stored Procedure w/out parameter'),AT(143,52,124,14),USE(?spWithOut)
       BUTTON('Call Scalar Function'),AT(271,32,99,14),USE(?btnCallScalar)
       LIST,AT(15,114,363,139),USE(?demoList),FORMAT('71L(2)|M~System Id~@N20@125L(2)|M~Label~59L(2)|M~Amount~@N20.2@40L(2)|M~Departme' &|
           'nt~@s60@'),FROM(demoQueue)
       BUTTON('&Done'),AT(163,262,36,14),USE(?btnCancel)
     END

  code

  open(window)
  accept
    case event()
      of Event:Accepted
      case field()
        of ?btnSpCall
          fillSp(fm)
        of ?btnSpNoConnect
          fillSpNoOpen(fm)
        of ?btnSpWithParam
          fillSpWithParam(fm)
        of ?btnFileManager
          fileFill(fm)
        of ?btnPropSql
          propSqlFill()
        of ?spWithOut
          spWithOut(fm)
        of ?btnCallScalar
          callScalar(fm)
        of ?btnExecScalar
          execScalar(fm)
        of ?btnExecQuery
          executeQuery(fm)
        of ?btnExecQueryTwo
          executeQueryTwo(fm)
        of ?btnInsertRow
          insertRow(fm)
        of ?btnInsertRowQuery
          InsertRowQuery(fm)
        of ?btnCancel
          break
      end ! case field
    end ! case event

  end

  close(window)

  return
! end main -------------------------------------------------

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

