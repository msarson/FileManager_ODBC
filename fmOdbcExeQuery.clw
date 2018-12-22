   member('fmOdbcDemo')

   map
   end

executeQuery procedure(fileMgrODBC fmOdbc)

dynStr    &IDynStr
retv      byte,auto

  code

  dynStr &= newDynStr()
  dynStr.cat('select ld.SysId, ld.Label, ld.amount from dbo.LabelDemo ld order by ld.SysId desc')

  free(demoQueue)
  clear(demoQueue)

  fmOdbc.columns.AddColumn(demoQueue.sysId)
  fmOdbc.columns.AddColumn(demoQueue.Label)
  fmOdbc.columns.AddColumn(demoQueue.amount)

  retv = fmOdbc.ExecuteQuery(dynStr, demoQueue)

  return
! end execureQury -----------------------------------------------------------

executeQueryTwo procedure(fileMgrODBC fmOdbc)

dynStr    &IDynStr
retv      byte,auto

  code

  dynStr &= newDynStr()
  dynStr.cat('select ld.SysId, ld.Label, ld.amount, d.Label from dbo.labelDemo ld inner join dbo.Department d on d.ldSysId = ld.sysId order by d.Label desc, ld.label desc;')

  free(demoQueue)
  clear(demoQueue)
  
  fmOdbc.columns.AddColumn(demoQueue.sysId)
  fmOdbc.columns.AddColumn(demoQueue.Label)
  fmOdbc.columns.AddColumn(demoQueue.amount)
  fmOdbc.columns.AddColumn(demoQueue.department)

  retv = fmOdbc.ExecuteQuery(dynStr, demoQueue)

  return
! end execureQury -----------------------------------------------------------


! --------------------------------------------------
! executes a scalar style query that returns one row
! and one column
! --------------------------------------------------
execScalar procedure(fileMgrODBC fmOdbc)

dynStr    &IDynStr
retv      byte,auto
inLabel   cstring('Willma')
outParam  long,auto

  code

  dynStr &= newDynStr()
  dynStr.cat('select ? = count(*) from dbo.LabelDemo ld where ld.Label <> ?;')

  fmOdbc.parameters.AddOutParameter(outParam)
  fmOdbc.parameters.AddInParameter(inLabel)

  retv = fmOdbc.ExecuteScalar(dynStr)

  stop('Label Used as a filter was ' & inLabel & ', the ID value returned ' &  outParam)

  return
! end execScalar ---------------------------------------------------

