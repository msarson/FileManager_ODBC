   member('fmOdbcDemo')

   map
   end

! -------------------------------------------------------------------
! execute a single query and place the result set into a queue
! the queue is displayed in a list box on the screen
! -------------------------------------------------------------------
executeQuery procedure(fileMgrODBC fmOdbc)

dynStr    &IDynStr
retv      byte,auto

  code

  dynStr &= newDynStr()
  dynStr.cat('select ld.SysId, ld.Label, ld.amount ' & |
             'from dbo.LabelDemo ld ' & |
             ' order by ld.SysId;')

  ! add the colums of the queue that will be read by the query
  fmOdbc.columns.AddColumn(demoQueue.SysId)
  fmOdbc.columns.AddColumn(demoQueue.Label)
  fmOdbc.columns.AddColumn(demoQueue.amount)

  ! do the actual read
  retv = fmOdbc.ExecuteQuery(dynStr, demoQueue)
  
  dynStr.kill()

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

  dynStr &= newDynStr()
  dynStr.cat('select ? = count(*) from dbo.LabelDemo ld where ld.Label <> ?;')

  ! note the order of the bindings, the out parameter and 
  ! then the in parameter
  fmOdbc.parameters.AddOutParameter(outParam)
  fmOdbc.parameters.AddInParameter(fltLabel)

  retv = fmOdbc.ExecuteScalar(dynStr)

  message('Label Used as a filter was ' & fltLabel & ', the count of rows is ' &  outParam & '. One row was removed by the filter.', 'Scalar Result')

  dynStr.kill()

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
  ! the column is from the joined table
  ! the table does not have a file definition in the application
  fmOdbc.columns.AddColumn(demoQueue.department)

  retv = fmOdbc.ExecuteQuery(dynStr, demoQueue)

  dynStr.kill()
  
  return
! end execureQury -----------------------------------------------------------