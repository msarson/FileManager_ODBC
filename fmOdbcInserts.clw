   member('fmOdbcDemo')

   map
   end

insertRow procedure(fileMgrODBC fmOdbc)

newLabel  cstring('Will Scarlet')
newAmount real(87.41)

identValue long,auto

  code

  fmOdbc.parameters.AddInParameter(newLabel)
  fmOdbc.parameters.AddInParameter(newAmount)
  fmOdbc.parameters.AddOutParameter(identValue)

  fmOdbc.callSp('dbo.addLabelRow')

  stop('new identity value ' & identValue)

  return

insertRowQuery procedure(fileMgrODBC fmOdbc)

dynStr    &IDynStr
newLabel  cstring('Hank smith')
newAmount real(33.12)

identValue long,auto

  code

  dynStr &= newDynStr()
  dynStr.cat('insert into dbo.LabelDemo(label, amount) ' & |
     'values(?, ?); ' & |
     'select ? = scope_identity();')

  fmOdbc.parameters.AddInParameter(newLabel)
  fmOdbc.parameters.AddInParameter(newAmount)
  fmOdbc.parameters.AddOutParameter(identValue)


  fmOdbc.ExecuteNonQueryOut(dynStr, true)

  stop('new identity value ' & identValue)

  return
