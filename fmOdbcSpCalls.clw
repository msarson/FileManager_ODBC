   member('fmOdbcDemo')

   map
   end

! --------------------------------------------------
! fills the queue from a stored procedure 
! --------------------------------------------------
fillSp procedure(fileMgrODBC fmOdbc)

retv   byte,auto

  code

  free(demoQueue)

  fm.columns.AddColumn(demoQueue.sysId)
  fm.columns.AddColumn(demoQueue.Label)
  fm.columns.AddColumn(demoQueue.amount)

  conn.connect()
  retv = fm.callSp('dbo.ReadLabelDemo', demoQueue)

  fm.clearParameters()
  fm.clearColumns()
  conn.disconnect()

  return 
! end fillSp ---------------------------------------------------

! --------------------------------------------------
! fills the queue from a stored procedure 
! --------------------------------------------------
fillSpNoOpen procedure(fileMgrODBC fmOdbc)

retv   byte,auto

  code

  free(demoQueue)

  fm.columns.AddColumn(demoQueue.sysId)
  fm.columns.AddColumn(demoQueue.Label)
  fm.columns.AddColumn(demoQueue.amount)

  retv = fm.callSp('dbo.ReadLabelDemo', demoQueue)

  return
! end fillSpNoOpen ---------------------------------------------------

! --------------------------------------------------
! fills the queue from a stored procedure 
! --------------------------------------------------
fillSpWithParam procedure(fileMgrODBC fmOdbc)

inLabel cstring('Fred')
retv    byte,auto

  code

  free(demoQueue)

  fmOdbc.columns.AddColumn(demoQueue.sysId)
  fmOdbc.columns.AddColumn(demoQueue.Label)
  fmOdbc.columns.AddColumn(demoQueue.amount)

  fmOdbc.Parameters.AddInParameter(inLabel)

  retv = fmOdbc.CallSp('dbo.ReadLabelDemoByLabel', demoQueue)

  return
! end fillSpWithParam --------------------------------------------------

! --------------------------------------------------
! calls a scalar function and gets the returned value
! --------------------------------------------------
callScalar procedure(fileMgrODBC fmOdbc)

retv      byte,auto
inLabel   cstring('Willma')
outParam  long,auto

  code

  fmOdbc.parameters.AddOutParameter(outParam)

  fmOdbc.parameters.AddInParameter(inLabel)
  retv = fmOdbc.callScalar('dbo.getId')

  stop('Label Used as a filter was ' & inLabel & ', the ID value returned ' &  outParam)

  return
! end callScalar ---------------------------------------------------

