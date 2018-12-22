   member('fmOdbcDemo')

   map
   end

! --------------------------------------------------
!
! --------------------------------------------------
spWithOut procedure(fileMgrODBC fmOdbc)

retv     byte,auto
rowCount long,auto

dynStr    &IDynStr

  code

  free(demoQueue)

  dynStr &= newDynStr()
  dynStr.cat('dbo.CountDemoLabels')

  fmOdbc.parameters.addOutParameter(rowCount)

  retv = fmOdbc.callSp(dynStr.str())

  stop(rowCount)

  return
! end spWithOut ---------------------------------------------------

